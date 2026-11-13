import '../../../core/content/content_models.dart';
import '../../../core/domain/enums.dart';
import '../../../core/plan/plan_models.dart';
import '../../../core/plan/session_definition.dart';
import 'engine_models.dart';

/// Builds a flat [TimelineSegment] list from a [SessionDefinition].
abstract final class SessionTimeline {
  static const Duration inhale = Duration(seconds: 4);
  static const Duration exhale = Duration(seconds: 6);

  static List<TimelineSegment> fromDefinition(
    SessionDefinition definition, {
    int countdownSeconds = 5,
  }) {
    final List<TimelineSegment> out = <TimelineSegment>[];
    if (countdownSeconds > 0) {
      out.add(
        TimelineSegment(
          machine: EngineMachineState.countdown,
          duration: Duration(seconds: countdownSeconds),
          blockIndex: -1,
          blockTitleKey: '',
          phaseWordAtStart: 'Get ready',
          isCountdown: true,
        ),
      );
    }

    for (int b = 0; b < definition.blocks.length; b++) {
      final SessionBlockDef block = definition.blocks[b];
      out.addAll(_blockSegments(block, b));
    }
    return out;
  }

  static List<TimelineSegment> _blockSegments(SessionBlockDef block, int index) {
    switch (block.type) {
      case 'hold':
      case 'slow_hold':
        return _repCycles(
          block: block,
          index: index,
          squeezeIsHold: true,
        );
      case 'quick':
      case 'quick_squeeze':
        return _repCycles(
          block: block,
          index: index,
          squeezeIsHold: false,
        );
      case 'rest':
        return <TimelineSegment>[
          TimelineSegment(
            machine: EngineMachineState.rest,
            duration: Duration(seconds: block.sec ?? 0),
            blockIndex: index,
            blockTitleKey: block.titleKey,
            phaseWordAtStart: 'Rest',
            startEvent: EngineEvent.restStarted,
          ),
        ];
      case 'breathing':
        return _breathing(block, index);
      case 'stretch':
      case 'reverse_kegel':
        return <TimelineSegment>[
          TimelineSegment(
            machine: EngineMachineState.relax,
            duration: Duration(seconds: block.sec ?? block.durationSeconds),
            blockIndex: index,
            blockTitleKey: block.titleKey,
            phaseWordAtStart: 'Relax',
            startEvent: EngineEvent.relaxStarted,
          ),
        ];
      default:
        return const <TimelineSegment>[];
    }
  }

  static List<TimelineSegment> _repCycles({
    required SessionBlockDef block,
    required int index,
    required bool squeezeIsHold,
  }) {
    final int reps = block.reps ?? 0;
    final int squeezeSec = block.squeezeSec ?? 0;
    final int relaxSec = block.relaxSec ?? 0;
    final List<TimelineSegment> out = <TimelineSegment>[];
    for (int r = 1; r <= reps; r++) {
      out.add(
        TimelineSegment(
          machine: EngineMachineState.squeeze,
          duration: Duration(seconds: squeezeSec),
          blockIndex: index,
          blockTitleKey: block.titleKey,
          phaseWordAtStart: 'Squeeze',
          holdAfterFirstSecond: squeezeIsHold && squeezeSec > 1,
          rep: r,
          totalReps: reps,
          startEvent: EngineEvent.squeezeStarted,
          prescribedHoldSeconds: squeezeIsHold ? squeezeSec : null,
        ),
      );
      if (relaxSec > 0) {
        out.add(
          TimelineSegment(
            machine: EngineMachineState.relax,
            duration: Duration(seconds: relaxSec),
            blockIndex: index,
            blockTitleKey: block.titleKey,
            phaseWordAtStart: 'Relax',
            rep: r,
            totalReps: reps,
            startEvent: EngineEvent.relaxStarted,
          ),
        );
      }
    }
    return out;
  }

  static List<TimelineSegment> _breathing(SessionBlockDef block, int index) {
    final int total = block.sec ?? 0;
    final List<TimelineSegment> out = <TimelineSegment>[];
    int remaining = total;
    while (remaining > 0) {
      final int inSec =
          remaining >= inhale.inSeconds ? inhale.inSeconds : remaining;
      out.add(
        TimelineSegment(
          machine: EngineMachineState.squeeze,
          duration: Duration(seconds: inSec),
          blockIndex: index,
          blockTitleKey: block.titleKey,
          phaseWordAtStart: 'Breathe in',
          startEvent: EngineEvent.squeezeStarted,
        ),
      );
      remaining -= inSec;
      if (remaining <= 0) {
        break;
      }
      final int outSec =
          remaining >= exhale.inSeconds ? exhale.inSeconds : remaining;
      out.add(
        TimelineSegment(
          machine: EngineMachineState.relax,
          duration: Duration(seconds: outSec),
          blockIndex: index,
          blockTitleKey: block.titleKey,
          phaseWordAtStart: 'Breathe out',
          startEvent: EngineEvent.relaxStarted,
        ),
      );
      remaining -= outSec;
    }
    return out;
  }
}

/// Builds a [SessionDefinition] from levels.json + track, or from JSON maps.
abstract final class SessionDefinitionFactory {
  /// Level strengthening session from [levels.json] content.
  static SessionDefinition fromLevel({
    required LevelContent level,
    required TrackId track,
    String? id,
    int sessionNumber = 1,
    int sessionsToday = 1,
  }) {
    // Track-specific block extras land with later content prompts.
    final SessionDefinition base = SessionDefinitionBuilder.fromLevelAndItem(
      level: level,
      item: TodayItem(
        id: 'strength_$sessionNumber',
        kind: SessionKind.strengthening,
        label: 'Session $sessionNumber',
        durationSeconds:
            SessionDefinitionBuilder.strengtheningDurationForLevel(level),
        done: false,
        sessionNumber: sessionNumber,
      ),
      sessionsToday: sessionsToday,
    );
    return base.copyWith(id: id ?? 'L${level.id}_standard');
  }

  /// Parses a JSON session map (spec §7 shape / prompt block types).
  static SessionDefinition fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawBlocks =
        json['blocks'] as List<dynamic>? ?? const <dynamic>[];
    final List<SessionBlockDef> blocks = <SessionBlockDef>[];
    for (final dynamic raw in rawBlocks) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(raw as Map);
      final String type = m['type'] as String;
      switch (type) {
        case 'hold':
        case 'slow_hold':
          blocks.add(
            SessionBlockDef(
              type: 'hold',
              titleKey: 'slowHolds',
              reps: (m['reps'] as num?)?.toInt(),
              squeezeSec: (m['squeezeSec'] as num?)?.toInt() ??
                  (m['holdSeconds'] as num?)?.toInt() ??
                  (m['holdSec'] as num?)?.toInt(),
              relaxSec: (m['relaxSec'] as num?)?.toInt() ??
                  (m['relaxSeconds'] as num?)?.toInt(),
              thumbnailAsset: 'assets/images/lying.svg',
            ),
          );
        case 'quick':
        case 'quick_squeeze':
          blocks.add(
            SessionBlockDef(
              type: 'quick',
              titleKey: 'quickSqueezes',
              reps: (m['reps'] as num?)?.toInt(),
              squeezeSec: (m['squeezeSec'] as num?)?.toInt() ??
                  (m['squeezeSeconds'] as num?)?.toInt(),
              relaxSec: (m['relaxSec'] as num?)?.toInt() ??
                  (m['relaxSeconds'] as num?)?.toInt(),
              thumbnailAsset: 'assets/images/bridge.svg',
            ),
          );
        case 'rest':
          blocks.add(
            SessionBlockDef(
              type: 'rest',
              titleKey: 'rest',
              sec: (m['sec'] as num?)?.toInt() ??
                  (m['seconds'] as num?)?.toInt(),
              thumbnailAsset: 'assets/images/stopwatch.svg',
            ),
          );
        case 'breathing':
          blocks.add(
            SessionBlockDef(
              type: 'breathing',
              titleKey: 'breathing',
              sec: (m['sec'] as num?)?.toInt() ??
                  (m['seconds'] as num?)?.toInt(),
              thumbnailAsset: 'assets/images/child.svg',
            ),
          );
        case 'stretch':
          blocks.add(
            SessionBlockDef(
              type: 'stretch',
              titleKey: 'stretch',
              sec: (m['sec'] as num?)?.toInt() ??
                  (m['seconds'] as num?)?.toInt(),
              thumbnailAsset: 'assets/images/child.svg',
            ),
          );
        default:
          break;
      }
    }
    return SessionDefinition(
      id: json['id'] as String? ?? 'session',
      level: (json['level'] as num?)?.toInt() ?? 1,
      position: json['position'] as String? ?? 'lying_or_sitting',
      blocks: blocks,
      kind: SessionKind.strengthening,
      label: json['label'] as String? ?? 'Session',
    );
  }
}
