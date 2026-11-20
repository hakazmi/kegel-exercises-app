import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';

/// One day cell for [WeekStrip].
class WeekDayItem {
  const WeekDayItem({
    required this.label,
    required this.dayNumber,
    this.completed = false,
    this.isToday = false,
    this.isRest = false,
    this.isFuture = false,
  });

  final String label;
  /// Calendar day number, or the rest label (same typography as day numbers).
  final String dayNumber;
  final bool completed;
  final bool isToday;
  final bool isRest;
  final bool isFuture;
}

/// Horizontal 7-day strip: today in an ink pill, completed days with a
/// check badge, the rest day with a moon. Cells drop in one after another.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.days});

  final List<WeekDayItem> days;

  @override
  Widget build(BuildContext context) {
    assert(days.length == 7, 'WeekStrip expects exactly 7 days');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            for (int i = 0; i < days.length; i++)
              Expanded(
                child: Reveal(
                  from: RevealFrom.drop,
                  distance: 18,
                  delay: AppMotion.stagger(i, base: const Duration(milliseconds: 80)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _DayCell(day: days[i], index: i),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.index});

  final WeekDayItem day;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool today = day.isToday;
    final Color labelColor =
        today ? AppColors.textOnPrimary.withValues(alpha: 0.8) : AppColors.textSecondary;
    final Color numberColor = today
        ? AppColors.textOnPrimary
        : (day.isFuture ? AppColors.textSecondary : AppColors.textPrimary);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: today ? AppColors.ink : Colors.transparent,
          borderRadius: AppRadii.lgAll,
          boxShadow: today ? AppElevation.level1 : AppElevation.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day.label,
                style: AppTypography.caption.copyWith(
                  color: labelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 22,
                child: Center(
                  child: Text(
                    day.dayNumber,
                    style: AppTypography.body.copyWith(
                      color: day.isRest && !today
                          ? AppColors.textSecondary
                          : numberColor,
                      fontWeight: FontWeight.w800,
                      fontSize: day.isRest ? 12 : 16,
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
                height: 16,
                child: Center(child: _marker(today)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _marker(bool today) {
    if (day.completed) {
      return AnimatedCheckBadge(
        size: 16,
        color: today ? AppColors.accent : AppColors.primary,
        checkColor: AppColors.textOnPrimary,
        delay: AppMotion.stagger(index, base: const Duration(milliseconds: 300)),
        strokeWidth: 2,
      );
    }
    if (day.isRest) {
      return Icon(
        Icons.nightlight_round,
        size: 13,
        color: today ? AppColors.textOnPrimary : AppColors.textSecondary,
      );
    }
    if (today) {
      return Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
