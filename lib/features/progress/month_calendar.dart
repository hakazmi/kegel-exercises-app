import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/time/app_clock.dart';
import '../../core/widgets/app_card.dart';

/// Month grid with completed training days marked. No calendar package.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.today,
    required this.completedDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  /// First day of the visible month (day truncated to 1).
  final DateTime month;
  final DateTime today;
  final Set<DateTime> completedDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime monthStart = DateTime(month.year, month.month);
    final DateTime todayDate = dateOnly(today);
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday = 1 … Sunday = 7 → leading blanks before day 1.
    final int leading = monthStart.weekday - DateTime.monday;
    final List<String> weekdayLabels = <String>[
      l10n.g1CalMon,
      l10n.g1CalTue,
      l10n.g1CalWed,
      l10n.g1CalThu,
      l10n.g1CalFri,
      l10n.g1CalSat,
      l10n.g1CalSun,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.g1CalPrevious,
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  l10n.g1CalMonthYear(_monthName(l10n, month.month), month.year),
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                tooltip: l10n.g1CalNext,
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            children: [
              const Spacer(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                l10n.g1CalTrained,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final String label in weekdayLabels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (int row = 0; row < 6; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Row(
                children: [
                  for (int col = 0; col < 7; col++)
                    Expanded(
                      child: _DayCell(
                        dayNumber: _dayNumber(
                          row: row,
                          col: col,
                          leading: leading,
                          daysInMonth: daysInMonth,
                        ),
                        isToday: _isToday(
                          row: row,
                          col: col,
                          leading: leading,
                          daysInMonth: daysInMonth,
                          monthStart: monthStart,
                          today: todayDate,
                        ),
                        isCompleted: _isCompleted(
                          row: row,
                          col: col,
                          leading: leading,
                          daysInMonth: daysInMonth,
                          monthStart: monthStart,
                          completedDays: completedDays,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static int? _dayNumber({
    required int row,
    required int col,
    required int leading,
    required int daysInMonth,
  }) {
    final int index = row * 7 + col - leading + 1;
    if (index < 1 || index > daysInMonth) {
      return null;
    }
    return index;
  }

  static bool _isToday({
    required int row,
    required int col,
    required int leading,
    required int daysInMonth,
    required DateTime monthStart,
    required DateTime today,
  }) {
    final int? day = _dayNumber(
      row: row,
      col: col,
      leading: leading,
      daysInMonth: daysInMonth,
    );
    if (day == null) {
      return false;
    }
    return isSameDay(DateTime(monthStart.year, monthStart.month, day), today);
  }

  static bool _isCompleted({
    required int row,
    required int col,
    required int leading,
    required int daysInMonth,
    required DateTime monthStart,
    required Set<DateTime> completedDays,
  }) {
    final int? day = _dayNumber(
      row: row,
      col: col,
      leading: leading,
      daysInMonth: daysInMonth,
    );
    if (day == null) {
      return false;
    }
    return completedDays.contains(
      DateTime(monthStart.year, monthStart.month, day),
    );
  }

  static String _monthName(AppLocalizations l10n, int month) {
    switch (month) {
      case 1:
        return l10n.g1MonthJanuary;
      case 2:
        return l10n.g1MonthFebruary;
      case 3:
        return l10n.g1MonthMarch;
      case 4:
        return l10n.g1MonthApril;
      case 5:
        return l10n.g1MonthMay;
      case 6:
        return l10n.g1MonthJune;
      case 7:
        return l10n.g1MonthJuly;
      case 8:
        return l10n.g1MonthAugust;
      case 9:
        return l10n.g1MonthSeptember;
      case 10:
        return l10n.g1MonthOctober;
      case 11:
        return l10n.g1MonthNovember;
      case 12:
        return l10n.g1MonthDecember;
      default:
        return l10n.g1MonthJanuary;
    }
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNumber,
    required this.isToday,
    required this.isCompleted,
  });

  final int? dayNumber;
  final bool isToday;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (dayNumber == null) {
      return const SizedBox(height: 36);
    }
    final Color textColor;
    if (isCompleted) {
      textColor = AppColors.textOnPrimary;
    } else if (isToday) {
      textColor = AppColors.textPrimary;
    } else {
      textColor = AppColors.textSecondary;
    }

    return SizedBox(
      height: 36,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.primary : Colors.transparent,
            border: isToday && !isCompleted
                ? Border.all(color: AppColors.ink, width: 1.5)
                : null,
          ),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: Text(
                '$dayNumber',
                style: AppTypography.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
