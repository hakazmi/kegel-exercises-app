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
    this.exerciseId,
    this.phaseCue,
  });

  /// hold | rest | quick | breathing | reverse_kegel | stretch | movement
  final String type;
  final String titleKey;
  final int? reps;
  final int? squeezeSec;
  final int? relaxSec;
  final int? sec;

  /// Illustration for S1 row; rest uses stopwatch.
  final String? thumbnailAsset;

  /// Content exercise id when [type] is movement / stretch.
  final String? exerciseId;

  /// Optional override for the squeeze-phase word (e.g. Lift, Squeeze).
  final String? phaseCue;

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

  int get durationSeconds => blocks.fold<int>(
    0,
    (int sum, SessionBlockDef b) => sum + b.durationSeconds,
  );

  int get partCount => blocks.length;

  SessionDefinition copyWith({
    String? id,
    int? level,
    String? position,
    List<SessionBlockDef>? blocks,
    SessionKind? kind,
    String? label,
    int? sessionNumber,
    int? sessionsToday,
  }) {
    return SessionDefinition(
      id: id ?? this.id,
      level: level ?? this.level,
      position: position ?? this.position,
      blocks: blocks ?? this.blocks,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      sessionsToday: sessionsToday ?? this.sessionsToday,
    );
  }
}

/// Builds [SessionDefinition]s from content JSON + today's plan item.
abstract final class SessionDefinitionBuilder {
  static const int restSec = 10;

  static SessionDefinition fromLevelAndItem({
    required LevelContent level,
    required TodayItem item,
    required int sessionsToday,
    TrackContent? track,
    Map<String, ExerciseContent>? exercisesById,
  }) {
    switch (item.kind) {
      case SessionKind.strengthening:
        return _strengthening(
          level,
          item,
          sessionsToday,
          track: track,
          exercisesById: exercisesById,
        );
      case SessionKind.body:
        return _fromExerciseList(
          level: level,
          item: item,
          sessionsToday: sessionsToday,
          kind: SessionKind.body,
          exerciseIds: item.exerciseIds,
          exercisesById: exercisesById ?? const <String, ExerciseContent>{},
        );
      case SessionKind.breathing:
      case SessionKind.relaxation:
        if (item.exerciseIds.isNotEmpty) {
          return _fromExerciseList(
            level: level,
            item: item,
            sessionsToday: sessionsToday,
            kind: item.kind,
            exerciseIds: item.exerciseIds,
            exercisesById: exercisesById ?? const <String, ExerciseContent>{},
          );
        }
        if (item.kind == SessionKind.breathing) {
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
                exerciseId: 'diaphragmatic_breathing',
              ),
            ],
          );
        }
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
              exerciseId: 'reverse_kegel',
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
        label: '',
        durationSeconds: estimateStrengtheningSeconds(
          slowReps: level.slowHolds['reps'] as int? ?? 5,
          holdSec:
              level.slowHolds['holdSec'] as int? ??
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
    int sessionsToday, {
    TrackContent? track,
    Map<String, ExerciseContent>? exercisesById,
  }) {
    int slowReps = level.slowHolds['reps'] as int? ?? 5;
    int holdSec =
        level.slowHolds['holdSec'] as int? ??
        level.slowHolds['holdSecMin'] as int? ??
        3;
    int relaxSec = level.slowHolds['relaxSec'] as int? ?? 3;
    if (track?.gentlerHolds == true && track?.gentleHold != null) {
      final Map<String, dynamic> g = track!.gentleHold!;
      final int? maxHold = g['holdSecMax'] as int?;
      final int? gRelax = g['relaxSec'] as int?;
      final int? maxReps = g['repsMax'] as int?;
      if (maxHold != null && holdSec > maxHold) {
        holdSec = maxHold;
      }
      if (gRelax != null) {
        relaxSec = gRelax;
      }
      if (maxReps != null && slowReps > maxReps) {
        slowReps = maxReps;
      }
    }
    final int quickReps = level.quickSqueezes['reps'] as int? ?? 5;
    final int quickSqueeze = level.quickSqueezes['squeezeSec'] as int? ?? 1;
    final int quickRelax = level.quickSqueezes['relaxSec'] as int? ?? 2;

    final List<SessionBlockDef> blocks = <SessionBlockDef>[
      SessionBlockDef(
        type: 'hold',
        titleKey: 'slowHolds',
        reps: slowReps,
        squeezeSec: holdSec,
        relaxSec: relaxSec,
        thumbnailAsset: 'assets/images/lying.svg',
        exerciseId: 'slow_hold',
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
        exerciseId: 'quick_squeeze',
      ),
    ];

    final String trackId = track?.id ?? '';
    final List<String> extras = level.kegelExtrasForTrack(trackId);
    for (final String exerciseId in extras) {
      final ExerciseContent? ex = exercisesById?[exerciseId];
      if (ex == null) {
        continue;
      }
      blocks.add(movementBlockFromExercise(ex));
    }

    return SessionDefinition(
      id: item.id,
      level: level.id,
      position: level.position,
      kind: SessionKind.strengthening,
      label: item.label,
      sessionNumber: item.sessionNumber,
      sessionsToday: sessionsToday,
      blocks: blocks,
    );
  }

  static SessionDefinition _fromExerciseList({
    required LevelContent level,
    required TodayItem item,
    required int sessionsToday,
    required SessionKind kind,
    required List<String> exerciseIds,
    required Map<String, ExerciseContent> exercisesById,
  }) {
    final List<SessionBlockDef> blocks = <SessionBlockDef>[];
    for (final String id in exerciseIds) {
      final ExerciseContent? ex = exercisesById[id];
      if (ex == null) {
        continue;
      }
      blocks.add(blockFromExercise(ex, level: level));
    }
    if (blocks.isEmpty) {
      blocks.add(
        SessionBlockDef(
          type: 'breathing',
          titleKey: 'breathing',
          sec: level.dailyBreathingSec,
          thumbnailAsset: 'assets/images/child.svg',
          exerciseId: 'diaphragmatic_breathing',
        ),
      );
    }
    return SessionDefinition(
      id: item.id,
      level: level.id,
      position: level.position,
      kind: kind,
      label: item.label,
      sessionsToday: sessionsToday,
      blocks: blocks,
    );
  }

  /// Maps a content exercise to a timed block.
  static SessionBlockDef blockFromExercise(
    ExerciseContent ex, {
    required LevelContent level,
  }) {
    switch (ex.id) {
      case 'diaphragmatic_breathing':
        return SessionBlockDef(
          type: 'breathing',
          titleKey: 'breathing',
          sec: ex.holdSec > 0 ? ex.holdSec : level.dailyBreathingSec,
          thumbnailAsset: ex.illustration ?? 'assets/images/child.svg',
          exerciseId: ex.id,
        );
      case 'reverse_kegel':
        return SessionBlockDef(
          type: 'reverse_kegel',
          titleKey: 'reverseKegel',
          sec: ex.holdSec > 0 ? ex.holdSec : 120,
          thumbnailAsset: ex.illustration ?? 'assets/images/child.svg',
          exerciseId: ex.id,
        );
      case 'childs_pose':
      case 'happy_baby':
      case 'supported_back_release':
        return SessionBlockDef(
          type: 'stretch',
          titleKey: ex.id,
          sec: ex.holdSec > 0 ? ex.holdSec : 90,
          thumbnailAsset: ex.illustration ?? 'assets/images/child.svg',
          exerciseId: ex.id,
        );
      case 'strong_hold':
        return SessionBlockDef(
          type: 'hold',
          titleKey: ex.id,
          reps: ex.defaultReps,
          squeezeSec: ex.holdSec > 0 ? ex.holdSec : 8,
          relaxSec: ex.holdSec > 0 ? ex.holdSec : 8,
          thumbnailAsset: ex.illustration ?? 'assets/images/lying.svg',
          exerciseId: ex.id,
        );
      default:
        return movementBlockFromExercise(ex);
    }
  }

  static SessionBlockDef movementBlockFromExercise(ExerciseContent ex) {
    final int hold = ex.holdSec > 0 ? ex.holdSec : 3;
    final int relax = hold.clamp(2, 10);
    return SessionBlockDef(
      type: 'movement',
      titleKey: ex.id,
      reps: ex.defaultReps,
      squeezeSec: hold > 0 ? hold : 3,
      relaxSec: relax,
      thumbnailAsset: ex.illustration ?? 'assets/images/standing.svg',
      exerciseId: ex.id,
      phaseCue: _phaseCueFor(ex.id),
    );
  }

  /// Phase cue keys (`lift` / `squeeze` / `hold`) for movement blocks.
  static String? _phaseCueFor(String exerciseId) {
    switch (exerciseId) {
      case 'bridge_with_hold':
        return 'lift';
      case 'squat_with_coordination':
        return 'squeeze';
      case 'sit_to_stand_squeeze':
        return 'squeeze';
      case 'the_knack':
        return 'squeeze';
      case 'pillow_squeeze_lift':
        return 'squeeze';
      case 'standing_walking_holds':
        return 'hold';
      default:
        return null;
    }
  }

  /// Estimated duration for a body card from exercise ids.
  static int estimateBodyDuration(
    List<String> exerciseIds,
    Map<String, ExerciseContent> byId,
  ) {
    int total = 0;
    for (final String id in exerciseIds) {
      final ExerciseContent? ex = byId[id];
      if (ex == null) {
        continue;
      }
      total += movementBlockFromExercise(ex).durationSeconds;
    }
    return total.clamp(60, 600);
  }

  /// Estimated duration for a breathe card.
  static int estimateBreatheDuration(
    List<String> exerciseIds,
    Map<String, ExerciseContent> byId,
    int fallbackBreathingSec,
  ) {
    if (exerciseIds.isEmpty) {
      return fallbackBreathingSec;
    }
    int total = 0;
    for (final String id in exerciseIds) {
      final ExerciseContent? ex = byId[id];
      if (ex == null) {
        continue;
      }
      if (ex.id == 'diaphragmatic_breathing') {
        total += ex.holdSec > 0 ? ex.holdSec : fallbackBreathingSec;
      } else if (ex.holdSec > 0) {
        total += ex.holdSec;
      } else {
        total += movementBlockFromExercise(ex).durationSeconds;
      }
    }
    return total.clamp(60, 900);
  }

  /// Duration helper used by PlanService defaults.
  static int strengtheningDurationForLevel(LevelContent level) {
    return estimateStrengtheningSeconds(
      slowReps: level.slowHolds['reps'] as int? ?? 5,
      holdSec:
          level.slowHolds['holdSec'] as int? ??
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
