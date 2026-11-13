import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/session_record.dart';
import '../database/app_database.dart';

/// CRUD for session rows in Drift.
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<List<SessionRecord>> getAll() async {
    final List<Session> rows =
        await _db.select(_db.sessions).get();
    return rows.map(_fromRow).toList();
  }

  Future<List<SessionRecord>> latest(int limit) async {
    final query = _db.select(_db.sessions)
      ..orderBy(<OrderingTerm Function(Sessions)>[
        (Sessions t) => OrderingTerm(
              expression: t.startedAt,
              mode: OrderingMode.desc,
            ),
      ])
      ..limit(limit);
    final List<Session> rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  Future<int> insert(SessionRecord session) {
    return _db.into(_db.sessions).insert(
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
          ),
        );
  }

  Future<void> clear() => _db.delete(_db.sessions).go();

  /// Deletes every session whose calendar day matches [day] (local date-only).
  Future<int> deleteOnDay(DateTime day) async {
    final DateTime target = DateTime(day.year, day.month, day.day);
    final List<SessionRecord> all = await getAll();
    int removed = 0;
    for (final SessionRecord session in all) {
      final DateTime when = session.completedAt ?? session.startedAt;
      final DateTime sessionDay = DateTime(when.year, when.month, when.day);
      if (session.id == null ||
          sessionDay.year != target.year ||
          sessionDay.month != target.month ||
          sessionDay.day != target.day) {
        continue;
      }
      await (_db.delete(_db.sessions)
            ..where((Sessions t) => t.id.equals(session.id!)))
          .go();
      removed += 1;
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
