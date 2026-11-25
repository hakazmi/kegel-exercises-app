import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/widgets/pelvic_floor_demo.dart';
import 'package:kegelexercisesapp/app/app.dart';
import 'package:kegelexercisesapp/app/l10n/app_localizations.dart';
import 'package:kegelexercisesapp/app/router.dart';
import 'package:kegelexercisesapp/app/theme/tokens.dart';
import 'package:kegelexercisesapp/core/content/content_models.dart';
import 'package:kegelexercisesapp/core/data/database/app_database.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/safety_flags.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/plan/plan_models.dart';
import 'package:kegelexercisesapp/core/widgets/progress_header.dart';
import 'package:kegelexercisesapp/features/session/s1_before_screen.dart';
import 'package:kegelexercisesapp/features/tutorial/side_pelvic_demo.dart';
import 'package:kegelexercisesapp/features/tutorial/anatomy_diagram.dart';
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

const TodayPlan _relaxationPlan = TodayPlan(
  state: TodayPlanState.normal,
  dayInLevel: 1,
  level: 1,
  track: TrackId.relaxationFirst,
  items: <TodayItem>[
    TodayItem(
      id: 'reverse_kegel',
      kind: SessionKind.relaxation,
      label: 'Reverse Kegel',
      durationSeconds: 120,
      done: false,
    ),
  ],
);

const List<ExerciseContent> _exercises = <ExerciseContent>[
  ExerciseContent(
    id: 'slow_hold',
    name: 'Slow hold',
    description: 'Squeeze, hold, fully release',
    type: 'strength',
  ),
  ExerciseContent(
    id: 'quick_squeeze',
    name: 'Quick squeeze',
    description: 'Squeeze hard for 1 second, release at once',
    type: 'strength',
  ),
  ExerciseContent(
    id: 'diaphragmatic_breathing',
    name: 'Diaphragmatic breathing',
    description: 'Belly breath in as the pelvic floor lets go',
    type: 'relaxation',
  ),
  ExerciseContent(
    id: 'reverse_kegel',
    name: 'Reverse Kegel',
    description: 'Gently release and lengthen instead of squeezing',
    type: 'relaxation',
  ),
];

Future<ProviderContainer> _container({
  UserProfile? profile,
  TodayPlan plan = _plan,
}) async {
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
      todayPlanProvider.overrideWith((Ref ref) async => plan),
      levelsProvider.overrideWith((Ref ref) async => <LevelContent>[_level1]),
      exercisesProvider.overrideWith(
        (Ref ref) async => _exercises,
      ),
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

  testWidgets('ProgressHeader step label sits on the right content edge',
      (WidgetTester tester) async {
    const Size surface = Size(360, 640);
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressHeader(step: 2, total: 6, onBack: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder label = find.text('2 of 6');
    expect(label, findsOneWidget);
    final Rect rect = tester.getRect(label);
    expect(rect.right, closeTo(surface.width - AppSpacing.xl, 0.5));
  });

  testWidgets('Anatomy diagram is square and labels the pelvic floor',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 320, child: AnatomyDiagram()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Pelvic floor'), findsOneWidget);
    final Size diagramSize = tester.getSize(find.byType(AnatomyDiagram));
    expect(diagramSize.width / diagramSize.height, closeTo(1, 0.01));
  });

  test('S1 meta uses ICU plural for parts', () {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));
    expect(l10n.s1Meta(55, 1), '55 seconds · 1 part');
    expect(l10n.s1Meta(55, 3), '55 seconds · 3 parts');
    expect(l10n.s1MetaMinutes(2, 1), '2 min · 1 part');
    expect(l10n.s1MetaMinutes(2, 3), '2 min · 3 parts');
  });

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
    expect(find.text('Do and don\'t'), findsOneWidget);
    expect(find.text('Keep breathing'), findsOneWidget);
    expect(find.text('Do not squeeze your buttocks'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Squeeze'), findsOneWidget);

    await _advancePractice(tester);
    expect(find.text('Did you feel the lift?'), findsOneWidget);
    expect(find.byType(PelvicFloorDemoLoop), findsOneWidget);

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

  testWidgets('S1 lists Level 1 blocks with exercise descriptions',
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
    // Tall screen so the exercise cards and the full step list both build.
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
    // Each Kegel exercise has an animated card plus its step in the list.
    expect(find.byType(SidePelvicDemoLoop), findsNWidgets(2));
    expect(find.text('Slow holds'), findsNWidgets(2));
    expect(find.text('Squeeze, hold, fully release'), findsOneWidget);
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('10 s'), findsOneWidget);
    expect(find.text('Quick squeezes'), findsNWidgets(2));
    expect(
      find.text('Squeeze hard for 1 second, release at once'),
      findsOneWidget,
    );
    expect(find.textContaining('55 seconds · 3 parts'), findsOneWidget);
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

  testWidgets('S1 relaxation track shows RELAXATION · DAY without Level',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        tutorialDone: true,
        goal: Goal.bladderControl,
        experience: Experience.confident,
        sessionsPerDay: 1,
        level: 1,
        track: TrackId.relaxationFirst,
        safetyFlags: const SafetyFlags(pain: true),
      ),
      plan: _relaxationPlan,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: S1BeforeScreen(itemId: 'reverse_kegel'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RELAXATION · DAY 1'), findsOneWidget);
    expect(find.textContaining('LEVEL'), findsNothing);
    expect(find.text('Reverse Kegel'), findsWidgets);
    expect(
      find.text('Gently release and lengthen instead of squeezing.'),
      findsOneWidget,
    );
    expect(find.textContaining('1 part'), findsOneWidget);
  });
}
