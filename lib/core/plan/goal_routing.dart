import '../domain/enums.dart';
import '../domain/goal_plan_snapshot.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';

/// Applies a Settings goal change with per-goal plan save/restore.
///
/// Saves the outgoing goal's level and calendar into [UserProfile.goalPlans],
/// then restores the incoming goal's snapshot (or starts a fresh plan).
/// Session rows stay in Drift and are filtered by track on Today.
abstract final class GoalRouting {
  /// Returns the profile after applying [goal].
  static UserProfile apply({
    required UserProfile profile,
    required Goal goal,
    required DateTime now,
  }) {
    final DateTime today = dateOnly(now);
    final Map<String, GoalPlanSnapshot> plans =
        Map<String, GoalPlanSnapshot>.from(profile.goalPlans);

    // Remember the current strengthening plan before switching away.
    if (profile.goal != null && profile.track != TrackId.relaxationFirst) {
      plans[profile.goal!.storageValue] = GoalPlanSnapshot.fromProfile(profile);
    }

    final bool painLocked =
        profile.safetyFlags.pain || profile.safetyFlags.painSexual;
    if (painLocked) {
      return profile.copyWith(goal: goal, goalPlans: plans);
    }

    if (goal == profile.goal) {
      return profile.copyWith(goalPlans: plans);
    }

    final GoalPlanSnapshot? saved = plans[goal.storageValue];
    if (saved != null && saved.track != TrackId.relaxationFirst) {
      return profile.copyWith(
        goal: goal,
        track: saved.track,
        level: saved.level,
        levelStartedOn: saved.levelStartedOn,
        planStartedOn: saved.planStartedOn,
        restWeekday: saved.restWeekday,
        levelUnlockSnoozed: saved.levelUnlockSnoozed,
        goalPlans: plans,
      );
    }

    final TrackId track = trackForGoal(goal);
    // Same track as live plan (e.g. bladder ↔ general): keep cursor, new label.
    if (track == profile.track) {
      return profile.copyWith(goal: goal, goalPlans: plans);
    }

    return profile.copyWith(
      goal: goal,
      track: track,
      level: 1,
      levelStartedOn: today,
      planStartedOn: today,
      restWeekday: restWeekdayForStart(today),
      levelUnlockSnoozed: false,
      goalPlans: plans,
    );
  }
}
