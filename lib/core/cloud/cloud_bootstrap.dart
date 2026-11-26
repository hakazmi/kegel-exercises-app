import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../diagnostics/crash_reporting.dart';
import 'cloud_config.dart';

/// Initializes Supabase when URL + anon key are present.
Future<bool> bootstrapCloud() async {
  if (!CloudConfig.isConfigured) {
    debugPrint('Cloud: SUPABASE_URL / SUPABASE_ANON_KEY not set');
    CrashReporting.setKey('cloud_sync_enabled', false);
    return false;
  }
  try {
    debugPrint(
      'Cloud init url=${CloudConfig.supabaseUrl.isNotEmpty} '
      'keyLen=${CloudConfig.supabaseAnonKey.length} '
      'google=${CloudConfig.googleConfigured}',
    );
    await Supabase.initialize(
      url: CloudConfig.supabaseUrl,
      // New Supabase publishable keys (sb_publishable_…) and legacy anon JWTs.
      publishableKey: CloudConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: true,
      ),
    );
    CrashReporting.setKey('cloud_sync_enabled', true);
    CrashReporting.log('cloud: supabase ready');
    return true;
  } on Object catch (e, st) {
    debugPrint('Cloud init failed: $e');
    CrashReporting.setKey('cloud_sync_enabled', false);
    CrashReporting.log('cloud: init failed');
    await CrashReporting.record(e, stackTrace: st);
    return false;
  }
}
