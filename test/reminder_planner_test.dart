import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/session_record.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/core/services/notification_gateway.dart';
import 'package:kegelexercisesapp/core/services/reminder_kinds.dart';
import 'package:kegelexercisesapp/core/services/reminder_planner.dart';
import 'package:kegelexercisesapp/core/services/reminder_service.dart';
import 'package:kegelexercisesapp/core/time/app_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

SessionRecord _session({
  required DateTime day,
  SessionKind kind = SessionKind.strengthening,
  int level = 1,
}) {
  return SessionRecord(
    startedAt: day,
    completedAt: day,
    level: level,
    dayInLevel: 1,
    track: TrackId.generalBladder,
    kind: kind,
    durationSeconds: 60,
    longestHoldSeconds: 3,
    completed: true,
  );
}

UserProfile _profile({
  bool reminderEnabled = true,
  int reminderTime = 21 * 60,
  List<int> reminderDays = const <int>[1, 2, 3, 4, 5, 6, 7],
  bool discreet = true,
  int restWeekday = DateTime.sunday,
  int sessionsPerDay = 1,
  int level = 1,
  TrackId track = TrackId.generalBladder,
}) {
  return UserProfile.initial().copyWith(
    onboardingDone: true,
    goal: Goal.bladderControl,
    track: track,
    level: level,
    sessionsPerDay: sessionsPerDay,
    reminderEnabled: reminderEnabled,
    reminderTime: reminderTime,
    reminderDays: reminderDays,
    discreetNotifications: discreet,
    restWeekday: restWeekday,
    levelStartedOn: DateTime(2026, 11, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReminderPlanner', () {
    test('schedules discreet daily copy and at most 2 per day', () {
      final DateTime now = DateTime(2026, 11, 11, 12); // Wednesday
      final List<PlannedNotification> planned = ReminderPlanner.plan(
        ReminderPlanInput(
          profile: _profile(reminderTime: 21 * 60),
          sessions: const <SessionRecord>[],
          checkIns: const <CheckInRecord>[],
          now: now,
        ),
      );

      expect(planned, isNotEmpty);
      expect(
        planned.every(
          (PlannedNotification n) =>
              !n.body.toLowerCase().contains('kegel') &&
              !n.title.toLowerCase().contains('kegel'),
        ),
        isTrue,
      );
      final PlannedNotification firstDaily = planned.firstWhere(
        (PlannedNotification n) => n.kind == ReminderKind.daily,
      );
      expect(firstDaily.body, 'Time for your 2-minute session');

      final Map<DateTime, int> perDay = <DateTime, int>{};
      for (final PlannedNotification n in planned) {
        final DateTime day = dateOnly(n.when);
        perDay[day] = (perDay[day] ?? 0) + 1;
      }
      expect(perDay.values.every((int c) => c <= 2), isTrue);
    });

    test('full copy names pelvic floor when discreet is off', () {
      final List<PlannedNotification> planned = ReminderPlanner.plan(
        ReminderPlanInput(
          profile: _profile(discreet: false, reminderTime: 21 * 60),
          sessions: const <SessionRecord>[],
          checkIns: const <CheckInRecord>[],
          now: DateTime(2026, 11, 11, 12),
        ),
      );
      expect(
        planned.any(
          (PlannedNotification n) =>
              n.kind == ReminderKind.daily &&
              n.body == 'Time for your pelvic floor session',
        ),
        isTrue,
      );
    });

    test('rest day only schedules breathing daily, no streak nudge', () {
      // Sunday rest; need a prior completed session so rest applies.
      final DateTime sunday = DateTime(2026, 11, 15, 10);
      final List<SessionRecord> history = <SessionRecord>[
        _session(day: DateTime(2026, 11, 10)),
        _session(day: DateTime(2026, 11, 11)),
        _session(day: DateTime(2026, 11, 12)),
      ];
      final List<PlannedNotification> planned = ReminderPlanner.plan(
        ReminderPlanInput(
          profile: _profile(reminderTime: 21 * 60),
          sessions: history,
          checkIns: const <CheckInRecord>[],
          now: sunday,
        ),
      );
      final List<PlannedNotification> sundayItems = planned
          .where((PlannedNotification n) => dateOnly(n.when) == dateOnly(sunday))
          .toList();
      expect(sundayItems, hasLength(1));
      expect(sundayItems.single.kind, ReminderKind.daily);
      expect(sundayItems.single.body, 'Time for your breathing session');
      expect(
        sundayItems.any((PlannedNotification n) => n.kind == ReminderKind.streakNudge),
        isFalse,
      );
    });

    test('no reminders after the day sessions are done', () {
      final DateTime wednesday = DateTime(2026, 11, 11, 12);
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(day: wednesday),
        _session(
          day: wednesday.add(const Duration(minutes: 5)),
          kind: SessionKind.breathing,
        ),
      ];
      final List<PlannedNotification> planned = ReminderPlanner.plan(
        ReminderPlanInput(
          profile: _profile(sessionsPerDay: 1, reminderTime: 21 * 60),
          sessions: sessions,
          checkIns: const <CheckInRecord>[],
          now: wednesday,
        ),
      );
      expect(
        planned.any(
          (PlannedNotification n) => dateOnly(n.when) == dateOnly(wednesday),
        ),
        isFalse,
      );
    });

    test('streak nudge only when streak is 3+ and 2 hours after reminder', () {
      final DateTime wednesday = DateTime(2026, 11, 11, 12);
      // Sunday rest skips: Sat/Mon/Tue completed → streak 3 on Wednesday.
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(day: DateTime(2026, 11, 7)),
        _session(day: DateTime(2026, 11, 9)),
        _session(day: DateTime(2026, 11, 10)),
      ];
      // Recent check-in so the second slot is the streak nudge, not check-in.
      final List<CheckInRecord> checkIns = <CheckInRecord>[
        CheckInRecord(
          date: DateTime(2026, 11, 3),
          goal: Goal.bladderControl,
          score: 3,
        ),
      ];
      final List<PlannedNotification> planned = ReminderPlanner.plan(
        ReminderPlanInput(
          profile: _profile(reminderTime: 21 * 60),
          sessions: sessions,
          checkIns: checkIns,
          now: wednesday,
        ),
      );
      final PlannedNotification nudge = planned.firstWhere(
        (PlannedNotification n) =>
            n.kind == ReminderKind.streakNudge &&
            dateOnly(n.when) == dateOnly(wednesday),
      );
      expect(nudge.when, DateTime(2026, 11, 11, 23));
      expect(nudge.body, 'Keep your streak going today');
    });

    test('bladder Never-style best score never required; check-in notice when due',
        () {
      final DateTime wednesday = DateTime(2026, 11, 11, 12);
      final List<SessionRecord> sessions = <SessionRecord>[
        _session(day: DateTime(2026, 11, 1)),
        _session(day: DateTime(2026, 11, 2)),
        _session(day: DateTime(2026, 11, 3)),
      ];
      final List<PlannedNotification> planned = ReminderPlanner.plan(
        ReminderPlanInput(
          profile: _profile(reminderTime: 21 * 60),
          sessions: sessions,
          checkIns: const <CheckInRecord>[],
          now: wednesday,
        ),
      );
      expect(
        planned.any((PlannedNotification n) => n.kind == ReminderKind.checkInDue),
        isTrue,
      );
      expect(
        planned
            .where((PlannedNotification n) => n.kind == ReminderKind.checkInDue)
            .single
            .body,
        'Your 4-week check-in is ready',
      );
    });

    test('level unlock notice uses exact copy', () {
      final List<PlannedNotification> planned = ReminderPlanner.plan(
        ReminderPlanInput(
          profile: _profile(reminderTime: 21 * 60),
          sessions: const <SessionRecord>[],
          checkIns: const <CheckInRecord>[],
          now: DateTime(2026, 11, 11, 12),
          notifyLevelUnlock: true,
        ),
      );
      expect(
        planned.any(
          (PlannedNotification n) =>
              n.kind == ReminderKind.levelUnlocked &&
              n.body == 'New level unlocked',
        ),
        isTrue,
      );
    });

    test('disabled reminders plan nothing', () {
      expect(
        ReminderPlanner.plan(
          ReminderPlanInput(
            profile: _profile(reminderEnabled: false),
            sessions: const <SessionRecord>[],
            checkIns: const <CheckInRecord>[],
            now: DateTime(2026, 11, 11, 12),
          ),
        ),
        isEmpty,
      );
    });
  });

  group('LocalReminderService with fake plugin', () {
    test('enable schedules; disable cancels; reschedule respects off', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FakeNotificationGateway gateway = FakeNotificationGateway();
      final FakeClock clock = FakeClock(DateTime(2026, 11, 11, 12));
      UserProfile profile = _profile(reminderEnabled: true, reminderTime: 21 * 60);

      final LocalReminderService service = LocalReminderService(
        gateway: gateway,
        prefs: prefs,
        loadInput: () async => ReminderPlanInput(
          profile: profile,
          sessions: const <SessionRecord>[],
          checkIns: const <CheckInRecord>[],
          now: clock.now(),
        ),
      );

      await service.enableReminder(
        minutesFromMidnight: 21 * 60,
        days: profile.reminderDays,
      );
      expect(gateway.permissionRequestCount, 1);
      expect(gateway.scheduled, isNotEmpty);

      await service.disableReminder();
      expect(gateway.scheduled, isEmpty);

      profile = profile.copyWith(reminderEnabled: false);
      await service.reschedule();
      expect(gateway.scheduled, isEmpty);
    });

    test('timezone change updates local zone then reschedules', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'reminder_last_timezone': 'UTC',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FakeNotificationGateway gateway =
          FakeNotificationGateway(timeZoneId: 'America/New_York');
      final FakeClock clock = FakeClock(DateTime(2026, 11, 11, 12));
      final UserProfile profile =
          _profile(reminderEnabled: true, reminderTime: 21 * 60);

      final LocalReminderService service = LocalReminderService(
        gateway: gateway,
        prefs: prefs,
        loadInput: () async => ReminderPlanInput(
          profile: profile,
          sessions: const <SessionRecord>[],
          checkIns: const <CheckInRecord>[],
          now: clock.now(),
        ),
      );

      await service.initialize();
      expect(prefs.getString('reminder_last_timezone'), 'America/New_York');
      expect(gateway.scheduled, isNotEmpty);
    });
  });
}
