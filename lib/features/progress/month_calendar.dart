import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/motion/app_motion.dart';
import '../../core/time/app_clock.dart';

/// Month grid with trained days, rest days and today. No calendar package.
///
/// Months slide left or right when paging ([direction]); trained days pop
/// in. Rest days follow the user's rest weekday from [planStart] onward.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.today,
    required this.completedDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.restWeekday,
    this.planStart,
    this.direction = 1,
  });

  /// First day of the visible month (day truncated to 1).
  final DateTime month;
  final DateTime today;
  final Set<DateTime> completedDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  /// ISO weekday of the weekly rest day; null hides rest markers.
  final int? restWeekday;

  /// First plan day; rest markers start here.
  final DateTime? planStart;

  /// +1 when the user paged forward, -1 backward.
  final int direction;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> weekdayLabels = <String>[
      l10n.g1CalMon,
      l10n.g1CalTue,
      l10n.g1CalWed,
      l10n.g1CalThu,
      l10n.g1CalFri,
      l10n.g1CalSat,
      l10n.g1CalSun,
    ];
    final int trainedThisMonth = completedDays
        .where((DateTime d) => d.year == month.year && d.month == month.month)
        .length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _NavButton(
                tooltip: l10n.g1CalPrevious,
                icon: Icons.chevron_left_rounded,
                onTap: onPreviousMonth,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.quick,
                  child: Column(
                    key: ValueKey<DateTime>(month),
                    children: [
                      Text(
                        l10n.g1CalMonthYear(
                          _monthName(l10n, month.month),
                          month.year,
                        ),
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        l10n.g1CalTrainedCount(trainedThisMonth),
                        style: AppTypography.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              _NavButton(
                tooltip: l10n.g1CalNext,
                icon: Icons.chevron_right_rounded,
                onTap: onNextMonth,
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRect(
            child: AnimatedSwitcher(
              duration: AppMotion.slide,
              switchInCurve: AppMotion.slideCurve,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[...previous, ?current],
              ),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final bool incoming =
                    child.key == ValueKey<DateTime>(month);
                final double from = incoming ? direction * 0.25 : -direction * 0.25;
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(from, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _MonthGrid(
                key: ValueKey<DateTime>(month),
                month: month,
                today: dateOnly(today),
                completedDays: completedDays,
                restWeekday: restWeekday,
                planStart: planStart == null ? null : dateOnly(planStart!),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xxs,
            children: [
              _Legend(
                marker: const _Dot(color: AppColors.primary),
                label: l10n.g1CalTrained,
              ),
              if (restWeekday != null && planStart != null)
                _Legend(
                  marker: const Icon(
                    Icons.nightlight_round,
                    size: 12,
                    color: AppColors.goalSurgeryFg,
                  ),
                  label: l10n.g1CalRest,
                ),
              _Legend(
                marker: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                ),
                label: l10n.tabToday,
              ),
            ],
          ),
        ],
      ),
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    super.key,
    required this.month,
    required this.today,
    required this.completedDays,
    required this.restWeekday,
    required this.planStart,
  });

  final DateTime month;
  final DateTime today;
  final Set<DateTime> completedDays;
  final int? restWeekday;
  final DateTime? planStart;

  @override
  Widget build(BuildContext context) {
    final DateTime monthStart = DateTime(month.year, month.month);
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday = 1 … Sunday = 7 → leading blanks before day 1.
    final int leading = monthStart.weekday - DateTime.monday;
    final int rows = ((leading + daysInMonth) / 7).ceil();

    return Column(
      children: [
        for (int row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Row(
              children: [
                for (int col = 0; col < 7; col++)
                  Expanded(child: _cell(row * 7 + col - leading + 1)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(int dayNumber) {
    if (dayNumber < 1 || dayNumber > daysInMonthOf(month)) {
      return const SizedBox(height: 38);
    }
    final DateTime date = DateTime(month.year, month.month, dayNumber);
    final bool completed = completedDays.contains(date);
    final bool isRest = !completed &&
        restWeekday != null &&
        planStart != null &&
        !date.isBefore(planStart!) &&
        date.weekday == restWeekday;
    return _DayCell(
      dayNumber: dayNumber,
      isToday: isSameDay(date, today),
      isCompleted: completed,
      isRest: isRest,
      isFuture: date.isAfter(today),
      popDelay: Duration(milliseconds: 120 + dayNumber * 14),
    );
  }

  static int daysInMonthOf(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNumber,
    required this.isToday,
    required this.isCompleted,
    required this.isRest,
    required this.isFuture,
    required this.popDelay,
  });

  final int dayNumber;
  final bool isToday;
  final bool isCompleted;
  final bool isRest;
  final bool isFuture;
  final Duration popDelay;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (isCompleted) {
      textColor = AppColors.textOnPrimary;
    } else if (isToday) {
      textColor = AppColors.textPrimary;
    } else if (isFuture) {
      textColor = AppColors.textDisabled;
    } else {
      textColor = AppColors.textSecondary;
    }

    final Widget label = Text(
      '$dayNumber',
      style: AppTypography.caption.copyWith(
        color: textColor,
        fontWeight: FontWeight.w800,
      ),
    );

    Widget circle = Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isCompleted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.accent, AppColors.primary],
              )
            : null,
        color: isCompleted
            ? null
            : (isRest ? AppColors.goalSurgeryBg : Colors.transparent),
        border: isToday && !isCompleted
            ? Border.all(color: AppColors.ink, width: 1.5)
            : null,
      ),
      child: label,
    );

    if (isCompleted) {
      circle = Reveal(
        from: RevealFrom.fade,
        delay: popDelay,
        child: _Pop(delay: popDelay, child: circle),
      );
    }

    return SizedBox(
      height: 38,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            circle,
            if (isRest)
              const Positioned(
                right: -1,
                top: -1,
                child: Icon(
                  Icons.nightlight_round,
                  size: 11,
                  color: AppColors.goalSurgeryFg,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Scale pop (0.6 → 1 with a small overshoot) after [delay].
class _Pop extends StatelessWidget {
  const _Pop({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedFraction(
      value: 1,
      delay: delay,
      duration: const Duration(milliseconds: 420),
      builder: (BuildContext context, double v) => Transform.scale(
        scale: 0.6 + 0.4 * AppMotion.dropCurve.transform(v),
        child: child,
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressScale(
        onTap: onTap,
        semanticLabel: tooltip,
        child: Container(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.marker, required this.label});

  final Widget marker;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        marker,
        const SizedBox(width: AppSpacing.xxs),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
