import 'dart:async';

import 'package:drift/drift.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../data/database/app_database.dart';
import '../data/repositories/hold_test_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../diagnostics/crash_reporting.dart';
import '../diagnostics/performance_traces.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';
import 'cloud_config.dart';
import 'cloud_errors.dart';
import 'device_id.dart';
import 'preferences_sync.dart';
import 'profile_payload.dart';
import 'sync_metadata_store.dart';

class SyncResult {
  const SyncResult({this.ok = true, this.errorMessage});

  final bool ok;
  final String? errorMessage;
}

/// Offline-first push/pull against kegel_* RPCs.
class SyncRepository {
  SyncRepository({
    required AppDatabase db,
    required SettingsRepository settings,
    required HoldTestRepository holdTests,
    required SyncMetadataStore meta,
    required DeviceIdStore deviceId,
    required AppClock clock,
    SupabaseClient? client,
  }) : _db = db,
       _settings = settings,
       _holdTests = holdTests,
       _meta = meta,
       _deviceId = deviceId,
       _clock = clock,
       _client = client;

  final AppDatabase _db;
  final SettingsRepository _settings;
  final HoldTestRepository _holdTests;
  final SyncMetadataStore _meta;
  final DeviceIdStore _deviceId;
  final AppClock _clock;
  SupabaseClient? _client;

  bool _busy = false;

  SupabaseClient? get _supabase {
    if (_client != null) {
      return _client;
    }
    if (!CloudConfig.syncAllowed) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } on Object {
      return null;
    }
  }

  String? get expectedUserId => _supabase?.auth.currentUser?.id;

  Future<int> pendingCount() async {
    final int sessions = await (_db.select(
      _db.sessions,
    )..where((Sessions t) => t.syncDirty.equals(true))).get().then((r) => r.length);
    final int checkins = await (_db.select(
      _db.checkins,
    )..where((Checkins t) => t.syncDirty.equals(true))).get().then((r) => r.length);
    final int habits = await (_db.select(
      _db.habitTicks,
    )..where((HabitTicks t) => t.syncDirty.equals(true))).get().then((r) => r.length);
    final int walks = await (_db.select(
      _db.walkingLogs,
    )..where((WalkingLogs t) => t.syncDirty.equals(true))).get().then((r) => r.length);
    int n = sessions + checkins + habits + walks;
    if (_meta.profileDirty) {
      n += 1;
    }
    if (_meta.prefsDirty) {
      n += 1;
    }
    n += _meta.dirtyHoldSyncIds.length;
    return n;
  }

  Future<SyncResult> syncAll({String? expectedUserId}) async {
    if (_busy) {
      return const SyncResult();
    }
    _busy = true;
    try {
      final SyncResult pull = await pullAll(expectedUserId: expectedUserId);
      if (!pull.ok) {
        return pull;
      }
      return await pushAll(expectedUserId: expectedUserId);
    } finally {
      _busy = false;
    }
  }

  Future<SyncResult> pushAll({String? expectedUserId}) async {
    final SupabaseClient? client = _supabase;
    final String? uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) {
      return const SyncResult();
    }
    if (expectedUserId != null && expectedUserId != uid) {
      return const SyncResult(
        ok: false,
        errorMessage: 'Account changed. Sync skipped.',
      );
    }
    final Trace? pushTrace = PerfTraces.start('sync_push');
    CrashReporting.log('sync: push start');
    try {
      await _db.ensureSyncBackfill();
      final int pending = await pendingCount();
      PerfTraces.putMetric(pushTrace, 'row_count', pending);

      if (_meta.profileDirty) {
        final int sentAt = _meta.profileUpdatedAtMillis;
        final UserProfile profile = _settings.load();
        final Map<String, dynamic> payload = ProfilePayload.toJson(
          profile: profile,
          updatedAtMillis: sentAt,
          displayName: _meta.displayName,
          guideSeenAtIso: _holdTests.guideSeenOn()?.toUtc().toIso8601String(),
        );
        await client.rpc('kegel_upsert_profile', params: <String, dynamic>{
          'p_profile': payload,
        });
        await _meta.clearProfileDirtyIf(sentAt);
      }

      if (_meta.prefsDirty) {
        final int sentAt = _meta.prefsUpdatedAtMillis;
        final UserProfile profile = _settings.load();
        final Map<String, dynamic> prefs = PreferencesSync.toCloudPrefs(
          profile,
          sentAt,
        );
        await client.from('user_preferences').upsert(<String, dynamic>{
          'user_id': uid,
          'prefs': prefs,
          'updated_at_millis': sentAt,
        });
        await _meta.clearPrefsDirtyIf(sentAt);
      }

      await _pushSessions(client);
      await _pushHabitTicks(client);
      await _pushWalking(client);
      await _pushCheckins(client);
      await _pushHoldTests(client);
      await _touchDevice(client);

      await _meta.setLastError(null);
      await _meta.setLastSync(_clock.now());
      CrashReporting.log('sync: push ok');
      await PerfTraces.stop(pushTrace);
      return const SyncResult();
    } on Object catch (e, st) {
      PerfTraces.abandon(pushTrace);
      debugPrint('Sync push failed: $e');
      CrashReporting.log('sync: push fail');
      unawaited(CrashReporting.record(e, stackTrace: st));
      final String msg = CloudErrors.fromSync(e);
      await _meta.setLastError(msg);
      return SyncResult(ok: false, errorMessage: msg);
    }
  }

  Future<SyncResult> pullAll({String? expectedUserId}) async {
    final SupabaseClient? client = _supabase;
    final String? uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) {
      return const SyncResult();
    }
    if (expectedUserId != null && expectedUserId != uid) {
      return const SyncResult(
        ok: false,
        errorMessage: 'Account changed. Sync skipped.',
      );
    }
    final Trace? pullTrace = PerfTraces.start('sync_pull');
    CrashReporting.log('sync: pull start');
    try {
      await _db.ensureSyncBackfill();

      // Profile
      final Map<String, dynamic>? profileRow = await client
          .from('profiles')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      if (profileRow != null) {
        final int remoteMillis =
            (profileRow['updated_at_millis'] as num?)?.toInt() ?? 0;
        final UserProfile local = _settings.load();
        if (remoteMillis >= _meta.profileUpdatedAtMillis ||
            (profileRow['onboarding_done'] == true && !local.onboardingDone)) {
          final UserProfile merged = ProfilePayload.applyRemote(
            local: local,
            remote: profileRow,
          );
          // Keep local-only safety flags.
          await _settings.save(
            merged.copyWith(safetyFlags: local.safetyFlags),
          );
          await _meta.setProfileUpdatedAtMillis(remoteMillis);
          final String? name = profileRow['display_name'] as String?;
          if (name != null && name.isNotEmpty) {
            await _meta.setDisplayName(name);
          }
        }
      }

      // Preferences
      final Map<String, dynamic>? prefsRow = await client
          .from('user_preferences')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      if (prefsRow != null) {
        final int remoteMillis =
            (prefsRow['updated_at_millis'] as num?)?.toInt() ?? 0;
        if (remoteMillis >= _meta.prefsUpdatedAtMillis) {
          final Object? prefsRaw = prefsRow['prefs'];
          if (prefsRaw is Map) {
            final UserProfile local = _settings.load();
            final UserProfile merged = PreferencesSync.mergeIntoProfile(
              local,
              Map<String, dynamic>.from(prefsRaw),
            );
            await _settings.save(merged);
            await _meta.setPrefsUpdatedAtMillis(remoteMillis);
          }
        }
      }

      DateTime? since;
      final String? cursor = _meta.pullCursorIso;
      if (cursor != null) {
        since = DateTime.tryParse(cursor)?.subtract(const Duration(seconds: 5));
      }

      await _pullSessions(client, uid, since);
      await _pullHabitTicks(client, uid, since);
      await _pullWalking(client, uid, since);
      await _pullCheckins(client, uid, since);
      await _pullHoldTests(client, uid);

      await _meta.setPullCursor(DateTime.now().toUtc().toIso8601String());
      await _meta.setLastError(null);
      await _meta.setLastSync(_clock.now());
      CrashReporting.log('sync: pull ok');
      await PerfTraces.stop(pullTrace);
      return const SyncResult();
    } on Object catch (e, st) {
      PerfTraces.abandon(pullTrace);
      debugPrint('Sync pull failed: $e');
      CrashReporting.log('sync: pull fail');
      unawaited(CrashReporting.record(e, stackTrace: st));
      final String msg = CloudErrors.fromSync(e);
      await _meta.setLastError(msg);
      return SyncResult(ok: false, errorMessage: msg);
    }
  }

  Future<void> _pushSessions(SupabaseClient client) async {
    final List<Session> rows = await (_db.select(
      _db.sessions,
    )..where((Sessions t) => t.syncDirty.equals(true))).get();
    if (rows.isEmpty) {
      return;
    }
    final List<Map<String, dynamic>> payload = <Map<String, dynamic>>[
      for (final Session r in rows)
        <String, dynamic>{
          'sync_id': r.syncId,
          'started_at': r.startedAt.toUtc().toIso8601String(),
          'completed_at': r.completedAt?.toUtc().toIso8601String(),
          'level': r.level,
          'day_in_level': r.dayInLevel,
          'track': r.track,
          'kind': r.kind,
          'duration_seconds': r.durationSeconds,
          'longest_hold_seconds': r.longestHoldSeconds,
          'completed': r.completed,
          'updated_at_millis': r.updatedAtMillis,
          'is_deleted': r.isDeleted,
          // feel intentionally omitted
        },
    ];
    await client.rpc(
      'kegel_upsert_sessions',
      params: <String, dynamic>{'p_rows': payload},
    );
    for (final Session r in rows) {
      await (_db.update(_db.sessions)..where(
            (Sessions t) =>
                t.id.equals(r.id) & t.updatedAtMillis.equals(r.updatedAtMillis),
          ))
          .write(const SessionsCompanion(syncDirty: Value<bool>(false)));
    }
  }

  Future<void> _pushHabitTicks(SupabaseClient client) async {
    final List<HabitTick> rows = await (_db.select(
      _db.habitTicks,
    )..where((HabitTicks t) => t.syncDirty.equals(true))).get();
    if (rows.isEmpty) {
      return;
    }
    final List<Map<String, dynamic>> payload = <Map<String, dynamic>>[
      for (final HabitTick r in rows)
        <String, dynamic>{
          'sync_id': r.syncId,
          'day': ProfilePayload.dateOnly(r.date),
          'habit_id': r.habitId,
          'updated_at_millis': r.updatedAtMillis,
          'is_deleted': r.isDeleted,
        },
    ];
    await client.rpc(
      'kegel_upsert_habit_ticks',
      params: <String, dynamic>{'p_rows': payload},
    );
    for (final HabitTick r in rows) {
      await (_db.update(_db.habitTicks)..where(
            (HabitTicks t) =>
                t.id.equals(r.id) & t.updatedAtMillis.equals(r.updatedAtMillis),
          ))
          .write(const HabitTicksCompanion(syncDirty: Value<bool>(false)));
    }
  }

  Future<void> _pushWalking(SupabaseClient client) async {
    final List<WalkingLog> rows = await (_db.select(
      _db.walkingLogs,
    )..where((WalkingLogs t) => t.syncDirty.equals(true))).get();
    if (rows.isEmpty) {
      return;
    }
    final List<Map<String, dynamic>> payload = <Map<String, dynamic>>[
      for (final WalkingLog r in rows)
        <String, dynamic>{
          'sync_id': r.syncId,
          'day': ProfilePayload.dateOnly(r.date),
          'minutes': r.minutes,
          'updated_at_millis': r.updatedAtMillis,
          'is_deleted': r.isDeleted,
        },
    ];
    await client.rpc(
      'kegel_upsert_walking_logs',
      params: <String, dynamic>{'p_rows': payload},
    );
    for (final WalkingLog r in rows) {
      await (_db.update(_db.walkingLogs)..where(
            (WalkingLogs t) =>
                t.id.equals(r.id) & t.updatedAtMillis.equals(r.updatedAtMillis),
          ))
          .write(const WalkingLogsCompanion(syncDirty: Value<bool>(false)));
    }
  }

  Future<void> _pushCheckins(SupabaseClient client) async {
    final List<Checkin> rows = await (_db.select(
      _db.checkins,
    )..where((Checkins t) => t.syncDirty.equals(true))).get();
    if (rows.isEmpty) {
      return;
    }
    final List<Map<String, dynamic>> payload = <Map<String, dynamic>>[
      for (final Checkin r in rows)
        <String, dynamic>{
          'sync_id': r.syncId,
          'day': ProfilePayload.dateOnly(r.date),
          'goal': r.goal,
          'score': r.score,
          'updated_at_millis': r.updatedAtMillis,
          'is_deleted': r.isDeleted,
        },
    ];
    await client.rpc(
      'kegel_upsert_checkins',
      params: <String, dynamic>{'p_rows': payload},
    );
    for (final Checkin r in rows) {
      await (_db.update(_db.checkins)..where(
            (Checkins t) =>
                t.id.equals(r.id) & t.updatedAtMillis.equals(r.updatedAtMillis),
          ))
          .write(const CheckinsCompanion(syncDirty: Value<bool>(false)));
    }
  }

  Future<void> _pushHoldTests(SupabaseClient client) async {
    final Set<String> dirty = _meta.dirtyHoldSyncIds;
    if (dirty.isEmpty) {
      return;
    }
    final List<HoldTestResult> all = _holdTests.all();
    final List<Map<String, dynamic>> payload = <Map<String, dynamic>>[];
    // Hold tests in prefs may not store syncId yet — use dirty ids as keys
    // matched by reconstructing from meta + results index.
    for (final String syncId in dirty) {
      HoldTestResult? match;
      for (final HoldTestResult r in all) {
        // Prefer matching via embedded sync id in future; for now upload all
        // dirty by pairing with stored mapping in prefs JSON if present.
        if (r.toJson()['syncId'] == syncId) {
          match = r;
          break;
        }
      }
      if (match == null) {
        continue;
      }
      payload.add(<String, dynamic>{
        'sync_id': syncId,
        'held_at': match.at.toUtc().toIso8601String(),
        'seconds': match.seconds.round(),
      });
    }
    if (payload.isEmpty) {
      // Fallback: upload every hold test once if dirty set non-empty but unmatched.
      for (final HoldTestResult r in all) {
        final Object? sid = r.toJson()['syncId'];
        if (sid is String && dirty.contains(sid)) {
          payload.add(<String, dynamic>{
            'sync_id': sid,
            'held_at': r.at.toUtc().toIso8601String(),
            'seconds': r.seconds.round(),
          });
        }
      }
    }
    if (payload.isEmpty) {
      return;
    }
    await client.rpc(
      'kegel_insert_hold_tests',
      params: <String, dynamic>{'p_rows': payload},
    );
    await _meta.clearHoldDirty(payload.map((m) => m['sync_id'] as String));
  }

  Future<void> _touchDevice(SupabaseClient client) async {
    final DateTime now = _clock.now();
    final String dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_meta.deviceTouchedDay == dayKey) {
      return;
    }
    final String hash = await _deviceId.hashedDeviceId();
    String? version;
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } on Object {
      version = null;
    }
    await client.from('devices').upsert(<String, dynamic>{
      'user_id': client.auth.currentUser!.id,
      'device_id': hash,
      'app_version': version,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _meta.setDeviceTouchedDay(dayKey);
  }

  Future<void> _pullSessions(
    SupabaseClient client,
    String uid,
    DateTime? since,
  ) async {
    var query = client.from('sessions').select().eq('user_id', uid);
    if (since != null) {
      query = query.gt('updated_at', since.toUtc().toIso8601String());
    }
    final List<dynamic> rows = await query;
    for (final dynamic raw in rows) {
      final Map<String, dynamic> r = Map<String, dynamic>.from(raw as Map);
      final String syncId = '${r['sync_id']}';
      final int remoteMillis = (r['updated_at_millis'] as num?)?.toInt() ?? 0;
      final bool deleted = r['is_deleted'] == true;
      final List<Session> existing = await (_db.select(
        _db.sessions,
      )..where((Sessions t) => t.syncId.equals(syncId))).get();
      if (existing.isNotEmpty) {
        final Session local = existing.first;
        if (local.updatedAtMillis >= remoteMillis) {
          continue;
        }
        if (deleted) {
          await (_db.delete(
            _db.sessions,
          )..where((Sessions t) => t.id.equals(local.id))).go();
          continue;
        }
        await (_db.update(
          _db.sessions,
        )..where((Sessions t) => t.id.equals(local.id))).write(
          SessionsCompanion(
            startedAt: Value<DateTime>(
              DateTime.parse('${r['started_at']}').toLocal(),
            ),
            completedAt: Value<DateTime?>(
              r['completed_at'] == null
                  ? null
                  : DateTime.parse('${r['completed_at']}').toLocal(),
            ),
            level: Value<int>((r['level'] as num).toInt()),
            dayInLevel: Value<int>((r['day_in_level'] as num).toInt()),
            track: Value<String>('${r['track']}'),
            kind: Value<String>('${r['kind']}'),
            durationSeconds: Value<int>(
              (r['duration_seconds'] as num?)?.toInt() ?? 0,
            ),
            longestHoldSeconds: Value<int>(
              (r['longest_hold_seconds'] as num?)?.toInt() ?? 0,
            ),
            completed: Value<bool>(r['completed'] == true),
            updatedAtMillis: Value<int>(remoteMillis),
            syncDirty: const Value<bool>(false),
            isDeleted: const Value<bool>(false),
          ),
        );
      } else if (!deleted) {
        await _db
            .into(_db.sessions)
            .insert(
              SessionsCompanion.insert(
                startedAt: DateTime.parse('${r['started_at']}').toLocal(),
                completedAt: Value<DateTime?>(
                  r['completed_at'] == null
                      ? null
                      : DateTime.parse('${r['completed_at']}').toLocal(),
                ),
                level: (r['level'] as num).toInt(),
                dayInLevel: (r['day_in_level'] as num).toInt(),
                track: '${r['track']}',
                kind: Value<String>('${r['kind']}'),
                durationSeconds: Value<int>(
                  (r['duration_seconds'] as num?)?.toInt() ?? 0,
                ),
                longestHoldSeconds: Value<int>(
                  (r['longest_hold_seconds'] as num?)?.toInt() ?? 0,
                ),
                completed: Value<bool>(r['completed'] == true),
                syncId: Value<String>(syncId),
                updatedAtMillis: Value<int>(remoteMillis),
                syncDirty: const Value<bool>(false),
              ),
            );
      }
    }
  }

  Future<void> _pullHabitTicks(
    SupabaseClient client,
    String uid,
    DateTime? since,
  ) async {
    var query = client.from('habit_ticks').select().eq('user_id', uid);
    if (since != null) {
      query = query.gt('updated_at', since.toUtc().toIso8601String());
    }
    final List<dynamic> rows = await query;
    for (final dynamic raw in rows) {
      final Map<String, dynamic> r = Map<String, dynamic>.from(raw as Map);
      final String syncId = '${r['sync_id']}';
      final int remoteMillis = (r['updated_at_millis'] as num?)?.toInt() ?? 0;
      final bool deleted = r['is_deleted'] == true;
      final List<HabitTick> existing = await (_db.select(
        _db.habitTicks,
      )..where((HabitTicks t) => t.syncId.equals(syncId))).get();
      if (existing.isNotEmpty) {
        final HabitTick local = existing.first;
        if (local.updatedAtMillis >= remoteMillis) {
          continue;
        }
        if (deleted) {
          await (_db.delete(
            _db.habitTicks,
          )..where((HabitTicks t) => t.id.equals(local.id))).go();
          continue;
        }
        await (_db.update(
          _db.habitTicks,
        )..where((HabitTicks t) => t.id.equals(local.id))).write(
          HabitTicksCompanion(
            date: Value<DateTime>(DateTime.parse('${r['day']}')),
            habitId: Value<String>('${r['habit_id']}'),
            updatedAtMillis: Value<int>(remoteMillis),
            syncDirty: const Value<bool>(false),
          ),
        );
      } else if (!deleted) {
        await _db
            .into(_db.habitTicks)
            .insert(
              HabitTicksCompanion.insert(
                date: DateTime.parse('${r['day']}'),
                habitId: '${r['habit_id']}',
                syncId: Value<String>(syncId),
                updatedAtMillis: Value<int>(remoteMillis),
                syncDirty: const Value<bool>(false),
              ),
            );
      }
    }
  }

  Future<void> _pullWalking(
    SupabaseClient client,
    String uid,
    DateTime? since,
  ) async {
    var query = client.from('walking_logs').select().eq('user_id', uid);
    if (since != null) {
      query = query.gt('updated_at', since.toUtc().toIso8601String());
    }
    final List<dynamic> rows = await query;
    for (final dynamic raw in rows) {
      final Map<String, dynamic> r = Map<String, dynamic>.from(raw as Map);
      final String syncId = '${r['sync_id']}';
      final int remoteMillis = (r['updated_at_millis'] as num?)?.toInt() ?? 0;
      final bool deleted = r['is_deleted'] == true;
      final List<WalkingLog> existing = await (_db.select(
        _db.walkingLogs,
      )..where((WalkingLogs t) => t.syncId.equals(syncId))).get();
      if (existing.isNotEmpty) {
        final WalkingLog local = existing.first;
        if (local.updatedAtMillis >= remoteMillis) {
          continue;
        }
        if (deleted) {
          await (_db.delete(
            _db.walkingLogs,
          )..where((WalkingLogs t) => t.id.equals(local.id))).go();
          continue;
        }
        await (_db.update(
          _db.walkingLogs,
        )..where((WalkingLogs t) => t.id.equals(local.id))).write(
          WalkingLogsCompanion(
            date: Value<DateTime>(DateTime.parse('${r['day']}')),
            minutes: Value<int>((r['minutes'] as num).toInt()),
            updatedAtMillis: Value<int>(remoteMillis),
            syncDirty: const Value<bool>(false),
          ),
        );
      } else if (!deleted) {
        await _db
            .into(_db.walkingLogs)
            .insert(
              WalkingLogsCompanion.insert(
                date: DateTime.parse('${r['day']}'),
                minutes: (r['minutes'] as num).toInt(),
                syncId: Value<String>(syncId),
                updatedAtMillis: Value<int>(remoteMillis),
                syncDirty: const Value<bool>(false),
              ),
            );
      }
    }
  }

  Future<void> _pullCheckins(
    SupabaseClient client,
    String uid,
    DateTime? since,
  ) async {
    var query = client.from('checkins').select().eq('user_id', uid);
    if (since != null) {
      query = query.gt('updated_at', since.toUtc().toIso8601String());
    }
    final List<dynamic> rows = await query;
    for (final dynamic raw in rows) {
      final Map<String, dynamic> r = Map<String, dynamic>.from(raw as Map);
      final String syncId = '${r['sync_id']}';
      final int remoteMillis = (r['updated_at_millis'] as num?)?.toInt() ?? 0;
      final bool deleted = r['is_deleted'] == true;
      final List<Checkin> existing = await (_db.select(
        _db.checkins,
      )..where((Checkins t) => t.syncId.equals(syncId))).get();
      if (existing.isNotEmpty) {
        final Checkin local = existing.first;
        if (local.updatedAtMillis >= remoteMillis) {
          continue;
        }
        if (deleted) {
          await (_db.delete(
            _db.checkins,
          )..where((Checkins t) => t.id.equals(local.id))).go();
          continue;
        }
        await (_db.update(
          _db.checkins,
        )..where((Checkins t) => t.id.equals(local.id))).write(
          CheckinsCompanion(
            date: Value<DateTime>(DateTime.parse('${r['day']}')),
            goal: Value<String>('${r['goal']}'),
            score: Value<int>((r['score'] as num).toInt()),
            updatedAtMillis: Value<int>(remoteMillis),
            syncDirty: const Value<bool>(false),
          ),
        );
      } else if (!deleted) {
        await _db
            .into(_db.checkins)
            .insert(
              CheckinsCompanion.insert(
                date: DateTime.parse('${r['day']}'),
                goal: '${r['goal']}',
                score: (r['score'] as num).toInt(),
                syncId: Value<String>(syncId),
                updatedAtMillis: Value<int>(remoteMillis),
                syncDirty: const Value<bool>(false),
              ),
            );
      }
    }
  }

  Future<void> _pullHoldTests(SupabaseClient client, String uid) async {
    final List<dynamic> rows = await client
        .from('hold_tests')
        .select()
        .eq('user_id', uid)
        .order('held_at');
    final List<HoldTestResult> local = _holdTests.all();
    final Set<String> localKeys = <String>{
      for (final HoldTestResult r in local)
        '${r.at.toUtc().toIso8601String()}|${r.seconds}',
    };
    for (final dynamic raw in rows) {
      final Map<String, dynamic> r = Map<String, dynamic>.from(raw as Map);
      final DateTime at = DateTime.parse('${r['held_at']}').toLocal();
      final double seconds = (r['seconds'] as num).toDouble();
      final String key = '${at.toUtc().toIso8601String()}|$seconds';
      if (localKeys.contains(key)) {
        continue;
      }
      await _holdTests.add(
        HoldTestResult(at: at, seconds: seconds, syncId: '${r['sync_id']}'),
      );
    }
  }

  Future<SyncResult> resetCloudData() async {
    final SupabaseClient? client = _supabase;
    if (client == null || client.auth.currentUser == null) {
      return const SyncResult();
    }
    try {
      await client.rpc('kegel_reset_my_data');
      return const SyncResult();
    } on Object catch (e) {
      return SyncResult(ok: false, errorMessage: CloudErrors.fromSync(e));
    }
  }

  Future<SyncResult> deleteAccount() async {
    final SupabaseClient? client = _supabase;
    if (client == null || client.auth.currentUser == null) {
      return const SyncResult();
    }
    try {
      await client.rpc('kegel_delete_my_account');
      return const SyncResult();
    } on Object catch (e) {
      return SyncResult(ok: false, errorMessage: CloudErrors.fromSync(e));
    }
  }
}
