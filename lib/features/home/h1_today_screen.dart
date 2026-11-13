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
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/widgets/widgets.dart';
import 'home_copy.dart';
import 'week_strip_builder.dart';

/// H1 Today — week's strip, level card, today's list, start CTA.
class H1TodayScreen extends ConsumerWidget {
  const H1TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final AsyncValue<TodayPlan> planAsync = ref.watch(todayPlanProvider);
    final AsyncValue<List<SessionRecord>> sessionsAsync =
        ref.watch(sessionsProvider);
    final AsyncValue<List<LevelContent>> levelsAsync =
        ref.watch(levelsProvider);
    final DateTime now = ref.watch(appClockProvider).now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: planAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (Object e, StackTrace st) => Center(child: Text('$e')),
          data: (TodayPlan plan) {
            final List<SessionRecord> sessions =
                sessionsAsync.asData?.value ?? const <SessionRecord>[];
            final List<LevelContent> levels =
                levelsAsync.asData?.value ?? const <LevelContent>[];
            final LevelContent? levelContent = levels.isEmpty
                ? null
                : levels.firstWhere(
                    (LevelContent l) => l.id == plan.level,
                    orElse: () => levels.first,
                  );
            final int streak = PlanRules.streak(
              sessions,
              now,
              restWeekday: profile.restWeekday,
            );

            if (plan.state == TodayPlanState.catheterBlocked) {
              return _CatheterBody(
                l10n: l10n,
                onUpdate: () => context.push(AppRoutes.settingsSafety),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TodayHeader(l10n: l10n, streak: streak),
                  const SizedBox(height: AppSpacing.lg),
                  WeekStrip(
                    days: buildTodayWeekStrip(
                      l10n: l10n,
                      today: now,
                      restWeekday: profile.restWeekday,
                      sessions: sessions,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LevelCard(
                    l10n: l10n,
                    plan: plan,
                    levelContent: levelContent,
                    onTap: () => context.push(AppRoutes.levels),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (plan.state == TodayPlanState.restDay)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        l10n.h1RestDay,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if (plan.state == TodayPlanState.allDone)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        l10n.h1AllDone,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if (plan.state == TodayPlanState.dailyCapReached)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        l10n.h1DailyCap,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  for (final TodayItem item in plan.items) ...[
                    _TodayItemRow(l10n: l10n, item: item),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: l10n.h1StartSession,
                    enabled: _canStart(plan),
                    onPressed: _canStart(plan)
                        ? () => _startNext(context, plan)
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: TextLinkButton(
                      label: l10n.h1FeltPain,
                      color: AppColors.textSecondary,
                      onPressed: () => context.push(AppRoutes.painHelp),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _canStart(TodayPlan plan) {
    if (plan.state == TodayPlanState.dailyCapReached ||
        plan.state == TodayPlanState.allDone ||
        plan.state == TodayPlanState.catheterBlocked) {
      return false;
    }
    return plan.items.any((TodayItem i) => !i.done);
  }

  void _startNext(BuildContext context, TodayPlan plan) {
    TodayItem? next;
    for (final TodayItem item in plan.items) {
      if (!item.done) {
        next = item;
        break;
      }
    }
    if (next == null) {
      return;
    }
    context.push('${AppRoutes.before}?itemId=${next.id}');
  }

}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.l10n, required this.streak});

  final AppLocalizations l10n;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(l10n.tabToday, style: AppTypography.display),
        ),
        if (streak > 0)
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.streakBg,
              borderRadius: AppRadii.pillAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Illustration(
                    assetPath: 'assets/images/flame.svg',
                    semanticLabel: l10n.h1Streak(streak),
                    width: 16,
                    height: 16,
                    color: AppColors.streakFg,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    l10n.h1Streak(streak),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.streakFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.l10n,
    required this.plan,
    required this.levelContent,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final TodayPlan plan;
  final LevelContent? levelContent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool relaxation = plan.track == TrackId.relaxationFirst;
    final int totalDays = HomeCopy.planTotalDays(
      track: plan.track,
      level: levelContent,
    );
    final int doneDays = (plan.dayInLevel - 1).clamp(0, totalDays);
    final int percent =
        totalDays == 0 ? 0 : (doneDays / totalDays * 100).round().clamp(0, 100);
    final String title = relaxation
        ? l10n.h1RelaxationWeeksTitle
        : l10n.h1LevelName(
            plan.level,
            HomeCopy.levelName(l10n, plan.level),
          );
    final String badge = l10n
        .o6TrackBadge(HomeCopy.trackName(l10n, plan.track))
        .toUpperCase();

    return Semantics(
      button: true,
      label: '${l10n.h1LevelCardSemantic}. $title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.xlAll,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.sessionBackground,
              borderRadius: AppRadii.xlAll,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              title,
                              style: AppTypography.title.copyWith(
                                color: AppColors.sessionText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Illustration(
                        assetPath: relaxation
                            ? 'assets/images/child.svg'
                            : 'assets/images/bridge.svg',
                        semanticLabel: title,
                        width: 48,
                        height: 40,
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.sessionTextSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.h1DayProgress(doneDays, totalDays),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.sessionTextSecondary,
                          ),
                        ),
                      ),
                      Text(
                        l10n.h1Percent(percent),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.sessionTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _StaticProgressBar(
                    progress: percent / 100,
                    trackColor: AppColors.sessionRingTrack,
                    fillColor: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayItemRow extends StatelessWidget {
  const _TodayItemRow({required this.l10n, required this.item});

  final AppLocalizations l10n;
  final TodayItem item;

  @override
  Widget build(BuildContext context) {
    final String title = HomeCopy.itemTitle(l10n, item);
    final String meta = HomeCopy.itemMeta(l10n, item);
    return AppCard(
      backgroundColor:
          item.done ? AppColors.surfaceMuted : AppColors.surface,
      child: Row(
        children: [
          _StatusIcon(item: item),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title, style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                    ),
                    if (item.optional) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.h1SessionOptional,
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.item});

  final TodayItem item;

  @override
  Widget build(BuildContext context) {
    if (item.done) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(Icons.check, size: 16, color: AppColors.textOnPrimary),
        ),
      );
    }
    if (item.kind == SessionKind.breathing ||
        item.kind == SessionKind.relaxation) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.mint,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            Icons.air,
            size: 16,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong, width: 1.5),
      ),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: Text(
            '${item.sessionNumber ?? 1}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticProgressBar extends StatelessWidget {
  const _StaticProgressBar({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: SizedBox(
        height: 6,
        child: ColoredBox(
          color: trackColor,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: ColoredBox(color: fillColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatheterBody extends StatelessWidget {
  const _CatheterBody({required this.l10n, required this.onUpdate});

  final AppLocalizations l10n;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.tabToday, style: AppTypography.display),
          const Spacer(),
          Text(
            l10n.o3CatheterMessage,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.h1UpdateCatheter,
            onPressed: onUpdate,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
