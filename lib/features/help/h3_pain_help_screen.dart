import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_service.dart';
import '../../core/widgets/widgets.dart';
import '../session/session_controller.dart';

/// H3 Pain help — stop strengthening, offer relaxation track, clinician note.
class H3PainHelpScreen extends ConsumerWidget {
  const H3PainHelpScreen({
    super.key,
    this.fromSession = false,
  });

  final bool fromSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.commonClose,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.today);
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.streakBg,
                borderRadius: AppRadii.xlAll,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Illustration(
                    assetPath: 'assets/images/child.svg',
                    semanticLabel: l10n.h3IllustrationSemantic,
                    height: 140,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.h3Headline, style: AppTypography.display),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.h3Body,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              backgroundColor: AppColors.surfaceMuted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.h3TrackBadge.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _Bullet(l10n.h3TrackBreathing),
                  _Bullet(l10n.h3TrackReverse),
                  _Bullet(l10n.h3TrackStretch),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.streakBg,
                borderRadius: AppRadii.lgAll,
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  l10n.h3ClinicianNote,
                  style: AppTypography.body.copyWith(
                    color: AppColors.streakFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.h3SwitchRelaxation,
              onPressed: () => _switchToRelaxation(context, ref),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: l10n.h3KeepPlan,
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.today);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchToRelaxation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (fromSession) {
      await ref.read(sessionControllerProvider.notifier).confirmPainTrack();
    } else {
      final PlanService plan = ref.read(planServiceProvider);
      final UserProfile next =
          plan.onPainReported(ref.read(userProfileProvider));
      await ref.read(userProfileProvider.notifier).save(next);
    }
    ref.invalidate(todayPlanProvider);
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
          title: Text(l10n.h3Title, style: AppTypography.title),
          content: Text(
            l10n.h3SwitchedConfirm,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonContinue),
            ),
          ],
        );
      },
    );
    if (!context.mounted) {
      return;
    }
    context.go(AppRoutes.today);
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 6, height: 6),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.body),
          ),
        ],
      ),
    );
  }
}
