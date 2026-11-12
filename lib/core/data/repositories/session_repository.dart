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
