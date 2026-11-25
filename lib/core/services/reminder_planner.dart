import '../domain/enums.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../plan/plan_models.dart';
import '../plan/plan_rules.dart';
import '../plan/plan_service.dart';
import '../time/app_clock.dart';
import 'reminder_copy.dart';
import 'reminder_kinds.dart';

/// One local notification the plugin should schedule.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.kind,
    required this.when,
    required this.title,
    required this.body,
  });

  final int id;
  final ReminderKind kind;
  final DateTime when;
  final String title;
  final String body;
}

/// Inputs for building the next 7 days of reminders.
class ReminderPlanInput {
  const ReminderPlanInput({
    required this.profile,
    required this.sessions,
    required this.checkIns,
    required this.now,
    this.notifyLevelUnlock = false,
  });

  final UserProfile profile;
  final List<SessionRecord> sessions;
  final List<CheckInRecord> checkIns;
  final DateTime now;

  /// True when a level-unlock notice should fire soon (one-shot).
  final bool notifyLevelUnlock;
}

/// Pure scheduling rules for local reminders (no Flutter / plugin imports).
abstract final class ReminderPlanner {
  static const int horizonDays = 7;
  static const int maxPerDay = 2;
  static const Duration streakNudgeDelay = Duration(hours: 2);
  static const int minStreakForNudge = 3;

  /// Stable notification id for [kind] on [day] (local calendar date).
  static int idFor(ReminderKind kind, DateTime day) {
    final DateTime d = dateOnly(day);
    final int dayKey = d.year * 10000 + d.month * 100 + d.day;
    switch (kind) {
      case ReminderKind.daily:
        return dayKey * 10 + 1;
      case ReminderKind.streakNudge:
        return dayKey * 10 + 2;
      case ReminderKind.checkInDue:
        return dayKey * 10 + 3;
      case ReminderKind.levelUnlocked:
        return 900000001;
    }
  }

  /// Builds at most [maxPerDay] notifications per day for the next [horizonDays].
  static List<PlannedNotification> plan(ReminderPlanInput input) {
    if (!input.profile.reminderEnabled) {
      return const <PlannedNotification>[];
    }
    if (PlanRules.isCatheterBlocked(input.profile)) {
      return const <PlannedNotification>[];
    }

    final List<PlannedNotification> out = <PlannedNotification>[];
    final DateTime now = input.now;
    final bool discreet = input.profile.discreetNotifications;
    final List<SessionRecord> planSessions = PlanRules.sessionsForActivePlan(
      profile: input.profile,
      sessions: input.sessions,
    );
    final int streak = PlanRules.streak(
      planSessions,
      now,
      restWeekday: input.profile.restWeekday,
    );
    bool checkInScheduled = false;

    for (int offset = 0; offset < horizonDays; offset++) {
      final DateTime day = dateOnly(now).add(Duration(days: offset));
      if (!_isReminderDay(input.profile, day)) {
        continue;
      }

      final _DayContext dayCtx = _dayContext(
        profile: input.profile,
        sessions: planSessions,
        day: day,
      );
      if (dayCtx.sessionsDone) {
        continue;
      }

      final List<PlannedNotification> dayItems = <PlannedNotification>[];
      final DateTime dailyAt = _atTime(day, input.profile.reminderTime);

      if (offset == 0 && input.notifyLevelUnlock) {
        final DateTime when = now.add(const Duration(minutes: 1));
        if (when.isAfter(now)) {
          dayItems.add(
            PlannedNotification(
              id: idFor(ReminderKind.levelUnlocked, day),
              kind: ReminderKind.levelUnlocked,
              when: when,
              title: ReminderCopy.title,
              body: ReminderCopy.body(
                kind: ReminderKind.levelUnlocked,
                discreet: discreet,
                restDay: false,
              ),
            ),
          );
        }
      }

      if (dailyAt.isAfter(now) && dayItems.length < maxPerDay) {
        dayItems.add(
          PlannedNotification(
            id: idFor(ReminderKind.daily, day),
            kind: ReminderKind.daily,
            when: dailyAt,
            title: ReminderCopy.title,
            body: ReminderCopy.body(
              kind: ReminderKind.daily,
              discreet: discreet,
              restDay: dayCtx.restDay,
            ),
          ),
        );
      }

      final bool checkInDue =
          !checkInScheduled &&
          !dayCtx.restDay &&
          PlanRules.isCheckInDue(
            sessions: input.sessions,
            checkIns: input.checkIns,
            today: day,
          );
      if (checkInDue && dayItems.length < maxPerDay) {
        final DateTime checkAt = dailyAt.isAfter(now)
            ? dailyAt.add(const Duration(minutes: 5))
            : now.add(const Duration(minutes: 2));
        if (checkAt.isAfter(now)) {
          dayItems.add(
            PlannedNotification(
              id: idFor(ReminderKind.checkInDue, day),
              kind: ReminderKind.checkInDue,
              when: checkAt,
              title: ReminderCopy.title,
              body: ReminderCopy.body(
                kind: ReminderKind.checkInDue,
                discreet: discreet,
                restDay: false,
              ),
            ),
          );
          checkInScheduled = true;
        }
      }

      if (!dayCtx.restDay &&
          streak >= minStreakForNudge &&
          dayItems.length < maxPerDay) {
        final DateTime nudgeAt = dailyAt.add(streakNudgeDelay);
        if (nudgeAt.isAfter(now)) {
          dayItems.add(
            PlannedNotification(
              id: idFor(ReminderKind.streakNudge, day),
              kind: ReminderKind.streakNudge,
              when: nudgeAt,
              title: ReminderCopy.title,
              body: ReminderCopy.body(
                kind: ReminderKind.streakNudge,
                discreet: discreet,
                restDay: false,
              ),
            ),
          );
        }
      }

      out.addAll(dayItems.take(maxPerDay));
    }

    out.sort(
      (PlannedNotification a, PlannedNotification b) =>
          a.when.compareTo(b.when),
    );
    return out;
  }

  static bool _isReminderDay(UserProfile profile, DateTime day) {
    return profile.reminderDays.contains(day.weekday);
  }

  static DateTime _atTime(DateTime day, int minutesFromMidnight) {
    final DateTime d = dateOnly(day);
    return DateTime(
      d.year,
      d.month,
      d.day,
      minutesFromMidnight ~/ 60,
      minutesFromMidnight % 60,
    );
  }

  static _DayContext _dayContext({
    required UserProfile profile,
    required List<SessionRecord> sessions,
    required DateTime day,
  }) {
    final TodayPlan plan = PlanService(clock: FakeClock(day))
        .todayPlan(profile: profile, sessions: sessions);
    final bool rest = PlanRules.isRestDay(
      date: day,
      restWeekday: profile.restWeekday,
      sessions: sessions,
    );
    final bool done =
        plan.state == TodayPlanState.allDone ||
        plan.state == TodayPlanState.dailyCapReached ||
        plan.state == TodayPlanState.catheterBlocked;
    return _DayContext(restDay: rest, sessionsDone: done);
  }
}

class _DayContext {
  const _DayContext({required this.restDay, required this.sessionsDone});

  final bool restDay;
  final bool sessionsDone;
}
