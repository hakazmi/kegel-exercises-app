import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/app/l10n/app_localizations.dart';
import 'package:kegelexercisesapp/core/content/content_models.dart';
import 'package:kegelexercisesapp/core/data/database/app_database.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/plan/plan_models.dart';
import 'package:kegelexercisesapp/core/services/haptics_service.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';
import 'package:kegelexercisesapp/features/session/engine/engine_models.dart';
import 'package:kegelexercisesapp/features/session/s3_player_screen.dart';
import 'package:kegelexercisesapp/features/session/session_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const LevelContent _level1 = LevelContent(
  id: 1,
  name: 'Start',
  dayStart: 1,
  dayEnd: 7,
  slowHolds: <String, dynamic>{'reps': 5, 'holdSec': 3, 'relaxSec': 3},
  quickSqueezes: <String, dynamic>{'reps': 5, 'squeezeSec': 1, 'relaxSec': 2},
  position: 'lying_or_sitting',
  bodyCard: <String, List<String>>{},
  kegelExtras: <String, List<String>>{},
  dailyBreathingSec: 120,
);

const TodayPlan _plan = TodayPlan(
  state: TodayPlanState.normal,
  dayInLevel: 1,
  level: 1,
  track: TrackId.generalBladder,
  items: <TodayItem>[
    TodayItem(
      id: 'strength_1',
      kind: SessionKind.strengthening,
      label: 'Session 1',
      durationSeconds: 55,
      done: false,
      sessionNumber: 1,
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android back on player shows exit confirmation',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppDatabase db = AppDatabase.memory();
    final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 12));
    final FakeHapticsService haptics = FakeHapticsService();

    final UserProfile profile = UserProfile.initial().copyWith(
      onboardingDone: true,
      tutorialDone: true,
      level: 1,
      track: TrackId.generalBladder,
      sessionsPerDay: 1,
      vibrationOn: true,
    );

    final ProviderContainer container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        appClockProvider.overrideWithValue(clock),
        hapticsServiceProvider.overrideWithValue(haptics),
        sessionsProvider.overrideWith(
          (Ref ref) async => const <SessionRecord>[],
        ),
        todayPlanProvider.overrideWith((Ref ref) async => _plan),
        levelsProvider.overrideWith(
          (Ref ref) async => <LevelContent>[_level1],
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      db.close();
    });
    await container.read(userProfileProvider.notifier).save(profile);

    // Start session before the widget so begin() finishes synchronously for the UI.
    await container.read(sessionControllerProvider.notifier).begin('strength_1');
    container.read(sessionControllerProvider.notifier).skipCountdown();
    container.read(sessionControllerProvider.notifier).pause();

    final SessionPlayState? play = container.read(sessionControllerProvider);
    expect(play, isNotNull);
    expect(play!.engineState.machine, EngineMachineState.paused);

    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: S3PlayerScreen(itemId: 'strength_1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Squeeze'), findsWidgets);

    final bool handled = await tester.binding.handlePopRoute();
    expect(handled, isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('End this session?'), findsOneWidget);
    expect(find.text('A partial session is not counted.'), findsOneWidget);
    expect(find.text('End session'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
