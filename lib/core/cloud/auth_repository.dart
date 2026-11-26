import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../diagnostics/crash_reporting.dart';
import 'cloud_config.dart';
import 'cloud_errors.dart';

enum AuthMode { signIn, signUp }

class AuthResult {
  const AuthResult({
    this.session,
    this.needsEmailConfirmation = false,
    this.errorMessage,
    this.cancelled = false,
  });

  final Session? session;
  final bool needsEmailConfirmation;
  final String? errorMessage;
  final bool cancelled;

  bool get ok => session != null || needsEmailConfirmation || cancelled;
}

/// Email + Google auth against Supabase.
class AuthRepository {
  AuthRepository();

  static const String _debugSha1 =
      '9F:1E:79:D7:56:7A:04:F8:B7:48:30:B8:C2:A8:96:54:8C:6B:E3:76';

  bool _googleReady = false;
  String? _googleRawNonce;

  bool get isConfigured => CloudConfig.isConfigured;

  SupabaseClient? get _client {
    if (!CloudConfig.isConfigured) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } on Object {
      return null;
    }
  }

  Session? get currentSession => _client?.auth.currentSession;
  User? get currentUser => _client?.auth.currentUser;
  bool get isSignedIn => currentSession != null;

  Stream<AuthState> get authStateChanges {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Stream<AuthState>.empty();
    }
    return client.auth.onAuthStateChange;
  }

  Future<void> restoreSession() async {}

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const AuthResult(
        errorMessage: 'Sign-in isn’t set up in this build.',
      );
    }
    CrashReporting.log('auth: email sign-in start');
    try {
      final AuthResponse res = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.session == null) {
        CrashReporting.log('auth: email sign-in no session');
        return const AuthResult(
          errorMessage: 'Couldn’t sign in. Check your email and password.',
        );
      }
      CrashReporting.setKey('signed_in', true);
      CrashReporting.log('auth: email sign-in ok');
      return AuthResult(session: res.session);
    } on AuthException catch (e) {
      debugPrint('Email sign-in AuthException: ${e.message} code=${e.code}');
      CrashReporting.log('auth: email sign-in fail code=${e.code}');
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    } on Object catch (e, st) {
      debugPrint('Email sign-in error: $e');
      CrashReporting.log('auth: email sign-in error');
      unawaited(CrashReporting.record(e, stackTrace: st));
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    }
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const AuthResult(
        errorMessage: 'Sign-in isn’t set up in this build.',
      );
    }
    try {
      final AuthResponse res = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: <String, dynamic>{'name': name.trim()},
        emailRedirectTo: CloudConfig.authCallbackUrl,
      );
      if (res.session == null) {
        return const AuthResult(needsEmailConfirmation: true);
      }
      return AuthResult(session: res.session);
    } on AuthException catch (e) {
      debugPrint('Email sign-up AuthException: ${e.message} code=${e.code}');
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    } on Object catch (e) {
      debugPrint('Email sign-up error: $e');
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    }
  }

  /// FocusFlow-style nonce: hashed value to Google, raw value to Supabase.
  static String _newRawNonce() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String _sha256Hex(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) {
      return;
    }
    final String rawNonce = _newRawNonce();
    final String hashedNonce = _sha256Hex(rawNonce);
    await GoogleSignIn.instance.initialize(
      serverClientId: CloudConfig.googleWebClientId,
      nonce: hashedNonce,
    );
    _googleRawNonce = rawNonce;
    _googleReady = true;
  }

  Future<AuthResult> signInWithGoogle() async {
    CrashReporting.log('auth: google sign-in start');
    final SupabaseClient? client = _client;
    if (client == null) {
      return const AuthResult(
        errorMessage: 'Sign-in isn’t set up in this build.',
      );
    }
    if (!CloudConfig.googleConfigured) {
      return const AuthResult(
        errorMessage: 'Google sign-in isn’t set up in this build.',
      );
    }

    // 1) Native Google ID token → Supabase (with nonce, same as FocusFlow)
    try {
      await _ensureGoogleInitialized();
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const AuthResult(
          errorMessage:
              'Google didn’t return an ID token. In Google Cloud, use a Web '
              'client ID as GOOGLE_WEB_CLIENT_ID and add an Android client with '
              'package com.syarix.kegelexercisesapp + the debug SHA-1.',
        );
      }

      final AuthResponse res = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        nonce: _googleRawNonce,
      );
      if (res.session == null) {
        CrashReporting.log('auth: google sign-in no session');
        return const AuthResult(
          errorMessage: 'Google sign-in failed. Please try again.',
        );
      }
      CrashReporting.setKey('signed_in', true);
      CrashReporting.log('auth: google sign-in ok');
      return AuthResult(session: res.session);
    } on GoogleSignInException catch (e) {
      CrashReporting.log('auth: google exception code=${e.code}');
      debugPrint(
        'GoogleSignInException: code=${e.code} desc=${e.description} $e',
      );
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // Credential Manager often returns "canceled" for SHA-1 / package
        // misconfiguration, not only user cancel — show a useful hint.
        return const AuthResult(
          errorMessage:
              'Google sign-in didn’t finish. If you didn’t cancel, add an '
              'Android OAuth client in Google Cloud for '
              'com.syarix.kegelexercisesapp with SHA-1:\n$_debugSha1\n'
              'Also put the Web client ID + secret in Supabase → Auth → Google.',
        );
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        return AuthResult(
          errorMessage:
              'Google isn’t configured on this phone build. Add Android OAuth '
              'client for com.syarix.kegelexercisesapp with SHA-1:\n$_debugSha1'
              '${e.description != null ? '\n(${e.description})' : ''}',
        );
      }
      // Fall through to browser OAuth for other recoverable cases.
    } on AuthException catch (e) {
      debugPrint('Google→Supabase AuthException: ${e.message} code=${e.code}');
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    } on Object catch (e) {
      debugPrint('Native Google sign-in error: $e');
      // Fall through to browser OAuth.
    }

    // 2) Browser OAuth + deep link (kegel://auth-callback)
    try {
      final Completer<Session?> completer = Completer<Session?>();
      late final StreamSubscription<AuthState> sub;
      sub = client.auth.onAuthStateChange.listen((AuthState state) {
        if (state.session != null && !completer.isCompleted) {
          completer.complete(state.session);
        }
      });

      final bool launched = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: CloudConfig.authCallbackUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await sub.cancel();
        return const AuthResult(
          errorMessage: 'Couldn’t open Google sign-in. Please try again.',
        );
      }

      final Session? session = await completer.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () => null,
      );
      await sub.cancel();
      if (session == null) {
        return const AuthResult(
          errorMessage:
              'Google browser sign-in didn’t complete. Confirm Supabase '
              'redirect URL includes kegel://auth-callback.',
        );
      }
      return AuthResult(session: session);
    } on Object catch (e) {
      debugPrint('Google OAuth fallback error: $e');
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    }
  }

  Future<AuthResult> resetPassword(String email) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const AuthResult(
        errorMessage: 'Sign-in isn’t set up in this build.',
      );
    }
    try {
      await client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: CloudConfig.authCallbackUrl,
      );
      return const AuthResult();
    } on Object catch (e) {
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    }
  }

  Future<AuthResult> resendConfirmation(String email) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const AuthResult(
        errorMessage: 'Sign-in isn’t set up in this build.',
      );
    }
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: CloudConfig.authCallbackUrl,
      );
      return const AuthResult(needsEmailConfirmation: true);
    } on Object catch (e) {
      return AuthResult(errorMessage: CloudErrors.fromAuth(e));
    }
  }

  Future<void> signOut() async {
    CrashReporting.log('auth: sign-out');
    try {
      if (_googleReady) {
        await GoogleSignIn.instance.signOut();
      }
    } on Object {
      // ignore
    }
    await _client?.auth.signOut();
    CrashReporting.setKey('signed_in', false);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client?.auth.updateUser(UserAttributes(password: newPassword));
  }
}
