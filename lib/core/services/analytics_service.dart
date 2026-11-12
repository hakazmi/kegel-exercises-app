import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics facade. Firebase wiring lands in Prompt 11.
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});
}

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

final analyticsServiceProvider = Provider<AnalyticsService>((Ref ref) {
  return ConsoleAnalyticsService();
});
