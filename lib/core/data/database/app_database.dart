import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

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
  IntColumn get longestHoldSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get feel => text().nullable()();
}

/// Drift table for goal check-ins (scores stay on device).
class Checkins extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get goal => text()();
  IntColumn get score => integer()();
}

/// Tick-only daily habits (never affect streak or unlock).
class HabitTicks extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get habitId => text()();
}

/// Self-reported walking minutes by calendar day.
class WalkingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get minutes => integer()();
}

/// Local SQLite database.
@DriftDatabase(tables: <Type>[Sessions, Checkins, HabitTicks, WalkingLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

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
        },
      );

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
