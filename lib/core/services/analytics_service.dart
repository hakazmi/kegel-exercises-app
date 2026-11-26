import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../diagnostics/firebase_bootstrap.dart';

/// Analytics facade (product-spec section 14 events only).
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});
}

/// Parameter names that must never leave the device via Analytics.
const Set<String> kAnalyticsDeniedKeys = <String>{
  'feel',
  'pain',
  'painSexual',
  'recentSurgery',
  'catheter',
  'score',
  'scores',
  'checkin_score',
  'email',
  'user_id',
  'display_name',
  'name',
};

/// Debug stub that prints events to the console.
class ConsoleAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[analytics] $name ${parameters ?? <String, Object?>{}}');
    }
  }
}

/// Firebase Analytics implementation. Strips denied keys before send.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[analytics] $name ${parameters ?? <String, Object?>{}}');
    }
    final Map<String, Object>? safe = _sanitize(parameters);
    try {
      await _analytics.logEvent(name: name, parameters: safe);
    } on Object catch (e) {
      debugPrint('Analytics logEvent($name) failed: $e');
    }
  }

  Map<String, Object>? _sanitize(Map<String, Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) {
      return null;
    }
    final Map<String, Object> out = <String, Object>{};
    for (final MapEntry<String, Object?> entry in parameters.entries) {
      if (kAnalyticsDeniedKeys.contains(entry.key)) {
        assert(() {
          debugPrint(
            'Analytics blocked denied key "${entry.key}" on event',
          );
          return true;
        }());
        continue;
      }
      final Object? value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is String || value is num || value is bool) {
        out[entry.key] = value;
      } else {
        out[entry.key] = value.toString();
      }
    }
    return out.isEmpty ? null : out;
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((Ref ref) {
  if (FirebaseBootstrap.isReady) {
    return FirebaseAnalyticsService();
  }
  return ConsoleAnalyticsService();
});
