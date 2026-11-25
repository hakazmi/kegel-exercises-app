import 'enums.dart';
import 'user_profile.dart';

/// Saved plan cursor for one [Goal], so switching goals can resume later.
///
/// Sessions stay in Drift tagged by [track]; this only stores level and
/// calendar fields. Never stores [TrackId.relaxationFirst] (pain lock).
class GoalPlanSnapshot {
  const GoalPlanSnapshot({
    required this.track,
    required this.level,
    required this.restWeekday,
    this.levelStartedOn,
    this.planStartedOn,
    this.levelUnlockSnoozed = false,
  });

  final TrackId track;
  final int level;
  final DateTime? levelStartedOn;
  final DateTime? planStartedOn;
  final int restWeekday;
  final bool levelUnlockSnoozed;

  /// Captures the live plan fields from [profile] for its current goal.
  factory GoalPlanSnapshot.fromProfile(UserProfile profile) {
    return GoalPlanSnapshot(
      track: profile.track,
      level: profile.level,
      levelStartedOn: profile.levelStartedOn,
      planStartedOn: profile.planStartedOn,
      restWeekday: profile.restWeekday,
      levelUnlockSnoozed: profile.levelUnlockSnoozed,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'track': track.storageValue,
    'level': level,
    'levelStartedOn': levelStartedOn?.toIso8601String(),
    'planStartedOn': planStartedOn?.toIso8601String(),
    'restWeekday': restWeekday,
    'levelUnlockSnoozed': levelUnlockSnoozed,
  };

  factory GoalPlanSnapshot.fromJson(Map<String, dynamic> json) {
    final String? levelStarted = json['levelStartedOn'] as String?;
    final String? planStarted = json['planStartedOn'] as String?;
    return GoalPlanSnapshot(
      track: TrackIdX.parse(
        json['track'] as String? ?? TrackId.generalBladder.storageValue,
      ),
      level: (json['level'] as num?)?.toInt() ?? 1,
      levelStartedOn: levelStarted == null ? null : DateTime.parse(levelStarted),
      planStartedOn: planStarted == null ? null : DateTime.parse(planStarted),
      restWeekday: ((json['restWeekday'] as num?)?.toInt() ?? DateTime.sunday)
          .clamp(1, 7),
      levelUnlockSnoozed: json['levelUnlockSnoozed'] as bool? ?? false,
    );
  }
}
