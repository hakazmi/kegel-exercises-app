import 'package:supabase_flutter/supabase_flutter.dart';

/// User-safe auth / sync error messages (never include tokens or emails).
abstract final class CloudErrors {
  static String fromAuth(Object error) {
    final String message = error is AuthException ? error.message : '$error';
    final String code = error is AuthException ? (error.code ?? '') : '';
    final String hay = '$message $code $error'.toLowerCase();

    if (hay.contains('invalid login') ||
        hay.contains('invalid credentials') ||
        hay.contains('wrong password') ||
        hay.contains('invalid_credentials')) {
      return 'That email or password doesn’t look right.';
    }
    if (hay.contains('email not confirmed') ||
        hay.contains('not confirmed') ||
        hay.contains('email_not_confirmed')) {
      return 'Confirm your email, then try again.';
    }
    if (hay.contains('user already registered') ||
        hay.contains('already been registered') ||
        hay.contains('already registered')) {
      return 'An account with that email already exists. Try signing in.';
    }
    if (hay.contains('rate limit') || hay.contains('too many')) {
      return 'Too many attempts. Wait a minute and try again.';
    }
    if (hay.contains('network') ||
        hay.contains('socket') ||
        hay.contains('failed host lookup') ||
        hay.contains('offline') ||
        hay.contains('connection')) {
      return 'You’re offline. Connect to the internet and try again.';
    }
    if (hay.contains('cancel')) {
      return '';
    }
    if (hay.contains('provider is not enabled') ||
        hay.contains('unsupported provider')) {
      return 'That sign-in method isn’t enabled yet. Check Supabase Auth providers.';
    }
    if ((hay.contains('google') || hay.contains('id_token')) &&
        (hay.contains('audience') ||
            hay.contains('invalid') ||
            hay.contains('provider'))) {
      return 'Google sign-in isn’t fully configured. Use the Web client ID in Supabase and add this app’s SHA-1 in Google Cloud.';
    }
    if (hay.contains('provider') && hay.contains('google')) {
      return 'This email uses Google sign-in. Tap Continue with Google.';
    }
    return 'Something went wrong. Please try again.';
  }

  static String fromSync(Object error) {
    final String raw = '$error'.toLowerCase();
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('failed host lookup') ||
        raw.contains('offline')) {
      return 'Couldn’t back up — you’re offline.';
    }
    return 'Couldn’t back up right now. We’ll try again later.';
  }
}
