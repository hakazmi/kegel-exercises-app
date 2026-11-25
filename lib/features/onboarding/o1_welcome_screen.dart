import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/cloud/cloud_config.dart';
import '../../core/constants/links.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_stage.dart';

/// O1 Welcome — 3D hero, feature cards, age gate and disclaimer.
class O1WelcomeScreen extends ConsumerWidget {
  const O1WelcomeScreen({super.key});

  Future<void> _open(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);

    final List<({IconData icon, String text, Color bg, Color fg})> features =
        <({IconData icon, String text, Color bg, Color fg})>[
      (
        icon: Icons.water_drop_rounded,
        text: l10n.o1FeatureBladder,
        bg: AppColors.goalBladderBg,
        fg: AppColors.goalBladderFg,
      ),
      (
        icon: Icons.route_rounded,
        text: l10n.o1FeaturePlan,
        bg: AppColors.goalErectionBg,
        fg: AppColors.goalErectionFg,
      ),
      (
        icon: Icons.health_and_safety_outlined,
        text: l10n.o1FeaturePrivate,
        bg: AppColors.goalSurgeryBg,
        fg: AppColors.goalSurgeryFg,
      ),
    ];

    return OnboardingScaffold(
      step: 1,
      showHeader: false,
      onBack: CloudConfig.isConfigured
          ? () => context.go(AppRoutes.auth)
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(from: RevealFrom.drop, child: _Hero(l10n: l10n)),
          const SizedBox(height: AppSpacing.lg),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 120),
            child: Text.rich(
              TextSpan(
                style: AppTypography.display,
                children: <InlineSpan>[
                  TextSpan(text: l10n.o1TitleBefore),
                  TextSpan(
                    text: l10n.o1TitleAccent,
                    style: AppTypography.display.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: l10n.o1TitleAfter),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 180),
            child: Text(
              l10n.o1Body,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Reveal(
            from: RevealFrom.rise,
            delay: const Duration(milliseconds: 220),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < features.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _FeatureCard(
                      icon: features[i].icon,
                      text: features[i].text,
                      bg: features[i].bg,
                      fg: features[i].fg,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Reveal(
            from: RevealFrom.rise,
            delay: const Duration(milliseconds: 420),
            child: _AgeToggle(
              label: l10n.o1AgeCheckbox,
              value: draft.acceptedAge,
              onChanged: controller.setAcceptedAge,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DisclaimerText(text: l10n.o1Disclaimer),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextLinkButton(
                label: l10n.o1Terms,
                underline: true,
                onPressed: () => _open(AppLinks.terms),
              ),
              const Text(' · ', style: AppTypography.caption),
              TextLinkButton(
                label: l10n.o1Privacy,
                underline: true,
                onPressed: () => _open(AppLinks.privacyPolicy),
              ),
            ],
          ),
        ],
      ),
      footer: PrimaryButton(
        label: l10n.o1GetStarted,
        trailingArrow: draft.acceptedAge,
        shimmer: draft.acceptedAge,
        enabled: draft.acceptedAge,
        onPressed: draft.acceptedAge
            ? () async {
                await controller.completeStep('O1');
                if (context.mounted) {
                  context.go(AppRoutes.goal);
                }
              }
            : null,
      ),
    );
  }
}

/// 3D welcome scene: the cut-out athlete squatting on a glowing floor, a
/// glass tile with the pelvic floor linked to his hips, and rising chevrons.
class _Hero extends StatelessWidget {
  const _Hero({required this.l10n});

  final AppLocalizations l10n;

  static const double _height = 300;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double w = box.maxWidth;
        const double manHeight = _height - 6;
        const double manWidth = manHeight * 456 / 900;
        final double manLeft = w - manWidth - 34;
        const double tileSize = 118;
        const double tileTop = 58;
        return OnboardingStage(
          height: _height,
          semanticLabel: l10n.o1HeroSemantic,
          children: [
            Positioned(
              left: manLeft,
              bottom: 6,
              child: const CutoutFigure(
                asset: OnboardingArt.welcomeMan,
                height: manHeight,
              ),
            ),
            // Arrow from the pelvic floor tile to where those muscles sit
            // in the body (drawn over the figure so the tip shows).
            ConnectorLine(
              from: const Offset(tileSize + 6, tileTop + tileSize * 0.62),
              to: Offset(manLeft + manWidth * 0.42, manHeight * 0.58),
              color: AppColors.primary,
            ),
            Positioned(
              left: 0,
              top: tileTop,
              child: Reveal(
                from: RevealFrom.left,
                delay: const Duration(milliseconds: 220),
                child: FloatBob(
                  lift: 5,
                  period: const Duration(milliseconds: 2600),
                  child: GlassTile(
                    size: tileSize,
                    badge: true,
                    tint: AppColors.mint,
                    child: Image.asset(
                      OnboardingArt.pelvis,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 0,
              top: 24,
              child: RisingChevrons(),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(icon, color: fg, size: 22),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// Large tappable 18+ confirmation with an animated check.
class _AgeToggle extends StatelessWidget {
  const _AgeToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      child: PressScale(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: value ? AppColors.mint : AppColors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: value ? AppColors.primary : AppColors.border,
              width: value ? 2 : 1.5,
            ),
            boxShadow: AppElevation.level1,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: value ? AppColors.primary : AppColors.borderStrong,
                    width: 2,
                  ),
                ),
                child: AnimatedScale(
                  scale: value ? 1 : 0,
                  duration: const Duration(milliseconds: 260),
                  curve: AppMotion.dropCurve,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Text(
                  '18+',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
