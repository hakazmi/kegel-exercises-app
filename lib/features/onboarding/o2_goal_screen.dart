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
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_stage.dart';

/// O2 Goal — single choice with pastel goal cards and shield hero.
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
        l10n.o2GoalBladderSubtitle,
        Icons.water_drop_outlined,
        AppColors.goalBladderBg,
        AppColors.goalBladderFg,
      ),
      _GoalOption(
        Goal.erectionSupport,
        l10n.o2GoalErection,
        l10n.o2GoalErectionSubtitle,
        Icons.trending_up,
        AppColors.goalErectionBg,
        AppColors.goalErectionFg,
      ),
      _GoalOption(
        Goal.ejaculationControl,
        l10n.o2GoalEjaculation,
        l10n.o2GoalEjaculationSubtitle,
        Icons.timer_outlined,
        AppColors.goalEjaculationBg,
        AppColors.goalEjaculationFg,
      ),
      _GoalOption(
        Goal.recoveryAfterProstateSurgery,
        l10n.o2GoalSurgery,
        l10n.o2GoalSurgerySubtitle,
        Icons.health_and_safety_outlined,
        AppColors.goalSurgeryBg,
        AppColors.goalSurgeryFg,
      ),
      _GoalOption(
        Goal.generalPelvicHealth,
        l10n.o2GoalGeneral,
        l10n.o2GoalGeneralSubtitle,
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
          Reveal(
            from: RevealFrom.drop,
            child: _GoalHero(semanticLabel: l10n.o2HeroSemantic),
          ),
          const SizedBox(height: AppSpacing.md),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 60),
            child: Text(l10n.o2Title, style: AppTypography.display),
          ),
          const SizedBox(height: AppSpacing.xs),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 110),
            child: Text(
              l10n.o2Subtitle,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < options.length; i++) ...[
            Reveal(
              from: i.isEven ? RevealFrom.left : RevealFrom.right,
              delay: AppMotion.stagger(
                i,
                base: const Duration(milliseconds: 160),
              ),
              child: SelectableCard(
                title: options[i].label,
                subtitle: options[i].subtitle,
                selected: draft.goal == options[i].goal,
                leading: Icon(options[i].icon),
                iconBackground: options[i].bg,
                iconForeground: options[i].fg,
                info: InfoCopy.goal(l10n, options[i].goal),
                onTap: () => controller.setGoal(options[i].goal),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
      footer: PrimaryButton(
        label: l10n.commonNext,
        trailingArrow: draft.goal != null,
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

/// 3D shield with the pelvis, floating inside a slowly orbiting ring.
class _GoalHero extends StatelessWidget {
  const _GoalHero({required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return OnboardingStage(
      height: 190,
      semanticLabel: semanticLabel,
      blob: AppColors.pistachio,
      floor: AppColors.lavender,
      children: const [
        Positioned(
          left: 0,
          right: 0,
          top: 92,
          child: Center(
            child: OrbitRing(
              width: 290,
              height: 70,
              color: AppColors.success,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Center(
            child: CutoutFigure(
              asset: OnboardingArt.goalShield,
              height: 170,
              shadowWidth: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalOption {
  const _GoalOption(
    this.goal,
    this.label,
    this.subtitle,
    this.icon,
    this.bg,
    this.fg,
  );

  final Goal goal;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color fg;
}
