import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// One day cell for [WeekStrip].
class WeekDayItem {
  const WeekDayItem({
    required this.label,
    required this.dayNumber,
    this.completed = false,
    this.isToday = false,
    this.isRest = false,
  });

  final String label;
  /// Calendar day number, or the rest label (same typography as day numbers).
  final String dayNumber;
  final bool completed;
  final bool isToday;
  final bool isRest;
}

/// Horizontal 7-day strip with completed dots and today highlight.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.days});

  final List<WeekDayItem> days;

  @override
  Widget build(BuildContext context) {
    assert(days.length == 7, 'WeekStrip expects exactly 7 days');
    return Row(
      children: [
        for (final WeekDayItem day in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DayCell(day: day),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day});

  final WeekDayItem day;

  @override
  Widget build(BuildContext context) {
    final Color bg = day.isToday ? AppColors.ink : Colors.transparent;
    final Color fg =
        day.isToday ? AppColors.textOnPrimary : AppColors.textPrimary;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day.label,
                style: AppTypography.caption.copyWith(
                  color: day.isToday
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 22,
                child: Center(
                  child: Text(
                    day.dayNumber,
                    style: AppTypography.body.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 6,
                child: day.completed
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 6, height: 6),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
