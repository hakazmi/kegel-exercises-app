import 'dart:async';
import 'dart:math' as math;

import '../../../core/plan/session_definition.dart';
import '../../../core/time/app_clock.dart';
import 'engine_models.dart';
import 'session_timeline.dart';

/// Pure-Dart session state machine.
///
/// Elapsed time comes from an injected [AppClock] (plus pause bookkeeping),
/// never from counting timer ticks, so the session does not drift under load.
class SessionEngine {
  SessionEngine({
    required SessionDefinition definition,
    required this.clock,
    this.countdownSeconds = 5,
    this.tickInterval = const Duration(milliseconds: 50),
  })  : _definition = definition,
        _segments = SessionTimeline.fromDefinition(
          definition,
          countdownSeconds: countdownSeconds,
        ) {
    _sessionDuration = _segments
        .where((TimelineSegment s) => !s.isCountdown)
        .fold<Duration>(
          Duration.zero,
          (Duration sum, TimelineSegment s) => sum + s.duration,
        );
  }

  /// Injected clock (monotonic session elapsed is derived from this).
  final AppClock clock;
  final SessionDefinition _definition;
  final int countdownSeconds;
  final Duration tickInterval;
  final List<TimelineSegment> _segments;

  late final Duration _sessionDuration;

  final StreamController<EngineState> _states =
      StreamController<EngineState>.broadcast(sync: true);
  final StreamController<EngineEvent> _events =
      StreamController<EngineEvent>.broadcast(sync: true);

  Timer? _timer;
  DateTime? _startedAt;
  Duration _pausedAccumulated = Duration.zero;
  DateTime? _pauseBegan;
  EngineMachineState? _pausedFrom;
  int _activeSegment = -1;
  int _longestHold = 0;

  /// Segment indices the user skipped (their holds never count).
  final Set<int> _skipped = <int>{};
  bool _exited = false;
  bool _completed = false;
  EngineState _state = EngineState.idle;

  Stream<EngineState> get states => _states.stream;
  Stream<EngineEvent> get events => _events.stream;
  EngineState get current => _state;
  SessionDefinition get definition => _definition;

  Duration get _elapsed {
    if (_startedAt == null) {
      return Duration.zero;
    }
    Duration elapsed = clock.now().difference(_startedAt!);
    elapsed -= _pausedAccumulated;
    if (_pauseBegan != null) {
      elapsed -= clock.now().difference(_pauseBegan!);
    }
    if (elapsed.isNegative) {
      return Duration.zero;
    }
    return elapsed;
  }

  /// Starts countdown (or the first block when [countdownSeconds] is 0).
  void start({bool autoTick = true}) {
    if (_state.machine != EngineMachineState.idle &&
        !_completed &&
        !_exited &&
        _state.machine != EngineMachineState.done) {
      return;
    }
    _exited = false;
    _completed = false;
    _longestHold = 0;
    _skipped.clear();
    _activeSegment = -1;
    _pausedAccumulated = Duration.zero;
    _pauseBegan = null;
    _pausedFrom = null;
    _startedAt = clock.now();
    _emitFromElapsed(fireEvents: true);
    if (autoTick) {
      _timer?.cancel();
      _timer = Timer.periodic(tickInterval, (_) => tick());
    }
  }

  /// Recompute state from the clock. Call after advancing a [FakeClock].
  void tick() {
    if (_exited || _completed) {
      return;
    }
    if (_state.machine == EngineMachineState.paused ||
        _state.machine == EngineMachineState.idle) {
      return;
    }
    _emitFromElapsed(fireEvents: true);
  }

  void pause() {
    if (!_state.isActive) {
      return;
    }
    _pausedFrom = _state.machine;
    _pauseBegan = clock.now();
    _setState(
      _state.copyWith(
        machine: EngineMachineState.paused,
        pausedFrom: _pausedFrom,
      ),
    );
  }

  void resume() {
    if (_state.machine != EngineMachineState.paused || _pauseBegan == null) {
      return;
    }
    _pausedAccumulated += clock.now().difference(_pauseBegan!);
    _pauseBegan = null;
    final EngineMachineState restore =
        _pausedFrom ?? EngineMachineState.squeeze;
    _pausedFrom = null;
    _setState(
      _state.copyWith(
        machine: restore,
        clearPausedFrom: true,
      ),
    );
    _emitFromElapsed(fireEvents: false);
  }

  void skipCountdown() {
    if (_state.machine != EngineMachineState.countdown) {
      return;
    }
    Duration countdownEnd = Duration.zero;
    for (final TimelineSegment s in _segments) {
      if (!s.isCountdown) {
        break;
      }
      countdownEnd += s.duration;
    }
    _startedAt = clock.now().subtract(countdownEnd + _pausedAccumulated);
    _emitFromElapsed(fireEvents: true);
  }

  /// Jumps to the start of the next phase (e.g. squeeze → relax → next rep).
  /// On the last phase this finishes the session. In the countdown it is
  /// the same as [skipCountdown].
  void skipPhase() {
    if (_state.machine == EngineMachineState.countdown) {
      skipCountdown();
      return;
    }
    final int current = _currentSegmentIndex();
    if (current < 0) {
      return;
    }
    _jumpToSegment(current + 1, skippedFrom: current);
  }

  /// Jumps to the first phase of the next block (next exercise).
  void skipBlock() {
    if (_state.machine == EngineMachineState.countdown) {
      skipCountdown();
      return;
    }
    final int current = _currentSegmentIndex();
    if (current < 0) {
      return;
    }
    final int block = _segments[current].blockIndex;
    int target = current + 1;
    while (target < _segments.length && _segments[target].blockIndex == block) {
      target++;
    }
    _jumpToSegment(target, skippedFrom: current, skipUntil: target);
  }

  /// Segment the engine is in now (resolved from elapsed time).
  int _currentSegmentIndex() {
    if (_startedAt == null || _completed || _exited || _segments.isEmpty) {
      return -1;
    }
    final Duration elapsed = _elapsed;
    Duration cursor = Duration.zero;
    for (int i = 0; i < _segments.length; i++) {
      cursor += _segments[i].duration;
      if (elapsed < cursor) {
        return i;
      }
    }
    return _segments.length - 1;
  }

  /// Moves the clock origin so elapsed time equals the start of [target].
  ///
  /// Skipped segments from [skippedFrom] up to [skipUntil] (exclusive) are
  /// recorded so a skipped hold never counts toward the longest hold.
  void _jumpToSegment(int target, {required int skippedFrom, int? skipUntil}) {
    if (_state.machine == EngineMachineState.paused) {
      resume();
    }
    for (int i = skippedFrom; i < (skipUntil ?? skippedFrom + 1); i++) {
      _skipped.add(i);
    }
    Duration start = Duration.zero;
    for (int i = 0; i < target && i < _segments.length; i++) {
      start += _segments[i].duration;
    }
    // elapsed = now - startedAt - pausedAccumulated  →  solve for startedAt.
    _startedAt = clock.now().subtract(start + _pausedAccumulated);
    _emitFromElapsed(fireEvents: true);
  }

  /// Leaves the session without marking it complete.
  void exit() {
    _exited = true;
    _timer?.cancel();
    _timer = null;
    _setState(
      _state.copyWith(
        machine: EngineMachineState.done,
        exited: true,
        completed: false,
      ),
    );
  }

  void dispose() {
    _timer?.cancel();
    _states.close();
    _events.close();
  }

  void _emitFromElapsed({required bool fireEvents}) {
    if (_segments.isEmpty) {
      _finish();
      return;
    }

    final Duration elapsed = _elapsed;
    Duration cursor = Duration.zero;

    for (int i = 0; i < _segments.length; i++) {
      final TimelineSegment seg = _segments[i];
      final Duration end = cursor + seg.duration;
      if (elapsed < end) {
        final Duration into = elapsed - cursor;
        if (fireEvents && i != _activeSegment) {
          _enterSegment(i, seg);
        } else {
          _activeSegment = i;
        }
        _emitSegment(seg, into, i);
        return;
      }
      if (seg.prescribedHoldSeconds != null && !_skipped.contains(i)) {
        _longestHold = math.max(_longestHold, seg.prescribedHoldSeconds!);
      }
      cursor = end;
    }
    _finish();
  }

  void _enterSegment(int index, TimelineSegment seg) {
    _activeSegment = index;
    if (seg.startEvent != null && !_events.isClosed) {
      _events.add(seg.startEvent!);
    }
  }

  void _emitSegment(TimelineSegment seg, Duration into, int index) {
    final double progress = seg.duration.inMicroseconds == 0
        ? 1.0
        : (into.inMicroseconds / seg.duration.inMicroseconds).clamp(0.0, 1.0);
    final Duration left = seg.duration - into;
    final int secondsRemaining =
        left.inMilliseconds <= 0 ? 0 : ((left.inMilliseconds + 999) ~/ 1000);

    Duration sessionElapsed = Duration.zero;
    for (int i = 0; i < index; i++) {
      if (!_segments[i].isCountdown) {
        sessionElapsed += _segments[i].duration;
      }
    }
    if (!seg.isCountdown) {
      sessionElapsed += into;
    }
    final double totalProgress = _sessionDuration.inMicroseconds == 0
        ? 1.0
        : (sessionElapsed.inMicroseconds / _sessionDuration.inMicroseconds)
            .clamp(0.0, 1.0);

    String? nextKey;
    for (int i = index + 1; i < _segments.length; i++) {
      if (_segments[i].isCountdown) {
        continue;
      }
      if (_segments[i].blockIndex != seg.blockIndex) {
        nextKey = _segments[i].blockTitleKey;
        break;
      }
    }

    _setState(
      EngineState(
        machine: seg.machine,
        phaseWord: seg.phaseWordAt(into),
        phaseProgress: progress,
        rep: seg.rep,
        totalReps: seg.totalReps,
        blockIndex: seg.blockIndex < 0 ? 0 : seg.blockIndex,
        blockTitleKey: seg.blockTitleKey,
        nextBlockTitleKey: nextKey,
        secondsRemaining: secondsRemaining,
        totalProgress: totalProgress,
        elapsedSeconds: sessionElapsed.inSeconds,
        totalDurationSeconds: _sessionDuration.inSeconds,
        longestHoldSeconds: _longestHold,
      ),
    );
  }

  void _finish() {
    if (_completed || _exited) {
      return;
    }
    _completed = true;
    _timer?.cancel();
    _timer = null;
    if (!_events.isClosed) {
      _events.add(EngineEvent.done);
    }
    _setState(
      EngineState(
        machine: EngineMachineState.done,
        phaseWord: SessionPhaseKey.done,
        phaseProgress: 1,
        blockIndex: _definition.blocks.isEmpty
            ? 0
            : _definition.blocks.length - 1,
        blockTitleKey: _definition.blocks.isEmpty
            ? ''
            : _definition.blocks.last.titleKey,
        secondsRemaining: 0,
        totalProgress: 1,
        elapsedSeconds: _sessionDuration.inSeconds,
        totalDurationSeconds: _sessionDuration.inSeconds,
        completed: true,
        longestHoldSeconds: _longestHold,
      ),
    );
  }

  void _setState(EngineState next) {
    _state = next;
    if (!_states.isClosed) {
      _states.add(next);
    }
  }
}
