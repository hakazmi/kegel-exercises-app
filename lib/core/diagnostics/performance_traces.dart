import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

/// Performance Monitoring facade. No-ops when Firebase is not configured.
///
/// Session-scoped traces only — never start/stop on every tick or frame.
class PerfTraces {
  PerfTraces._();

  static Trace? start(String name) {
    if (!FirebaseBootstrap.isReady || name.isEmpty) {
      return null;
    }
    try {
      final Trace trace = FirebasePerformance.instance.newTrace(name);
      trace.start();
      return trace;
    } on Object catch (e) {
      debugPrint('PerfTraces.start($name) failed: $e');
      return null;
    }
  }

  static Future<void> stop(Trace? trace) async {
    if (!FirebaseBootstrap.isReady || trace == null) {
      return;
    }
    try {
      await trace.stop();
    } on Object catch (e) {
      debugPrint('PerfTraces.stop failed: $e');
    }
  }

  /// Drop without uploading so failures do not skew averages.
  static void abandon(Trace? trace) {
    // Intentionally do not call Trace.stop() — Firebase drops unstopped traces.
    assert(() {
      // Keep the reference so analyzers know it is intentionally unused.
      return trace == null || true;
    }());
  }

  static void putAttribute(Trace? trace, String key, String value) {
    if (!FirebaseBootstrap.isReady ||
        trace == null ||
        key.isEmpty ||
        value.isEmpty) {
      return;
    }
    try {
      final String safeKey = key.length > 32 ? key.substring(0, 32) : key;
      final String safeValue =
          value.length > 100 ? value.substring(0, 100) : value;
      trace.putAttribute(safeKey, safeValue);
    } on Object catch (_) {}
  }

  static void putMetric(Trace? trace, String name, int value) {
    if (!FirebaseBootstrap.isReady || trace == null || name.isEmpty) {
      return;
    }
    try {
      trace.setMetric(name, value < 0 ? 0 : value);
    } on Object catch (_) {}
  }
}

/// Enables or disables Performance collection alongside Crashlytics.
Future<void> setPerformanceCollectionEnabled(bool enabled) async {
  if (!FirebaseBootstrap.isReady) {
    return;
  }
  try {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(enabled);
  } on Object catch (e) {
    debugPrint('setPerformanceCollectionEnabled failed: $e');
  }
}
