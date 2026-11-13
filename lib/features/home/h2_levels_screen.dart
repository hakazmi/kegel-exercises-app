import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/plan_service.dart';
import '../../core/widgets/widgets.dart';
import 'home_copy.dart';

/// H2 Levels — five levels, lock state, repeat / step down.
class H2LevelsScreen extends ConsumerWidget {
  const H2LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final bool isPremium = ref.watch(isPremiumProvider);
    final AsyncValue<List<LevelContent>> levelsAsync =
        ref.watch(levelsProvider);
    final AsyncValue<List<SessionRecord>> sessionsAsync =
        ref.watch(sessionsProvider);
    final int dayInLevel = PlanRules.dayInLevel(
      profile: profile,
      sessions: sessionsAsync.asData?.value ?? const <SessionRecord>[],
    );
    final bool relaxation = profile.track == TrackId.relaxationFirst;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final bool showAdjust = !relaxation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.commonBack,
          onPressed: () => context.pop(),
        ),
      ),
      body: levelsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (Object e, StackTrace st) => Center(child: Text('$e')),
        data: (List<LevelContent> levels) {
          final String trackLabel = HomeCopy.trackName(l10n, profile.track);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    showAdjust
                        ? AppSpacing.md
                        : bottomInset + AppSpacing.md,
                  ),
                  children: [
                    Text(l10n.h2Title, style: AppTypography.display),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      relaxation
                          ? l10n.h2SubtitleRelaxation(trackLabel)
                          : l10n.h2Subtitle(trackLabel),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (relaxation) ...[
                      _RelaxationRow(
                        l10n: l10n,
                        dayInLevel: dayInLevel,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    for (final LevelContent level in levels) ...[
                      _LevelRow(
                        l10n: l10n,
                        level: level,
                        current: !relaxation && level.id == profile.level,
                        dayInLevel: dayInLevel,
                        locked: level.id > 1 && !isPremium,
                        relaxationPending: relaxation && level.id == 1,
                        onLockedTap: () => context.push(
                          '${AppRoutes.paywall}?source=locked_content',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      backgroundColor: AppColors.surfaceMuted,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              relaxation
                                  ? l10n.h2UnlockNoteRelaxation
                                  : l10n.h2UnlockNote,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showAdjust)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: SecondaryButton(
                      label: l10n.h2RepeatOrStepDown,
                      onPressed: () => _showAdjustSheet(context, ref),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAdjustSheet(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.read(userProfileProvider);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.h2ChooseActionTitle, style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: l10n.h2ChooseRepeat,
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await _confirmRepeat(context, ref);
                  },
                ),
                if (profile.level > 1) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: l10n.h2ChooseStepDown,
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await _confirmStepDown(context, ref);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TextLinkButton(
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmRepeat(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await ConfirmDialog.show(
      context,
      title: l10n.h2RepeatTitle,
      message: l10n.h2RepeatMessage,
      confirmLabel: l10n.h2RepeatConfirm,
      cancelLabel: l10n.commonCancel,
    );
    if (!ok) {
      return;
    }
    final PlanService plan = ref.read(planServiceProvider);
    final UserProfile next =
        plan.repeatLevel(ref.read(userProfileProvider));
    await ref.read(userProfileProvider.notifier).save(next);
    ref.invalidate(todayPlanProvider);
  }

  Future<void> _confirmStepDown(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await ConfirmDialog.show(
      context,
      title: l10n.h2StepDownTitle,
      message: l10n.h2StepDownMessage,
      confirmLabel: l10n.h2StepDownConfirm,
      cancelLabel: l10n.commonCancel,
    );
    if (!ok) {
      return;
    }
    final PlanService plan = ref.read(planServiceProvider);
    final UserProfile next = plan.stepDown(ref.read(userProfileProvider));
    await ref.read(userProfileProvider.notifier).save(next);
    ref.invalidate(todayPlanProvider);
  }
}

class _RelaxationRow extends StatelessWidget {
  const _RelaxationRow({
    required this.l10n,
    required this.dayInLevel,
  });

  final AppLocalizations l10n;
  final int dayInLevel;

  @override
  Widget build(BuildContext context) {
    final int total = PlanRules.relaxationFirstDays;
    final int doneDays = (dayInLevel - 1).clamp(0, total);
    final double progress = total == 0 ? 0 : doneDays / total;

    return AppCard(
      borderColor: AppColors.borderStrong,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.mdAll,
                ),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.air,
                      size: 18,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.h2RelaxationName,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.h2RelaxationMeta(total),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: AppRadii.pillAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Text(
                    l10n.h2Current,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadii.pillAll,
                  child: SizedBox(
                    height: 6,
                    child: ColoredBox(
                      color: AppColors.border,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: const ColoredBox(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.h2DaysOf(doneDays, total),
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.l10n,
    required this.level,
    required this.current,
    required this.dayInLevel,
    required this.locked,
    required this.relaxationPending,
    required this.onLockedTap,
  });

  final AppLocalizations l10n;
  final LevelContent level;
  final bool current;
  final int dayInLevel;
  final bool locked;
  final bool relaxationPending;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    final int total = HomeCopy.daysInLevel(level);
    final int doneDays = current
        ? (dayInLevel - 1).clamp(0, total)
        : 0;
    final double progress = total == 0 ? 0 : doneDays / total;

    return AppCard(
      borderColor: current ? AppColors.borderStrong : AppColors.border,
      backgroundColor: locked ? AppColors.surfaceMuted : AppColors.surface,
      onTap: locked ? onLockedTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: current
                      ? AppColors.primary
                      : (locked ? AppColors.border : AppColors.mint),
                  borderRadius: AppRadii.mdAll,
                ),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: locked
                        ? const Icon(
                            Icons.lock,
                            size: 18,
                            color: AppColors.textSecondary,
                          )
                        : Text(
                            '${level.id}',
                            style: AppTypography.body.copyWith(
                              color: current
                                  ? AppColors.textOnPrimary
                                  : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeCopy.levelName(l10n, level.id),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      HomeCopy.levelMeta(l10n, level),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              if (current)
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: AppRadii.pillAll,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      l10n.h2Current,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (locked)
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: AppRadii.pillAll,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      l10n.h2Premium,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (current) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadii.pillAll,
                    child: SizedBox(
                      height: 6,
                      child: ColoredBox(
                        color: AppColors.border,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: const ColoredBox(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.h2DaysOf(doneDays, total),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
          if (relaxationPending) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.h2RelaxationLevel1Note,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
