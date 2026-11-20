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
    expect(engine.current.phaseWord, SessionPhaseKey.squeeze);
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

    // Rep 1 slow: squeeze, hold, hold, relax, relax, relax
    expect(phases.sublist(0, 6), <String>[
      SessionPhaseKey.squeeze,
      SessionPhaseKey.hold,
      SessionPhaseKey.hold,
      SessionPhaseKey.relax,
      SessionPhaseKey.relax,
      SessionPhaseKey.relax,
    ]);

    // After 5 slow holds (30s) → rest
    expect(phases[30], SessionPhaseKey.rest);
    expect(phases[39], SessionPhaseKey.rest);

    // Quick squeezes start at t=40
    expect(phases[40], SessionPhaseKey.squeeze);
    expect(phases[41], SessionPhaseKey.relax);
    expect(phases[42], SessionPhaseKey.relax);

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
    expect(engine.current.phaseWord, SessionPhaseKey.squeeze);

    clock.add(const Duration(seconds: 1));
    engine.tick();
    expect(engine.current.phaseWord, SessionPhaseKey.hold);

    engine.pause();
    expect(engine.current.machine, EngineMachineState.paused);
    clock.add(const Duration(seconds: 10));
    engine.tick(); // ignored while paused
    expect(engine.current.machine, EngineMachineState.paused);

    engine.resume();
    engine.tick();
    expect(engine.current.phaseWord, SessionPhaseKey.hold);
    clock.add(const Duration(seconds: 1));
    engine.tick();
    expect(engine.current.phaseWord, SessionPhaseKey.hold);
    clock.add(const Duration(seconds: 1));
    engine.tick();
    expect(engine.current.phaseWord, SessionPhaseKey.relax);
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
    expect(engine.current.phaseWord, SessionPhaseKey.squeeze);
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
        bodyCard: <String, List<String>>{},
  kegelExtras: <String, List<String>>{},
        dailyBreathingSec: 120,
      ),
      track: TrackId.generalBladder,
    );
    expect(fromLevel.durationSeconds, 55);
  });

  group('forward button', () {
    SessionEngine started(FakeClock clock) {
      final SessionEngine engine = SessionEngine(
        definition: _level1Ref(),
        clock: clock,
        countdownSeconds: 0,
      )..start(autoTick: false);
      engine.tick();
      return engine;
    }

    test('skipPhase moves squeeze → relax → next rep', () {
      final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
      final SessionEngine engine = started(clock);
      expect(engine.current.machine, EngineMachineState.squeeze);
      expect(engine.current.rep, 1);

      engine.skipPhase();
      expect(engine.current.machine, EngineMachineState.relax);
      expect(engine.current.rep, 1);

      engine.skipPhase();
      expect(engine.current.machine, EngineMachineState.squeeze);
      expect(engine.current.rep, 2);
      engine.dispose();
    });

    test('skipBlock jumps to the next exercise', () {
      final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
      final SessionEngine engine = started(clock);
      expect(engine.current.blockIndex, 0);
      engine.skipBlock();
      expect(engine.current.blockIndex, 1);
      expect(engine.current.machine, EngineMachineState.rest);
      engine.skipBlock();
      expect(engine.current.blockIndex, 2);
      expect(engine.current.blockTitleKey, 'quickSqueezes');
      engine.dispose();
    });

    test('a skipped hold never counts toward the longest hold', () {
      final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
      final SessionEngine engine = started(clock);
      engine.skipBlock(); // skip all five 3 s holds
      engine.skipBlock(); // skip rest
      clock.add(const Duration(seconds: 30));
      engine.tick();
      expect(engine.current.completed, isTrue);
      expect(engine.current.longestHoldSeconds, 0);
      engine.dispose();
    });

    test('skipping while paused resumes, and the last skip finishes', () {
      final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
      final SessionEngine engine = started(clock);
      engine.pause();
      engine.skipPhase();
      expect(engine.current.machine, EngineMachineState.relax);
      engine.skipBlock();
      engine.skipBlock();
      engine.skipBlock();
      expect(engine.current.completed, isTrue);
      engine.dispose();
    });
  });
}
