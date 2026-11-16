import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/safety_flags.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/plan/plan_models.dart';
import 'package:kegelexercisesapp/core/plan/plan_rules.dart';
import 'package:kegelexercisesapp/core/plan/plan_service.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';

SessionRecord _session({
  required DateTime at,
  bool completed = true,
  SessionKind kind = SessionKind.strengthening,
  int level = 1,
  int dayInLevel = 1,
  TrackId track = TrackId.generalBladder,
  SessionFeel? feel,
}) {
  return SessionRecord(
    startedAt: at,
    completedAt: completed ? at : null,
    level: level,
    dayInLevel: dayInLevel,
    track: track,
    kind: kind,
    completed: completed,
    feel: feel,
    durationSeconds: 55,
  );
}

UserProfile _profile({
  TrackId track = TrackId.generalBladder,
  int level = 1,
  int sessionsPerDay = 2,
  int restWeekday = DateTime.sunday,
  SafetyFlags flags = const SafetyFlags(),
}) {
  return UserProfile(
    goal: Goal.bladderControl,
    safetyFlags: flags,
    experience: Experience.none,
    sessionsPerDay: sessionsPerDay,
    reminderEnabled: false,
    reminderTime: 21 * 60,
    reminderDays: const <int>[1, 2, 3, 4, 5, 6, 7],
    track: track,
    level: level,
    levelStartedOn: DateTime(2026, 11, 1),
    restWeekday: restWeekday,
    onboardingDone: true,
  );
}

void main() {
  group('rest day', () {
    test('Sunday is configured rest weekday by default', () {
      expect(
        PlanRules.isConfiguredRestWeekday(
          DateTime(2026, 11, 8),
          DateTime.sunday,
        ),
        isTrue,
      );
      expect(
        PlanRules.isConfiguredRestWeekday(
          DateTime(2026, 11, 9),
          DateTime.sunday,
        ),
        isFalse,
      );
    });

    test('active rest day requires a prior completed session', () {
      final DateTime sunday = DateTime(2026, 11, 8);
      expect(
        PlanRules.isRestDay(
          date: sunday,
          restWeekday: DateTime.sunday,
          sessions: const <SessionRecord>[],
        ),
        isFalse,
      );
      expect(
        PlanRules.isRestDay(
          date: sunday,
          restWeekday: DateTime.sunday,
          sessions: <SessionRecord>[_session(at: DateTime(2026, 11, 7))],
        ),
        isTrue,
      );
    });

    test('install on rest weekday still gets Level 1 Day 1 (not rest)', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 8, 12)); // Sunday
      final PlanService service = PlanService(clock: clock);
      final TodayPlan plan = service.todayPlan(
        profile: _profile(sessionsPerDay: 1),
        sessions: const <SessionRecord>[],
      );
      expect(plan.state, TodayPlanState.normal);
      expect(plan.dayInLevel, 1);
      expect(plan.level, 1);
      expect(
        plan.items.any((TodayItem i) => i.kind == SessionKind.strengthening),
        isTrue,
      );
    });

    test('changing restWeekday moves the rest day', () {
      final List<SessionRecord> history = <SessionRecord>[
        _session(at: DateTime(2026, 11, 7)), // prior completed session
      ];
      // Default Sunday: Monday is not rest.
      expect(
        PlanRules.isRestDay(
          date: DateTime(2026, 11, 9),
          restWeekday: DateTime.sunday,
          sessions: history,
        ),
        isFalse,
      );
      // Profile switches rest day to Monday.
      expect(
        PlanRules.isRestDay(
          date: DateTime(2026, 11, 9),
          restWeekday: DateTime.monday,
          sessions: history,
        ),
        isTrue,
      );

      final FakeClock clock = FakeClock(DateTime(2026, 11, 9, 12)); // Monday
      final PlanService service = PlanService(clock: clock);
      final TodayPlan mondayRest = service.todayPlan(
        profile: _profile(restWeekday: DateTime.monday),
        sessions: history,
      );
      expect(mondayRest.state, TodayPlanState.restDay);
      expect(
        mondayRest.items
            .any((TodayItem i) => i.kind == SessionKind.strengthening),
        isFalse,
      );

      final TodayPlan mondayTrain = service.todayPlan(
        profile: _profile(restWeekday: DateTime.sunday),
        sessions: history,
      );
      expect(mondayTrain.state, isNot(TodayPlanState.restDay));
      expect(
        mondayTrain.items
            .any((TodayItem i) => i.kind == SessionKind.strengthening),
        isTrue,
      );
    });
  });

  group('streak', () {
    test('counts consecutive completed days, skipping Sundays', () {
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: DateTime(2026, 11, 9)), // Mon
        _session(at: DateTime(2026, 11, 10)), // Tue
        _session(at: DateTime(2026, 11, 11)), // Wed
      ];
      expect(PlanRules.streak(sessions, DateTime(2026, 11, 11)), 3);
    });

    test('breaks on a missed weekday', () {
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: DateTime(2026, 11, 9)),
        _session(at: DateTime(2026, 11, 11)),
      ];
      expect(PlanRules.streak(sessions, DateTime(2026, 11, 11)), 1);
    });

    test('a day counts with at least one completed session', () {
      expect(
        PlanRules.dayCounts(DateTime(2026, 11, 10), <SessionRecord>[
          _session(at: DateTime(2026, 11, 10, 9)),
          _session(at: DateTime(2026, 11, 10, 18)),
        ]),
        isTrue,
      );
    });
  });

  group('level unlock', () {
    test('unlocks when span complete and 5 of last 7 days at level', () {
      final DateTime today = DateTime(2026, 11, 12);
      final List<SessionRecord> sessions = <SessionRecord>[
        for (int i = 0; i < 7; i++)
          _session(at: today.subtract(Duration(days: i)), level: 1),
      ];
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: sessions,
          today: today,
        ),
        isTrue,
      );
    });

    test('does not unlock with only 4 of 7', () {
      final DateTime today = DateTime(2026, 11, 12);
      final List<SessionRecord> sessions = <SessionRecord>[
        for (int i = 0; i < 4; i++)
          _session(at: today.subtract(Duration(days: i)), level: 1),
      ];
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: sessions,
          today: today,
        ),
        isFalse,
      );
    });

    test('does not unlock when 5 of 7 but span incomplete', () {
      final DateTime today = DateTime(2026, 11, 12);
      final List<SessionRecord> sessions = <SessionRecord>[
        for (int i = 0; i < 5; i++)
          _session(at: today.subtract(Duration(days: i)), level: 1),
      ];
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: sessions,
          today: today,
        ),
        isFalse,
      );
    });
  });

  group('step down suggestion', () {
    test('suggests after two mild discomfort in a row', () {
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(
          at: DateTime(2026, 11, 10),
          feel: SessionFeel.mildDiscomfort,
        ),
        _session(
          at: DateTime(2026, 11, 11),
          feel: SessionFeel.mildDiscomfort,
        ),
      ];
      expect(PlanRules.shouldSuggestStepDown(sessions), isTrue);
    });

    test('does not suggest after fine then mild', () {
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: DateTime(2026, 11, 10), feel: SessionFeel.fine),
        _session(
          at: DateTime(2026, 11, 11),
          feel: SessionFeel.mildDiscomfort,
        ),
      ];
      expect(PlanRules.shouldSuggestStepDown(sessions), isFalse);
    });

    test('manual step down never goes below 1', () {
      expect(PlanRules.stepDownLevel(1), 1);
      expect(PlanRules.stepDownLevel(3), 2);
    });

    test('repeat keeps the same level', () {
      expect(PlanRules.repeatLevel(2), 2);
    });
  });

  group('daily cap', () {
    test('caps at 3 strengthening sessions', () {
      final DateTime day = DateTime(2026, 11, 10);
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: day.add(const Duration(hours: 8))),
        _session(at: day.add(const Duration(hours: 12))),
        _session(at: day.add(const Duration(hours: 18))),
        _session(
          at: day.add(const Duration(hours: 19)),
          kind: SessionKind.breathing,
        ),
      ];
      expect(PlanRules.dailyCapReached(sessions, day), isTrue);
      expect(PlanRules.strengtheningCountOnDay(sessions, day), 3);
    });
  });

  group('missed days / dayInLevel', () {
    test('dayInLevel counts completed training days, not calendar gaps', () {
      final UserProfile profile = _profile();
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: DateTime(2026, 11, 2), dayInLevel: 1),
        // gap of several calendar days
        _session(at: DateTime(2026, 11, 10), dayInLevel: 2),
      ];
      expect(
        PlanRules.dayInLevel(profile: profile, sessions: sessions),
        3,
      );
    });

    test('breathing sessions do not advance dayInLevel', () {
      final UserProfile profile = _profile();
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: DateTime(2026, 11, 2)),
        _session(
          at: DateTime(2026, 11, 3),
          kind: SessionKind.breathing,
        ),
      ];
      expect(
        PlanRules.dayInLevel(profile: profile, sessions: sessions),
        2,
      );
    });

    test('relaxation-first dayInLevel counts breathing and relaxation days', () {
      final UserProfile profile = _profile(track: TrackId.relaxationFirst);
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(
          at: DateTime(2026, 11, 2),
          kind: SessionKind.breathing,
          track: TrackId.relaxationFirst,
        ),
        _session(
          at: DateTime(2026, 11, 3),
          kind: SessionKind.relaxation,
          track: TrackId.relaxationFirst,
        ),
      ];
      expect(
        PlanRules.dayInLevel(profile: profile, sessions: sessions),
        3,
      );
      expect(PlanRules.relaxationFirstDays, 14);
    });
  });

  group('relaxation first and catheter', () {
    test('catheter blocks exercises', () {
      expect(
        PlanRules.isCatheterBlocked(
          _profile(flags: const SafetyFlags(catheter: true)),
        ),
        isTrue,
      );
    });

    test('pain switches to relaxation-first', () {
      final UserProfile next = PlanRules.applyPainTrack(
        _profile(),
        DateTime(2026, 11, 12),
      );
      expect(next.track, TrackId.relaxationFirst);
      expect(next.safetyFlags.pain, isTrue);
    });

    test('relaxation-first is detected', () {
      expect(
        PlanRules.isRelaxationOnly(_profile(track: TrackId.relaxationFirst)),
        isTrue,
      );
    });
  });

  group('check-in timing', () {
    test('baseline due after third completed session', () {
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: DateTime(2026, 11, 1)),
        _session(at: DateTime(2026, 11, 2)),
        _session(at: DateTime(2026, 11, 3)),
      ];
      expect(
        PlanRules.isCheckInDue(
          sessions: sessions,
          checkIns: const <CheckInRecord>[],
          today: DateTime(2026, 11, 3),
        ),
        isTrue,
      );
    });

    test('not due before third session', () {
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(at: DateTime(2026, 11, 1)),
        _session(at: DateTime(2026, 11, 2)),
      ];
      expect(
        PlanRules.isCheckInDue(
          sessions: sessions,
          checkIns: const <CheckInRecord>[],
          today: DateTime(2026, 11, 2),
        ),
        isFalse,
      );
    });

    test('due again every 4 weeks after last check-in', () {
      final List<SessionRecord> sessions = <SessionRecord>[
        for (int i = 0; i < 5; i++) _session(at: DateTime(2026, 10, 1 + i)),
      ];
      final List<CheckInRecord> checkIns = <CheckInRecord>[
        CheckInRecord(
          date: DateTime(2026, 10, 3),
          goal: Goal.bladderControl,
          score: 3,
        ),
      ];
      expect(
        PlanRules.isCheckInDue(
          sessions: sessions,
          checkIns: checkIns,
          today: DateTime(2026, 10, 30),
        ),
        isFalse,
      );
      expect(
        PlanRules.isCheckInDue(
          sessions: sessions,
          checkIns: checkIns,
          today: DateTime(2026, 10, 31),
        ),
        isTrue,
      );
    });
  });

  group('PlanService todayPlan with fake clock', () {
    test('catheterBlocked state', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 10, 12)); // Monday
      final PlanService service = PlanService(clock: clock);
      final TodayPlan plan = service.todayPlan(
        profile: _profile(flags: const SafetyFlags(catheter: true)),
        sessions: const <SessionRecord>[],
      );
      expect(plan.state, TodayPlanState.catheterBlocked);
      expect(plan.items, isEmpty);
    });

    test('rest day shows breathing only after first completed session', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 8, 12)); // Sunday
      final PlanService service = PlanService(clock: clock);
      final TodayPlan plan = service.todayPlan(
        profile: _profile(),
        sessions: <SessionRecord>[
          _session(at: DateTime(2026, 11, 7)),
        ],
      );
      expect(plan.state, TodayPlanState.restDay);
      expect(
        plan.items.every((TodayItem i) => i.kind != SessionKind.strengthening),
        isTrue,
      );
      expect(
        plan.items.any((TodayItem i) => i.kind == SessionKind.breathing),
        isTrue,
      );
    });

    test('dailyCapReached after 3 strengthening', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 10, 20));
      final PlanService service = PlanService(clock: clock);
      final DateTime day = DateTime(2026, 11, 10);
      final TodayPlan plan = service.todayPlan(
        profile: _profile(sessionsPerDay: 3),
        sessions: <SessionRecord>[
          _session(at: day.add(const Duration(hours: 8))),
          _session(at: day.add(const Duration(hours: 12))),
          _session(at: day.add(const Duration(hours: 16))),
        ],
      );
      expect(plan.state, TodayPlanState.dailyCapReached);
    });

    test('relaxation-first has no strengthening', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 10, 12));
      final PlanService service = PlanService(clock: clock);
      final TodayPlan plan = service.todayPlan(
        profile: _profile(track: TrackId.relaxationFirst),
        sessions: const <SessionRecord>[],
      );
      expect(
        plan.items.any((TodayItem i) => i.kind == SessionKind.strengthening),
        isFalse,
      );
      expect(
        plan.items.any((TodayItem i) => i.kind == SessionKind.breathing),
        isTrue,
      );
    });

    test('allDone when required items finished', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 10, 20));
      final PlanService service = PlanService(clock: clock);
      final DateTime day = DateTime(2026, 11, 10);
      final TodayPlan plan = service.todayPlan(
        profile: _profile(sessionsPerDay: 1),
        sessions: <SessionRecord>[
          _session(at: day.add(const Duration(hours: 9))),
          _session(
            at: day.add(const Duration(hours: 10)),
            kind: SessionKind.breathing,
          ),
        ],
      );
      expect(plan.state, TodayPlanState.allDone);
    });

    test('stepDown mutates level only via service', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 10));
      final PlanService service = PlanService(clock: clock);
      final UserProfile next = service.stepDown(_profile(level: 3));
      expect(next.level, 2);
    });
  });
}
