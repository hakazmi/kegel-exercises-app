import '../../app/l10n/app_localizations.dart';
import '../../core/domain/session_record.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/time/app_clock.dart';
import '../../core/widgets/week_strip.dart';

/// Builds the Mon–Sun [WeekStrip] cells for H1 from plan history.
List<WeekDayItem> buildTodayWeekStrip({
  required AppLocalizations l10n,
  required DateTime today,
  required int restWeekday,
  required List<SessionRecord> sessions,
}) {
  final DateTime todayDate = dateOnly(today);
  final DateTime monday =
      todayDate.subtract(Duration(days: todayDate.weekday - DateTime.monday));
  final List<String> labels = <String>[
    l10n.h1WeekMon,
    l10n.h1WeekTue,
    l10n.h1WeekWed,
    l10n.h1WeekThu,
    l10n.h1WeekFri,
    l10n.h1WeekSat,
    l10n.h1WeekSun,
  ];
  final Set<DateTime> done = PlanRules.completedDays(sessions).toSet();

  return List<WeekDayItem>.generate(7, (int index) {
    final DateTime day = monday.add(Duration(days: index));
    final bool configuredRest =
        PlanRules.isConfiguredRestWeekday(day, restWeekday);
    final bool activeRest = PlanRules.isRestDay(
      date: day,
      restWeekday: restWeekday,
      sessions: sessions,
    );
    final bool rest = configuredRest || activeRest;
    return WeekDayItem(
      label: labels[index],
      dayNumber: rest ? l10n.h1WeekRest : '${day.day}',
      completed: done.contains(day),
      isToday: isSameDay(day, todayDate),
      isRest: rest,
    );
  });
}
