import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// One-shot Firebase init. Safe when config files are missing.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _ready = false;

  /// True after a successful [initialize].
  static bool get isReady => _ready;

  /// Initializes Firebase from platform config (`google-services.json` /
  /// `GoogleService-Info.plist`). Returns false when config is missing.
  static Future<bool> initialize() async {
    if (_ready) {
      return true;
    }
    try {
      await Firebase.initializeApp();
      _ready = true;
      debugPrint('Firebase: initialized');
      return true;
    } on Object catch (e) {
      _ready = false;
      debugPrint('Firebase: not available ($e)');
      return false;
    }
  }

  /// Test-only: force ready/unready without touching the native SDK.
  @visibleForTesting
  static void debugSetReady(bool ready) {
    _ready = ready;
  }
}
