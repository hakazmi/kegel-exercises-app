import '../../core/domain/enums.dart';
import '../../core/domain/safety_flags.dart';

/// In-progress answers for O1–O6 before the profile is saved.
class OnboardingDraft {
  const OnboardingDraft({
    this.acceptedAge = false,
    this.goal,
    this.pain = false,
    this.painSexual = false,
    this.recentSurgery = false,
    this.catheter = false,
    this.noneOfThese = false,
    this.surgeryConfirmed = false,
    this.experience,
    this.sessionsPerDay = 2,
    this.reminderEnabled = false,
    this.reminderTime = 21 * 60,
    this.reminderDays = const <int>[1, 2, 3, 4, 5, 6, 7],
  });

  final bool acceptedAge;
  final Goal? goal;
  final bool pain;
  final bool painSexual;
  final bool recentSurgery;
  final bool catheter;
  final bool noneOfThese;
  final bool surgeryConfirmed;
  final Experience? experience;
  final int sessionsPerDay;
  final bool reminderEnabled;
  final int reminderTime;
  final List<int> reminderDays;

  SafetyFlags get safetyFlags => SafetyFlags(
        pain: pain,
        painSexual: painSexual,
        recentSurgery: recentSurgery,
        catheter: catheter,
      );

  bool get hasPain => pain || painSexual;

  bool get safetySelectionValid =>
      noneOfThese || pain || painSexual || recentSurgery || catheter;

  TrackId resolveTrack() {
    if (hasPain) {
      return TrackId.relaxationFirst;
    }
    if (goal == null) {
      return TrackId.generalBladder;
    }
    return trackForGoal(goal!);
  }

  OnboardingDraft copyWith({
    bool? acceptedAge,
    Goal? goal,
    bool? pain,
    bool? painSexual,
    bool? recentSurgery,
    bool? catheter,
    bool? noneOfThese,
    bool? surgeryConfirmed,
    Experience? experience,
    int? sessionsPerDay,
    bool? reminderEnabled,
    int? reminderTime,
    List<int>? reminderDays,
    bool clearGoal = false,
    bool clearExperience = false,
  }) {
    return OnboardingDraft(
      acceptedAge: acceptedAge ?? this.acceptedAge,
      goal: clearGoal ? null : (goal ?? this.goal),
      pain: pain ?? this.pain,
      painSexual: painSexual ?? this.painSexual,
      recentSurgery: recentSurgery ?? this.recentSurgery,
      catheter: catheter ?? this.catheter,
      noneOfThese: noneOfThese ?? this.noneOfThese,
      surgeryConfirmed: surgeryConfirmed ?? this.surgeryConfirmed,
      experience: clearExperience ? null : (experience ?? this.experience),
      sessionsPerDay: sessionsPerDay ?? this.sessionsPerDay,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }
}
