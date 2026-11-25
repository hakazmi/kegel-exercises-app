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
import 'package:kegelexercisesapp/core/plan/goal_routing.dart';
import 'package:kegelexercisesapp/core/plan/safety_routing.dart';
import 'package:kegelexercisesapp/core/services/reminder_service.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';
import 'package:kegelexercisesapp/features/learn/l1_learn_screen.dart';
import 'package:kegelexercisesapp/features/onboarding/o1_welcome_screen.dart';
import 'package:kegelexercisesapp/features/onboarding/onboarding_controller.dart';
import 'package:kegelexercisesapp/features/settings/settings_copy.dart';
import 'package:kegelexercisesapp/features/settings/settings_safety_screen.dart';
import 'package:kegelexercisesapp/features/settings/x1_settings_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReminders implements ReminderService {
  bool disabled = false;
  bool enabled = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> reschedule() async {}

  @override
  Future<void> clearLevelUnlockNotice() async {}

  @override
  Future<void> disableReminder() async {
    disabled = true;
    enabled = false;
  }

  @override
  Future<void> enableReminder({
    required int minutesFromMidnight,
    required List<int> days,
  }) async {
    enabled = true;
    disabled = false;
  }
}

Future<ProviderContainer> _container({
  UserProfile? profile,
  ReminderService? reminders,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppDatabase db = AppDatabase.memory();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
      appClockProvider.overrideWithValue(FakeClock(DateTime(2026, 11, 13, 12))),
      if (reminders != null)
        reminderServiceProvider.overrideWithValue(reminders),
    ],
  );
  addTearDown(db.close);
  final UserProfile base = profile ??
      UserProfile.initial().copyWith(
        onboardingDone: true,
        tutorialDone: true,
        goal: Goal.bladderControl,
        sessionsPerDay: 2,
        level: 1,
        track: TrackId.generalBladder,
        reminderEnabled: true,
      );
  await container.read(userProfileProvider.notifier).save(base);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Settings safety summary shows count; reminder uses Daily', () {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      SettingsCopy.safetySummary(l10n, const SafetyFlags()),
      'None',
    );
    expect(
      SettingsCopy.safetySummary(l10n, const SafetyFlags(catheter: true)),
      '1 selected',
    );
    expect(
      SettingsCopy.safetySummary(
        l10n,
        const SafetyFlags(pain: true, catheter: true),
      ),
      '2 selected',
    );
    final UserProfile profile = UserProfile.initial().copyWith(
      reminderEnabled: true,
      reminderTime: 21 * 60,
      reminderDays: <int>[1, 2, 3, 4, 5, 6, 7],
    );
    expect(SettingsCopy.reminderSummary(l10n, profile), '9:00 PM · Daily');
  });

  test('SafetyRouting sets catheter and keeps Learn usable via flags only', () {
    final UserProfile profile = UserProfile.initial().copyWith(
      onboardingDone: true,
      goal: Goal.bladderControl,
      track: TrackId.generalBladder,
    );
    final UserProfile next = SafetyRouting.apply(
      profile: profile,
      flags: const SafetyFlags(catheter: true),
      now: DateTime(2026, 11, 13),
    );
    expect(next.safetyFlags.catheter, isTrue);
    expect(next.onboardingDone, isTrue);
    expect(next.track, TrackId.generalBladder);
  });

  test('SafetyRouting pain switches to relaxation-first', () {
    final UserProfile next = SafetyRouting.apply(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
      ),
      flags: const SafetyFlags(pain: true),
      now: DateTime(2026, 11, 13),
    );
    expect(next.track, TrackId.relaxationFirst);
    expect(next.safetyFlags.pain, isTrue);
  });

  test('GoalRouting starts fresh plan and saves outgoing snapshot', () {
    final DateTime now = DateTime(2026, 11, 13, 9);
    final UserProfile next = GoalRouting.apply(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        level: 3,
        levelStartedOn: DateTime(2026, 10, 1),
        planStartedOn: DateTime(2026, 9, 1),
        restWeekday: DateTime.sunday,
      ),
      goal: Goal.erectionSupport,
      now: now,
    );
    expect(next.goal, Goal.erectionSupport);
    expect(next.track, TrackId.erectionSupport);
    expect(next.level, 1);
    expect(next.levelStartedOn, DateTime(2026, 11, 13));
    expect(next.planStartedOn, DateTime(2026, 11, 13));
    expect(next.restWeekday, restWeekdayForStart(DateTime(2026, 11, 13)));
    expect(next.goalPlans[Goal.bladderControl.storageValue]?.level, 3);
  });

  test('GoalRouting restores previous goal snapshot', () {
    final DateTime now = DateTime(2026, 11, 20, 9);
    final UserProfile afterNew = GoalRouting.apply(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.erectionSupport,
        track: TrackId.erectionSupport,
        level: 2,
        levelStartedOn: DateTime(2026, 11, 1),
        planStartedOn: DateTime(2026, 10, 20),
        restWeekday: DateTime.saturday,
      ),
      goal: Goal.ejaculationControl,
      now: now,
    );
    expect(afterNew.track, TrackId.ejaculationControl);
    expect(afterNew.level, 1);

    final UserProfile restored = GoalRouting.apply(
      profile: afterNew,
      goal: Goal.erectionSupport,
      now: now,
    );
    expect(restored.goal, Goal.erectionSupport);
    expect(restored.track, TrackId.erectionSupport);
    expect(restored.level, 2);
    expect(restored.levelStartedOn, DateTime(2026, 11, 1));
    expect(restored.planStartedOn, DateTime(2026, 10, 20));
    expect(restored.restWeekday, DateTime.saturday);
  });

  test('GoalRouting same-track goal only updates goal', () {
    final UserProfile profile = UserProfile.initial().copyWith(
      onboardingDone: true,
      goal: Goal.bladderControl,
      track: TrackId.generalBladder,
      level: 2,
      levelStartedOn: DateTime(2026, 10, 1),
      planStartedOn: DateTime(2026, 9, 1),
    );
    final UserProfile next = GoalRouting.apply(
      profile: profile,
      goal: Goal.generalPelvicHealth,
      now: DateTime(2026, 11, 13),
    );
    expect(next.goal, Goal.generalPelvicHealth);
    expect(next.track, TrackId.generalBladder);
    expect(next.level, 2);
    expect(next.levelStartedOn, profile.levelStartedOn);
    expect(next.planStartedOn, profile.planStartedOn);
  });

  test('GoalRouting pain-locked keeps relaxation track', () {
    final UserProfile next = GoalRouting.apply(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.relaxationFirst,
        safetyFlags: const SafetyFlags(pain: true),
        level: 1,
      ),
      goal: Goal.ejaculationControl,
      now: DateTime(2026, 11, 13),
    );
    expect(next.goal, Goal.ejaculationControl);
    expect(next.track, TrackId.relaxationFirst);
    expect(next.level, 1);
  });

  testWidgets('delete all my data clears storage and returns to Welcome',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakeReminders reminders = _FakeReminders();
    final ProviderContainer container = await _container(reminders: reminders);
    addTearDown(container.dispose);

    await container.read(sessionRepositoryProvider).insert(
          SessionRecord(
            startedAt: DateTime(2026, 11, 12),
            completedAt: DateTime(2026, 11, 12),
            level: 1,
            dayInLevel: 1,
            track: TrackId.generalBladder,
            kind: SessionKind.strengthening,
            completed: true,
          ),
        );

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.settings,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.settings,
          builder: (BuildContext context, GoRouterState state) {
            return const X1SettingsScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (BuildContext context, GoRouterState state) {
            return const O1WelcomeScreen();
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
    await tester.pump(const Duration(milliseconds: 50));

    final Finder delete = find.text('Delete all my data');
    await tester.ensureVisible(delete);
    await tester.pump();
    await tester.tap(delete);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Delete all data?'), findsOneWidget);
    await tester.tap(find.text('Delete everything'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(reminders.disabled, isTrue);
    expect(container.read(userProfileProvider).onboardingDone, isFalse);
    expect(await container.read(sessionRepositoryProvider).getAll(), isEmpty);
    expect(find.byType(O1WelcomeScreen), findsOneWidget);
    expect(container.read(onboardingControllerProvider).acceptedAge, isFalse);
  });

  testWidgets('changing safety answer to catheter saves catheter flag',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ProviderContainer container = await _container();
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.settingsSafety,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.settings,
          builder: (BuildContext context, GoRouterState state) {
            return const SizedBox.shrink();
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

    final Finder catheter = find.text('A urinary catheter in place right now');
    await tester.ensureVisible(catheter);
    await tester.pump();
    await tester.tap(catheter);
    await tester.pump();

    final Finder confirm = find.text('Confirm');
    await tester.ensureVisible(confirm);
    await tester.pump();
    await tester.tap(confirm);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(container.read(userProfileProvider).safetyFlags.catheter, isTrue);
  });

  testWidgets('Learn lists articles while catheter-blocked',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ProviderContainer container = await _container(
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        safetyFlags: const SafetyFlags(catheter: true),
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const L1LearnScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Finding the right muscles'), findsOneWidget);
    expect(find.text('Articles'), findsOneWidget);
    for (final String title in <String>[
      'How the pelvic floor works',
      'Five common mistakes',
      'When to relax instead of squeeze',
      'What to expect, week by week',
      'Exercises after prostate surgery',
      'When to see a doctor',
      'Where our guidance comes from',
    ]) {
      final Finder row = find.text(title);
      await tester.ensureVisible(row);
      await tester.pump();
      expect(row, findsOneWidget);
    }
  });
}
