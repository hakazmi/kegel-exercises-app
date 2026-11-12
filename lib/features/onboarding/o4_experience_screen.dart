import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/domain/enums.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
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
          Center(
            child: Illustration(
              assetPath: 'assets/images/target.svg',
              semanticLabel: l10n.o4TargetSemantic,
              width: 56,
              height: 56,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.o4Title, style: AppTypography.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.o4Subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          SelectableCard(
            title: l10n.o4None,
            selected: draft.experience == Experience.none,
            onTap: () => controller.setExperience(Experience.none),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableCard(
            title: l10n.o4Unsure,
            selected: draft.experience == Experience.unsure,
            onTap: () => controller.setExperience(Experience.unsure),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableCard(
            title: l10n.o4Confident,
            selected: draft.experience == Experience.confident,
            onTap: () => controller.setExperience(Experience.confident),
          ),
        ],
      ),
      footer: PrimaryButton(
        label: l10n.commonNext,
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
