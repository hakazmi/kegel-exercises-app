import 'package:drift/drift.dart';

import '../../time/app_clock.dart';
import '../database/app_database.dart';

/// Local habit ticks — never sent off-device.
class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;

  Future<Set<String>> doneHabitIdsOn(DateTime day) async {
    final DateTime d = dateOnly(day);
    final List<HabitTick> rows = await (_db.select(_db.habitTicks)
          ..where((HabitTicks t) => t.date.equals(d)))
        .get();
    return rows.map((HabitTick r) => r.habitId).toSet();
  }

  Future<void> markDone({
    required String habitId,
    required DateTime day,
  }) async {
    final DateTime d = dateOnly(day);
    final Set<String> existing = await doneHabitIdsOn(d);
    if (existing.contains(habitId)) {
      return;
    }
    await _db.into(_db.habitTicks).insert(
          HabitTicksCompanion.insert(date: d, habitId: habitId),
        );
  }

  /// Removes today's tick so an accidental tap can be undone.
  Future<void> markUndone({
    required String habitId,
    required DateTime day,
  }) async {
    final DateTime d = dateOnly(day);
    await (_db.delete(_db.habitTicks)
          ..where(
            (HabitTicks t) => t.habitId.equals(habitId) & t.date.equals(d),
          ))
        .go();
  }

  /// Ticks or unticks a habit for [day]. Safe to call repeatedly.
  Future<bool> toggle({
    required String habitId,
    required DateTime day,
  }) async {
    final Set<String> existing = await doneHabitIdsOn(day);
    if (existing.contains(habitId)) {
      await markUndone(habitId: habitId, day: day);
      return false;
    }
    await markDone(habitId: habitId, day: day);
    return true;
  }

  Future<void> clearAll() async {
    await _db.delete(_db.habitTicks).go();
  }
}

/// Self-reported walking minutes.
class WalkingRepository {
  WalkingRepository(this._db);

  final AppDatabase _db;

  Future<int> minutesOn(DateTime day) async {
    final DateTime d = dateOnly(day);
    final DateTime next = d.add(const Duration(days: 1));
    final List<WalkingLog> rows = await (_db.select(_db.walkingLogs)
          ..where(
            (WalkingLogs t) =>
                t.date.isBiggerOrEqualValue(d) & t.date.isSmallerThanValue(next),
          ))
        .get();
    return rows.fold<int>(0, (int sum, WalkingLog r) => sum + r.minutes);
  }

  /// Minutes and distinct trained days in the week containing [day] (Mon–Sun).
  Future<({int minutes, int days})> weekStats(DateTime day) async {
    final DateTime d = dateOnly(day);
    final DateTime monday = d.subtract(Duration(days: d.weekday - 1));
    final DateTime nextMonday = monday.add(const Duration(days: 7));
    final List<WalkingLog> rows = await (_db.select(_db.walkingLogs)
          ..where(
            (WalkingLogs t) =>
                t.date.isBiggerOrEqualValue(monday) &
                t.date.isSmallerThanValue(nextMonday),
          ))
        .get();
    final Set<DateTime> days = <DateTime>{};
    int minutes = 0;
    for (final WalkingLog r in rows) {
      if (r.minutes <= 0) {
        continue;
      }
      minutes += r.minutes;
      days.add(dateOnly(r.date));
    }
    return (minutes: minutes, days: days.length);
  }

  Future<void> addMinutes({
    required DateTime day,
    required int minutes,
  }) async {
    if (minutes <= 0) {
      return;
    }
    await _db.into(_db.walkingLogs).insert(
          WalkingLogsCompanion.insert(date: dateOnly(day), minutes: minutes),
        );
  }

  Future<void> clearAll() async {
    await _db.delete(_db.walkingLogs).go();
  }
}
