import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/services/haptics_service.dart';
import 'package:kegelexercisesapp/features/session/engine/engine_models.dart';

void main() {
  group('FakeHapticsService playSessionEvent', () {
    test('squeeze fires heavy, relax fires medium, end fires vibrate', () async {
      final FakeHapticsService fake = FakeHapticsService();

      await fake.playSessionEvent(
        EngineEvent.squeezeStarted,
        vibrationOn: true,
      );
      expect(fake.calls, <String>['heavy']);

      await fake.playSessionEvent(
        EngineEvent.relaxStarted,
        vibrationOn: true,
      );
      expect(fake.calls, <String>['heavy', 'medium']);

      await fake.playSessionEvent(
        EngineEvent.done,
        vibrationOn: true,
      );
      expect(fake.calls, <String>['heavy', 'medium', 'vibrate']);
    });

    test('nothing fires when vibration cues are off', () async {
      final FakeHapticsService fake = FakeHapticsService();

      await fake.playSessionEvent(
        EngineEvent.squeezeStarted,
        vibrationOn: false,
      );
      await fake.playSessionEvent(
        EngineEvent.relaxStarted,
        vibrationOn: false,
      );
      await fake.playSessionEvent(
        EngineEvent.done,
        vibrationOn: false,
      );

      expect(fake.calls, isEmpty);
    });

    test('rest does not fire a haptic', () async {
      final FakeHapticsService fake = FakeHapticsService();
      await fake.playSessionEvent(
        EngineEvent.restStarted,
        vibrationOn: true,
      );
      expect(fake.calls, isEmpty);
    });
  });
}
