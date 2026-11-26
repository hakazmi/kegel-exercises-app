import '../domain/enums.dart';

/// One timed item on today's list (Kegel, body, breathing, or relaxation).
class TodayItem {
  const TodayItem({
    required this.id,
    required this.kind,
    required this.label,
    required this.durationSeconds,
    required this.done,
    this.optional = false,
    this.sessionNumber,
    this.locked = false,
    this.exerciseIds = const <String>[],
  });

  final String id;
  final SessionKind kind;
  final String label;
  final int durationSeconds;
  final bool done;
  final bool optional;

  /// 1-based strengthening slot when [kind] is strengthening.
  final int? sessionNumber;

  /// Premium lock (body card for free users at Level 2+).
  final bool locked;

  /// Exercise ids that compose this session (body / breathe cards).
  final List<String> exerciseIds;
}

/// Tick-only habit row (never opens the player).
class TodayHabitItem {
  const TodayHabitItem({
    required this.id,
    required this.exerciseId,
    required this.label,
    required this.done,
  });

  final String id;
  final String exerciseId;
  final String label;
  final bool done;
}

/// Result of [PlanService.todayPlan].
class TodayPlan {
  const TodayPlan({
    required this.state,
    required this.items,
    required this.dayInLevel,
    required this.level,
    required this.track,
    this.habits = const <TodayHabitItem>[],
    this.highlightDayInLevel,
    this.highlightIsTomorrow = false,
  });

  final TodayPlanState state;
  final List<TodayItem> items;

  /// Plan day used for today’s items and session stamps ([PlanRules.activePlanDay]).
  final int dayInLevel;
  final int level;
  final TrackId track;
  final List<TodayHabitItem> habits;

  /// Day shown on the Today hero. When [highlightIsTomorrow] is true this is
  /// the next plan day after a finished day, so the figure and “Day N of T”
  /// preview tomorrow without opening that day’s sessions yet.
  final int? highlightDayInLevel;

  /// True when the hero is previewing the next plan day as tomorrow.
  final bool highlightIsTomorrow;

  /// Day number for the level card figure and progress line.
  int get displayDayInLevel => highlightDayInLevel ?? dayInLevel;

  /// Timed items that can open S1 (excludes locked body).
  List<TodayItem> get playableItems =>
      items.where((TodayItem i) => !i.locked).toList();
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
