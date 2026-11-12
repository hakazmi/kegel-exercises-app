import '../domain/enums.dart';

/// One item on today's list (strengthening slot or breathing).
class TodayItem {
  const TodayItem({
    required this.id,
    required this.kind,
    required this.label,
    required this.durationSeconds,
    required this.done,
    this.optional = false,
    this.sessionNumber,
  });

  final String id;
  final SessionKind kind;
  final String label;
  final int durationSeconds;
  final bool done;
  final bool optional;

  /// 1-based strengthening slot when [kind] is strengthening.
  final int? sessionNumber;
}

/// Result of [PlanService.todayPlan].
class TodayPlan {
  const TodayPlan({
    required this.state,
    required this.items,
    required this.dayInLevel,
    required this.level,
    required this.track,
  });

  final TodayPlanState state;
  final List<TodayItem> items;
  final int dayInLevel;
  final int level;
  final TrackId track;
}

/// Estimated session length for a level's standard strengthening block.
int estimateStrengtheningSeconds({
  required int slowReps,
  required int holdSec,
  required int relaxSec,
  required int quickReps,
  int quickSqueezeSec = 1,
  int quickRelaxSec = 2,
  int restSec = 10,
}) {
  final int holds = slowReps * (holdSec + relaxSec);
  final int quick = quickReps * (quickSqueezeSec + quickRelaxSec);
  return holds + restSec + quick;
}
