import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// App-generated anonymous install id for Crashlytics.
///
/// Not a device serial, Advertising ID, email, or Supabase user id.
class InstallationId {
  InstallationId._();

  static const String _prefsKey = 'crashlytics_installation_id';

  /// Returns the existing id or creates one.
  static String get(SharedPreferences prefs) {
    final String? existing = prefs.getString(_prefsKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final String created = const Uuid().v4();
    prefs.setString(_prefsKey, created);
    return created;
  }

  /// Clears and returns a fresh id (after reset data / delete account).
  static String reset(SharedPreferences prefs) {
    prefs.remove(_prefsKey);
    return get(prefs);
  }
}
