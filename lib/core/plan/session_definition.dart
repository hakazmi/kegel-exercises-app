import '../content/content_models.dart';
import '../domain/enums.dart';
import 'plan_models.dart';
import 'plan_rules.dart';

/// One timed block inside a [SessionDefinition].
class SessionBlockDef {
  const SessionBlockDef({
    required this.type,
    required this.titleKey,
    this.reps,
    this.squeezeSec,
    this.relaxSec,
    this.sec,
    this.thumbnailAsset,
  });

  /// hold | rest | quick | breathing | reverse_kegel | stretch
  final String type;
  final String titleKey;
  final int? reps;
  final int? squeezeSec;
  final int? relaxSec;
  final int? sec;

  /// Illustration for S1 row; rest uses stopwatch.
  final String? thumbnailAsset;

  bool get isRest => type == 'rest';

  int get durationSeconds {
    if (sec != null) {
      return sec!;
    }
    if (reps != null && squeezeSec != null && relaxSec != null) {
      return reps! * (squeezeSec! + relaxSec!);
    }
    return 0;
  }
}

/// Playable session built from level content and a [TodayItem].
class SessionDefinition {
  const SessionDefinition({
    required this.id,
    required this.level,
    required this.position,
    required this.blocks,
    required this.kind,
    required this.label,
    this.sessionNumber,
    this.sessionsToday = 1,
  });

  final String id;
  final int level;
  final String position;
  final List<SessionBlockDef> blocks;
  final SessionKind kind;
  final String label;
  final int? sessionNumber;
  final int sessionsToday;

  int get durationSeconds =>
      blocks.fold<int>(0, (int sum, SessionBlockDef b) => sum + b.durationSeconds);

  int get partCount => blocks.length;
}

/// Builds [SessionDefinition]s from content JSON + today's plan item.
abstract final class SessionDefinitionBuilder {
  static const int restSec = 10;

  static SessionDefinition fromLevelAndItem({
    required LevelContent level,
    required TodayItem item,
    required int sessionsToday,
  }) {
    switch (item.kind) {
      case SessionKind.strengthening:
        return _strengthening(level, item, sessionsToday);
      case SessionKind.breathing:
        return SessionDefinition(
          id: item.id,
          level: level.id,
          position: level.position,
          kind: SessionKind.breathing,
          label: item.label,
          sessionsToday: sessionsToday,
          blocks: <SessionBlockDef>[
            SessionBlockDef(
              type: 'breathing',
              titleKey: 'breathing',
              sec: level.dailyBreathingSec,
              thumbnailAsset: 'assets/images/child.svg',
            ),
          ],
        );
      case SessionKind.relaxation:
        return SessionDefinition(
          id: item.id,
          level: level.id,
          position: level.position,
          kind: SessionKind.relaxation,
          label: item.label,
          sessionsToday: sessionsToday,
          blocks: <SessionBlockDef>[
            SessionBlockDef(
              type: 'reverse_kegel',
              titleKey: 'reverseKegel',
              sec: item.durationSeconds > 0 ? item.durationSeconds : 120,
              thumbnailAsset: 'assets/images/child.svg',
            ),
          ],
        );
    }
  }

  /// Level 1 default when no plan item is available yet.
  static SessionDefinition level1Standard({
    required LevelContent level,
    int sessionNumber = 1,
    int sessionsToday = 2,
  }) {
    return fromLevelAndItem(
      level: level,
      item: TodayItem(
        id: 'strength_$sessionNumber',
        kind: SessionKind.strengthening,
        label: 'Session $sessionNumber',
        durationSeconds: estimateStrengtheningSeconds(
          slowReps: level.slowHolds['reps'] as int? ?? 5,
          holdSec: level.slowHolds['holdSec'] as int? ??
              level.slowHolds['holdSecMin'] as int? ??
              3,
          relaxSec: level.slowHolds['relaxSec'] as int? ?? 3,
          quickReps: level.quickSqueezes['reps'] as int? ?? 5,
          quickSqueezeSec: level.quickSqueezes['squeezeSec'] as int? ?? 1,
          quickRelaxSec: level.quickSqueezes['relaxSec'] as int? ?? 2,
          restSec: restSec,
        ),
        done: false,
        sessionNumber: sessionNumber,
      ),
      sessionsToday: sessionsToday,
    );
  }

  static SessionDefinition _strengthening(
    LevelContent level,
    TodayItem item,
    int sessionsToday,
  ) {
    final int slowReps = level.slowHolds['reps'] as int? ?? 5;
    final int holdSec = level.slowHolds['holdSec'] as int? ??
        level.slowHolds['holdSecMin'] as int? ??
        3;
    final int relaxSec = level.slowHolds['relaxSec'] as int? ?? 3;
    final int quickReps = level.quickSqueezes['reps'] as int? ?? 5;
    final int quickSqueeze = level.quickSqueezes['squeezeSec'] as int? ?? 1;
    final int quickRelax = level.quickSqueezes['relaxSec'] as int? ?? 2;

    return SessionDefinition(
      id: item.id,
      level: level.id,
      position: level.position,
      kind: SessionKind.strengthening,
      label: item.label,
      sessionNumber: item.sessionNumber,
      sessionsToday: sessionsToday,
      blocks: <SessionBlockDef>[
        SessionBlockDef(
          type: 'hold',
          titleKey: 'slowHolds',
          reps: slowReps,
          squeezeSec: holdSec,
          relaxSec: relaxSec,
          thumbnailAsset: 'assets/images/lying.svg',
        ),
        const SessionBlockDef(
          type: 'rest',
          titleKey: 'rest',
          sec: restSec,
          thumbnailAsset: 'assets/images/stopwatch.svg',
        ),
        SessionBlockDef(
          type: 'quick',
          titleKey: 'quickSqueezes',
          reps: quickReps,
          squeezeSec: quickSqueeze,
          relaxSec: quickRelax,
          thumbnailAsset: 'assets/images/bridge.svg',
        ),
      ],
    );
  }

  /// Duration helper used by PlanService defaults.
  static int strengtheningDurationForLevel(LevelContent level) {
    return estimateStrengtheningSeconds(
      slowReps: level.slowHolds['reps'] as int? ?? 5,
      holdSec: level.slowHolds['holdSec'] as int? ??
          level.slowHolds['holdSecMin'] as int? ??
          3,
      relaxSec: level.slowHolds['relaxSec'] as int? ?? 3,
      quickReps: level.quickSqueezes['reps'] as int? ?? 5,
      quickSqueezeSec: level.quickSqueezes['squeezeSec'] as int? ?? 1,
      quickRelaxSec: level.quickSqueezes['relaxSec'] as int? ?? 2,
      restSec: restSec,
    );
  }
}

/// Maps a content position id to a short copy key.
String positionCopyKey(String position) {
  switch (position) {
    case 'lying_or_sitting':
      return 'lyingOrSitting';
    case 'sitting':
      return 'sitting';
    case 'sitting_and_standing':
      return 'sittingAndStanding';
    case 'standing':
      return 'standing';
    case 'any':
      return 'any';
    default:
      return 'lyingOrSitting';
  }
}

/// Expose rest constant for tests without importing builder guts twice.
int get sessionRestSeconds => SessionDefinitionBuilder.restSec;

/// PlanRules breathing duration alias for session defs.
int get sessionBreathingSeconds => PlanRules.breathingDurationSeconds;
