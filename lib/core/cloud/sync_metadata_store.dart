import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Prefs-backed dirty flags and sync cursors (profile / preferences / hold tests).
class SyncMetadataStore {
  SyncMetadataStore(this._prefs);

  static const String _profileDirtyKey = 'sync_profile_dirty_v1';
  static const String _prefsDirtyKey = 'sync_prefs_dirty_v1';
  static const String _profileMillisKey = 'sync_profile_millis_v1';
  static const String _prefsMillisKey = 'sync_prefs_millis_v1';
  static const String _pullCursorKey = 'sync_pull_cursor_v1';
  static const String _lastSyncKey = 'sync_last_at_v1';
  static const String _lastErrorKey = 'sync_last_error_v1';
  static const String _lastAuthUserKey = 'sync_last_auth_user_v1';
  static const String _backfillDoneKey = 'sync_backfill_done_v1';
  static const String _deviceTouchedDayKey = 'sync_device_touched_day_v1';
  static const String _holdDirtyKey = 'sync_hold_dirty_ids_v1';
  static const String _displayNameKey = 'sync_display_name_v1';

  final SharedPreferences _prefs;

  bool get profileDirty => _prefs.getBool(_profileDirtyKey) ?? false;
  bool get prefsDirty => _prefs.getBool(_prefsDirtyKey) ?? false;
  bool get backfillDone => _prefs.getBool(_backfillDoneKey) ?? false;

  int get profileUpdatedAtMillis => _prefs.getInt(_profileMillisKey) ?? 0;
  int get prefsUpdatedAtMillis => _prefs.getInt(_prefsMillisKey) ?? 0;

  String? get pullCursorIso => _prefs.getString(_pullCursorKey);
  String? get lastSyncIso => _prefs.getString(_lastSyncKey);
  String? get lastError => _prefs.getString(_lastErrorKey);
  String? get lastAuthUserId => _prefs.getString(_lastAuthUserKey);
  String? get displayName => _prefs.getString(_displayNameKey);
  String? get deviceTouchedDay => _prefs.getString(_deviceTouchedDayKey);

  Set<String> get dirtyHoldSyncIds {
    final String? raw = _prefs.getString(_holdDirtyKey);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String>{};
      }
      return decoded.map((Object? e) => '$e').toSet();
    } on FormatException {
      return <String>{};
    }
  }

  Future<void> markProfileDirty({int? atMillis}) async {
    final int at = atMillis ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    await _prefs.setBool(_profileDirtyKey, true);
    await _prefs.setInt(_profileMillisKey, at);
  }

  Future<void> markPrefsDirty({int? atMillis}) async {
    final int at = atMillis ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    await _prefs.setBool(_prefsDirtyKey, true);
    await _prefs.setInt(_prefsMillisKey, at);
  }

  Future<void> clearProfileDirtyIf(int sentAt) async {
    if (profileUpdatedAtMillis == sentAt) {
      await _prefs.setBool(_profileDirtyKey, false);
    }
  }

  Future<void> clearPrefsDirtyIf(int sentAt) async {
    if (prefsUpdatedAtMillis == sentAt) {
      await _prefs.setBool(_prefsDirtyKey, false);
    }
  }

  Future<void> setProfileUpdatedAtMillis(int millis) =>
      _prefs.setInt(_profileMillisKey, millis);

  Future<void> setPrefsUpdatedAtMillis(int millis) =>
      _prefs.setInt(_prefsMillisKey, millis);

  Future<void> setPullCursor(String? iso) async {
    if (iso == null) {
      await _prefs.remove(_pullCursorKey);
    } else {
      await _prefs.setString(_pullCursorKey, iso);
    }
  }

  Future<void> setLastSync(DateTime at) =>
      _prefs.setString(_lastSyncKey, at.toUtc().toIso8601String());

  Future<void> setLastError(String? message) async {
    if (message == null || message.isEmpty) {
      await _prefs.remove(_lastErrorKey);
    } else {
      await _prefs.setString(_lastErrorKey, message);
    }
  }

  Future<void> setLastAuthUserId(String? userId) async {
    if (userId == null || userId.isEmpty) {
      await _prefs.remove(_lastAuthUserKey);
    } else {
      await _prefs.setString(_lastAuthUserKey, userId);
    }
  }

  Future<void> setBackfillDone(bool done) =>
      _prefs.setBool(_backfillDoneKey, done);

  Future<void> setDeviceTouchedDay(String dayKey) =>
      _prefs.setString(_deviceTouchedDayKey, dayKey);

  Future<void> setDisplayName(String? name) async {
    if (name == null || name.trim().isEmpty) {
      await _prefs.remove(_displayNameKey);
    } else {
      await _prefs.setString(_displayNameKey, name.trim());
    }
  }

  Future<void> markHoldDirty(String syncId) async {
    final Set<String> ids = dirtyHoldSyncIds..add(syncId);
    await _prefs.setString(_holdDirtyKey, jsonEncode(ids.toList()));
  }

  Future<void> clearHoldDirty(Iterable<String> syncedIds) async {
    final Set<String> ids = dirtyHoldSyncIds
      ..removeAll(syncedIds);
    await _prefs.setString(_holdDirtyKey, jsonEncode(ids.toList()));
  }

  Future<void> clearSyncState() async {
    await _prefs.remove(_profileDirtyKey);
    await _prefs.remove(_prefsDirtyKey);
    await _prefs.remove(_profileMillisKey);
    await _prefs.remove(_prefsMillisKey);
    await _prefs.remove(_pullCursorKey);
    await _prefs.remove(_lastSyncKey);
    await _prefs.remove(_lastErrorKey);
    await _prefs.remove(_backfillDoneKey);
    await _prefs.remove(_deviceTouchedDayKey);
    await _prefs.remove(_holdDirtyKey);
    // Keep lastAuthUserId for account-switch detection after sign-out.
  }

  Future<void> clearAllIncludingAuthHint() async {
    await clearSyncState();
    await _prefs.remove(_lastAuthUserKey);
    await _prefs.remove(_displayNameKey);
  }
}
