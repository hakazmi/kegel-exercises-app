import '../../domain/enums.dart';
import '../../domain/session_record.dart';
import '../database/app_database.dart';

/// CRUD for check-in rows in Drift.
class CheckInRepository {
  CheckInRepository(this._db);

  final AppDatabase _db;

  Future<List<CheckInRecord>> getAll() async {
    final List<Checkin> rows = await _db.select(_db.checkins).get();
    return rows
        .map(
          (Checkin row) => CheckInRecord(
            id: row.id,
            date: row.date,
            goal: GoalX.parse(row.goal),
            score: row.score,
          ),
        )
        .toList();
  }

  Future<int> insert(CheckInRecord checkIn) {
    return _db.into(_db.checkins).insert(
          CheckinsCompanion.insert(
            date: checkIn.date,
            goal: checkIn.goal.storageValue,
            score: checkIn.score,
          ),
        );
  }

  Future<void> clear() => _db.delete(_db.checkins).go();
}
