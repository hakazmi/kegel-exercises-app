import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/data/database/app_database.dart';
import 'package:kegelexercisesapp/core/data/repositories/checkin_repository.dart';
import 'package:kegelexercisesapp/core/data/repositories/data_reset_service.dart';
import 'package:kegelexercisesapp/core/data/repositories/session_repository.dart';
import 'package:kegelexercisesapp/core/data/repositories/settings_repository.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SessionRepository sessions;
  late CheckInRepository checkIns;
  late SettingsRepository settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    db = AppDatabase.memory();
    sessions = SessionRepository(db);
    checkIns = CheckInRepository(db);
    settings = SettingsRepository(prefs);
  });

  tearDown(() async {
    await db.close();
  });

  test('session insert and latest', () async {
    await sessions.insert(
      SessionRecord(
        startedAt: DateTime(2026, 11, 10, 9),
        completedAt: DateTime(2026, 11, 10, 9, 1),
        level: 1,
        dayInLevel: 1,
        track: TrackId.generalBladder,
        kind: SessionKind.strengthening,
        completed: true,
        feel: SessionFeel.fine,
        durationSeconds: 55,
        longestHoldSeconds: 3,
      ),
    );
    final List<SessionRecord> rows = await sessions.latest(10);
    expect(rows, hasLength(1));
    expect(rows.first.feel, SessionFeel.fine);
    expect(rows.first.kind, SessionKind.strengthening);
  });

  test('settings round-trip', () async {
    final UserProfile profile = UserProfile.initial().copyWith(
      goal: Goal.bladderControl,
      sessionsPerDay: 2,
      onboardingDone: true,
      level: 2,
      restWeekday: DateTime.wednesday,
    );
    await settings.save(profile);
    final UserProfile loaded = settings.load();
    expect(loaded.goal, Goal.bladderControl);
    expect(loaded.sessionsPerDay, 2);
    expect(loaded.level, 2);
    expect(loaded.restWeekday, DateTime.wednesday);
    expect(loaded.discreetNotifications, isTrue);
    expect(loaded.voiceOn, isFalse);
    expect(loaded.vibrationOn, isTrue);
  });

  test('DataResetService clears profile sessions and check-ins', () async {
    await settings.save(
      UserProfile.initial().copyWith(onboardingDone: true, level: 3),
    );
    await sessions.insert(
      SessionRecord(
        startedAt: DateTime(2026, 11, 10),
        completedAt: DateTime(2026, 11, 10),
        level: 1,
        dayInLevel: 1,
        track: TrackId.generalBladder,
        kind: SessionKind.strengthening,
        completed: true,
      ),
    );
    await checkIns.insert(
      CheckInRecord(
        date: DateTime(2026, 11, 10),
        goal: Goal.bladderControl,
        score: 3,
      ),
    );

    final DataResetService reset = DataResetService(
      settings: settings,
      sessions: sessions,
      checkIns: checkIns,
    );
    await reset.deleteEverything();

    expect(await sessions.getAll(), isEmpty);
    expect(await checkIns.getAll(), isEmpty);
    expect(settings.load().onboardingDone, isFalse);
    expect(settings.load().level, 1);
  });
}
