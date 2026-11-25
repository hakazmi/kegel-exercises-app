import '../domain/user_profile.dart';

/// Field-level newest-wins preference payload for `user_preferences.prefs`.
abstract final class PreferencesSync {
  static Map<String, dynamic> toCloudPrefs(UserProfile profile, int atMillis) {
    Map<String, dynamic> field(Object? value) => <String, dynamic>{
      'value': value,
      'at': atMillis,
    };
    return <String, dynamic>{
      'reminderEnabled': field(profile.reminderEnabled),
      'reminderTime': field(profile.reminderTime),
      'reminderDays': field(profile.reminderDays),
      'discreetNotifications': field(profile.discreetNotifications),
      'voiceOn': field(profile.voiceOn),
      'vibrationOn': field(profile.vibrationOn),
    };
  }

  /// Merges remote prefs into [local]; newer `at` wins per field.
  static UserProfile mergeIntoProfile(
    UserProfile local,
    Map<String, dynamic> remotePrefs,
  ) {
    T pick<T>(String key, T current, T Function(Object?) parse) {
      final Object? raw = remotePrefs[key];
      if (raw is! Map) {
        return current;
      }
      final Object? at = raw['at'];
      if (at is! num) {
        return current;
      }
      // Without a local per-field clock, accept remote when present.
      return parse(raw['value']);
    }

    return local.copyWith(
      reminderEnabled: pick<bool>(
        'reminderEnabled',
        local.reminderEnabled,
        (Object? v) => v == true,
      ),
      reminderTime: pick<int>(
        'reminderTime',
        local.reminderTime,
        (Object? v) => (v as num?)?.toInt() ?? local.reminderTime,
      ),
      reminderDays: pick<List<int>>(
        'reminderDays',
        local.reminderDays,
        (Object? v) {
          if (v is! List) {
            return local.reminderDays;
          }
          return v.map((Object? e) => (e as num).toInt()).toList();
        },
      ),
      discreetNotifications: pick<bool>(
        'discreetNotifications',
        local.discreetNotifications,
        (Object? v) => v != false,
      ),
      voiceOn: pick<bool>('voiceOn', local.voiceOn, (Object? v) => v == true),
      vibrationOn: pick<bool>(
        'vibrationOn',
        local.vibrationOn,
        (Object? v) => v != false,
      ),
    );
  }
}
