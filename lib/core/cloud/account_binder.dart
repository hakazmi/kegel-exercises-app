import '../data/repositories/data_reset_service.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/user_profile.dart';
import 'sync_metadata_store.dart';
import 'sync_repository.dart';

enum AccountBindAction {
  continueOnboarding,
  goMain,
  askReplace,
}

class AccountBindResult {
  const AccountBindResult({
    required this.action,
    this.cloudEmail,
  });

  final AccountBindAction action;
  final String? cloudEmail;
}

/// Decides restore / merge / replace after a successful sign-in.
class AccountBinder {
  AccountBinder({
    required SyncRepository sync,
    required SyncMetadataStore meta,
    required SettingsRepository settings,
    required DataResetService reset,
  }) : _sync = sync,
       _meta = meta,
       _settings = settings,
       _reset = reset;

  final SyncRepository _sync;
  final SyncMetadataStore _meta;
  final SettingsRepository _settings;
  final DataResetService _reset;

  Future<AccountBindResult> onSignedIn({
    required String userId,
    String? email,
  }) async {
    final String? previous = _meta.lastAuthUserId;
    final UserProfile local = _settings.load();
    final bool localHasData =
        local.onboardingDone || local.goal != null || local.level > 1;

    if (previous != null && previous != userId && localHasData) {
      return AccountBindResult(
        action: AccountBindAction.askReplace,
        cloudEmail: email,
      );
    }

    await _meta.setLastAuthUserId(userId);

    // Pull then push with a short timeout so splash/auth can proceed.
    try {
      await _sync
          .syncAll(expectedUserId: userId)
          .timeout(const Duration(seconds: 10));
    } on Object {
      // Continue with local; background sync will retry.
    }

    final UserProfile after = _settings.load();
    if (after.onboardingDone) {
      return const AccountBindResult(action: AccountBindAction.goMain);
    }
    return const AccountBindResult(
      action: AccountBindAction.continueOnboarding,
    );
  }

  /// Wipe local synced data then restore from cloud for [userId].
  Future<AccountBindResult> replaceWithAccount({
    required String userId,
    String? email,
  }) async {
    await _reset.deleteEverything();
    await _meta.clearSyncState();
    await _meta.setLastAuthUserId(userId);
    try {
      await _sync
          .pullAll(expectedUserId: userId)
          .timeout(const Duration(seconds: 10));
    } on Object {
      // ignore
    }
    final UserProfile after = _settings.load();
    if (after.onboardingDone) {
      return AccountBindResult(
        action: AccountBindAction.goMain,
        cloudEmail: email,
      );
    }
    return AccountBindResult(
      action: AccountBindAction.continueOnboarding,
      cloudEmail: email,
    );
  }

  /// Keep local data; mark dirty and upload under the new account.
  Future<AccountBindResult> keepLocalAndBind({
    required String userId,
    String? email,
  }) async {
    await _meta.setLastAuthUserId(userId);
    await _meta.markProfileDirty();
    await _meta.markPrefsDirty();
    await _meta.setBackfillDone(false);
    try {
      await _sync
          .pushAll(expectedUserId: userId)
          .timeout(const Duration(seconds: 10));
    } on Object {
      // ignore
    }
    final UserProfile local = _settings.load();
    if (local.onboardingDone) {
      return AccountBindResult(
        action: AccountBindAction.goMain,
        cloudEmail: email,
      );
    }
    return AccountBindResult(
      action: AccountBindAction.continueOnboarding,
      cloudEmail: email,
    );
  }
}
