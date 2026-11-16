import '../domain/enums.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';
import 'plan_models.dart';
import 'plan_rules.dart';

/// Builds today's plan and applies profile mutations that the rules allow.
class PlanService {
  PlanService({AppClock? clock}) : _clock = clock ?? const SystemClock();

  final AppClock _clock;

  DateTime get now => _clock.now();

  /// Today's items and surface state.
  TodayPlan todayPlan({
    required UserProfile profile,
    required List<SessionRecord> sessions,
    int strengtheningDurationSeconds = 55,
  }) {
    final DateTime today = dateOnly(now);
    final int day = PlanRules.dayInLevel(profile: profile, sessions: sessions);
    final TrackId track = profile.track;

    if (PlanRules.isCatheterBlocked(profile)) {
      return TodayPlan(
        state: TodayPlanState.catheterBlocked,
        items: const <TodayItem>[],
        dayInLevel: day,
        level: profile.level,
        track: track,
      );
    }

    final bool relaxationOnly = profile.track == TrackId.relaxationFirst;
    final bool rest = PlanRules.isRestDay(
      date: today,
      restWeekday: profile.restWeekday,
      sessions: sessions,
    );

    final List<TodayItem> items = <TodayItem>[];

    if (!relaxationOnly && !rest) {
      final int planned = PlanRules.plannedStrengtheningSlots(profile.sessionsPerDay);
      final int doneCount = PlanRules.strengtheningCountOnDay(sessions, today);
      for (int i = 1; i <= planned; i++) {
        final bool optional = planned == 3 && i == 3;
        items.add(
          TodayItem(
            id: 'strength_$i',
            kind: SessionKind.strengthening,
            label: 'Session $i',
            durationSeconds: strengtheningDurationSeconds,
            done: doneCount >= i,
            optional: optional,
            sessionNumber: i,
          ),
        );
      }
    }

    if (relaxationOnly) {
      items.add(
        TodayItem(
          id: 'reverse_kegel',
          kind: SessionKind.relaxation,
          label: 'Reverse Kegel',
          durationSeconds: 120,
          done: _kindDoneToday(sessions, today, SessionKind.relaxation),
        ),
      );
    }

    final bool breathingDone = sessions.any(
      (SessionRecord s) =>
          s.completed &&
          s.kind == SessionKind.breathing &&
          isSameDay(dateOnly(s.completedAt ?? s.startedAt), today),
    );
    items.add(
      TodayItem(
        id: 'breathing',
        kind: SessionKind.breathing,
        label: 'Relaxation breathing',
        durationSeconds: PlanRules.breathingDurationSeconds,
        done: breathingDone,
      ),
    );

    final TodayPlanState state = _resolveState(
      profile: profile,
      sessions: sessions,
      today: today,
      rest: rest,
      relaxationOnly: relaxationOnly,
      items: items,
    );

    return TodayPlan(
      state: state,
      items: items,
      dayInLevel: day,
      level: profile.level,
      track: track,
    );
  }

  TodayPlanState _resolveState({
    required UserProfile profile,
    required List<SessionRecord> sessions,
    required DateTime today,
    required bool rest,
    required bool relaxationOnly,
    required List<TodayItem> items,
  }) {
    if (PlanRules.isCatheterBlocked(profile)) {
      return TodayPlanState.catheterBlocked;
    }
    if (rest && !relaxationOnly) {
      final bool breathingDone =
          items.any((TodayItem i) => i.kind == SessionKind.breathing && i.done);
      return breathingDone ? TodayPlanState.allDone : TodayPlanState.restDay;
    }
    if (PlanRules.dailyCapReached(sessions, today) && !relaxationOnly) {
      return TodayPlanState.dailyCapReached;
    }
    final bool allRequiredDone = items
        .where((TodayItem i) => !i.optional)
        .every((TodayItem i) => i.done);
    if (allRequiredDone) {
      return TodayPlanState.allDone;
    }
    return TodayPlanState.normal;
  }

  bool _kindDoneToday(
    List<SessionRecord> sessions,
    DateTime today,
    SessionKind kind,
  ) {
    return sessions.any(
      (SessionRecord s) =>
          s.completed &&
          s.kind == kind &&
          isSameDay(dateOnly(s.completedAt ?? s.startedAt), today),
    );
  }

  /// Applies pain routing: relaxation-first track + pain flag.
  UserProfile onPainReported(UserProfile profile) =>
      PlanRules.applyPainTrack(profile, now);

  /// Manual step down (never automatic).
  UserProfile stepDown(UserProfile profile) {
    final int next = PlanRules.stepDownLevel(profile.level);
    return profile.copyWith(
      level: next,
      levelStartedOn: dateOnly(now),
      levelUnlockSnoozed: false,
    );
  }

  /// Repeat current level from day 1 (clears level start date for caller to reset history scoping).
  UserProfile repeatLevel(UserProfile profile) {
    return profile.copyWith(
      level: PlanRules.repeatLevel(profile.level),
      levelStartedOn: dateOnly(now),
      levelUnlockSnoozed: false,
    );
  }

  /// Explicit advance after the user taps Start Level N (never call silently).
  UserProfile advanceLevel(UserProfile profile, int nextLevel) {
    return profile.copyWith(
      level: nextLevel.clamp(1, 5),
      levelStartedOn: dateOnly(now),
      levelUnlockSnoozed: false,
    );
  }
}
