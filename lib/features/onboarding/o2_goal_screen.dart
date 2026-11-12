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

/// O2 Goal — single choice.
class O2GoalScreen extends ConsumerWidget {
  const O2GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);

    final List<_GoalOption> options = <_GoalOption>[
      _GoalOption(
        Goal.bladderControl,
        l10n.o2GoalBladder,
        Icons.water_drop_outlined,
        AppColors.goalBladderBg,
        AppColors.goalBladderFg,
      ),
      _GoalOption(
        Goal.erectionSupport,
        l10n.o2GoalErection,
        Icons.trending_up,
        AppColors.goalErectionBg,
        AppColors.goalErectionFg,
      ),
      _GoalOption(
        Goal.ejaculationControl,
        l10n.o2GoalEjaculation,
        Icons.timer_outlined,
        AppColors.goalEjaculationBg,
        AppColors.goalEjaculationFg,
      ),
      _GoalOption(
        Goal.recoveryAfterProstateSurgery,
        l10n.o2GoalSurgery,
        Icons.health_and_safety_outlined,
        AppColors.goalSurgeryBg,
        AppColors.goalSurgeryFg,
      ),
      _GoalOption(
        Goal.generalPelvicHealth,
        l10n.o2GoalGeneral,
        Icons.favorite_border,
        AppColors.goalGeneralBg,
        AppColors.goalGeneralFg,
      ),
    ];

    return OnboardingScaffold(
      step: 2,
      onBack: () => context.go(AppRoutes.welcome),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.o2Title, style: AppTypography.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.o2Subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final _GoalOption option in options) ...[
            SelectableCard(
              title: option.label,
              selected: draft.goal == option.goal,
              leading: Icon(option.icon),
              iconBackground: option.bg,
              iconForeground: option.fg,
              onTap: () => controller.setGoal(option.goal),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
      footer: PrimaryButton(
        label: l10n.commonNext,
        enabled: draft.goal != null,
        onPressed: draft.goal == null
            ? null
            : () async {
                await controller.completeStep('O2');
                if (context.mounted) {
                  context.go(AppRoutes.safety);
                }
              },
      ),
    );
  }
}

class _GoalOption {
  const _GoalOption(this.goal, this.label, this.icon, this.bg, this.fg);

  final Goal goal;
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
}
