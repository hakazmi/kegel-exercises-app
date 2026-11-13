/// Machine states for the session player (pure Dart).
enum EngineMachineState {
  idle,
  countdown,
  squeeze,
  relax,
  rest,
  paused,
  done,
}

/// One-off cues for haptics and voice.
enum EngineEvent {
  squeezeStarted,
  relaxStarted,
  restStarted,
  done,
}

/// Immutable snapshot emitted by [SessionEngine].
class EngineState {
  const EngineState({
    required this.machine,
    required this.phaseWord,
    required this.phaseProgress,
    required this.blockIndex,
    required this.secondsRemaining,
    required this.totalProgress,
    required this.elapsedSeconds,
    required this.totalDurationSeconds,
    this.rep,
    this.totalReps,
    this.blockTitleKey = '',
    this.nextBlockTitleKey,
    this.completed = false,
    this.exited = false,
    this.longestHoldSeconds = 0,
    this.pausedFrom,
  });

  final EngineMachineState machine;

  /// User-facing label: Squeeze, Hold, Relax, Rest, Breathe in, Breathe out, Get ready.
  final String phaseWord;

  /// 0..1 progress through the current timed segment.
  final double phaseProgress;

  final int? rep;
  final int? totalReps;
  final int blockIndex;
  final String blockTitleKey;
  final String? nextBlockTitleKey;

  /// Whole seconds left in the current segment (ceil).
  final int secondsRemaining;

  /// 0..1 through the whole session (excluding countdown).
  final double totalProgress;

  final int elapsedSeconds;
  final int totalDurationSeconds;

  final bool completed;
  final bool exited;

  /// Longest prescribed hold (seconds) the user finished in this session.
  /// The phone cannot measure the real hold — this is the programmed duration.
  final int longestHoldSeconds;

  /// Machine state before pause, if [machine] is [EngineMachineState.paused].
  final EngineMachineState? pausedFrom;

  bool get isActive =>
      machine == EngineMachineState.countdown ||
      machine == EngineMachineState.squeeze ||
      machine == EngineMachineState.relax ||
      machine == EngineMachineState.rest;

  EngineState copyWith({
    EngineMachineState? machine,
    String? phaseWord,
    double? phaseProgress,
    int? rep,
    int? totalReps,
    int? blockIndex,
    String? blockTitleKey,
    String? nextBlockTitleKey,
    int? secondsRemaining,
    double? totalProgress,
    int? elapsedSeconds,
    int? totalDurationSeconds,
    bool? completed,
    bool? exited,
    int? longestHoldSeconds,
    EngineMachineState? pausedFrom,
    bool clearPausedFrom = false,
    bool clearNext = false,
  }) {
    return EngineState(
      machine: machine ?? this.machine,
      phaseWord: phaseWord ?? this.phaseWord,
      phaseProgress: phaseProgress ?? this.phaseProgress,
      rep: rep ?? this.rep,
      totalReps: totalReps ?? this.totalReps,
      blockIndex: blockIndex ?? this.blockIndex,
      blockTitleKey: blockTitleKey ?? this.blockTitleKey,
      nextBlockTitleKey:
          clearNext ? null : (nextBlockTitleKey ?? this.nextBlockTitleKey),
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalProgress: totalProgress ?? this.totalProgress,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalDurationSeconds:
          totalDurationSeconds ?? this.totalDurationSeconds,
      completed: completed ?? this.completed,
      exited: exited ?? this.exited,
      longestHoldSeconds: longestHoldSeconds ?? this.longestHoldSeconds,
      pausedFrom: clearPausedFrom ? null : (pausedFrom ?? this.pausedFrom),
    );
  }

  static const EngineState idle = EngineState(
    machine: EngineMachineState.idle,
    phaseWord: '',
    phaseProgress: 0,
    blockIndex: 0,
    secondsRemaining: 0,
    totalProgress: 0,
    elapsedSeconds: 0,
    totalDurationSeconds: 0,
  );
}

/// One timed slice on the session timeline.
class TimelineSegment {
  const TimelineSegment({
    required this.machine,
    required this.duration,
    required this.blockIndex,
    required this.blockTitleKey,
    required this.phaseWordAtStart,
    this.holdAfterFirstSecond = false,
    this.rep,
    this.totalReps,
    this.startEvent,
    this.prescribedHoldSeconds,
    this.isCountdown = false,
  });

  final EngineMachineState machine;
  final Duration duration;
  final int blockIndex;
  final String blockTitleKey;
  final String phaseWordAtStart;

  /// When true, after the first second of this segment the word becomes "Hold".
  final bool holdAfterFirstSecond;

  final int? rep;
  final int? totalReps;
  final EngineEvent? startEvent;

  /// If this segment completes a prescribed hold, its length in seconds.
  final int? prescribedHoldSeconds;

  final bool isCountdown;

  String phaseWordAt(Duration elapsedInSegment) {
    if (holdAfterFirstSecond && elapsedInSegment >= const Duration(seconds: 1)) {
      return 'Hold';
    }
    return phaseWordAtStart;
  }
}
