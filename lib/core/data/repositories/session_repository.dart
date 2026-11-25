import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/session_record.dart';
import '../database/app_database.dart';

/// CRUD for session rows in Drift.
class SessionRepository {
  SessionRepository(this._db, {this.onDirty});

  final AppDatabase _db;
  final void Function()? onDirty;

  Future<List<SessionRecord>> getAll() async {
    final List<Session> rows =
        await (_db.select(_db.sessions)
              ..where((Sessions t) => t.isDeleted.equals(false)))
            .get();
    return rows.map(_fromRow).toList();
  }

  Future<List<SessionRecord>> latest(int limit) async {
    final query = _db.select(_db.sessions)
      ..where((Sessions t) => t.isDeleted.equals(false))
      ..orderBy(<OrderingTerm Function(Sessions)>[
        (Sessions t) =>
            OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    final List<Session> rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  Future<int> insert(SessionRecord session) async {
    final int now = nowMillis();
    final int id = await _db
        .into(_db.sessions)
        .insert(
          SessionsCompanion.insert(
            startedAt: session.startedAt,
            completedAt: Value<DateTime?>(session.completedAt),
            level: session.level,
            dayInLevel: session.dayInLevel,
            track: session.track.storageValue,
            kind: Value<String>(session.kind.storageValue),
            durationSeconds: Value<int>(session.durationSeconds),
            longestHoldSeconds: Value<int>(session.longestHoldSeconds),
            completed: Value<bool>(session.completed),
            feel: Value<String?>(session.feel?.storageValue),
            syncId: Value<String>(newSyncId()),
            updatedAtMillis: Value<int>(now),
            syncDirty: const Value<bool>(true),
          ),
        );
    onDirty?.call();
    return id;
  }

  Future<void> clear() => _db.delete(_db.sessions).go();

  /// Soft-deletes every session whose calendar day matches [day].
  Future<int> deleteOnDay(DateTime day) async {
    final DateTime target = DateTime(day.year, day.month, day.day);
    final List<SessionRecord> all = await getAll();
    int removed = 0;
    final int now = nowMillis();
    for (final SessionRecord session in all) {
      final DateTime when = session.completedAt ?? session.startedAt;
      final DateTime sessionDay = DateTime(when.year, when.month, when.day);
      if (session.id == null ||
          sessionDay.year != target.year ||
          sessionDay.month != target.month ||
          sessionDay.day != target.day) {
        continue;
      }
      await (_db.update(
        _db.sessions,
      )..where((Sessions t) => t.id.equals(session.id!))).write(
        SessionsCompanion(
          isDeleted: const Value<bool>(true),
          syncDirty: const Value<bool>(true),
          updatedAtMillis: Value<int>(now),
        ),
      );
      removed += 1;
    }
    if (removed > 0) {
      onDirty?.call();
    }
    return removed;
  }

  SessionRecord _fromRow(Session row) {
    return SessionRecord(
      id: row.id,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      level: row.level,
      dayInLevel: row.dayInLevel,
      track: TrackIdX.parse(row.track),
      kind: SessionKindX.parse(row.kind),
      durationSeconds: row.durationSeconds,
      longestHoldSeconds: row.longestHoldSeconds,
      completed: row.completed,
      feel: SessionFeelX.tryParse(row.feel),
    );
  }
}
