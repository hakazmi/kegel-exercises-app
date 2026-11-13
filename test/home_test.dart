import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kegelexercisesapp/app/l10n/app_localizations.dart';
import 'package:kegelexercisesapp/app/router.dart';
import 'package:kegelexercisesapp/app/theme/app_theme.dart';
import 'package:kegelexercisesapp/core/data/database/app_database.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/safety_flags.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';
import 'package:kegelexercisesapp/core/widgets/primary_button.dart';
import 'package:kegelexercisesapp/features/home/h1_today_screen.dart';
import 'package:kegelexercisesapp/features/home/h2_levels_screen.dart';
import 'package:kegelexercisesapp/features/settings/settings_safety_screen.dart';
import 'package:kegelexercisesapp/features/shell/main_shell.dart';
import 'package:kegelexercisesapp/features/shell/placeholder_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container({
  UserProfile? profile,
  List<SessionRecord> sessions = const <SessionRecord>[],
  AppClock? clock,
  bool premium = false,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppDatabase db = AppDatabase.memory();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
      if (clock != null) appClockProvider.overrideWithValue(clock),
    ],
  );
  addTearDown(db.close);
  container.read(isPremiumOverrideProvider.notifier).set(premium);
  final UserProfile base = profile ??
      UserProfile.initial().copyWith(
        onboardingDone: true,
        tutorialDone: true,
        goal: Goal.bladderControl,
        sessionsPerDay: 2,
        level: 1,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      );
  await container.read(userProfileProvider.notifier).save(base);
  for (final SessionRecord session in sessions) {
    await container.read(sessionRepositoryProvider).insert(session);
  }
  container.invalidate(sessionsProvider);
  container.invalidate(todayPlanProvider);
  await container.read(todayPlanProvider.future);
  return container;
}

Future<void> _pumpHome(
  WidgetTester tester,
  ProviderContainer container, {
  Widget home = const H1TodayScreen(),
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pump();
}

SessionRecord _session({
  required DateTime day,
  required SessionKind kind,
  int level = 1,
  int dayInLevel = 1,
  TrackId track = TrackId.generalBladder,
}) {
  return SessionRecord(
    startedAt: day,
    completedAt: day,
    level: level,
    dayInLevel: dayInLevel,
    track: track,
    kind: kind,
    durationSeconds: 55,
    longestHoldSeconds: 3,
    completed: true,
    feel: SessionFeel.fine,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DateTime wednesday = DateTime(2026, 11, 11, 12);

  testWidgets('H1 all done shows rest-is-training copy and disables start',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(
      clock: clock,
      sessions: <SessionRecord>[
        _session(day: wednesday, kind: SessionKind.strengthening),
        _session(
          day: wednesday.add(const Duration(minutes: 1)),
          kind: SessionKind.strengthening,
        ),
        _session(
          day: wednesday.add(const Duration(minutes: 2)),
          kind: SessionKind.breathing,
        ),
      ],
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        sessionsPerDay: 2,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      ),
    );
    addTearDown(container.dispose);
    await _pumpHome(tester, container);

    expect(
      find.text('Done for today. Rest is part of the training.'),
      findsOneWidget,
    );
    expect(find.text('Start session'), findsOneWidget);
    final Finder start = find.widgetWithText(PrimaryButton, 'Start session');
    expect(start, findsOneWidget);
    expect(tester.widget<PrimaryButton>(start).enabled, isFalse);
  });

  testWidgets('H1 rest day shows breathing only and rest copy',
      (WidgetTester tester) async {
    final DateTime sunday = DateTime(2026, 11, 8, 12);
    final FakeClock clock = FakeClock(sunday);
    final ProviderContainer container = await _container(
      clock: clock,
      sessions: <SessionRecord>[
        _session(
          day: sunday.subtract(const Duration(days: 2)),
          kind: SessionKind.strengthening,
        ),
      ],
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        sessionsPerDay: 2,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      ),
    );
    addTearDown(container.dispose);
    await _pumpHome(tester, container);

    expect(
      find.text('Rest day. Your muscles recover today.'),
      findsOneWidget,
    );
    expect(find.text('Relaxation breathing'), findsOneWidget);
    expect(find.text('Session 1'), findsNothing);
  });

  testWidgets('H1 daily cap disables button with exact copy',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(
      clock: clock,
      sessions: <SessionRecord>[
        _session(day: wednesday, kind: SessionKind.strengthening),
        _session(
          day: wednesday.add(const Duration(minutes: 1)),
          kind: SessionKind.strengthening,
        ),
        _session(
          day: wednesday.add(const Duration(minutes: 2)),
          kind: SessionKind.strengthening,
        ),
      ],
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        sessionsPerDay: 3,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      ),
    );
    addTearDown(container.dispose);
    await _pumpHome(tester, container);

    expect(
      find.text(
        'That is enough for today. Doing more can tire the muscles and slow progress.',
      ),
      findsOneWidget,
    );
    final PrimaryButton button = tester.widget<PrimaryButton>(
      find.widgetWithText(PrimaryButton, 'Start session'),
    );
    expect(button.enabled, isFalse);
  });

  testWidgets('H1 missed days resume without guilt copy',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(
      clock: clock,
      sessions: <SessionRecord>[
        _session(
          day: wednesday.subtract(const Duration(days: 5)),
          kind: SessionKind.strengthening,
        ),
        _session(
          day: wednesday.subtract(const Duration(days: 4)),
          kind: SessionKind.strengthening,
        ),
      ],
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        sessionsPerDay: 1,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      ),
    );
    addTearDown(container.dispose);
    await _pumpHome(tester, container);

    expect(find.textContaining('missed'), findsNothing);
    expect(find.textContaining('behind'), findsNothing);
    expect(find.textContaining('catch up'), findsNothing);
    expect(find.text('Start session'), findsOneWidget);
    expect(find.textContaining('Level 1 · Day'), findsOneWidget);
  });

  testWidgets('H1 catheter Update opens Settings safety editor',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(
      clock: clock,
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        safetyFlags: const SafetyFlags(catheter: true),
      ),
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.today,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.today,
          builder: (BuildContext context, GoRouterState state) {
            return const H1TodayScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.settingsSafety,
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsSafetyScreen();
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'Do not do these exercises with a catheter in place. Come back when it is removed and your care team says you can start.',
      ),
      findsOneWidget,
    );
    expect(find.text('Update my answer'), findsOneWidget);
    expect(find.text('Start session'), findsNothing);

    await tester.tap(find.text('Update my answer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SettingsSafetyScreen), findsOneWidget);
    expect(
      container.read(userProfileProvider).safetyFlags.catheter,
      isTrue,
    );
  });

  testWidgets('H1 relaxation-first level card uses 14-day progress',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(
      clock: clock,
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.relaxationFirst,
        safetyFlags: const SafetyFlags(pain: true),
        sessionsPerDay: 1,
      ),
    );
    addTearDown(container.dispose);
    await _pumpHome(tester, container);

    expect(find.text('Weeks 1 to 2'), findsOneWidget);
    expect(find.text('0 of 14 days'), findsOneWidget);
    expect(find.textContaining('Relaxation · Weeks'), findsNothing);
    expect(find.textContaining('Level 1 · Day'), findsNothing);
  });

  testWidgets('H1 week strip shows Rest aligned as dayNumber text',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(clock: clock);
    addTearDown(container.dispose);
    await _pumpHome(tester, container);

    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
  });

  testWidgets('H2 relaxation-first shows relaxation current and Level 1 note',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(
      clock: clock,
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.relaxationFirst,
        safetyFlags: const SafetyFlags(pain: true),
        sessionsPerDay: 1,
        level: 1,
      ),
    );
    addTearDown(container.dispose);
    await _pumpHome(tester, container, home: const H2LevelsScreen());

    expect(find.text('Relaxation'), findsOneWidget);
    expect(find.text('Days 1–14 · daily breathing and stretches'), findsOneWidget);
    expect(find.text('0 of 14 days'), findsOneWidget);
    expect(
      find.text(
        'If the pain has settled and a clinician agrees, you can start Level 1.',
      ),
      findsWidgets,
    );
    expect(
      find.text(
        'Relaxation first plan. Breathing and stretches come before strengthening.',
      ),
      findsOneWidget,
    );
    // Only the relaxation card is Current (one badge).
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.textContaining('3 s holds'), findsOneWidget);
  });

  testWidgets('H2 locked level opens paywall with locked_content source',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(clock: clock);
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.levels,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.levels,
          builder: (BuildContext context, GoRouterState state) {
            return const H2LevelsScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.paywall,
          builder: (BuildContext context, GoRouterState state) {
            final String source =
                state.uri.queryParameters['source'] ?? 'unknown';
            return PlaceholderScreen(
              id: 'P1',
              name: 'Paywall ($source)',
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Your levels'), findsOneWidget);

    await tester.tap(find.text('Build'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Paywall (locked_content)'), findsOneWidget);
  });

  testWidgets('shell back from Progress returns to Today',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(clock: clock);
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.today,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return MainShell(
              navigationShell: navigationShell,
              todayLabel: 'Today',
              progressLabel: 'Progress',
              learnLabel: 'Learn',
            );
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.today,
                  builder: (BuildContext context, GoRouterState state) {
                    return const H1TodayScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.progress,
                  builder: (BuildContext context, GoRouterState state) {
                    return const PlaceholderScreen(id: 'G1', name: 'Progress');
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.learn,
                  builder: (BuildContext context, GoRouterState state) {
                    return const PlaceholderScreen(id: 'L1', name: 'Learn');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(H1TodayScreen), findsOneWidget);

    router.go(AppRoutes.progress);
    await tester.pump();
    expect(find.byType(H1TodayScreen), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(H1TodayScreen), findsOneWidget);
  });
}
