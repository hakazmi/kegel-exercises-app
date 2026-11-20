import 'checkin_repository.dart';
import 'habit_repository.dart';
import 'hold_test_repository.dart';
import 'session_repository.dart';
import 'settings_repository.dart';

/// Deletes all on-device user data (Settings → delete all my data).
class DataResetService {
  DataResetService({
    required this.settings,
    required this.sessions,
    required this.checkIns,
    required this.habits,
    required this.walking,
    this.holdTests,
  });

  final SettingsRepository settings;
  final SessionRepository sessions;
  final CheckInRepository checkIns;
  final HabitRepository habits;
  final WalkingRepository walking;

  /// Saved hold tests (optional so older call sites keep working).
  final HoldTestRepository? holdTests;

  Future<void> deleteEverything() async {
    await sessions.clear();
    await checkIns.clear();
    await habits.clearAll();
    await walking.clearAll();
    await holdTests?.clear();
    await settings.clear();
  }
}
