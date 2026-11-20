import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';

/// Onboarding header: round back button, segmented progress and `n of 6`.
///
/// One segment per step: finished steps are filled, the current one fills
/// in as the screen opens. Horizontal padding matches onboarding content
/// ([AppSpacing.xl]) so the step label sits on the right content edge.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.step,
    required this.total,
    this.onBack,
  });

  final int step;
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            enabled: onBack != null,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            child: PressScale(
              onTap: onBack,
              child: AnimatedOpacity(
                duration: AppMotion.quick,
                opacity: onBack == null ? 0.4 : 1,
                child: Container(
                  width: AppSpacing.minTouchTarget,
                  height: AppSpacing.minTouchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              value: '$step of $total',
              child: Row(
                children: [
                  for (int i = 1; i <= total; i++) ...[
                    if (i > 1) const SizedBox(width: 4),
                    Expanded(child: _Segment(state: _segmentState(i))),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$step of $total',
            textAlign: TextAlign.end,
            maxLines: 1,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _SegmentState _segmentState(int index) {
    if (index < step) {
      return _SegmentState.done;
    }
    if (index == step) {
      return _SegmentState.current;
    }
    return _SegmentState.todo;
  }
}

enum _SegmentState { done, current, todo }

class _Segment extends StatelessWidget {
  const _Segment({required this.state});

  final _SegmentState state;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: SizedBox(
        height: 6,
        child: ColoredBox(
          color: AppColors.surfaceMuted,
          child: AnimatedFraction(
            value: state == _SegmentState.todo ? 0 : 1,
            delay: state == _SegmentState.current
                ? const Duration(milliseconds: 150)
                : Duration.zero,
            duration: state == _SegmentState.current
                ? const Duration(milliseconds: 700)
                : const Duration(milliseconds: 1),
            builder: (BuildContext context, double v) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: state == _SegmentState.current
                          ? const <Color>[AppColors.primary, AppColors.accent]
                          : const <Color>[AppColors.primary, AppColors.primary],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
