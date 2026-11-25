import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/motion/app_motion.dart';
import '../onboarding/widgets/onboarding_stage.dart';

/// Level 1: two steps at the top of today's plan, on the same rail as the
/// journey: "How to do a Kegel" (the technique guide) and the pelvic floor
/// hold test. Each ticks when done today.
class TodayPrepSteps extends StatelessWidget {
  const TodayPrepSteps({
    super.key,
    required this.l10n,
    required this.guideDone,
    required this.testDone,
    this.showTest = true,
  });

  final AppLocalizations l10n;
  final bool guideDone;
  final bool testDone;
  final bool showTest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Reveal(
          from: RevealFrom.left,
          delay: const Duration(milliseconds: 200),
          child: _PrepRow(
            done: guideDone,
            isFirst: true,
            nextDone: showTest && testDone,
            title: l10n.htTodayLearnTitle,
            subtitle: l10n.htTodayLearnSub,
            art: OnboardingArt.pelvis,
            tint: AppColors.blush,
            onTap: () => context.push('${AppRoutes.tutorial}?replay=1'),
          ),
        ),
        if (showTest)
          Reveal(
            from: RevealFrom.right,
            delay: const Duration(milliseconds: 240),
            child: _PrepRow(
              done: testDone,
              isFirst: false,
              nextDone: false,
              title: l10n.htTodayTestTitle,
              subtitle: l10n.htTodayTestSub,
              art: OnboardingArt.stopwatch,
              tint: AppColors.sky,
              tag: l10n.h1SessionOptional,
              onTap: () => context.push(AppRoutes.holdTest),
            ),
          ),
      ],
    );
  }
}

class _PrepRow extends StatelessWidget {
  const _PrepRow({
    required this.done,
    required this.isFirst,
    required this.nextDone,
    required this.title,
    required this.subtitle,
    required this.art,
    required this.tint,
    required this.onTap,
    this.tag,
  });

  /// Small label next to the title (e.g. "Optional").
  final String? tag;
  final bool done;
  final bool isFirst;

  /// The step below is done too (the rail between them fills).
  final bool nextDone;
  final String title;
  final String subtitle;
  final String art;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                SizedBox(
                  height: 26,
                  child: isFirst
                      ? null
                      : Center(
                          child: Container(
                            width: 3,
                            color: done ? AppColors.primary : AppColors.border,
                          ),
                        ),
                ),
                done
                    ? const AnimatedCheckBadge(
                        size: 34,
                        color: AppColors.primary,
                        checkColor: AppColors.textOnPrimary,
                        strokeWidth: 3,
                      )
                    : Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 3,
                      color: done && nextDone
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PrepCard(
                title: title,
                subtitle: subtitle,
                art: art,
                tint: tint,
                done: done,
                tag: tag,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrepCard extends StatelessWidget {
  const _PrepCard({
    required this.title,
    required this.subtitle,
    required this.art,
    required this.tint,
    required this.done,
    required this.onTap,
    this.compact = false,
    this.tag,
  });

  final String? tag;
  final String title;
  final String subtitle;
  final String art;
  final Color tint;
  final bool done;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      semanticLabel: title,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.xlAll,
          border: Border.all(
            color: done ? AppColors.mint : AppColors.surface,
            width: 1.5,
          ),
          boxShadow: AppElevation.level1,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  if (tag != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: AppRadii.pillAll,
                      ),
                      child: Text(
                        tag!,
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  if (!compact) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: compact ? 48 : 60,
              height: compact ? 48 : 60,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.55),
                borderRadius: AppRadii.lgAll,
              ),
              child: Image.asset(
                art,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// After Level 1: the guide and the test stay one tap away, under
/// "I felt pain".
class TodayToolsRow extends StatelessWidget {
  const TodayToolsRow({super.key, required this.l10n, this.showTest = true});

  final AppLocalizations l10n;
  final bool showTest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.htTodayToolsTitle,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _PrepCard(
                title: l10n.htTodayLearnTitle,
                subtitle: l10n.htTodayLearnSub,
                art: OnboardingArt.pelvis,
                tint: AppColors.blush,
                done: false,
                compact: true,
                onTap: () => context.push('${AppRoutes.tutorial}?replay=1'),
              ),
            ),
            if (showTest) ...[
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _PrepCard(
                  title: l10n.htTodayTestTitle,
                  subtitle: l10n.htTodayTestSub,
                  art: OnboardingArt.stopwatch,
                  tint: AppColors.sky,
                  done: false,
                  compact: true,
                  onTap: () => context.push(AppRoutes.holdTest),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
