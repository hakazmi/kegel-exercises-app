import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/app/l10n/app_localizations.dart';
import 'package:kegelexercisesapp/app/theme/app_theme.dart';
import 'package:kegelexercisesapp/core/data/database/app_database.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/plan/check_in_rules.dart';
import 'package:kegelexercisesapp/core/plan/check_in_scoring.dart';
import 'package:kegelexercisesapp/core/plan/progress_stats.dart';
import 'package:kegelexercisesapp/core/services/analytics_service.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';
import 'package:kegelexercisesapp/features/progress/g1_progress_screen.dart';
import 'package:kegelexercisesapp/features/progress/g2_checkin_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/preload.dart';

class _RecordingAnalytics implements AnalyticsService {
  final List<String> events = <String>[];

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    events.add(name);
  }
}

Future<ProviderContainer> _container({
  UserProfile? profile,
  List<SessionRecord> sessions = const <SessionRecord>[],
  List<CheckInRecord> checkIns = const <CheckInRecord>[],
  AppClock? clock,
  bool premium = false,
  AnalyticsService? analytics,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppDatabase db = AppDatabase.memory();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
      if (clock != null) appClockProvider.overrideWithValue(clock),
      if (analytics != null)
        analyticsServiceProvider.overrideWithValue(analytics),
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
  for (final CheckInRecord checkIn in checkIns) {
    await container.read(checkInRepositoryProvider).insert(checkIn);
  }
  container.invalidate(sessionsProvider);
  container.invalidate(checkInsProvider);
  await container.read(sessionsProvider.future);
  await container.read(checkInsProvider.future);
  return container;
}

SessionRecord _session({
  required DateTime day,
  SessionKind kind = SessionKind.strengthening,
  int longestHoldSeconds = 3,
  int dayInLevel = 1,
  TrackId track = TrackId.generalBladder,
}) {
  return SessionRecord(
    startedAt: day,
    completedAt: day,
    level: 1,
    dayInLevel: dayInLevel,
    track: track,
    kind: kind,
    durationSeconds: 55,
    longestHoldSeconds: longestHoldSeconds,
    completed: true,
    feel: SessionFeel.fine,
  );
}

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer container,
  Widget home,
) async {
  await preloadContent(tester, container);
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DateTime wednesday = DateTime(2026, 11, 11, 12);

  group('ProgressStats', () {
    test('streak, week sessions, longest hold and completed days', () {
      final UserProfile profile = UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
        level: 1,
      );
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(day: DateTime(2026, 11, 9), longestHoldSeconds: 3),
        _session(day: DateTime(2026, 11, 10), longestHoldSeconds: 5),
        _session(
          day: DateTime(2026, 11, 10, 18),
          longestHoldSeconds: 4,
        ),
        _session(day: DateTime(2026, 11, 11), longestHoldSeconds: 2),
      ];
      final ProgressStats stats = ProgressStats.from(
        profile: profile,
        sessions: sessions,
        today: wednesday,
      );
      expect(stats.streakDays, 3);
      expect(stats.sessionsThisWeek, 4);
      expect(stats.longestHoldSeconds, 5);
      expect(stats.completedDays, contains(DateTime(2026, 11, 9)));
      expect(stats.completedDays, contains(DateTime(2026, 11, 10)));
      expect(stats.completedDays, contains(DateTime(2026, 11, 11)));
      expect(stats.isRelaxationFirst, isFalse);
    });

    test('longest hold ignores non-strengthening sessions', () {
      final UserProfile profile = UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      );
      final ProgressStats stats = ProgressStats.from(
        profile: profile,
        sessions: <SessionRecord>[
          _session(day: DateTime(2026, 11, 10), longestHoldSeconds: 4),
          _session(
            day: DateTime(2026, 11, 11),
            kind: SessionKind.breathing,
            longestHoldSeconds: 99,
          ),
        ],
        today: wednesday,
      );
      expect(stats.longestHoldSeconds, 4);
      expect(stats.sessionsThisWeek, 2);
    });

    test('streak skips rest weekday and does not break', () {
      // Rest = Sunday. Train Fri + Sat; today Monday with no session yet.
      final DateTime monday = DateTime(2026, 11, 16, 12);
      final UserProfile profile = UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      );
      final ProgressStats stats = ProgressStats.from(
        profile: profile,
        sessions: <SessionRecord>[
          _session(day: DateTime(2026, 11, 13)), // Fri
          _session(day: DateTime(2026, 11, 14)), // Sat
          _session(
            day: DateTime(2026, 11, 15),
            kind: SessionKind.breathing,
          ), // Sun rest
        ],
        today: monday,
      );
      expect(stats.streakDays, 2);
    });
  });

  group('CheckInScoring', () {
    test('normalises all five goals with 1 worst and 5 best', () {
      expect(
        CheckInScoring.normalisedFromOptionIndex(Goal.bladderControl, 0),
        5,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(Goal.bladderControl, 4),
        1,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(Goal.erectionSupport, 0),
        1,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(Goal.erectionSupport, 4),
        5,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(Goal.ejaculationControl, 0),
        1,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(Goal.ejaculationControl, 4),
        5,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(
          Goal.recoveryAfterProstateSurgery,
          0,
        ),
        1,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(
          Goal.recoveryAfterProstateSurgery,
          4,
        ),
        5,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(
          Goal.generalPelvicHealth,
          0,
        ),
        1,
      );
      expect(
        CheckInScoring.normalisedFromOptionIndex(
          Goal.generalPelvicHealth,
          4,
        ),
        5,
      );
    });

    test('bladder Never never triggers doctor hint after 8 weeks', () {
      final int neverScore =
          CheckInScoring.normalisedFromOptionIndex(Goal.bladderControl, 0);
      expect(neverScore, 5);
      expect(
        CheckInRules.shouldSuggestDoctor(
          checkIns: <CheckInRecord>[
            CheckInRecord(
              date: DateTime(2026, 9, 1),
              goal: Goal.bladderControl,
              score: neverScore,
            ),
            CheckInRecord(
              date: DateTime(2026, 10, 27),
              goal: Goal.bladderControl,
              score: neverScore,
            ),
          ],
          today: DateTime(2026, 10, 27),
        ),
        isFalse,
      );
    });

    test('doctor hint uses normalised lowest score for each goal', () {
      for (final Goal goal in Goal.values) {
        final int worst =
            CheckInScoring.normalisedFromOptionIndex(goal, goal == Goal.bladderControl ? 4 : 0);
        expect(worst, 1);
        expect(
          CheckInRules.shouldSuggestDoctor(
            checkIns: <CheckInRecord>[
              CheckInRecord(
                date: DateTime(2026, 9, 1),
                goal: goal,
                score: worst,
              ),
              CheckInRecord(
                date: DateTime(2026, 10, 27),
                goal: goal,
                score: worst,
              ),
            ],
            today: DateTime(2026, 10, 27),
          ),
          isTrue,
          reason: '$goal at normalised 1 after 8 weeks',
        );
      }
    });
  });

  group('CheckInRules', () {
    test('due after third session then every 4 weeks', () {
      final List<SessionRecord> three = <SessionRecord>[
        _session(day: DateTime(2026, 11, 1)),
        _session(day: DateTime(2026, 11, 2)),
        _session(day: DateTime(2026, 11, 3)),
      ];
      expect(
        CheckInRules.isDue(
          sessions: three,
          checkIns: const <CheckInRecord>[],
          today: DateTime(2026, 11, 3),
        ),
        isTrue,
      );

      final List<CheckInRecord> baseline = <CheckInRecord>[
        CheckInRecord(
          date: DateTime(2026, 11, 3),
          goal: Goal.bladderControl,
          score: 2,
        ),
      ];
      expect(
        CheckInRules.isDue(
          sessions: three,
          checkIns: baseline,
          today: DateTime(2026, 11, 30),
        ),
        isFalse,
      );
      expect(
        CheckInRules.isDue(
          sessions: three,
          checkIns: baseline,
          today: DateTime(2026, 12, 1),
        ),
        isTrue,
      );
    });

    test('doctor hint after 8 weeks at lowest score', () {
      final List<CheckInRecord> checkIns = <CheckInRecord>[
        CheckInRecord(
          date: DateTime(2026, 9, 1),
          goal: Goal.erectionSupport,
          score: 1,
        ),
        CheckInRecord(
          date: DateTime(2026, 10, 27),
          goal: Goal.erectionSupport,
          score: 1,
        ),
      ];
      expect(
        CheckInRules.shouldSuggestDoctor(
          checkIns: checkIns,
          today: DateTime(2026, 10, 27),
        ),
        isTrue,
      );
      expect(
        CheckInRules.shouldSuggestDoctor(
          checkIns: <CheckInRecord>[
            CheckInRecord(
              date: DateTime(2026, 9, 1),
              goal: Goal.erectionSupport,
              score: 1,
            ),
            CheckInRecord(
              date: DateTime(2026, 10, 27),
              goal: Goal.erectionSupport,
              score: 2,
            ),
          ],
          today: DateTime(2026, 10, 27),
        ),
        isFalse,
      );
    });

    test('free history shows baseline only', () {
      final List<CheckInRecord> checkIns = <CheckInRecord>[
        CheckInRecord(
          date: DateTime(2026, 9, 1),
          goal: Goal.bladderControl,
          score: 2,
        ),
        CheckInRecord(
          date: DateTime(2026, 10, 1),
          goal: Goal.bladderControl,
          score: 3,
        ),
      ];
      expect(
        CheckInRules.visibleHistory(checkIns: checkIns, isPremium: false),
        hasLength(1),
      );
      expect(
        CheckInRules.visibleHistory(checkIns: checkIns, isPremium: true),
        hasLength(2),
      );
    });
  });

  testWidgets('G1 shows streak and calendar marks from sessions',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    // One session a day, so each of the three days counts as a full
    // training day (a day counts only when all planned sessions are done).
    final ProviderContainer container = await _container(
      clock: clock,
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        tutorialDone: true,
        goal: Goal.bladderControl,
        sessionsPerDay: 1,
        level: 1,
        track: TrackId.generalBladder,
        restWeekday: DateTime.sunday,
      ),
      sessions: <SessionRecord>[
        _session(day: DateTime(2026, 11, 9), dayInLevel: 1),
        _session(day: DateTime(2026, 11, 10), dayInLevel: 2),
        _session(day: DateTime(2026, 11, 11), dayInLevel: 3),
      ],
    );
    addTearDown(container.dispose);
    await _pump(tester, container, const G1ProgressScreen());

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);
    expect(find.text('3 sessions'), findsOneWidget);
    expect(find.text('3 s'), findsOneWidget);
    expect(find.text('1 · day 4'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Trained'), findsOneWidget);
  });

  testWidgets('G1 relaxation track never says Level', (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final ProviderContainer container = await _container(
      clock: clock,
      profile: UserProfile.initial().copyWith(
        onboardingDone: true,
        goal: Goal.bladderControl,
        track: TrackId.relaxationFirst,
        level: 1,
        sessionsPerDay: 1,
      ),
      sessions: <SessionRecord>[
        _session(
          day: DateTime(2026, 11, 10),
          kind: SessionKind.breathing,
          track: TrackId.relaxationFirst,
          longestHoldSeconds: 0,
        ),
      ],
    );
    addTearDown(container.dispose);
    await _pump(tester, container, const G1ProgressScreen());

    expect(find.text('Relaxation plan'), findsOneWidget);
    expect(find.text('Day 2 of 14'), findsOneWidget);
    expect(find.textContaining('Level'), findsNothing);
  });

  testWidgets('G2 save stores locally and never logs analytics',
      (WidgetTester tester) async {
    final FakeClock clock = FakeClock(wednesday);
    final _RecordingAnalytics analytics = _RecordingAnalytics();
    final ProviderContainer container = await _container(
      clock: clock,
      analytics: analytics,
      sessions: <SessionRecord>[
        _session(day: DateTime(2026, 11, 1)),
        _session(day: DateTime(2026, 11, 2)),
        _session(day: DateTime(2026, 11, 3)),
      ],
    );
    addTearDown(container.dispose);
    await _pump(tester, container, const G2CheckInScreen());

    expect(
      find.text('In the last week, how often did you leak urine?'),
      findsOneWidget,
    );
    await tester.tap(find.text('A few times'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    // Saving writes to the database and reloads history; give it real
    // async between frames.
    for (int i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    final List<CheckInRecord> saved =
        await container.read(checkInRepositoryProvider).getAll();
    expect(saved, hasLength(1));
    expect(saved.single.score, 3);
    expect(analytics.events, isEmpty);
    expect(
      find.textContaining('Week 0: 3 of 5 · A few times'),
      findsOneWidget,
    );
  });
}
