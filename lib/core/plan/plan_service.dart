import '../content/content_models.dart';
import '../domain/enums.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';
import 'plan_models.dart';
import 'plan_rules.dart';
import 'session_definition.dart';

/// Builds today's plan and applies profile mutations that the rules allow.
class PlanService {
  PlanService({AppClock? clock}) : _clock = clock ?? const SystemClock();

  final AppClock _clock;

  DateTime get now => _clock.now();

  /// Today's timed items, habits, and surface state.
  ///
  /// Content args are optional so unit tests can exercise plan states with
  /// strengthening + breathing only.
  TodayPlan todayPlan({
    required UserProfile profile,
    required List<SessionRecord> sessions,
    TrackContent? trackContent,
    LevelContent? levelContent,
    Map<String, ExerciseContent> exercisesById = const <String, ExerciseContent>{},
    Set<String> habitsDoneToday = const <String>{},
    bool isPremium = false,
    int strengtheningDurationSeconds = 55,
  }) {
    final DateTime today = dateOnly(now);
    final int day = PlanRules.dayInLevel(profile: profile, sessions: sessions);
    final TrackId track = profile.track;
    final String trackKey = track.contentId;
    final int breathingSec = levelContent?.dailyBreathingSec ?? 120;

    if (PlanRules.isCatheterBlocked(profile)) {
      return TodayPlan(
        state: TodayPlanState.catheterBlocked,
        items: const <TodayItem>[],
        habits: const <TodayHabitItem>[],
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
      final int planned =
          PlanRules.plannedStrengtheningSlots(profile.sessionsPerDay);
      final int doneCount = PlanRules.strengtheningCountOnDay(sessions, today);
      for (int i = 1; i <= planned; i++) {
        final bool optional = planned == 3 && i == 3;
        items.add(
          TodayItem(
            id: 'strength_$i',
            kind: SessionKind.strengthening,
            label: '',
            durationSeconds: strengtheningDurationSeconds,
            done: doneCount >= i,
            optional: optional,
            sessionNumber: i,
          ),
        );
      }

      // Body and function — once a day from Level 2 (Premium).
      final List<String> bodyIds =
          levelContent?.bodyExercisesForTrack(trackKey) ?? const <String>[];
      if (bodyIds.isNotEmpty && profile.level >= 2) {
        final bool bodyDone = sessions.any(
          (SessionRecord s) =>
              s.completed &&
              s.kind == SessionKind.body &&
              isSameDay(dateOnly(s.completedAt ?? s.startedAt), today),
        );
        final bool locked = !isPremium;
        items.add(
          TodayItem(
            id: 'body_1',
            kind: SessionKind.body,
            label: '',
            durationSeconds: SessionDefinitionBuilder.estimateBodyDuration(
              bodyIds,
              exercisesById,
            ),
            done: bodyDone,
            locked: locked,
            exerciseIds: bodyIds,
          ),
        );
      }
    }

    // Relax and breathe card.
    final List<String> breatheIds = rest
        ? (trackContent?.restDayBreatheCard ??
            const <String>['diaphragmatic_breathing'])
        : (trackContent?.breatheCard ??
            const <String>['diaphragmatic_breathing']);
    if (relaxationOnly) {
      // Legacy single reverse-kegel item when no content loaded (tests).
      if (trackContent == null) {
        items.add(
          TodayItem(
            id: 'reverse_kegel',
            kind: SessionKind.relaxation,
            label: '',
            durationSeconds: 120,
            done: sessions.any(
              (SessionRecord s) =>
                  s.completed &&
                  s.kind == SessionKind.relaxation &&
                  isSameDay(dateOnly(s.completedAt ?? s.startedAt), today),
            ),
          ),
        );
        items.add(
          TodayItem(
            id: 'breathing',
            kind: SessionKind.breathing,
            label: '',
            durationSeconds: PlanRules.breathingDurationSeconds,
            done: sessions.any(
              (SessionRecord s) =>
                  s.completed &&
                  s.kind == SessionKind.breathing &&
                  isSameDay(dateOnly(s.completedAt ?? s.startedAt), today),
            ),
          ),
        );
      } else {
        items.add(
          TodayItem(
            id: 'breathe_1',
            kind: SessionKind.relaxation,
            label: '',
            durationSeconds: SessionDefinitionBuilder.estimateBreatheDuration(
              breatheIds,
              exercisesById,
              breathingSec,
            ),
            done: _breatheDoneToday(sessions, today),
            exerciseIds: breatheIds,
          ),
        );
      }
    } else {
      if (trackContent == null) {
        items.add(
          TodayItem(
            id: 'breathing',
            kind: SessionKind.breathing,
            label: '',
            durationSeconds: PlanRules.breathingDurationSeconds,
            done: sessions.any(
              (SessionRecord s) =>
                  s.completed &&
                  s.kind == SessionKind.breathing &&
                  isSameDay(dateOnly(s.completedAt ?? s.startedAt), today),
            ),
          ),
        );
      } else {
        items.add(
          TodayItem(
            id: 'breathe_1',
            kind: SessionKind.breathing,
            label: '',
            durationSeconds: SessionDefinitionBuilder.estimateBreatheDuration(
              breatheIds,
              exercisesById,
              breathingSec,
            ),
            done: _breatheDoneToday(sessions, today),
            exerciseIds: breatheIds,
          ),
        );
      }
    }

    final List<TodayHabitItem> habits = <TodayHabitItem>[];
    for (final String habitId in trackContent?.habits ?? const <String>[]) {
      final ExerciseContent? ex = exercisesById[habitId];
      habits.add(
        TodayHabitItem(
          id: habitId,
          exerciseId: habitId,
          label: ex?.name ?? habitId,
          done: habitsDoneToday.contains(habitId),
        ),
      );
    }

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
      habits: habits,
      dayInLevel: day,
      level: profile.level,
      track: track,
    );
  }

  bool _breatheDoneToday(List<SessionRecord> sessions, DateTime today) {
    return sessions.any(
      (SessionRecord s) =>
          s.completed &&
          (s.kind == SessionKind.breathing ||
              s.kind == SessionKind.relaxation) &&
          isSameDay(dateOnly(s.completedAt ?? s.startedAt), today),
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
    if (rest) {
      final bool breatheDone = items
          .where(
            (TodayItem i) =>
                i.kind == SessionKind.breathing ||
                i.kind == SessionKind.relaxation,
          )
          .every((TodayItem i) => i.done);
      return breatheDone ? TodayPlanState.allDone : TodayPlanState.restDay;
    }
    if (PlanRules.dailyCapReached(sessions, today) && !relaxationOnly) {
      return TodayPlanState.dailyCapReached;
    }
    final bool allRequiredDone = items
        .where((TodayItem i) => !i.optional && !i.locked)
        .every((TodayItem i) => i.done);
    if (allRequiredDone) {
      return TodayPlanState.allDone;
    }
    return TodayPlanState.normal;
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

  /// Repeat current level from day 1.
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
