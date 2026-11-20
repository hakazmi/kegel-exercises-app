import 'package:material_ui/material_ui.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/motion/app_motion.dart';

/// Soft white card hero used at the top of onboarding steps.
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    super.key,
    required this.assetPath,
    required this.semanticLabel,
    this.fallbackAssetPath,
    this.height = 168,
  });

  final String assetPath;
  final String? fallbackAssetPath;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FloatBob(
      lift: 4,
      period: const Duration(milliseconds: 2800),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.xlAll,
          border: Border.all(color: AppColors.border),
          boxShadow: AppElevation.level2,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFFF8FBFA),
              AppColors.surface,
            ],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -36,
              right: -24,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mint.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                semanticLabel: semanticLabel,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  final String? fallback = fallbackAssetPath;
                  if (fallback == null) {
                    return const SizedBox.shrink();
                  }
                  return Image.asset(
                    fallback,
                    fit: BoxFit.contain,
                    semanticLabel: semanticLabel,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
