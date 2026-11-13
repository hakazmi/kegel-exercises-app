import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/content/content_models.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/plan/session_definition.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';
import 'package:kegelexercisesapp/features/session/engine/engine_models.dart';
import 'package:kegelexercisesapp/features/session/engine/session_engine.dart';
import 'package:kegelexercisesapp/features/session/engine/session_timeline.dart';

SessionDefinition _level1Ref() {
  return SessionDefinitionFactory.fromJson(<String, dynamic>{
    'id': 'L1_standard',
    'level': 1,
    'position': 'lying_or_sitting',
    'blocks': <Map<String, dynamic>>[
      <String, dynamic>{
        'type': 'hold',
        'reps': 5,
        'squeezeSec': 3,
        'relaxSec': 3,
      },
      <String, dynamic>{'type': 'rest', 'sec': 10},
      <String, dynamic>{
        'type': 'quick',
        'reps': 5,
        'squeezeSec': 1,
        'relaxSec': 2,
      },
    ],
  });
}

void main() {
  test('reference session totals 55 seconds', () {
    final SessionDefinition def = _level1Ref();
    expect(def.durationSeconds, 55);
  });

  test('timeline phases, events, pause/resume, exit', () async {
    final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
    final SessionEngine engine = SessionEngine(
      definition: _level1Ref(),
      clock: clock,
      countdownSeconds: 0,
    );

    final List<EngineEvent> events = <EngineEvent>[];
    engine.events.listen(events.add);

    engine.start(autoTick: false);
    engine.tick();
    await Future<void>.delayed(Duration.zero);

    // t=0: first squeeze
    expect(engine.current.phaseWord, 'Squeeze');
    expect(engine.current.machine, EngineMachineState.squeeze);
    expect(engine.current.rep, 1);
    expect(events, contains(EngineEvent.squeezeStarted));

    // Advance through every second of the 55s session and record phase words.
    final List<String> phases = <String>[engine.current.phaseWord];
    for (int s = 1; s < 55; s++) {
      clock.add(const Duration(seconds: 1));
      engine.tick();
      phases.add(engine.current.phaseWord);
    }

    // Rep 1 slow: Squeeze, Hold, Hold, Relax, Relax, Relax
    expect(phases.sublist(0, 6), <String>[
      'Squeeze',
      'Hold',
      'Hold',
      'Relax',
      'Relax',
      'Relax',
    ]);

    // After 5 slow holds (30s) → rest
    expect(phases[30], 'Rest');
    expect(phases[39], 'Rest');

    // Quick squeezes start at t=40
    expect(phases[40], 'Squeeze');
    expect(phases[41], 'Relax');
    expect(phases[42], 'Relax');

    clock.add(const Duration(seconds: 1));
    engine.tick();
    await Future<void>.delayed(Duration.zero);
    expect(engine.current.completed, isTrue);
    expect(engine.current.machine, EngineMachineState.done);
    expect(events, contains(EngineEvent.done));
    expect(engine.current.longestHoldSeconds, 3);

    engine.dispose();
  });

  test('pause and resume freeze elapsed time', () {
    final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
    final SessionEngine engine = SessionEngine(
      definition: _level1Ref(),
      clock: clock,
      countdownSeconds: 0,
    );
    engine.start(autoTick: false);
    engine.tick();
    expect(engine.current.phaseWord, 'Squeeze');

    clock.add(const Duration(seconds: 1));
    engine.tick();
    expect(engine.current.phaseWord, 'Hold');

    engine.pause();
    expect(engine.current.machine, EngineMachineState.paused);
    clock.add(const Duration(seconds: 10));
    engine.tick(); // ignored while paused
    expect(engine.current.machine, EngineMachineState.paused);

    engine.resume();
    engine.tick();
    expect(engine.current.phaseWord, 'Hold');
    clock.add(const Duration(seconds: 1));
    engine.tick();
    expect(engine.current.phaseWord, 'Hold');
    clock.add(const Duration(seconds: 1));
    engine.tick();
    expect(engine.current.phaseWord, 'Relax');
    engine.dispose();
  });

  test('exit does not complete the session', () {
    final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
    final SessionEngine engine = SessionEngine(
      definition: _level1Ref(),
      clock: clock,
      countdownSeconds: 0,
    );
    final List<EngineEvent> events = <EngineEvent>[];
    engine.events.listen(events.add);

    engine.start(autoTick: false);
    engine.tick();
    clock.add(const Duration(seconds: 2));
    engine.tick();
    engine.exit();

    expect(engine.current.exited, isTrue);
    expect(engine.current.completed, isFalse);
    expect(events.contains(EngineEvent.done), isFalse);
    engine.dispose();
  });

  test('skip countdown jumps to first squeeze', () {
    final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
    final SessionEngine engine = SessionEngine(
      definition: _level1Ref(),
      clock: clock,
      countdownSeconds: 5,
    );
    engine.start(autoTick: false);
    engine.tick();
    expect(engine.current.machine, EngineMachineState.countdown);
    engine.skipCountdown();
    expect(engine.current.machine, EngineMachineState.squeeze);
    expect(engine.current.phaseWord, 'Squeeze');
    engine.dispose();
  });

  test('fromJson and fromLevel builders', () {
    final SessionDefinition fromJson = _level1Ref();
    expect(fromJson.blocks.length, 3);
    expect(fromJson.durationSeconds, 55);

    final SessionDefinition fromLevel = SessionDefinitionFactory.fromLevel(
      level: const LevelContent(
        id: 1,
        name: 'Start',
        dayStart: 1,
        dayEnd: 7,
        slowHolds: <String, dynamic>{'reps': 5, 'holdSec': 3, 'relaxSec': 3},
        quickSqueezes: <String, dynamic>{
          'reps': 5,
          'squeezeSec': 1,
          'relaxSec': 2,
        },
        position: 'lying_or_sitting',
        extras: <String>[],
        dailyBreathingSec: 120,
      ),
      track: TrackId.generalBladder,
    );
    expect(fromLevel.durationSeconds, 55);
  });
}
