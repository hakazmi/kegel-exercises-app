import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/providers.dart';
import 'account_binder.dart';
import 'auth_repository.dart';
import 'cloud_config.dart';
import 'device_id.dart';
import 'sync_coordinator.dart';
import 'sync_metadata_store.dart';
import 'sync_repository.dart';

final syncMetadataStoreProvider = Provider<SyncMetadataStore>((Ref ref) {
  return SyncMetadataStore(ref.watch(sharedPreferencesProvider));
});

final deviceIdStoreProvider = Provider<DeviceIdStore>((Ref ref) {
  return DeviceIdStore();
});

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepository();
});

final syncRepositoryProvider = Provider<SyncRepository>((Ref ref) {
  return SyncRepository(
    db: ref.watch(appDatabaseProvider),
    settings: ref.watch(settingsRepositoryProvider),
    holdTests: ref.watch(holdTestRepositoryProvider),
    meta: ref.watch(syncMetadataStoreProvider),
    deviceId: ref.watch(deviceIdStoreProvider),
    clock: ref.watch(appClockProvider),
  );
});

final syncCoordinatorProvider = Provider<SyncCoordinator>((Ref ref) {
  final SyncCoordinator coordinator = SyncCoordinator(
    ref.watch(syncRepositoryProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final accountBinderProvider = Provider<AccountBinder>((Ref ref) {
  return AccountBinder(
    sync: ref.watch(syncRepositoryProvider),
    meta: ref.watch(syncMetadataStoreProvider),
    settings: ref.watch(settingsRepositoryProvider),
    reset: ref.watch(dataResetServiceProvider),
  );
});

/// Whether the user currently has a Supabase session.
final authSessionProvider = StreamProvider<Session?>((Ref ref) async* {
  final AuthRepository auth = ref.watch(authRepositoryProvider);
  yield auth.currentSession;
  if (!CloudConfig.isConfigured) {
    return;
  }
  await for (final AuthState state in auth.authStateChanges) {
    yield state.session;
  }
});

final isSignedInProvider = Provider<bool>((Ref ref) {
  final AsyncValue<Session?> session = ref.watch(authSessionProvider);
  return session.asData?.value != null ||
      ref.watch(authRepositoryProvider).isSignedIn;
});
