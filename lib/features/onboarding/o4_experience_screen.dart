import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/info_copy.dart';
import '../../core/domain/enums.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_stage.dart';
import 'widgets/onboarding_scaffold.dart';

/// O4 Experience — single choice.
class O4ExperienceScreen extends ConsumerWidget {
  const O4ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);

    return OnboardingScaffold(
      step: 4,
      onBack: () => context.go(AppRoutes.safety),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            from: RevealFrom.drop,
            child: Stack(
              children: [
                ExperienceScene(semanticLabel: l10n.o4HeroSemantic),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: InfoButton(content: InfoCopy.kegel(l10n)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 60),
            child: Text(l10n.o4Title, style: AppTypography.display),
          ),
          const SizedBox(height: AppSpacing.xs),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 110),
            child: Text(
              l10n.o4Subtitle,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (int i, (Experience, String, String, IconData, Color, Color)
              option) in <(Experience, String, String, IconData, Color, Color)>[
            (
              Experience.none,
              l10n.o4None,
              l10n.o4GuideHint,
              Icons.lightbulb_outline_rounded,
              AppColors.goalEjaculationBg,
              AppColors.goalEjaculationFg,
            ),
            (
              Experience.unsure,
              l10n.o4Unsure,
              l10n.o4GuideHint,
              Icons.help_outline_rounded,
              AppColors.goalBladderBg,
              AppColors.goalBladderFg,
            ),
            (
              Experience.confident,
              l10n.o4Confident,
              l10n.o4ConfidentHint,
              Icons.verified_outlined,
              AppColors.goalSurgeryBg,
              AppColors.goalSurgeryFg,
            ),
          ].indexed) ...[
            Reveal(
              from: i.isEven ? RevealFrom.left : RevealFrom.right,
              delay: AppMotion.stagger(
                i,
                base: const Duration(milliseconds: 160),
              ),
              child: SelectableCard(
                title: option.$2,
                subtitle: option.$3,
                leading: Icon(option.$4),
                iconBackground: option.$5,
                iconForeground: option.$6,
                selected: draft.experience == option.$1,
                onTap: () => controller.setExperience(option.$1),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
      footer: PrimaryButton(
        label: l10n.commonNext,
        trailingArrow: draft.experience != null,
        enabled: draft.experience != null,
        onPressed: draft.experience == null
            ? null
            : () async {
                await controller.completeStep('O4');
                if (context.mounted) {
                  context.go(AppRoutes.time);
                }
              },
      ),
    );
  }
}
