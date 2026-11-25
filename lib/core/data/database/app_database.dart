import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

const Uuid _uuid = Uuid();

String newSyncId() => _uuid.v4();

int nowMillis() => DateTime.now().toUtc().millisecondsSinceEpoch;

/// Drift table for completed / partial sessions.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get level => integer()();
  IntColumn get dayInLevel => integer()();
  TextColumn get track => text()();

  /// strengthening | body | breathing | relaxation
  TextColumn get kind => text().withDefault(const Constant('strengthening'))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get longestHoldSeconds =>
      integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get feel => text().nullable()();

  /// Permanent cloud id (UUID). Empty until backfill / first write.
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get updatedAtMillis => integer().withDefault(const Constant(0))();
  BoolColumn get syncDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// Drift table for goal check-ins (synced under RLS; never analytics).
class Checkins extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get goal => text()();
  IntColumn get score => integer()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get updatedAtMillis => integer().withDefault(const Constant(0))();
  BoolColumn get syncDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// Tick-only daily habits (synced; never affect streak or unlock).
class HabitTicks extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get habitId => text()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get updatedAtMillis => integer().withDefault(const Constant(0))();
  BoolColumn get syncDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// Self-reported walking minutes by calendar day.
class WalkingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get minutes => integer()();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get updatedAtMillis => integer().withDefault(const Constant(0))();
  BoolColumn get syncDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// Local SQLite database.
@DriftDatabase(tables: <Type>[Sessions, Checkins, HabitTicks, WalkingLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(habitTicks);
        await m.createTable(walkingLogs);
      }
      if (from < 3) {
        // Tables that already existed before v3 need ALTER; freshly created
        // habit/walking tables (from < 2) already include sync columns.
        await _addSyncColumnsSql('sessions');
        await _addSyncColumnsSql('checkins');
        if (from >= 2) {
          await _addSyncColumnsSql('habit_ticks');
          await _addSyncColumnsSql('walking_logs');
        }
        await _backfillSyncIds();
      }
    },
  );

  Future<void> _addSyncColumnsSql(String table) async {
    await customStatement(
      'ALTER TABLE $table ADD COLUMN sync_id TEXT NOT NULL DEFAULT \'\'',
    );
    await customStatement(
      'ALTER TABLE $table ADD COLUMN updated_at_millis INTEGER NOT NULL DEFAULT 0',
    );
    await customStatement(
      'ALTER TABLE $table ADD COLUMN sync_dirty INTEGER NOT NULL DEFAULT 1',
    );
    await customStatement(
      'ALTER TABLE $table ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
    );
  }

  /// Assigns sync ids to legacy rows once after schema upgrade.
  Future<void> _backfillSyncIds() async {
    final int now = nowMillis();
    final List<Session> sessionRows = await select(sessions).get();
    for (final Session row in sessionRows) {
      if (row.syncId.isNotEmpty) {
        continue;
      }
      await (update(sessions)..where((Sessions t) => t.id.equals(row.id))).write(
        SessionsCompanion(
          syncId: Value<String>(newSyncId()),
          updatedAtMillis: Value<int>(now),
          syncDirty: const Value<bool>(true),
        ),
      );
    }
    final List<Checkin> checkinRows = await select(checkins).get();
    for (final Checkin row in checkinRows) {
      if (row.syncId.isNotEmpty) {
        continue;
      }
      await (update(checkins)..where((Checkins t) => t.id.equals(row.id))).write(
        CheckinsCompanion(
          syncId: Value<String>(newSyncId()),
          updatedAtMillis: Value<int>(now),
          syncDirty: const Value<bool>(true),
        ),
      );
    }
    final List<HabitTick> habitRows = await select(habitTicks).get();
    for (final HabitTick row in habitRows) {
      if (row.syncId.isNotEmpty) {
        continue;
      }
      await (update(
        habitTicks,
      )..where((HabitTicks t) => t.id.equals(row.id))).write(
        HabitTicksCompanion(
          syncId: Value<String>(newSyncId()),
          updatedAtMillis: Value<int>(now),
          syncDirty: const Value<bool>(true),
        ),
      );
    }
    final List<WalkingLog> walkRows = await select(walkingLogs).get();
    for (final WalkingLog row in walkRows) {
      if (row.syncId.isNotEmpty) {
        continue;
      }
      await (update(
        walkingLogs,
      )..where((WalkingLogs t) => t.id.equals(row.id))).write(
        WalkingLogsCompanion(
          syncId: Value<String>(newSyncId()),
          updatedAtMillis: Value<int>(now),
          syncDirty: const Value<bool>(true),
        ),
      );
    }
  }

  Future<void> ensureSyncBackfill() async {
    await _backfillSyncIds();
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(sessions).go();
      await delete(checkins).go();
      await delete(habitTicks).go();
      await delete(walkingLogs).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'kegel_exercises.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
