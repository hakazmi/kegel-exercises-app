import '../../app/l10n/app_localizations.dart';
import '../../core/domain/session_record.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/time/app_clock.dart';
import '../../core/widgets/week_strip.dart';

/// Whole calendar days from [from] to [to] (date-only, DST-safe).
int _calendarDaysBetween(DateTime from, DateTime to) {
  final DateTime a = DateTime.utc(from.year, from.month, from.day);
  final DateTime b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// 1-based plan week containing [today], or null without a start date.
int? planWeekNumber({required DateTime today, DateTime? planStart}) {
  if (planStart == null) {
    return null;
  }
  final int days = _calendarDaysBetween(planStart, today);
  if (days < 0) {
    return null;
  }
  return days ~/ 7 + 1;
}

/// First day shown in the strip.
///
/// With a plan start: the start of the current 7-day plan week, so the day
/// the user joined is always first and the rest day (day 7) is last; once
/// those seven days pass, the next seven appear. Without one: this Monday.
DateTime weekStripStart({required DateTime today, DateTime? planStart}) {
  final DateTime todayDate = dateOnly(today);
  final int? week = planWeekNumber(today: todayDate, planStart: planStart);
  if (week == null) {
    return todayDate.subtract(
      Duration(days: todayDate.weekday - DateTime.monday),
    );
  }
  final DateTime start = dateOnly(planStart!);
  return DateTime(start.year, start.month, start.day + (week - 1) * 7);
}

/// Builds the seven [WeekStrip] cells for H1 from plan history.
List<WeekDayItem> buildTodayWeekStrip({
  required AppLocalizations l10n,
  required DateTime today,
  required int restWeekday,
  required List<SessionRecord> sessions,
  DateTime? planStart,
}) {
  final DateTime todayDate = dateOnly(today);
  final DateTime first = weekStripStart(today: todayDate, planStart: planStart);
  final Set<DateTime> done = PlanRules.completedDays(sessions).toSet();

  return List<WeekDayItem>.generate(7, (int index) {
    final DateTime day = DateTime(first.year, first.month, first.day + index);
    final bool configuredRest = PlanRules.isConfiguredRestWeekday(
      day,
      restWeekday,
    );
    final bool activeRest = PlanRules.isRestDay(
      date: day,
      restWeekday: restWeekday,
      sessions: sessions,
    );
    final bool rest = configuredRest || activeRest;
    return WeekDayItem(
      label: _weekdayShort(l10n, day.weekday),
      dayNumber: rest ? l10n.h1WeekRest : '${day.day}',
      completed: done.contains(day),
      isToday: isSameDay(day, todayDate),
      isRest: rest,
      isFuture: day.isAfter(todayDate),
    );
  });
}

String _weekdayShort(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.h1WeekMon,
    DateTime.tuesday => l10n.h1WeekTue,
    DateTime.wednesday => l10n.h1WeekWed,
    DateTime.thursday => l10n.h1WeekThu,
    DateTime.friday => l10n.h1WeekFri,
    DateTime.saturday => l10n.h1WeekSat,
    _ => l10n.h1WeekSun,
  };
}
