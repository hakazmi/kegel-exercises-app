// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayInLevelMeta = const VerificationMeta(
    'dayInLevel',
  );
  @override
  late final GeneratedColumn<int> dayInLevel = GeneratedColumn<int>(
    'day_in_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<String> track = GeneratedColumn<String>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('strengthening'),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestHoldSecondsMeta =
      const VerificationMeta('longestHoldSeconds');
  @override
  late final GeneratedColumn<int> longestHoldSeconds = GeneratedColumn<int>(
    'longest_hold_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _feelMeta = const VerificationMeta('feel');
  @override
  late final GeneratedColumn<String> feel = GeneratedColumn<String>(
    'feel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    completedAt,
    level,
    dayInLevel,
    track,
    kind,
    durationSeconds,
    longestHoldSeconds,
    completed,
    feel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('day_in_level')) {
      context.handle(
        _dayInLevelMeta,
        dayInLevel.isAcceptableOrUnknown(
          data['day_in_level']!,
          _dayInLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayInLevelMeta);
    }
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    } else if (isInserting) {
      context.missing(_trackMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('longest_hold_seconds')) {
      context.handle(
        _longestHoldSecondsMeta,
        longestHoldSeconds.isAcceptableOrUnknown(
          data['longest_hold_seconds']!,
          _longestHoldSecondsMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('feel')) {
      context.handle(
        _feelMeta,
        feel.isAcceptableOrUnknown(data['feel']!, _feelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      dayInLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_in_level'],
      )!,
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      longestHoldSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_hold_seconds'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      feel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feel'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int level;
  final int dayInLevel;
  final String track;

  /// strengthening | body | breathing | relaxation
  final String kind;
  final int durationSeconds;
  final int longestHoldSeconds;
  final bool completed;
  final String? feel;
  const Session({
    required this.id,
    required this.startedAt,
    this.completedAt,
    required this.level,
    required this.dayInLevel,
    required this.track,
    required this.kind,
    required this.durationSeconds,
    required this.longestHoldSeconds,
    required this.completed,
    this.feel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['level'] = Variable<int>(level);
    map['day_in_level'] = Variable<int>(dayInLevel);
    map['track'] = Variable<String>(track);
    map['kind'] = Variable<String>(kind);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['longest_hold_seconds'] = Variable<int>(longestHoldSeconds);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || feel != null) {
      map['feel'] = Variable<String>(feel);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      level: Value(level),
      dayInLevel: Value(dayInLevel),
      track: Value(track),
      kind: Value(kind),
      durationSeconds: Value(durationSeconds),
      longestHoldSeconds: Value(longestHoldSeconds),
      completed: Value(completed),
      feel: feel == null && nullToAbsent ? const Value.absent() : Value(feel),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      level: serializer.fromJson<int>(json['level']),
      dayInLevel: serializer.fromJson<int>(json['dayInLevel']),
      track: serializer.fromJson<String>(json['track']),
      kind: serializer.fromJson<String>(json['kind']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      longestHoldSeconds: serializer.fromJson<int>(json['longestHoldSeconds']),
      completed: serializer.fromJson<bool>(json['completed']),
      feel: serializer.fromJson<String?>(json['feel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'level': serializer.toJson<int>(level),
      'dayInLevel': serializer.toJson<int>(dayInLevel),
      'track': serializer.toJson<String>(track),
      'kind': serializer.toJson<String>(kind),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'longestHoldSeconds': serializer.toJson<int>(longestHoldSeconds),
      'completed': serializer.toJson<bool>(completed),
      'feel': serializer.toJson<String?>(feel),
    };
  }

  Session copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    int? level,
    int? dayInLevel,
    String? track,
    String? kind,
    int? durationSeconds,
    int? longestHoldSeconds,
    bool? completed,
    Value<String?> feel = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    level: level ?? this.level,
    dayInLevel: dayInLevel ?? this.dayInLevel,
    track: track ?? this.track,
    kind: kind ?? this.kind,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    longestHoldSeconds: longestHoldSeconds ?? this.longestHoldSeconds,
    completed: completed ?? this.completed,
    feel: feel.present ? feel.value : this.feel,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      level: data.level.present ? data.level.value : this.level,
      dayInLevel: data.dayInLevel.present
          ? data.dayInLevel.value
          : this.dayInLevel,
      track: data.track.present ? data.track.value : this.track,
      kind: data.kind.present ? data.kind.value : this.kind,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      longestHoldSeconds: data.longestHoldSeconds.present
          ? data.longestHoldSeconds.value
          : this.longestHoldSeconds,
      completed: data.completed.present ? data.completed.value : this.completed,
      feel: data.feel.present ? data.feel.value : this.feel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('level: $level, ')
          ..write('dayInLevel: $dayInLevel, ')
          ..write('track: $track, ')
          ..write('kind: $kind, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('longestHoldSeconds: $longestHoldSeconds, ')
          ..write('completed: $completed, ')
          ..write('feel: $feel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    completedAt,
    level,
    dayInLevel,
    track,
    kind,
    durationSeconds,
    longestHoldSeconds,
    completed,
    feel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.level == this.level &&
          other.dayInLevel == this.dayInLevel &&
          other.track == this.track &&
          other.kind == this.kind &&
          other.durationSeconds == this.durationSeconds &&
          other.longestHoldSeconds == this.longestHoldSeconds &&
          other.completed == this.completed &&
          other.feel == this.feel);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> level;
  final Value<int> dayInLevel;
  final Value<String> track;
  final Value<String> kind;
  final Value<int> durationSeconds;
  final Value<int> longestHoldSeconds;
  final Value<bool> completed;
  final Value<String?> feel;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.level = const Value.absent(),
    this.dayInLevel = const Value.absent(),
    this.track = const Value.absent(),
    this.kind = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.longestHoldSeconds = const Value.absent(),
    this.completed = const Value.absent(),
    this.feel = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    required int level,
    required int dayInLevel,
    required String track,
    this.kind = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.longestHoldSeconds = const Value.absent(),
    this.completed = const Value.absent(),
    this.feel = const Value.absent(),
  }) : startedAt = Value(startedAt),
       level = Value(level),
       dayInLevel = Value(dayInLevel),
       track = Value(track);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? level,
    Expression<int>? dayInLevel,
    Expression<String>? track,
    Expression<String>? kind,
    Expression<int>? durationSeconds,
    Expression<int>? longestHoldSeconds,
    Expression<bool>? completed,
    Expression<String>? feel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (level != null) 'level': level,
      if (dayInLevel != null) 'day_in_level': dayInLevel,
      if (track != null) 'track': track,
      if (kind != null) 'kind': kind,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (longestHoldSeconds != null)
        'longest_hold_seconds': longestHoldSeconds,
      if (completed != null) 'completed': completed,
      if (feel != null) 'feel': feel,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? level,
    Value<int>? dayInLevel,
    Value<String>? track,
    Value<String>? kind,
    Value<int>? durationSeconds,
    Value<int>? longestHoldSeconds,
    Value<bool>? completed,
    Value<String?>? feel,
  }) {
    return SessionsCompanion(
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
      feel: feel ?? this.feel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (dayInLevel.present) {
      map['day_in_level'] = Variable<int>(dayInLevel.value);
    }
    if (track.present) {
      map['track'] = Variable<String>(track.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (longestHoldSeconds.present) {
      map['longest_hold_seconds'] = Variable<int>(longestHoldSeconds.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (feel.present) {
      map['feel'] = Variable<String>(feel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('level: $level, ')
          ..write('dayInLevel: $dayInLevel, ')
          ..write('track: $track, ')
          ..write('kind: $kind, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('longestHoldSeconds: $longestHoldSeconds, ')
          ..write('completed: $completed, ')
          ..write('feel: $feel')
          ..write(')'))
        .toString();
  }
}

class $CheckinsTable extends Checkins with TableInfo<$CheckinsTable, Checkin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, goal, score];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<Checkin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Checkin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Checkin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
    );
  }

  @override
  $CheckinsTable createAlias(String alias) {
    return $CheckinsTable(attachedDatabase, alias);
  }
}

class Checkin extends DataClass implements Insertable<Checkin> {
  final int id;
  final DateTime date;
  final String goal;
  final int score;
  const Checkin({
    required this.id,
    required this.date,
    required this.goal,
    required this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['goal'] = Variable<String>(goal);
    map['score'] = Variable<int>(score);
    return map;
  }

  CheckinsCompanion toCompanion(bool nullToAbsent) {
    return CheckinsCompanion(
      id: Value(id),
      date: Value(date),
      goal: Value(goal),
      score: Value(score),
    );
  }

  factory Checkin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Checkin(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      goal: serializer.fromJson<String>(json['goal']),
      score: serializer.fromJson<int>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'goal': serializer.toJson<String>(goal),
      'score': serializer.toJson<int>(score),
    };
  }

  Checkin copyWith({int? id, DateTime? date, String? goal, int? score}) =>
      Checkin(
        id: id ?? this.id,
        date: date ?? this.date,
        goal: goal ?? this.goal,
        score: score ?? this.score,
      );
  Checkin copyWithCompanion(CheckinsCompanion data) {
    return Checkin(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      goal: data.goal.present ? data.goal.value : this.goal,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Checkin(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('goal: $goal, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, goal, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Checkin &&
          other.id == this.id &&
          other.date == this.date &&
          other.goal == this.goal &&
          other.score == this.score);
}

class CheckinsCompanion extends UpdateCompanion<Checkin> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> goal;
  final Value<int> score;
  const CheckinsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.goal = const Value.absent(),
    this.score = const Value.absent(),
  });
  CheckinsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String goal,
    required int score,
  }) : date = Value(date),
       goal = Value(goal),
       score = Value(score);
  static Insertable<Checkin> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? goal,
    Expression<int>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (goal != null) 'goal': goal,
      if (score != null) 'score': score,
    });
  }

  CheckinsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? goal,
    Value<int>? score,
  }) {
    return CheckinsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      goal: goal ?? this.goal,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckinsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('goal: $goal, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

class $HabitTicksTable extends HabitTicks
    with TableInfo<$HabitTicksTable, HabitTick> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitTicksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, habitId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_ticks';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitTick> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitTick map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitTick(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
    );
  }

  @override
  $HabitTicksTable createAlias(String alias) {
    return $HabitTicksTable(attachedDatabase, alias);
  }
}

class HabitTick extends DataClass implements Insertable<HabitTick> {
  final int id;
  final DateTime date;
  final String habitId;
  const HabitTick({
    required this.id,
    required this.date,
    required this.habitId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['habit_id'] = Variable<String>(habitId);
    return map;
  }

  HabitTicksCompanion toCompanion(bool nullToAbsent) {
    return HabitTicksCompanion(
      id: Value(id),
      date: Value(date),
      habitId: Value(habitId),
    );
  }

  factory HabitTick.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitTick(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      habitId: serializer.fromJson<String>(json['habitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'habitId': serializer.toJson<String>(habitId),
    };
  }

  HabitTick copyWith({int? id, DateTime? date, String? habitId}) => HabitTick(
    id: id ?? this.id,
    date: date ?? this.date,
    habitId: habitId ?? this.habitId,
  );
  HabitTick copyWithCompanion(HabitTicksCompanion data) {
    return HabitTick(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitTick(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('habitId: $habitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, habitId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitTick &&
          other.id == this.id &&
          other.date == this.date &&
          other.habitId == this.habitId);
}

class HabitTicksCompanion extends UpdateCompanion<HabitTick> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> habitId;
  const HabitTicksCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.habitId = const Value.absent(),
  });
  HabitTicksCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String habitId,
  }) : date = Value(date),
       habitId = Value(habitId);
  static Insertable<HabitTick> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? habitId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (habitId != null) 'habit_id': habitId,
    });
  }

  HabitTicksCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? habitId,
  }) {
    return HabitTicksCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      habitId: habitId ?? this.habitId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitTicksCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('habitId: $habitId')
          ..write(')'))
        .toString();
  }
}

class $WalkingLogsTable extends WalkingLogs
    with TableInfo<$WalkingLogsTable, WalkingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalkingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, minutes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'walking_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalkingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalkingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalkingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
    );
  }

  @override
  $WalkingLogsTable createAlias(String alias) {
    return $WalkingLogsTable(attachedDatabase, alias);
  }
}

class WalkingLog extends DataClass implements Insertable<WalkingLog> {
  final int id;
  final DateTime date;
  final int minutes;
  const WalkingLog({
    required this.id,
    required this.date,
    required this.minutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['minutes'] = Variable<int>(minutes);
    return map;
  }

  WalkingLogsCompanion toCompanion(bool nullToAbsent) {
    return WalkingLogsCompanion(
      id: Value(id),
      date: Value(date),
      minutes: Value(minutes),
    );
  }

  factory WalkingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalkingLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      minutes: serializer.fromJson<int>(json['minutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'minutes': serializer.toJson<int>(minutes),
    };
  }

  WalkingLog copyWith({int? id, DateTime? date, int? minutes}) => WalkingLog(
    id: id ?? this.id,
    date: date ?? this.date,
    minutes: minutes ?? this.minutes,
  );
  WalkingLog copyWithCompanion(WalkingLogsCompanion data) {
    return WalkingLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalkingLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minutes: $minutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, minutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalkingLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.minutes == this.minutes);
}

class WalkingLogsCompanion extends UpdateCompanion<WalkingLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> minutes;
  const WalkingLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.minutes = const Value.absent(),
  });
  WalkingLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int minutes,
  }) : date = Value(date),
       minutes = Value(minutes);
  static Insertable<WalkingLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? minutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (minutes != null) 'minutes': minutes,
    });
  }

  WalkingLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? minutes,
  }) {
    return WalkingLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      minutes: minutes ?? this.minutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalkingLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minutes: $minutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $CheckinsTable checkins = $CheckinsTable(this);
  late final $HabitTicksTable habitTicks = $HabitTicksTable(this);
  late final $WalkingLogsTable walkingLogs = $WalkingLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    checkins,
    habitTicks,
    walkingLogs,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  required int level,
  required int dayInLevel,
  required String track,
  Value<String> kind,
  Value<int> durationSeconds,
  Value<int> longestHoldSeconds,
  Value<bool> completed,
  Value<String?> feel,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<int> level,
  Value<int> dayInLevel,
  Value<String> track,
  Value<String> kind,
  Value<int> durationSeconds,
  Value<int> longestHoldSeconds,
  Value<bool> completed,
  Value<String?> feel,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayInLevel => $composableBuilder(
    column: $table.dayInLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestHoldSeconds => $composableBuilder(
    column: $table.longestHoldSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feel => $composableBuilder(
    column: $table.feel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayInLevel => $composableBuilder(
    column: $table.dayInLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestHoldSeconds => $composableBuilder(
    column: $table.longestHoldSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feel => $composableBuilder(
    column: $table.feel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get dayInLevel => $composableBuilder(
    column: $table.dayInLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestHoldSeconds => $composableBuilder(
    column: $table.longestHoldSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get feel =>
      $composableBuilder(column: $table.feel, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> dayInLevel = const Value.absent(),
                Value<String> track = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> longestHoldSeconds = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> feel = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                level: level,
                dayInLevel: dayInLevel,
                track: track,
                kind: kind,
                durationSeconds: durationSeconds,
                longestHoldSeconds: longestHoldSeconds,
                completed: completed,
                feel: feel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                required int level,
                required int dayInLevel,
                required String track,
                Value<String> kind = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> longestHoldSeconds = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> feel = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                level: level,
                dayInLevel: dayInLevel,
                track: track,
                kind: kind,
                durationSeconds: durationSeconds,
                longestHoldSeconds: longestHoldSeconds,
                completed: completed,
                feel: feel,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, Session>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$CheckinsTableCreateCompanionBuilder = CheckinsCompanion Function({
  Value<int> id,
  required DateTime date,
  required String goal,
  required int score,
});
typedef $$CheckinsTableUpdateCompanionBuilder = CheckinsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> goal,
  Value<int> score,
});

class $$CheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);
}

class $$CheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckinsTable,
          Checkin,
          $$CheckinsTableFilterComposer,
          $$CheckinsTableOrderingComposer,
          $$CheckinsTableAnnotationComposer,
          $$CheckinsTableCreateCompanionBuilder,
          $$CheckinsTableUpdateCompanionBuilder,
          (Checkin, BaseReferences<_$AppDatabase, $CheckinsTable, Checkin>),
          Checkin,
          PrefetchHooks Function()
        > {
  $$CheckinsTableTableManager(_$AppDatabase db, $CheckinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> goal = const Value.absent(),
            Value<int> score = const Value.absent(),
          }) => CheckinsCompanion(id: id, date: date, goal: goal, score: score),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String goal,
                required int score,
              }) => CheckinsCompanion.insert(
                id: id,
                date: date,
                goal: goal,
                score: score,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckinsTable, Checkin>(table),
                  BaseReferences<_$AppDatabase, $CheckinsTable, Checkin>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckinsTable,
      Checkin,
      $$CheckinsTableFilterComposer,
      $$CheckinsTableOrderingComposer,
      $$CheckinsTableAnnotationComposer,
      $$CheckinsTableCreateCompanionBuilder,
      $$CheckinsTableUpdateCompanionBuilder,
      (Checkin, BaseReferences<_$AppDatabase, $CheckinsTable, Checkin>),
      Checkin,
      PrefetchHooks Function()
    >;
typedef $$HabitTicksTableCreateCompanionBuilder = HabitTicksCompanion Function({
  Value<int> id,
  required DateTime date,
  required String habitId,
});
typedef $$HabitTicksTableUpdateCompanionBuilder = HabitTicksCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> habitId,
});

class $$HabitTicksTableFilterComposer
    extends Composer<_$AppDatabase, $HabitTicksTable> {
  $$HabitTicksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitTicksTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitTicksTable> {
  $$HabitTicksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitTicksTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitTicksTable> {
  $$HabitTicksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);
}

class $$HabitTicksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitTicksTable,
          HabitTick,
          $$HabitTicksTableFilterComposer,
          $$HabitTicksTableOrderingComposer,
          $$HabitTicksTableAnnotationComposer,
          $$HabitTicksTableCreateCompanionBuilder,
          $$HabitTicksTableUpdateCompanionBuilder,
          (
            HabitTick,
            BaseReferences<_$AppDatabase, $HabitTicksTable, HabitTick>,
          ),
          HabitTick,
          PrefetchHooks Function()
        > {
  $$HabitTicksTableTableManager(_$AppDatabase db, $HabitTicksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitTicksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitTicksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitTicksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> habitId = const Value.absent(),
          }) => HabitTicksCompanion(id: id, date: date, habitId: habitId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String habitId,
              }) => HabitTicksCompanion.insert(
                id: id,
                date: date,
                habitId: habitId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitTicksTable, HabitTick>(table),
                  BaseReferences<_$AppDatabase, $HabitTicksTable, HabitTick>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitTicksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitTicksTable,
      HabitTick,
      $$HabitTicksTableFilterComposer,
      $$HabitTicksTableOrderingComposer,
      $$HabitTicksTableAnnotationComposer,
      $$HabitTicksTableCreateCompanionBuilder,
      $$HabitTicksTableUpdateCompanionBuilder,
      (HabitTick, BaseReferences<_$AppDatabase, $HabitTicksTable, HabitTick>),
      HabitTick,
      PrefetchHooks Function()
    >;
typedef $$WalkingLogsTableCreateCompanionBuilder =
    WalkingLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required int minutes,
    });
typedef $$WalkingLogsTableUpdateCompanionBuilder =
    WalkingLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> minutes,
    });

class $$WalkingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WalkingLogsTable> {
  $$WalkingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalkingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalkingLogsTable> {
  $$WalkingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalkingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalkingLogsTable> {
  $$WalkingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);
}

class $$WalkingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalkingLogsTable,
          WalkingLog,
          $$WalkingLogsTableFilterComposer,
          $$WalkingLogsTableOrderingComposer,
          $$WalkingLogsTableAnnotationComposer,
          $$WalkingLogsTableCreateCompanionBuilder,
          $$WalkingLogsTableUpdateCompanionBuilder,
          (
            WalkingLog,
            BaseReferences<_$AppDatabase, $WalkingLogsTable, WalkingLog>,
          ),
          WalkingLog,
          PrefetchHooks Function()
        > {
  $$WalkingLogsTableTableManager(_$AppDatabase db, $WalkingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalkingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalkingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalkingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> minutes = const Value.absent(),
          }) => WalkingLogsCompanion(id: id, date: date, minutes: minutes),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int minutes,
              }) => WalkingLogsCompanion.insert(
                id: id,
                date: date,
                minutes: minutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WalkingLogsTable, WalkingLog>(table),
                  BaseReferences<_$AppDatabase, $WalkingLogsTable, WalkingLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalkingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalkingLogsTable,
      WalkingLog,
      $$WalkingLogsTableFilterComposer,
      $$WalkingLogsTableOrderingComposer,
      $$WalkingLogsTableAnnotationComposer,
      $$WalkingLogsTableCreateCompanionBuilder,
      $$WalkingLogsTableUpdateCompanionBuilder,
      (
        WalkingLog,
        BaseReferences<_$AppDatabase, $WalkingLogsTable, WalkingLog>,
      ),
      WalkingLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db, _db.checkins);
  $$HabitTicksTableTableManager get habitTicks =>
      $$HabitTicksTableTableManager(_db, _db.habitTicks);
  $$WalkingLogsTableTableManager get walkingLogs =>
      $$WalkingLogsTableTableManager(_db, _db.walkingLogs);
}
