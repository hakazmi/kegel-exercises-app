import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../features/session/engine/engine_models.dart';

/// Capability probe results for the vibration package (debug / diagnostics).
class HapticsCapabilities {
  const HapticsCapabilities({
    this.hasVibrator,
    this.hasCustomVibrationsSupport,
  });

  final bool? hasVibrator;
  final bool? hasCustomVibrationsSupport;
}

/// Session and UI haptics. Platform implementation differs; tests use [FakeHapticsService].
abstract class HapticsService {
  Future<void> heavyImpact();
  Future<void> mediumImpact();
  Future<void> vibrate();

  /// Maps engine events to cues. No-op when [vibrationOn] is false.
  Future<void> playSessionEvent(
    EngineEvent event, {
    required bool vibrationOn,
  });

  /// Reads [Vibration.hasVibrator] / [Vibration.hasCustomVibrationsSupport] for debug UI.
  Future<HapticsCapabilities> probe();
}

/// Production haptics.
///
/// Patterns (both platforms): long pulse at squeeze, two short at relax,
/// one pulse at session end. Android uses the `vibration` package when a
/// vibrator exists; iOS uses [HapticFeedback]. Both fall back to
/// [HapticFeedback] when the vibrator path fails.
class PlatformHapticsService implements HapticsService {
  bool get _useIosHaptics =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// One long pulse (~400 ms) — squeeze.
  @override
  Future<void> heavyImpact() async {
    if (_useIosHaptics) {
      await HapticFeedback.heavyImpact();
      return;
    }
    if (await _androidVibrate(duration: 400)) {
      return;
    }
    await HapticFeedback.heavyImpact();
  }

  /// Two short pulses (~80 ms, 120 ms apart) — relax.
  @override
  Future<void> mediumImpact() async {
    if (_useIosHaptics) {
      await HapticFeedback.mediumImpact();
      return;
    }
    if (await _androidVibrate(pattern: <int>[0, 80, 120, 80])) {
      return;
    }
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.mediumImpact();
  }

  /// Single pulse — session end.
  @override
  Future<void> vibrate() async {
    if (_useIosHaptics) {
      await HapticFeedback.vibrate();
      return;
    }
    if (await _androidVibrate(duration: 200)) {
      return;
    }
    await HapticFeedback.vibrate();
  }

  /// Returns false when there is no vibrator or the call fails.
  Future<bool> _androidVibrate({int? duration, List<int>? pattern}) async {
    try {
      if (!await Vibration.hasVibrator()) {
        return false;
      }
      if (pattern != null) {
        if (await Vibration.hasCustomVibrationsSupport()) {
          await Vibration.vibrate(pattern: pattern);
          return true;
        }
        // No custom patterns: approximate with two short pulses.
        await Vibration.vibrate(duration: 80);
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await Vibration.vibrate(duration: 80);
        return true;
      }
      await Vibration.vibrate(duration: duration ?? 200);
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> playSessionEvent(
    EngineEvent event, {
    required bool vibrationOn,
  }) async {
    if (!vibrationOn) {
      return;
    }
    switch (event) {
      case EngineEvent.squeezeStarted:
        await heavyImpact();
      case EngineEvent.relaxStarted:
        await mediumImpact();
      case EngineEvent.done:
        await vibrate();
      case EngineEvent.restStarted:
        break;
    }
  }

  @override
  Future<HapticsCapabilities> probe() async {
    bool? hasVibrator;
    bool? hasCustom;
    try {
      hasVibrator = await Vibration.hasVibrator();
    } on Object {
      hasVibrator = null;
    }
    try {
      hasCustom = await Vibration.hasCustomVibrationsSupport();
    } on Object {
      hasCustom = null;
    }
    return HapticsCapabilities(
      hasVibrator: hasVibrator,
      hasCustomVibrationsSupport: hasCustom,
    );
  }
}

/// Records haptic calls for unit tests.
class FakeHapticsService implements HapticsService {
  final List<String> calls = <String>[];

  @override
  Future<void> heavyImpact() async {
    calls.add('heavy');
  }

  @override
  Future<void> mediumImpact() async {
    calls.add('medium');
  }

  @override
  Future<void> vibrate() async {
    calls.add('vibrate');
  }

  @override
  Future<void> playSessionEvent(
    EngineEvent event, {
    required bool vibrationOn,
  }) async {
    if (!vibrationOn) {
      return;
    }
    switch (event) {
      case EngineEvent.squeezeStarted:
        await heavyImpact();
      case EngineEvent.relaxStarted:
        await mediumImpact();
      case EngineEvent.done:
        await vibrate();
      case EngineEvent.restStarted:
        break;
    }
  }

  @override
  Future<HapticsCapabilities> probe() async {
    return const HapticsCapabilities(
      hasVibrator: true,
      hasCustomVibrationsSupport: false,
    );
  }
}

final hapticsServiceProvider = Provider<HapticsService>((Ref ref) {
  return PlatformHapticsService();
});
