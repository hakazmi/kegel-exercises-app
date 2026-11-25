import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/session_record.dart';
import '../database/app_database.dart';

/// CRUD for check-in rows in Drift (synced under RLS; never analytics).
class CheckInRepository {
  CheckInRepository(this._db, {this.onDirty});

  final AppDatabase _db;
  final void Function()? onDirty;

  Future<List<CheckInRecord>> getAll() async {
    final List<Checkin> rows =
        await (_db.select(_db.checkins)
              ..where((Checkins t) => t.isDeleted.equals(false)))
            .get();
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

  Future<int> insert(CheckInRecord checkIn) async {
    final int now = nowMillis();
    final int id = await _db
        .into(_db.checkins)
        .insert(
          CheckinsCompanion.insert(
            date: checkIn.date,
            goal: checkIn.goal.storageValue,
            score: checkIn.score,
            syncId: Value<String>(newSyncId()),
            updatedAtMillis: Value<int>(now),
            syncDirty: const Value<bool>(true),
          ),
        );
    onDirty?.call();
    return id;
  }

  Future<void> clear() => _db.delete(_db.checkins).go();
}
