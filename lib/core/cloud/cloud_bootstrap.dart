import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cloud_config.dart';

/// Initializes Supabase when URL + anon key are present.
Future<bool> bootstrapCloud() async {
  if (!CloudConfig.isConfigured) {
    debugPrint('Cloud: SUPABASE_URL / SUPABASE_ANON_KEY not set');
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
    return true;
  } on Object catch (e) {
    debugPrint('Cloud init failed: $e');
    return false;
  }
}
