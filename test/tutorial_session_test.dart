import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/app/app.dart';
import 'package:kegelexercisesapp/app/l10n/app_localizations.dart';
import 'package:kegelexercisesapp/app/router.dart';
import 'package:kegelexercisesapp/core/content/content_models.dart';
import 'package:kegelexercisesapp/core/data/database/app_database.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/plan/plan_models.dart';
import 'package:kegelexercisesapp/features/session/s1_before_screen.dart';
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
  extras: <String>[],
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
    TodayItem(
      id: 'strength_2',
      kind: SessionKind.strengthening,
      label: 'Session 2',
      durationSeconds: 55,
      done: false,
      sessionNumber: 2,
    ),
  ],
);

Future<ProviderContainer> _container({UserProfile? profile}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppDatabase db = AppDatabase.memory();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
      sessionsProvider.overrideWith(
        (Ref ref) async => const <SessionRecord>[],
      ),
      todayPlanProvider.overrideWith((Ref ref) async => _plan),
      levelsProvider.overrideWith((Ref ref) async => <LevelContent>[_level1]),
    ],
  );
  addTearDown(db.close);
  if (profile != null) {
    await container.read(userProfileProvider.notifier).save(profile);
  }
  return container;
}

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const KegelApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _advancePractice(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(seconds: 3, milliseconds: 50));
  }
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('T1 flow: cards, practice, Not sure then Try again',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        experience: Experience.none,
        sessionsPerDay: 2,
        level: 1,
      ),
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    container.read(routerProvider).go(AppRoutes.tutorial);
    await tester.pumpAndSettle();

    expect(find.text('How to do a Kegel'), findsOneWidget);
    expect(find.text('Where the muscles are'), findsOneWidget);
    expect(
      find.textContaining('pubic bone to the tailbone'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('How to find them'), findsOneWidget);
    expect(
      find.textContaining('Do not practise that way'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('What to avoid'), findsOneWidget);
    expect(find.text('Keep breathing'), findsOneWidget);
    expect(find.text('Do not squeeze your buttocks'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Squeeze'), findsOneWidget);

    await _advancePractice(tester);
    expect(find.text('Did you feel the lift?'), findsOneWidget);

    await tester.tap(find.text('Not sure'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Try lying down'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Squeeze'), findsOneWidget);

    await _advancePractice(tester);
    expect(find.text('Did you feel the lift?'), findsOneWidget);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(container.read(userProfileProvider).tutorialDone, isTrue);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Slow holds'), findsOneWidget);
  });

  testWidgets('T1 replay does not set tutorialDone', (WidgetTester tester) async {
    final ProviderContainer container = await _container(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        tutorialDone: false,
        goal: Goal.bladderControl,
        experience: Experience.confident,
        sessionsPerDay: 2,
        level: 1,
      ),
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    container.read(routerProvider).go('${AppRoutes.tutorial}?replay=1');
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(container.read(userProfileProvider).tutorialDone, isFalse);
  });

  testWidgets('S1 lists Level 1 blocks for a strengthening item',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        tutorialDone: true,
        goal: Goal.bladderControl,
        experience: Experience.confident,
        sessionsPerDay: 2,
        level: 1,
        vibrationOn: true,
        voiceOn: false,
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: S1BeforeScreen(itemId: 'strength_1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('LEVEL 1'), findsOneWidget);
    expect(find.text('Slow holds'), findsOneWidget);
    expect(find.textContaining('5 reps · squeeze 3 s, relax 3 s'), findsOneWidget);
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('10 s'), findsOneWidget);
    expect(find.text('Quick squeezes'), findsOneWidget);
    expect(find.textContaining('5 reps · squeeze 1 s, relax 2 s'), findsOneWidget);
    expect(
      find.textContaining('Lie on your back with knees bent'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Show me how'),
      40,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Show me how'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
