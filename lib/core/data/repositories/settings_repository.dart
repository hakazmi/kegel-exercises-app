import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/user_profile.dart';

/// Persists [UserProfile] in shared_preferences.
class SettingsRepository {
  SettingsRepository(this._prefs);

  static const String _key = 'user_profile_v1';

  final SharedPreferences _prefs;

  UserProfile load() {
    final String? raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return UserProfile.initial();
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return UserProfile.initial();
    }
    return UserProfile.fromJson(decoded);
  }

  Future<void> save(UserProfile profile) async {
    await _prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
