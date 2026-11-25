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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncDirtyMeta = const VerificationMeta(
    'syncDirty',
  );
  @override
  late final GeneratedColumn<bool> syncDirty = GeneratedColumn<bool>(
    'sync_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('sync_dirty')) {
      context.handle(
        _syncDirtyMeta,
        syncDirty.isAcceptableOrUnknown(data['sync_dirty']!, _syncDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      syncDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
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

  /// Permanent cloud id (UUID). Empty until backfill / first write.
  final String syncId;
  final int updatedAtMillis;
  final bool syncDirty;
  final bool isDeleted;
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
    required this.syncId,
    required this.updatedAtMillis,
    required this.syncDirty,
    required this.isDeleted,
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
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    map['sync_dirty'] = Variable<bool>(syncDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
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
      syncId: Value(syncId),
      updatedAtMillis: Value(updatedAtMillis),
      syncDirty: Value(syncDirty),
      isDeleted: Value(isDeleted),
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
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      syncDirty: serializer.fromJson<bool>(json['syncDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
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
      'syncId': serializer.toJson<String>(syncId),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'syncDirty': serializer.toJson<bool>(syncDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
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
    String? syncId,
    int? updatedAtMillis,
    bool? syncDirty,
    bool? isDeleted,
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
    syncId: syncId ?? this.syncId,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    syncDirty: syncDirty ?? this.syncDirty,
    isDeleted: isDeleted ?? this.isDeleted,
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
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      syncDirty: data.syncDirty.present ? data.syncDirty.value : this.syncDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
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
          ..write('feel: $feel, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
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
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
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
          other.feel == this.feel &&
          other.syncId == this.syncId &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.syncDirty == this.syncDirty &&
          other.isDeleted == this.isDeleted);
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
  final Value<String> syncId;
  final Value<int> updatedAtMillis;
  final Value<bool> syncDirty;
  final Value<bool> isDeleted;
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
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
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
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
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
    Expression<String>? syncId,
    Expression<int>? updatedAtMillis,
    Expression<bool>? syncDirty,
    Expression<bool>? isDeleted,
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
      if (syncId != null) 'sync_id': syncId,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (syncDirty != null) 'sync_dirty': syncDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
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
    Value<String>? syncId,
    Value<int>? updatedAtMillis,
    Value<bool>? syncDirty,
    Value<bool>? isDeleted,
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
      syncId: syncId ?? this.syncId,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      syncDirty: syncDirty ?? this.syncDirty,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (syncDirty.present) {
      map['sync_dirty'] = Variable<bool>(syncDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('feel: $feel, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncDirtyMeta = const VerificationMeta(
    'syncDirty',
  );
  @override
  late final GeneratedColumn<bool> syncDirty = GeneratedColumn<bool>(
    'sync_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    goal,
    score,
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
  ];
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('sync_dirty')) {
      context.handle(
        _syncDirtyMeta,
        syncDirty.isAcceptableOrUnknown(data['sync_dirty']!, _syncDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      syncDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
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
  final String syncId;
  final int updatedAtMillis;
  final bool syncDirty;
  final bool isDeleted;
  const Checkin({
    required this.id,
    required this.date,
    required this.goal,
    required this.score,
    required this.syncId,
    required this.updatedAtMillis,
    required this.syncDirty,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['goal'] = Variable<String>(goal);
    map['score'] = Variable<int>(score);
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    map['sync_dirty'] = Variable<bool>(syncDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CheckinsCompanion toCompanion(bool nullToAbsent) {
    return CheckinsCompanion(
      id: Value(id),
      date: Value(date),
      goal: Value(goal),
      score: Value(score),
      syncId: Value(syncId),
      updatedAtMillis: Value(updatedAtMillis),
      syncDirty: Value(syncDirty),
      isDeleted: Value(isDeleted),
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
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      syncDirty: serializer.fromJson<bool>(json['syncDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
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
      'syncId': serializer.toJson<String>(syncId),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'syncDirty': serializer.toJson<bool>(syncDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Checkin copyWith({
    int? id,
    DateTime? date,
    String? goal,
    int? score,
    String? syncId,
    int? updatedAtMillis,
    bool? syncDirty,
    bool? isDeleted,
  }) => Checkin(
    id: id ?? this.id,
    date: date ?? this.date,
    goal: goal ?? this.goal,
    score: score ?? this.score,
    syncId: syncId ?? this.syncId,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    syncDirty: syncDirty ?? this.syncDirty,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Checkin copyWithCompanion(CheckinsCompanion data) {
    return Checkin(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      goal: data.goal.present ? data.goal.value : this.goal,
      score: data.score.present ? data.score.value : this.score,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      syncDirty: data.syncDirty.present ? data.syncDirty.value : this.syncDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Checkin(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('goal: $goal, ')
          ..write('score: $score, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    goal,
    score,
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Checkin &&
          other.id == this.id &&
          other.date == this.date &&
          other.goal == this.goal &&
          other.score == this.score &&
          other.syncId == this.syncId &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.syncDirty == this.syncDirty &&
          other.isDeleted == this.isDeleted);
}

class CheckinsCompanion extends UpdateCompanion<Checkin> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> goal;
  final Value<int> score;
  final Value<String> syncId;
  final Value<int> updatedAtMillis;
  final Value<bool> syncDirty;
  final Value<bool> isDeleted;
  const CheckinsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.goal = const Value.absent(),
    this.score = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  CheckinsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String goal,
    required int score,
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : date = Value(date),
       goal = Value(goal),
       score = Value(score);
  static Insertable<Checkin> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? goal,
    Expression<int>? score,
    Expression<String>? syncId,
    Expression<int>? updatedAtMillis,
    Expression<bool>? syncDirty,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (goal != null) 'goal': goal,
      if (score != null) 'score': score,
      if (syncId != null) 'sync_id': syncId,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (syncDirty != null) 'sync_dirty': syncDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  CheckinsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? goal,
    Value<int>? score,
    Value<String>? syncId,
    Value<int>? updatedAtMillis,
    Value<bool>? syncDirty,
    Value<bool>? isDeleted,
  }) {
    return CheckinsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      goal: goal ?? this.goal,
      score: score ?? this.score,
      syncId: syncId ?? this.syncId,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      syncDirty: syncDirty ?? this.syncDirty,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (syncDirty.present) {
      map['sync_dirty'] = Variable<bool>(syncDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckinsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('goal: $goal, ')
          ..write('score: $score, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncDirtyMeta = const VerificationMeta(
    'syncDirty',
  );
  @override
  late final GeneratedColumn<bool> syncDirty = GeneratedColumn<bool>(
    'sync_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    habitId,
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
  ];
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('sync_dirty')) {
      context.handle(
        _syncDirtyMeta,
        syncDirty.isAcceptableOrUnknown(data['sync_dirty']!, _syncDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      syncDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
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
  final String syncId;
  final int updatedAtMillis;
  final bool syncDirty;
  final bool isDeleted;
  const HabitTick({
    required this.id,
    required this.date,
    required this.habitId,
    required this.syncId,
    required this.updatedAtMillis,
    required this.syncDirty,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['habit_id'] = Variable<String>(habitId);
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    map['sync_dirty'] = Variable<bool>(syncDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  HabitTicksCompanion toCompanion(bool nullToAbsent) {
    return HabitTicksCompanion(
      id: Value(id),
      date: Value(date),
      habitId: Value(habitId),
      syncId: Value(syncId),
      updatedAtMillis: Value(updatedAtMillis),
      syncDirty: Value(syncDirty),
      isDeleted: Value(isDeleted),
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
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      syncDirty: serializer.fromJson<bool>(json['syncDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'habitId': serializer.toJson<String>(habitId),
      'syncId': serializer.toJson<String>(syncId),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'syncDirty': serializer.toJson<bool>(syncDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  HabitTick copyWith({
    int? id,
    DateTime? date,
    String? habitId,
    String? syncId,
    int? updatedAtMillis,
    bool? syncDirty,
    bool? isDeleted,
  }) => HabitTick(
    id: id ?? this.id,
    date: date ?? this.date,
    habitId: habitId ?? this.habitId,
    syncId: syncId ?? this.syncId,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    syncDirty: syncDirty ?? this.syncDirty,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  HabitTick copyWithCompanion(HabitTicksCompanion data) {
    return HabitTick(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      syncDirty: data.syncDirty.present ? data.syncDirty.value : this.syncDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitTick(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('habitId: $habitId, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    habitId,
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitTick &&
          other.id == this.id &&
          other.date == this.date &&
          other.habitId == this.habitId &&
          other.syncId == this.syncId &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.syncDirty == this.syncDirty &&
          other.isDeleted == this.isDeleted);
}

class HabitTicksCompanion extends UpdateCompanion<HabitTick> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> habitId;
  final Value<String> syncId;
  final Value<int> updatedAtMillis;
  final Value<bool> syncDirty;
  final Value<bool> isDeleted;
  const HabitTicksCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.habitId = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  HabitTicksCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String habitId,
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : date = Value(date),
       habitId = Value(habitId);
  static Insertable<HabitTick> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? habitId,
    Expression<String>? syncId,
    Expression<int>? updatedAtMillis,
    Expression<bool>? syncDirty,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (habitId != null) 'habit_id': habitId,
      if (syncId != null) 'sync_id': syncId,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (syncDirty != null) 'sync_dirty': syncDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  HabitTicksCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? habitId,
    Value<String>? syncId,
    Value<int>? updatedAtMillis,
    Value<bool>? syncDirty,
    Value<bool>? isDeleted,
  }) {
    return HabitTicksCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      habitId: habitId ?? this.habitId,
      syncId: syncId ?? this.syncId,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      syncDirty: syncDirty ?? this.syncDirty,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (syncDirty.present) {
      map['sync_dirty'] = Variable<bool>(syncDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitTicksCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('habitId: $habitId, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncDirtyMeta = const VerificationMeta(
    'syncDirty',
  );
  @override
  late final GeneratedColumn<bool> syncDirty = GeneratedColumn<bool>(
    'sync_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    minutes,
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
  ];
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('sync_dirty')) {
      context.handle(
        _syncDirtyMeta,
        syncDirty.isAcceptableOrUnknown(data['sync_dirty']!, _syncDirtyMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      syncDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_dirty'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
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
  final String syncId;
  final int updatedAtMillis;
  final bool syncDirty;
  final bool isDeleted;
  const WalkingLog({
    required this.id,
    required this.date,
    required this.minutes,
    required this.syncId,
    required this.updatedAtMillis,
    required this.syncDirty,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['minutes'] = Variable<int>(minutes);
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    map['sync_dirty'] = Variable<bool>(syncDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  WalkingLogsCompanion toCompanion(bool nullToAbsent) {
    return WalkingLogsCompanion(
      id: Value(id),
      date: Value(date),
      minutes: Value(minutes),
      syncId: Value(syncId),
      updatedAtMillis: Value(updatedAtMillis),
      syncDirty: Value(syncDirty),
      isDeleted: Value(isDeleted),
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
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      syncDirty: serializer.fromJson<bool>(json['syncDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'minutes': serializer.toJson<int>(minutes),
      'syncId': serializer.toJson<String>(syncId),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'syncDirty': serializer.toJson<bool>(syncDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  WalkingLog copyWith({
    int? id,
    DateTime? date,
    int? minutes,
    String? syncId,
    int? updatedAtMillis,
    bool? syncDirty,
    bool? isDeleted,
  }) => WalkingLog(
    id: id ?? this.id,
    date: date ?? this.date,
    minutes: minutes ?? this.minutes,
    syncId: syncId ?? this.syncId,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    syncDirty: syncDirty ?? this.syncDirty,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  WalkingLog copyWithCompanion(WalkingLogsCompanion data) {
    return WalkingLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      syncDirty: data.syncDirty.present ? data.syncDirty.value : this.syncDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalkingLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minutes: $minutes, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    minutes,
    syncId,
    updatedAtMillis,
    syncDirty,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalkingLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.minutes == this.minutes &&
          other.syncId == this.syncId &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.syncDirty == this.syncDirty &&
          other.isDeleted == this.isDeleted);
}

class WalkingLogsCompanion extends UpdateCompanion<WalkingLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> minutes;
  final Value<String> syncId;
  final Value<int> updatedAtMillis;
  final Value<bool> syncDirty;
  final Value<bool> isDeleted;
  const WalkingLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.minutes = const Value.absent(),
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  WalkingLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int minutes,
    this.syncId = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.syncDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : date = Value(date),
       minutes = Value(minutes);
  static Insertable<WalkingLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? minutes,
    Expression<String>? syncId,
    Expression<int>? updatedAtMillis,
    Expression<bool>? syncDirty,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (minutes != null) 'minutes': minutes,
      if (syncId != null) 'sync_id': syncId,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (syncDirty != null) 'sync_dirty': syncDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  WalkingLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? minutes,
    Value<String>? syncId,
    Value<int>? updatedAtMillis,
    Value<bool>? syncDirty,
    Value<bool>? isDeleted,
  }) {
    return WalkingLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      minutes: minutes ?? this.minutes,
      syncId: syncId ?? this.syncId,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      syncDirty: syncDirty ?? this.syncDirty,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (syncDirty.present) {
      map['sync_dirty'] = Variable<bool>(syncDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalkingLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minutes: $minutes, ')
          ..write('syncId: $syncId, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('syncDirty: $syncDirty, ')
          ..write('isDeleted: $isDeleted')
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
  Value<String> syncId,
  Value<int> updatedAtMillis,
  Value<bool> syncDirty,
  Value<bool> isDeleted,
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
  Value<String> syncId,
  Value<int> updatedAtMillis,
  Value<bool> syncDirty,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncDirty =>
      $composableBuilder(column: $table.syncDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
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
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
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
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
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
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
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
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
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
  Value<String> syncId,
  Value<int> updatedAtMillis,
  Value<bool> syncDirty,
  Value<bool> isDeleted,
});
typedef $$CheckinsTableUpdateCompanionBuilder = CheckinsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> goal,
  Value<int> score,
  Value<String> syncId,
  Value<int> updatedAtMillis,
  Value<bool> syncDirty,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncDirty =>
      $composableBuilder(column: $table.syncDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
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
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => CheckinsCompanion(
                id: id,
                date: date,
                goal: goal,
                score: score,
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String goal,
                required int score,
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => CheckinsCompanion.insert(
                id: id,
                date: date,
                goal: goal,
                score: score,
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
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
  Value<String> syncId,
  Value<int> updatedAtMillis,
  Value<bool> syncDirty,
  Value<bool> isDeleted,
});
typedef $$HabitTicksTableUpdateCompanionBuilder = HabitTicksCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> habitId,
  Value<String> syncId,
  Value<int> updatedAtMillis,
  Value<bool> syncDirty,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncDirty =>
      $composableBuilder(column: $table.syncDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
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
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HabitTicksCompanion(
                id: id,
                date: date,
                habitId: habitId,
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String habitId,
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => HabitTicksCompanion.insert(
                id: id,
                date: date,
                habitId: habitId,
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
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
      Value<String> syncId,
      Value<int> updatedAtMillis,
      Value<bool> syncDirty,
      Value<bool> isDeleted,
    });
typedef $$WalkingLogsTableUpdateCompanionBuilder =
    WalkingLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> minutes,
      Value<String> syncId,
      Value<int> updatedAtMillis,
      Value<bool> syncDirty,
      Value<bool> isDeleted,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncDirty => $composableBuilder(
    column: $table.syncDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncDirty =>
      $composableBuilder(column: $table.syncDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
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
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => WalkingLogsCompanion(
                id: id,
                date: date,
                minutes: minutes,
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int minutes,
                Value<String> syncId = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> syncDirty = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => WalkingLogsCompanion.insert(
                id: id,
                date: date,
                minutes: minutes,
                syncId: syncId,
                updatedAtMillis: updatedAtMillis,
                syncDirty: syncDirty,
                isDeleted: isDeleted,
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
