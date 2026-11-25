import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';

/// Animated pelvic-floor diagram: squeeze → hold → relax GIF with labels.
///
/// Shows red PF muscles and the central sphincter opening in the relax phase,
/// matching the clinical bottom-up anatomy used in onboarding.
class AnatomyDiagram extends StatelessWidget {
  const AnatomyDiagram({super.key});

  static const String _gifAsset =
      'assets/images/onboarding/pf_squeeze_hold_relax.gif';
  static const String _relaxFallback =
      'assets/images/onboarding/pf_phase_relax.jpg';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.t1AnatomySemantic,
      image: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.xlAll,
            border: Border.all(color: AppColors.border),
            boxShadow: AppElevation.level2,
          ),
          child: ClipRRect(
            borderRadius: AppRadii.xlAll,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: AppColors.surfaceMuted,
                  child: Image.asset(
                    _gifAsset,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Image.asset(_relaxFallback, fit: BoxFit.cover);
                        },
                  ),
                ),
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: _MuscleCallout(label: l10n.t1AnatomyPelvicFloor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MuscleCallout extends StatelessWidget {
  const _MuscleCallout({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFD24A4A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
