import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Onboarding header: back, linear progress, and `n of 6` label.
///
/// Horizontal padding matches onboarding content ([AppSpacing.xl]) so the
/// progress bar fills the remaining width and the step label sits on the
/// right content edge.
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
    final double progress = total == 0 ? 0 : step / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(
              minWidth: AppSpacing.minTouchTarget,
              minHeight: AppSpacing.minTouchTarget,
            ),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              minimumSize: const Size(
                AppSpacing.minTouchTarget,
                AppSpacing.minTouchTarget,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadii.pillAll,
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.surfaceMuted,
                color: AppColors.primary,
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
