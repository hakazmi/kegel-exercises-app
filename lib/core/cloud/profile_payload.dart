import '../domain/enums.dart';
import '../domain/goal_plan_snapshot.dart';
import '../domain/user_profile.dart';

/// Cloud profile JSON — never includes safety flags.
abstract final class ProfilePayload {
  static Map<String, dynamic> toJson({
    required UserProfile profile,
    required int updatedAtMillis,
    String? displayName,
    String? guideSeenAtIso,
    String? timeZone,
  }) {
    return <String, dynamic>{
      'display_name': displayName,
      'goal': profile.goal?.storageValue,
      'experience': profile.experience?.storageValue,
      'sessions_per_day': profile.sessionsPerDay,
      'track': profile.track.storageValue,
      'level': profile.level,
      'level_started_on': dateOnly(profile.levelStartedOn),
      'plan_started_on': dateOnly(profile.planStartedOn),
      'rest_weekday': profile.restWeekday,
      'onboarding_done': profile.onboardingDone,
      'tutorial_done': profile.tutorialDone,
      'paywall_seen': profile.paywallSeen,
      'level_unlock_snoozed': profile.levelUnlockSnoozed,
      'goal_plans': <String, dynamic>{
        for (final MapEntry<String, GoalPlanSnapshot> e
            in profile.goalPlans.entries)
          e.key: e.value.toJson(),
      },
      'guide_seen_at': guideSeenAtIso,
      'time_zone': timeZone,
      'updated_at_millis': updatedAtMillis,
    };
  }

  /// Applies remote profile onto [local]. Flags only turn on; plan fields LWW.
  static UserProfile applyRemote({
    required UserProfile local,
    required Map<String, dynamic> remote,
  }) {
    final bool onboardingDone =
        local.onboardingDone || (remote['onboarding_done'] as bool? ?? false);
    final bool tutorialDone =
        local.tutorialDone || (remote['tutorial_done'] as bool? ?? false);
    final bool paywallSeen =
        local.paywallSeen || (remote['paywall_seen'] as bool? ?? false);

    final String? goalRaw = remote['goal'] as String?;
    final String? experienceRaw = remote['experience'] as String?;
    final String? trackRaw = remote['track'] as String?;
    final DateTime? levelStarted = parseDate(remote['level_started_on']);
    final DateTime? planStarted = parseDate(remote['plan_started_on']);

    Map<String, GoalPlanSnapshot>? goalPlans;
    final Object? rawPlans = remote['goal_plans'];
    if (rawPlans is Map) {
      goalPlans = <String, GoalPlanSnapshot>{};
      for (final MapEntry<dynamic, dynamic> e in rawPlans.entries) {
        final Object? value = e.value;
        if (value is Map) {
          goalPlans['${e.key}'] = GoalPlanSnapshot.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      }
    }

    return local.copyWith(
      goal: goalRaw == null ? local.goal : GoalX.parse(goalRaw),
      clearGoal: remote.containsKey('goal') && goalRaw == null,
      experience: experienceRaw == null
          ? local.experience
          : ExperienceX.parse(experienceRaw),
      clearExperience: remote.containsKey('experience') && experienceRaw == null,
      sessionsPerDay:
          (remote['sessions_per_day'] as num?)?.toInt() ?? local.sessionsPerDay,
      track: trackRaw == null ? local.track : TrackIdX.parse(trackRaw),
      level: (remote['level'] as num?)?.toInt() ?? local.level,
      levelStartedOn: levelStarted,
      clearLevelStartedOn:
          remote.containsKey('level_started_on') && levelStarted == null,
      planStartedOn: planStarted ?? local.planStartedOn,
      restWeekday:
          (remote['rest_weekday'] as num?)?.toInt() ?? local.restWeekday,
      onboardingDone: onboardingDone,
      tutorialDone: tutorialDone,
      paywallSeen: paywallSeen,
      levelUnlockSnoozed:
          remote['level_unlock_snoozed'] as bool? ?? local.levelUnlockSnoozed,
      goalPlans: goalPlans,
    );
  }

  static String? dateOnly(DateTime? d) {
    if (d == null) {
      return null;
    }
    final String m = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static DateTime? parseDate(Object? raw) {
    if (raw == null) {
      return null;
    }
    final String s = '$raw';
    if (s.isEmpty) {
      return null;
    }
    return DateTime.tryParse(s);
  }
}
