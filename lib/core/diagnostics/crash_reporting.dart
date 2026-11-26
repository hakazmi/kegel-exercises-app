import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_bootstrap.dart';
import 'installation_id.dart';

/// Crashlytics facade. No-ops when Firebase is not configured.
///
/// Never pass emails, user ids, safety answers, session feel, or check-in scores.
class CrashReporting {
  CrashReporting._();

  static bool get isEnabled => FirebaseBootstrap.isReady;

  /// Sets install id, version, build type, and wires Flutter error hooks.
  static Future<void> initialize(SharedPreferences prefs) async {
    if (!FirebaseBootstrap.isReady) {
      return;
    }
    try {
      final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCustomKey(
        'installation_id',
        InstallationId.get(prefs),
      );
      final PackageInfo info = await PackageInfo.fromPlatform();
      await crashlytics.setCustomKey(
        'app_version',
        '${info.version} (${info.buildNumber})',
      );
      await crashlytics.setCustomKey(
        'build_type',
        kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
      );
      await crashlytics.log('App/session started');

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        crashlytics.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    } on Object catch (e, st) {
      debugPrint('CrashReporting.initialize failed: $e\n$st');
    }
  }

  /// Enables or disables Crashlytics collection (and clears unsent when off).
  static Future<void> setCollectionEnabled(bool enabled) async {
    if (!FirebaseBootstrap.isReady) {
      return;
    }
    try {
      final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(enabled);
      if (!enabled) {
        await crashlytics.deleteUnsentReports();
      }
    } on Object catch (e) {
      debugPrint('CrashReporting.setCollectionEnabled failed: $e');
    }
  }

  /// After wipe / delete account: new anonymous install id for future reports.
  static Future<void> resetInstallationId(SharedPreferences prefs) async {
    if (!FirebaseBootstrap.isReady) {
      InstallationId.reset(prefs);
      return;
    }
    try {
      final String id = InstallationId.reset(prefs);
      await FirebaseCrashlytics.instance.setCustomKey('installation_id', id);
      await FirebaseCrashlytics.instance.log('installation_id reset');
    } on Object catch (e) {
      debugPrint('CrashReporting.resetInstallationId failed: $e');
    }
  }

  static void log(String message) {
    if (!FirebaseBootstrap.isReady || message.isEmpty) {
      return;
    }
    try {
      FirebaseCrashlytics.instance.log(
        message.length > 300 ? message.substring(0, 300) : message,
      );
    } on Object catch (_) {}
  }

  static Future<void> setKey(String name, Object? value) async {
    if (!FirebaseBootstrap.isReady || name.isEmpty || value == null) {
      return;
    }
    try {
      final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
      if (value is bool) {
        await crashlytics.setCustomKey(name, value);
      } else if (value is int) {
        await crashlytics.setCustomKey(name, value);
      } else if (value is double) {
        await crashlytics.setCustomKey(name, value);
      } else {
        final String text = value.toString();
        if (text.isEmpty) {
          return;
        }
        await crashlytics.setCustomKey(
          name,
          text.length > 100 ? text.substring(0, 100) : text,
        );
      }
    } on Object catch (_) {}
  }

  static Future<void> record(
    Object error, {
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    if (!FirebaseBootstrap.isReady) {
      return;
    }
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: fatal,
      );
    } on Object catch (_) {}
  }

  /// Debug / Data Debug only.
  static Future<void> recordTestNonFatal() async {
    log('Test non-fatal exception');
    await record(StateError('Test Crashlytics non-fatal'));
  }

  /// Debug only — throws a fatal crash for console verification.
  static Never forceTestFatalCrash() {
    log('Test fatal crash');
    throw StateError('Test Crashlytics fatal crash');
  }
}
