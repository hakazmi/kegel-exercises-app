import 'cloud_secrets.dart';

/// Cloud config: `--dart-define` wins; falls back to [CloudSecrets]
/// (generated from android/local.properties).
abstract final class CloudConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: CloudSecrets.supabaseUrl,
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: CloudSecrets.supabaseAnonKey,
  );

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: CloudSecrets.googleWebClientId,
  );

  /// Kill switch: when false, auth UI can still show but sync is a no-op.
  static const bool cloudSyncEnabled = bool.fromEnvironment(
    'CLOUD_SYNC_ENABLED',
    defaultValue: CloudSecrets.cloudSyncEnabled,
  );

  static const String authCallbackUrl = 'kegel://auth-callback';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get googleConfigured => googleWebClientId.isNotEmpty;

  static bool get syncAllowed => isConfigured && cloudSyncEnabled;
}
