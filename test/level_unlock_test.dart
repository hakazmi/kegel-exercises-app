import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/plan/level_progression.dart';
import 'package:kegelexercisesapp/core/plan/plan_rules.dart';
import 'package:kegelexercisesapp/core/plan/plan_service.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';

SessionRecord _session({
  required DateTime at,
  int level = 1,
  SessionKind kind = SessionKind.strengthening,
}) {
  return SessionRecord(
    startedAt: at,
    completedAt: at,
    level: level,
    dayInLevel: 1,
    track: TrackId.generalBladder,
    kind: kind,
    durationSeconds: 60,
    longestHoldSeconds: 3,
    completed: true,
  );
}

UserProfile _profile({
  int level = 1,
  TrackId track = TrackId.generalBladder,
  bool snoozed = false,
}) {
  return UserProfile.initial().copyWith(
    onboardingDone: true,
    goal: Goal.bladderControl,
    track: track,
    level: level,
    levelStartedOn: DateTime(2026, 11, 1),
    levelUnlockSnoozed: snoozed,
  );
}

/// Seven training days ending on [end], plus enough history for span complete.
List<SessionRecord> _sevenDaySpanEnding(DateTime end, {int level = 1}) {
  return <SessionRecord>[
    for (int i = 6; i >= 0; i--)
      _session(at: end.subtract(Duration(days: i)), level: level),
  ];
}

void main() {
  group('PlanRules unlock', () {
    test('unlocks at 5 of 7 when level span is complete', () {
      final DateTime today = DateTime(2026, 11, 12);
      final List<SessionRecord> sessions = _sevenDaySpanEnding(today);
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: sessions,
          today: today,
        ),
        isTrue,
      );
      expect(
        LevelProgression.shouldShowUnlockCard(
          profile: _profile(),
          sessions: sessions,
          today: today,
        ),
        isTrue,
      );
    });

    test('no unlock at 4 of 7 even when span is complete', () {
      // Span complete on days 1–7; today day 10 → only 4 days in the last 7.
      final DateTime spanEnd = DateTime(2026, 11, 7);
      final DateTime today = DateTime(2026, 11, 10);
      final List<SessionRecord> sessions = _sevenDaySpanEnding(spanEnd);
      expect(
        PlanRules.isLevelSpanComplete(level: 1, sessions: sessions),
        isTrue,
      );
      expect(
        PlanRules.completedDaysInUnlockWindow(
          level: 1,
          sessions: sessions,
          today: today,
        ),
        4,
      );
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: sessions,
          today: today,
        ),
        isFalse,
      );
    });

    test('repeat still available when span ends without 5 of 7', () {
      final FakeClock clock = FakeClock(DateTime(2026, 11, 10, 12));
      final PlanService service = PlanService(clock: clock);
      final UserProfile profile = _profile();
      final List<SessionRecord> sessions =
          _sevenDaySpanEnding(DateTime(2026, 11, 7));
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: sessions,
          today: clock.now(),
        ),
        isFalse,
      );
      final UserProfile repeated = service.repeatLevel(profile);
      expect(repeated.level, 1);
      expect(repeated.levelStartedOn, dateOnly(clock.now()));
      expect(repeated.levelUnlockSnoozed, isFalse);
    });

    test('relaxation-first never unlocks', () {
      final DateTime today = DateTime(2026, 11, 12);
      final List<SessionRecord> sessions = _sevenDaySpanEnding(today);
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: sessions,
          today: today,
          track: TrackId.relaxationFirst,
        ),
        isFalse,
      );
      expect(
        LevelProgression.shouldShowUnlockCard(
          profile: _profile(track: TrackId.relaxationFirst),
          sessions: sessions,
          today: today,
        ),
        isFalse,
      );
    });

    test('partial day does not count toward unlock when 2 sessions/day', () {
      final DateTime today = DateTime(2026, 11, 12);
      // One strengthening session per calendar day — incomplete for 2/day.
      final List<SessionRecord> partial = _sevenDaySpanEnding(today);
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: partial,
          today: today,
          sessionsPerDay: 2,
        ),
        isFalse,
      );
      expect(
        PlanRules.completedTrainingDaysAtLevel(
          level: 1,
          sessions: partial,
          sessionsPerDay: 2,
        ),
        0,
      );

      final List<SessionRecord> full = <SessionRecord>[
        for (int i = 6; i >= 0; i--) ...<SessionRecord>[
          _session(
            at: today.subtract(Duration(days: i)).add(const Duration(hours: 8)),
            level: 1,
          ),
          _session(
            at: today
                .subtract(Duration(days: i))
                .add(const Duration(hours: 18)),
            level: 1,
          ),
        ],
      ];
      expect(
        PlanRules.canUnlockNextLevel(
          level: 1,
          sessions: full,
          today: today,
          sessionsPerDay: 2,
        ),
        isTrue,
      );
      expect(
        LevelProgression.shouldShowUnlockCard(
          profile: _profile().copyWith(sessionsPerDay: 2),
          sessions: full,
          today: today,
        ),
        isTrue,
      );
    });
  });

  group('LevelProgression start / stay', () {
    test('free user going to Level 2 needs premium paywall', () {
      expect(
        LevelProgression.startOutcome(nextLevel: 2, isPremium: false),
        LevelStartOutcome.needsPremium,
      );
      expect(
        LevelProgression.startOutcome(nextLevel: 2, isPremium: true),
        LevelStartOutcome.advanced,
      );
    });

    test('premium user advances level, day and snooze', () {
      final DateTime now = DateTime(2026, 11, 12, 15);
      final UserProfile next = LevelProgression.advanceTo(
        profile: _profile(snoozed: true),
        nextLevel: 2,
        now: now,
      );
      expect(next.level, 2);
      expect(next.levelStartedOn, dateOnly(now));
      expect(next.levelUnlockSnoozed, isFalse);
    });

    test('stay on this level hides the card until cleared', () {
      final DateTime today = DateTime(2026, 11, 12);
      final List<SessionRecord> sessions = _sevenDaySpanEnding(today);
      final UserProfile snoozed =
          LevelProgression.snooze(_profile());
      expect(
        LevelProgression.shouldShowUnlockCard(
          profile: snoozed,
          sessions: sessions,
          today: today,
        ),
        isFalse,
      );
      expect(
        LevelProgression.shouldShowUnlockCard(
          profile: LevelProgression.clearSnooze(snoozed),
          sessions: sessions,
          today: today,
        ),
        isTrue,
      );
    });
  });
}
