import 'enums.dart';
import 'goal_plan_snapshot.dart';
import 'safety_flags.dart';

/// Rest weekday for a plan that starts on [start]: the 7th day of the first
/// week, i.e. the weekday just before the start weekday. Joining on a
/// Wednesday trains Wednesday to Monday and rests on Tuesday.
int restWeekdayForStart(DateTime start) =>
    start.weekday == DateTime.monday ? DateTime.sunday : start.weekday - 1;

/// Persisted user plan and preferences (shared_preferences).
class UserProfile {
  const UserProfile({
    required this.goal,
    required this.safetyFlags,
    required this.experience,
    required this.sessionsPerDay,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.reminderDays,
    required this.track,
    required this.level,
    required this.levelStartedOn,
    this.planStartedOn,
    this.restWeekday = DateTime.sunday,
    this.discreetNotifications = true,
    this.voiceOn = false,
    this.vibrationOn = true,
    this.onboardingDone = false,
    this.tutorialDone = false,
    this.paywallSeen = false,
    this.levelUnlockSnoozed = false,
    this.goalPlans = const <String, GoalPlanSnapshot>{},
  });

  final Goal? goal;
  final SafetyFlags safetyFlags;
  final Experience? experience;

  /// Planned strengthening sessions per day (1–3).
  final int sessionsPerDay;

  final bool reminderEnabled;

  /// Minutes from midnight (default 21:00 → 1260).
  final int reminderTime;

  /// Weekdays 1=Mon … 7=Sun. Empty means every day.
  final List<int> reminderDays;

  final TrackId track;
  final int level;

  /// Calendar date the current level started (date-only, local).
  final DateTime? levelStartedOn;

  /// Calendar date the user finished onboarding (date-only, local).
  final DateTime? planStartedOn;

  /// ISO weekday for the weekly rest day (1=Mon … 7=Sun).
  ///
  /// Onboarding sets it from the start date with [restWeekdayForStart];
  /// Sunday is only the fallback before onboarding.
  final int restWeekday;

  final bool discreetNotifications;
  final bool voiceOn;
  final bool vibrationOn;
  final bool onboardingDone;
  final bool tutorialDone;
  final bool paywallSeen;

  /// When true, hide the Level unlocked card until the next completed session.
  final bool levelUnlockSnoozed;

  /// Per-goal plan cursors (level + calendar). Keyed by [Goal.storageValue].
  final Map<String, GoalPlanSnapshot> goalPlans;

  /// Fresh install defaults before onboarding.
  factory UserProfile.initial() {
    return const UserProfile(
      goal: null,
      safetyFlags: SafetyFlags(),
      experience: null,
      sessionsPerDay: 1,
      reminderEnabled: false,
      reminderTime: 21 * 60,
      reminderDays: <int>[1, 2, 3, 4, 5, 6, 7],
      track: TrackId.generalBladder,
      level: 1,
      levelStartedOn: null,
      restWeekday: DateTime.sunday,
    );
  }

  UserProfile copyWith({
    Goal? goal,
    SafetyFlags? safetyFlags,
    Experience? experience,
    int? sessionsPerDay,
    bool? reminderEnabled,
    int? reminderTime,
    List<int>? reminderDays,
    TrackId? track,
    int? level,
    DateTime? levelStartedOn,
    DateTime? planStartedOn,
    int? restWeekday,
    bool? discreetNotifications,
    bool? voiceOn,
    bool? vibrationOn,
    bool? onboardingDone,
    bool? tutorialDone,
    bool? paywallSeen,
    bool? levelUnlockSnoozed,
    Map<String, GoalPlanSnapshot>? goalPlans,
    bool clearGoal = false,
    bool clearExperience = false,
    bool clearLevelStartedOn = false,
  }) {
    return UserProfile(
      goal: clearGoal ? null : (goal ?? this.goal),
      safetyFlags: safetyFlags ?? this.safetyFlags,
      experience: clearExperience ? null : (experience ?? this.experience),
      sessionsPerDay: sessionsPerDay ?? this.sessionsPerDay,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      track: track ?? this.track,
      level: level ?? this.level,
      levelStartedOn: clearLevelStartedOn
          ? null
          : (levelStartedOn ?? this.levelStartedOn),
      planStartedOn: planStartedOn ?? this.planStartedOn,
      restWeekday: restWeekday ?? this.restWeekday,
      discreetNotifications:
          discreetNotifications ?? this.discreetNotifications,
      voiceOn: voiceOn ?? this.voiceOn,
      vibrationOn: vibrationOn ?? this.vibrationOn,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      tutorialDone: tutorialDone ?? this.tutorialDone,
      paywallSeen: paywallSeen ?? this.paywallSeen,
      levelUnlockSnoozed: levelUnlockSnoozed ?? this.levelUnlockSnoozed,
      goalPlans: goalPlans ?? this.goalPlans,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'goal': goal?.storageValue,
    'safetyFlags': safetyFlags.toJson(),
    'experience': experience?.storageValue,
    'sessionsPerDay': sessionsPerDay,
    'reminderEnabled': reminderEnabled,
    'reminderTime': reminderTime,
    'reminderDays': reminderDays,
    'track': track.storageValue,
    'level': level,
    'levelStartedOn': levelStartedOn?.toIso8601String(),
    'planStartedOn': planStartedOn?.toIso8601String(),
    'restWeekday': restWeekday,
    'discreetNotifications': discreetNotifications,
    'voiceOn': voiceOn,
    'vibrationOn': vibrationOn,
    'onboardingDone': onboardingDone,
    'tutorialDone': tutorialDone,
    'paywallSeen': paywallSeen,
    'levelUnlockSnoozed': levelUnlockSnoozed,
    'goalPlans': <String, dynamic>{
      for (final MapEntry<String, GoalPlanSnapshot> e in goalPlans.entries)
        e.key: e.value.toJson(),
    },
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final String? goalRaw = json['goal'] as String?;
    final String? experienceRaw = json['experience'] as String?;
    final String? started = json['levelStartedOn'] as String?;
    final DateTime? levelStart = started == null
        ? null
        : DateTime.parse(started);
    int rest = (json['restWeekday'] as int? ?? DateTime.sunday).clamp(1, 7);
    DateTime? planStart;
    if (json.containsKey('planStartedOn')) {
      final String? raw = json['planStartedOn'] as String?;
      planStart = raw == null ? null : DateTime.parse(raw);
    } else if ((json['onboardingDone'] as bool? ?? false) &&
        levelStart != null) {
      // One-time migration: profiles saved before the rest day followed the
      // start date had a fixed Sunday. Best guess for the start date is the
      // current level start (still Level 1 for every tester so far).
      planStart = levelStart;
      rest = restWeekdayForStart(levelStart);
    }
    final Map<String, GoalPlanSnapshot> plans = <String, GoalPlanSnapshot>{};
    final Object? rawPlans = json['goalPlans'];
    if (rawPlans is Map) {
      for (final MapEntry<dynamic, dynamic> e in rawPlans.entries) {
        final Object? value = e.value;
        if (value is Map) {
          plans['${e.key}'] = GoalPlanSnapshot.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      }
    }
    return UserProfile(
      goal: goalRaw == null ? null : GoalX.parse(goalRaw),
      safetyFlags: SafetyFlags.fromJson(
        Map<String, dynamic>.from(json['safetyFlags'] as Map? ?? const {}),
      ),
      experience: experienceRaw == null
          ? null
          : ExperienceX.parse(experienceRaw),
      sessionsPerDay: (json['sessionsPerDay'] as int? ?? 1).clamp(1, 3),
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTime: json['reminderTime'] as int? ?? 21 * 60,
      reminderDays:
          (json['reminderDays'] as List<dynamic>? ??
                  <dynamic>[1, 2, 3, 4, 5, 6, 7])
              .map((dynamic e) => e as int)
              .toList(),
      track: TrackIdX.parse(
        json['track'] as String? ?? TrackId.generalBladder.storageValue,
      ),
      level: json['level'] as int? ?? 1,
      levelStartedOn: levelStart,
      planStartedOn: planStart,
      restWeekday: rest,
      discreetNotifications: json['discreetNotifications'] as bool? ?? true,
      voiceOn: json['voiceOn'] as bool? ?? false,
      vibrationOn: json['vibrationOn'] as bool? ?? true,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      tutorialDone: json['tutorialDone'] as bool? ?? false,
      paywallSeen: json['paywallSeen'] as bool? ?? false,
      levelUnlockSnoozed: json['levelUnlockSnoozed'] as bool? ?? false,
      goalPlans: plans,
    );
  }
}
