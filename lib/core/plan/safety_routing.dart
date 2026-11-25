import '../domain/enums.dart';
import '../domain/goal_plan_snapshot.dart';
import '../domain/safety_flags.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';

/// Applies O3-style safety routing to an existing profile (Settings editor).
abstract final class SafetyRouting {
  /// Updates flags and track the same way onboarding Safety check does.
  ///
  /// Pain → relaxation-first (after saving the current goal snapshot).
  /// No pain → restore that goal's snapshot when present, else track from goal.
  /// Catheter is stored and blocks exercises on Today without changing
  /// onboardingDone.
  static UserProfile apply({
    required UserProfile profile,
    required SafetyFlags flags,
    required DateTime now,
  }) {
    final DateTime today = dateOnly(now);
    final Map<String, GoalPlanSnapshot> plans =
        Map<String, GoalPlanSnapshot>.from(profile.goalPlans);
    final bool wasPain =
        profile.safetyFlags.pain || profile.safetyFlags.painSexual;
    final bool nowPain = flags.pain || flags.painSexual;

    if (nowPain) {
      if (!wasPain &&
          profile.goal != null &&
          profile.track != TrackId.relaxationFirst) {
        plans[profile.goal!.storageValue] =
            GoalPlanSnapshot.fromProfile(profile);
      }
      final bool enteringRelaxation =
          profile.track != TrackId.relaxationFirst;
      return profile.copyWith(
        safetyFlags: flags,
        track: TrackId.relaxationFirst,
        level: enteringRelaxation ? 1 : profile.level,
        levelStartedOn: enteringRelaxation ? today : profile.levelStartedOn,
        goalPlans: plans,
      );
    }

    final Goal? goal = profile.goal;
    if (goal != null) {
      final GoalPlanSnapshot? saved = plans[goal.storageValue];
      if (saved != null && saved.track != TrackId.relaxationFirst) {
        return profile.copyWith(
          safetyFlags: flags,
          track: saved.track,
          level: saved.level,
          levelStartedOn: saved.levelStartedOn,
          planStartedOn: saved.planStartedOn,
          restWeekday: saved.restWeekday,
          levelUnlockSnoozed: saved.levelUnlockSnoozed,
          goalPlans: plans,
        );
      }
    }

    final TrackId track = goal != null
        ? trackForGoal(goal)
        : TrackId.generalBladder;
    final bool trackChanged = track != profile.track;
    return profile.copyWith(
      safetyFlags: flags,
      track: track,
      level: trackChanged ? 1 : profile.level,
      levelStartedOn: trackChanged ? today : profile.levelStartedOn,
      planStartedOn: trackChanged ? today : profile.planStartedOn,
      restWeekday: trackChanged
          ? restWeekdayForStart(today)
          : profile.restWeekday,
      goalPlans: plans,
    );
  }
}
