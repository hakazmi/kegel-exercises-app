import 'checkin_repository.dart';
import 'session_repository.dart';
import 'settings_repository.dart';

/// Deletes all on-device user data (Settings → delete all my data).
class DataResetService {
  DataResetService({
    required this.settings,
    required this.sessions,
    required this.checkIns,
  });

  final SettingsRepository settings;
  final SessionRepository sessions;
  final CheckInRepository checkIns;

  Future<void> deleteEverything() async {
    await sessions.clear();
    await checkIns.clear();
    await settings.clear();
  }
}
