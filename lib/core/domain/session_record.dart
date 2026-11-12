import 'enums.dart';

/// A stored training or relaxation session.
class SessionRecord {
  const SessionRecord({
    this.id,
    required this.startedAt,
    this.completedAt,
    required this.level,
    required this.dayInLevel,
    required this.track,
    required this.kind,
    this.durationSeconds = 0,
    this.longestHoldSeconds = 0,
    this.completed = false,
    this.feel,
  });

  final int? id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int level;
  final int dayInLevel;
  final TrackId track;
  final SessionKind kind;
  final int durationSeconds;
  final int longestHoldSeconds;
  final bool completed;
  final SessionFeel? feel;

  SessionRecord copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? completedAt,
    int? level,
    int? dayInLevel,
    TrackId? track,
    SessionKind? kind,
    int? durationSeconds,
    int? longestHoldSeconds,
    bool? completed,
    SessionFeel? feel,
    bool clearFeel = false,
  }) {
    return SessionRecord(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      level: level ?? this.level,
      dayInLevel: dayInLevel ?? this.dayInLevel,
      track: track ?? this.track,
      kind: kind ?? this.kind,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      longestHoldSeconds: longestHoldSeconds ?? this.longestHoldSeconds,
      completed: completed ?? this.completed,
      feel: clearFeel ? null : (feel ?? this.feel),
    );
  }
}

/// A stored goal check-in score.
class CheckInRecord {
  const CheckInRecord({
    this.id,
    required this.date,
    required this.goal,
    required this.score,
  });

  final int? id;
  final DateTime date;
  final Goal goal;
  final int score;
}
