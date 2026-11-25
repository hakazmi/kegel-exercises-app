import '../../cloud/sync_metadata_store.dart';
import 'checkin_repository.dart';
import 'habit_repository.dart';
import 'hold_test_repository.dart';
import 'session_repository.dart';
import 'settings_repository.dart';

/// Deletes all on-device user data (Settings → reset / delete account).
class DataResetService {
  DataResetService({
    required this.settings,
    required this.sessions,
    required this.checkIns,
    required this.habits,
    required this.walking,
    this.holdTests,
    this.syncMeta,
  });

  final SettingsRepository settings;
  final SessionRepository sessions;
  final CheckInRepository checkIns;
  final HabitRepository habits;
  final WalkingRepository walking;

  /// Saved hold tests (optional so older call sites keep working).
  final HoldTestRepository? holdTests;

  final SyncMetadataStore? syncMeta;

  Future<void> deleteEverything({bool clearAuthHint = false}) async {
    await sessions.clear();
    await checkIns.clear();
    await habits.clearAll();
    await walking.clearAll();
    await holdTests?.clear();
    await settings.clear();
    if (clearAuthHint) {
      await syncMeta?.clearAllIncludingAuthHint();
    } else {
      await syncMeta?.clearSyncState();
    }
  }
}
