import 'dart:ui' show ImageFilter;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/content/info_copy.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/level_progression.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/plan_service.dart';
import '../../core/plan/session_definition.dart';
import '../../core/widgets/widgets.dart';
import 'home_copy.dart';
import 'level_unlock_actions.dart';
import 'today_journey.dart' show RingPainter;

/// TEMP: jump levels from H2 without earning unlock — remove before store.
const bool _kShowLevelTestComplete = true;

/// H2 Levels — level rings, then one card per level.
///
/// The current and completed levels expand to a grid of days: done days are
/// ticked, today's day is open (tap to see the day's plan) and later days
/// are locked. Later levels stay collapsed behind a lock.
class H2LevelsScreen extends ConsumerWidget {
  const H2LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final bool isPremium = ref.watch(isPremiumProvider);
    final AsyncValue<List<LevelContent>> levelsAsync =
        ref.watch(levelsProvider);
    // Today's real rest day (calendar), from the plan.
    final bool restToday = ref.watch(todayPlanProvider).asData?.value.state ==
        TodayPlanState.restDay;
    final AsyncValue<List<SessionRecord>> sessionsAsync =
        ref.watch(sessionsProvider);
    final List<SessionRecord> sessions =
        sessionsAsync.asData?.value ?? const <SessionRecord>[];
    final DateTime today = ref.watch(appClockProvider).now();
    final int dayInLevel = PlanRules.dayInLevel(
      profile: profile,
      sessions: sessions,
    );
    final bool relaxation = profile.track == TrackId.relaxationFirst;
    final bool unlockReady = LevelProgression.isUnlockReady(
      profile: profile,
      sessions: sessions,
      today: today,
    );
    final int? nextLevel = LevelProgression.offeredLevel(profile);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final bool showAdjust = !relaxation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: levelsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (Object e, StackTrace st) => Center(child: Text('$e')),
          data: (List<LevelContent> levels) {
            final String trackLabel = HomeCopy.trackName(l10n, profile.track);

            double levelProgress(LevelContent level) {
              if (relaxation) {
                return 0;
              }
              if (level.id < profile.level) {
                return 1;
              }
              if (level.id > profile.level) {
                return 0;
              }
              final int span = HomeCopy.daysInLevel(level);
              return span == 0
                  ? 0
                  : ((dayInLevel - 1) / span).clamp(0.0, 1.0);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      showAdjust
                          ? AppSpacing.md
                          : bottomInset + AppSpacing.md,
                    ),
                    children: [
                      Reveal(
                        from: RevealFrom.drop,
                        child: Row(
                          children: [
                            _TopButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              label: l10n.commonBack,
                              dark: true,
                              onTap: () => context.pop(),
                            ),
                            const Spacer(),
                            if (!relaxation)
                              _LevelBadge(
                                text: l10n.h1LevelName(
                                  profile.level,
                                  HomeCopy.levelName(l10n, profile.level),
                                ),
                              ),
                            const Spacer(),
                            _TopButton(
                              icon: Icons.info_outline_rounded,
                              label: InfoCopy.levels(l10n).title,
                              onTap: () => InfoSheet.show(
                                context,
                                InfoCopy.levels(l10n),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Reveal(
                        from: RevealFrom.left,
                        delay: const Duration(milliseconds: 60),
                        child: Text(l10n.h2Title, style: AppTypography.display),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Reveal(
                        from: RevealFrom.left,
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          relaxation
                              ? l10n.h2SubtitleRelaxation(trackLabel)
                              : l10n.h2Subtitle(trackLabel),
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (!relaxation) ...[
                        _LevelRings(
                          l10n: l10n,
                          levels: levels,
                          currentLevel: profile.level,
                          isPremium: isPremium,
                          progressOf: levelProgress,
                          onLockedTap: (LevelContent level) {
                            if (level.id > 1 && !isPremium) {
                              context.push(
                                '${AppRoutes.paywall}?source=locked_content',
                              );
                              return;
                            }
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(l10n.h2StatusUnlocksWhen),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (relaxation) ...[
                        _RelaxationRow(
                          l10n: l10n,
                          dayInLevel: dayInLevel,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      for (final LevelContent level in levels) ...[
                        Reveal(
                          from: level.id.isOdd
                              ? RevealFrom.left
                              : RevealFrom.right,
                          delay: AppMotion.stagger(
                            level.id,
                            base: const Duration(milliseconds: 120),
                          ),
                          child: _LevelCard(
                            l10n: l10n,
                            level: level,
                            sessionsPerDay: profile.sessionsPerDay.clamp(1, 3),
                            restToday: restToday,
                            current: !relaxation && level.id == profile.level,
                            completed: !relaxation && level.id < profile.level,
                            dayInLevel: dayInLevel,
                            progress: levelProgress(level),
                            premiumLocked: level.id > 1 && !isPremium,
                            isNext: !relaxation &&
                                nextLevel != null &&
                                level.id == nextLevel,
                            unlockReady: unlockReady &&
                                !relaxation &&
                                nextLevel != null &&
                                level.id == nextLevel,
                            relaxationPending: relaxation && level.id == 1,
                            onOpenDay: (int day) => context.push(
                              '${AppRoutes.levelDay}?level=${level.id}&day=$day',
                            ),
                            onLockedTap: () {
                              if (level.id > 1 && !isPremium) {
                                context.push(
                                  '${AppRoutes.paywall}?source=locked_content',
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      relaxation
                                          ? l10n.h2RelaxationLevel1Note
                                          : l10n.h2StatusUnlocksWhen,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                            },
                            onStartNext: unlockReady &&
                                    !relaxation &&
                                    nextLevel != null &&
                                    level.id == nextLevel
                                ? () async {
                                    final bool advanced =
                                        await LevelUnlockActions.startNext(
                                      context: context,
                                      ref: ref,
                                      nextLevel: nextLevel,
                                    );
                                    if (advanced && context.mounted) {
                                      LevelUnlockActions.showStartedConfirm(
                                        context,
                                        l10n,
                                        nextLevel,
                                      );
                                    }
                                  }
                                : null,
                            onTestComplete: _kShowLevelTestComplete &&
                                    !relaxation &&
                                    level.id == profile.level &&
                                    level.id < 5
                                ? () => _testCompleteLevel(
                                      context,
                                      ref,
                                      fromLevel: level.id,
                                    )
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: AppRadii.lgAll,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                relaxation
                                    ? l10n.h2UnlockNoteRelaxation
                                    : l10n.h2UnlockNote,
                                style: AppTypography.caption,
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
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Reveal(
                        from: RevealFrom.rise,
                        delay: const Duration(milliseconds: 400),
                        child: _AdjustBar(
                          label: l10n.h2RepeatOrStepDown,
                          onTap: () => _showAdjustSheet(context, ref),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAdjustSheet(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.read(userProfileProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return _AdjustSheet(
          l10n: l10n,
          level: profile.level,
          onRepeat: () async {
            Navigator.of(sheetContext).pop();
            await _confirmRepeat(context, ref);
          },
          onStepDown: profile.level > 1
              ? () async {
                  Navigator.of(sheetContext).pop();
                  await _confirmStepDown(context, ref);
                }
              : null,
          onCancel: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
  }

  /// TEMP test helper: mark this level done and open the next one.
  Future<void> _testCompleteLevel(
    BuildContext context,
    WidgetRef ref, {
    required int fromLevel,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int nextLevel = fromLevel + 1;
    if (nextLevel > 5) {
      return;
    }
    // Levels 2–5 need Premium content unlocked for body cards.
    ref.read(isPremiumOverrideProvider.notifier).set(true);
    final UserProfile profile = ref.read(userProfileProvider);
    final DateTime now = ref.read(appClockProvider).now();
    final UserProfile next = LevelProgression.advanceTo(
      profile: profile,
      nextLevel: nextLevel,
      now: now,
    );
    await ref.read(userProfileProvider.notifier).save(next);
    ref.invalidate(todayPlanProvider);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.h2TestCompleteConfirm(nextLevel))),
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
                          heightFactor: 1,
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

/// Horizontal strip of level cards: "LEVEL N", the level's name and a ring,
/// each in its own colour. The current level is ink with its colour ring.
class _LevelRings extends StatelessWidget {
  const _LevelRings({
    required this.l10n,
    required this.levels,
    required this.currentLevel,
    required this.isPremium,
    required this.progressOf,
    required this.onLockedTap,
  });

  final AppLocalizations l10n;
  final List<LevelContent> levels;
  final int currentLevel;
  final bool isPremium;
  final double Function(LevelContent level) progressOf;

  /// Tapping a locked level: paywall for Premium levels, otherwise a note
  /// on when it unlocks.
  final ValueChanged<LevelContent> onLockedTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        clipBehavior: Clip.none,
        separatorBuilder: (BuildContext context, int i) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int i) {
          final LevelContent level = levels[i];
          final LevelPalette palette = LevelPalette.of(level.id);
          final bool current = level.id == currentLevel;
          final bool done = level.id < currentLevel;
          final bool locked = level.id > currentLevel;
          final double p = progressOf(level);
          final Color fg = current ? AppColors.textOnPrimary : AppColors.ink;
          final Widget card = Container(
              width: 112,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: current
                    ? AppColors.ink
                    : (locked ? palette.tint : palette.base),
                borderRadius: AppRadii.xlAll,
                boxShadow: current
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : AppElevation.none,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.h2LevelShort(level.id).toUpperCase(),
                    maxLines: 1,
                    style: AppTypography.caption.copyWith(
                      color: current ? palette.base : palette.deep,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    HomeCopy.levelName(l10n, level.id),
                    maxLines: 2,
                    style: AppTypography.title.copyWith(
                      color: fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: AnimatedFraction(
                          value: p,
                          delay: AppMotion.stagger(
                            i,
                            base: const Duration(milliseconds: 300),
                          ),
                          builder: (BuildContext context, double v) =>
                              CustomPaint(
                            painter: RingPainter(
                              progress: v,
                              track: current
                                  ? AppColors.textOnPrimary.withValues(alpha: 0.15)
                                  : AppColors.ink.withValues(alpha: 0.1),
                              fill: current ? palette.base : AppColors.ink,
                              stroke: 5,
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: AppColors.ink,
                                    )
                                  : (locked
                                      ? Icon(
                                          level.id > 1 && !isPremium
                                              ? Icons.workspace_premium_outlined
                                              : Icons.lock_rounded,
                                          size: 17,
                                          color: palette.deep,
                                        )
                                      : null),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.h1Percent((p * 100).round()),
                              style: AppTypography.caption.copyWith(
                                color: current
                                    ? AppColors.textOnPrimary
                                    : palette.deep,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          return Reveal(
            from: RevealFrom.right,
            delay: AppMotion.stagger(i, base: const Duration(milliseconds: 80)),
            child: locked
                ? PressScale(
                    onTap: () => onLockedTap(level),
                    semanticLabel:
                        '${l10n.h2LevelShort(level.id)}. ${HomeCopy.levelName(l10n, level.id)}',
                    child: card,
                  )
                : card,
          );
        },
      ),
    );
  }
}

/// State of one day chip in a level's grid.
enum _DayState { done, today, locked }

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.l10n,
    required this.level,
    required this.current,
    required this.completed,
    required this.dayInLevel,
    required this.progress,
    required this.premiumLocked,
    required this.isNext,
    required this.unlockReady,
    required this.relaxationPending,
    required this.onOpenDay,
    required this.onLockedTap,
    required this.sessionsPerDay,
    this.restToday = false,
    this.onStartNext,
    this.onTestComplete,
  });

  final AppLocalizations l10n;
  final LevelContent level;
  final int sessionsPerDay;

  /// Today is the user's weekly rest day.
  final bool restToday;
  final bool current;
  final bool completed;
  final int dayInLevel;
  final double progress;
  final bool premiumLocked;
  final bool isNext;
  final bool unlockReady;
  final bool relaxationPending;
  final ValueChanged<int> onOpenDay;
  final VoidCallback onLockedTap;
  final VoidCallback? onStartNext;
  final VoidCallback? onTestComplete;

  bool get _expanded => current || completed;
  bool get _locked => !current && !completed && !unlockReady;

  /// Days shown in the grid. Level 5 is open-ended: show its current week.
  (int first, int count) _dayWindow() {
    final int span = HomeCopy.daysInLevel(level);
    if (level.dayEnd == null && current) {
      final int week = (dayInLevel - 1) ~/ span;
      return (week * span + 1, span);
    }
    return (1, span);
  }

  /// Planned time for one training day of this level: the Kegel sessions
  /// plus the daily breathing.
  int _dayDuration() =>
      SessionDefinitionBuilder.strengtheningDurationForLevel(level) *
          sessionsPerDay +
      level.dailyBreathingSec;

  _DayState _stateOf(int day) {
    if (completed) {
      return _DayState.done;
    }
    if (day < dayInLevel) {
      return _DayState.done;
    }
    if (day == dayInLevel) {
      return _DayState.today;
    }
    return _DayState.locked;
  }

  @override
  Widget build(BuildContext context) {
    final LevelPalette palette = LevelPalette.of(level.id);
    final int total = HomeCopy.daysInLevel(level);
    final int doneDays = current
        ? (dayInLevel - 1).clamp(0, total)
        : (completed ? total : 0);

    // Collapsed (locked / next) levels: big number on the level's colour.
    final Widget header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: palette.base,
            borderRadius: AppRadii.lgAll,
          ),
          alignment: Alignment.center,
          child: Text(
            '${level.id}'.padLeft(2, '0'),
            style: AppTypography.title.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 22,
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
                style: AppTypography.title.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                HomeCopy.levelMeta(l10n, level),
                style: AppTypography.caption.copyWith(color: palette.deep),
              ),
              if (isNext) ...[
                const SizedBox(height: 4),
                Text(
                  unlockReady ? l10n.h2StatusUnlocked : l10n.h2StatusUnlocksWhen,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        if (_locked)
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              premiumLocked
                  ? Icons.workspace_premium_outlined
                  : Icons.lock_rounded,
              size: 18,
              color: palette.deep,
            ),
          ),
      ],
    );

    final (int first, int count) = _dayWindow();

    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Open levels: the cover panel is the whole top of the card and
        // already names the level, days and status, so no header row.
        if (!_expanded) header,
        if (_expanded) ...[
          // Room for the status tag and the figure's head rising above the
          // panel.
          const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),
          _LevelHeroPanel(
            l10n: l10n,
            level: level.id,
            palette: palette,
            levelName: HomeCopy.levelName(l10n, level.id),
            dayRange: level.dayEnd == null
                ? l10n.h2DayOnward(level.dayStart)
                : l10n.h2DayRange(level.dayStart, level.dayEnd!),
            completed: completed,
            rest: current && restToday,
            // A completed level shows Day 1 (standing) again as its cover.
            day: completed ? first : dayInLevel,
            doneDays: doneDays,
            totalDays: total,
            progress: progress,
            sentence:
                completed ? _achieved(l10n, level.id) : _focus(l10n, level.id),
            durationSeconds: _dayDuration(),
            onOpen: () => onOpenDay(completed ? first : dayInLevel),
          ),
          const SizedBox(height: AppSpacing.xs),
          _DayStrip(
            l10n: l10n,
            palette: palette,
            first: first,
            count: count,
            stateOf: _stateOf,
            durationSeconds: _dayDuration(),
            onOpen: onOpenDay,
            onLocked: onLockedTap,
          ),
        ],
        if (unlockReady && onStartNext != null) ...[
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: l10n.h2StartLevel(level.id),
            icon: Icons.lock_open_rounded,
            shimmer: true,
            onPressed: onStartNext,
          ),
        ],
        if (onTestComplete != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: l10n.h2TestCompleteLevel,
            icon: Icons.check_circle_outline_rounded,
            onPressed: onTestComplete,
          ),
        ],
        if (relaxationPending) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.h2RelaxationLevel1Note, style: AppTypography.caption),
        ],
      ],
    );

    final Widget card = AnimatedContainer(
      duration: AppMotion.quick,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _expanded ? AppColors.surface : palette.tint,
        borderRadius: AppRadii.xlAll,
        border: Border.all(
          color: current ? palette.base : AppColors.surface,
          width: current ? 2 : 1,
        ),
        boxShadow: _expanded ? AppElevation.level1 : AppElevation.none,
      ),
      child: body,
    );

    if (_locked) {
      return PressScale(onTap: onLockedTap, child: card);
    }
    return card;
  }
}


/// What a level trains (current) — training facts, never health outcomes.
String _focus(AppLocalizations l10n, int level) => switch (level) {
      1 => l10n.h2FocusL1,
      2 => l10n.h2FocusL2,
      3 => l10n.h2FocusL3,
      4 => l10n.h2FocusL4,
      _ => l10n.h2FocusL5,
    };

/// What the user completed in a level.
String _achieved(AppLocalizations l10n, int level) => switch (level) {
      1 => l10n.h2AchievedL1,
      2 => l10n.h2AchievedL2,
      3 => l10n.h2AchievedL3,
      4 => l10n.h2AchievedL4,
      _ => l10n.h2AchievedL5,
    };

/// Cover panel for an open level, in the level's own colour: status tag on
/// its top edge, the level number and name large, days and the current day,
/// the level sentence, a progress line and a full-width start button, with
/// the day's 3D figure popping out on the right.
class _LevelHeroPanel extends StatelessWidget {
  const _LevelHeroPanel({
    required this.l10n,
    required this.level,
    required this.palette,
    required this.levelName,
    required this.dayRange,
    required this.completed,
    required this.day,
    required this.doneDays,
    required this.totalDays,
    required this.progress,
    required this.sentence,
    required this.durationSeconds,
    required this.onOpen,
    this.rest = false,
  });

  final AppLocalizations l10n;
  final int level;
  final LevelPalette palette;
  final String levelName;
  final String dayRange;
  final bool completed;

  /// Today is a rest day: only the calm figure and a "Rest day" label.
  final bool rest;
  final int day;
  final int doneDays;
  final int totalDays;
  final double progress;
  final String sentence;
  final int durationSeconds;
  final VoidCallback onOpen;

  static const double _height = 296;
  static const double _button = 52;

  @override
  Widget build(BuildContext context) {
    if (rest) {
      return _RestCover(
        l10n: l10n,
        eyebrow: '${l10n.h2LevelShort(level)} · $levelName'.toUpperCase(),
        tag: l10n.h2TagCurrent,
        height: _height,
      );
    }
    final DayPose pose = DayPose.forDay(day);
    final bool wide = pose.isWide;
    final double figureHeight = wide ? 92 : 290;
    final double figureWidth = wide ? 176 : 148;
    final Color panelTop = palette.base;
    final Color panelBottom = Color.lerp(palette.base, AppColors.surface, 0.45)!;

    return SizedBox(
      height: _height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Panel in the level's colour, with a soft ring motif.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadii.xlAll,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[panelTop, panelBottom],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: palette.deep.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppRadii.xlAll,
                child: Stack(
                  children: [
                    Positioned(
                      right: -60,
                      bottom: 20,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface.withValues(alpha: 0.35),
                            width: 28,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              AppColors.surface.withValues(alpha: 0.55),
                              AppColors.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Figure popping out of the top-right.
          Positioned(
            right: wide ? -4 : 0,
            bottom: _button + AppSpacing.md + (wide ? 8 : -6),
            child: FloatBob(
              lift: 3,
              period: const Duration(milliseconds: 3200),
              child: PoseFigure(
                pose: pose,
                width: figureWidth,
                height: figureHeight,
                glowColor: AppColors.surface,
                semanticLabel: pose.label(l10n),
              ),
            ),
          ),
          // Level number + name, days, sentence.
          Positioned(
            left: AppSpacing.md,
            right: wide ? AppSpacing.md : 150,
            top: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$level'.padLeft(2, '0'),
                      style: AppTypography.display.copyWith(
                        color: AppColors.ink,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          levelName,
                          maxLines: 2,
                          style: AppTypography.title.copyWith(
                            color: AppColors.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  (completed
                          ? '$dayRange · ${l10n.h2TagCompleted}'
                          : '$dayRange · ${l10n.h2DayLabel(day)}')
                      .toUpperCase(),
                  maxLines: 2,
                  style: AppTypography.caption.copyWith(
                    color: palette.deep,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 15, color: palette.deep),
                    const SizedBox(width: 4),
                    Text(
                      HomeCopy.formatDuration(l10n, durationSeconds),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: wide ? 190 : null,
                  child: Text(
                    sentence,
                    maxLines: 4,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Progress line above the button.
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: _button + AppSpacing.md + AppSpacing.sm,
            child: Row(
              children: [
                Text(
                  '$doneDays/$totalDays',
                  style: AppTypography.body.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadii.pillAll,
                    child: SizedBox(
                      height: 6,
                      child: ColoredBox(
                        color: AppColors.ink.withValues(alpha: 0.12),
                        child: AnimatedFraction(
                          value: progress,
                          delay: const Duration(milliseconds: 300),
                          builder: (BuildContext context, double v) => Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: v,
                              heightFactor: 1,
                              child: const ColoredBox(color: AppColors.ink),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Full-width start button.
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            height: _button,
            child: PressScale(
              onTap: onOpen,
              semanticLabel:
                  completed ? l10n.h2ReviewDays : l10n.h2StartDay(day),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: AppRadii.pillAll,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      (completed ? l10n.h2ReviewDays : l10n.h2StartDay(day))
                          .toUpperCase(),
                      style: AppTypography.button.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: palette.base,
                          shape: BoxShape.circle,
                        ),
                        child: const NudgeArrow(
                          icon: Icons.chevron_right_rounded,
                          color: AppColors.ink,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Status tag riding the top edge.
          Positioned(
            left: AppSpacing.md,
            top: -14,
            child: _StatusTag(
              label: completed ? l10n.h2TagCompleted : l10n.h2TagCurrent,
              completed: completed,
              color: palette.base,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill tag on the panel's top edge ("CURRENT" / "COMPLETED").
class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.label,
    required this.completed,
    required this.color,
  });

  final String label;
  final bool completed;

  /// The level's colour, used for the dot / check.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: completed ? AppColors.surface : AppColors.ink,
        borderRadius: AppRadii.mdAll,
        border: completed ? Border.all(color: AppColors.ink, width: 1.5) : null,
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (completed)
            const Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: AppColors.ink,
            )
          else
            PulseHalo(
              color: color,
              size: 8,
              child: SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: completed ? AppColors.ink : AppColors.textOnPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of compact day cards under the panel, in the level's colours, with a
/// rest card after every six training days.
class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.l10n,
    required this.palette,
    required this.first,
    required this.count,
    required this.stateOf,
    required this.durationSeconds,
    required this.onOpen,
    required this.onLocked,
  });

  final AppLocalizations l10n;
  final LevelPalette palette;
  final int first;
  final int count;
  final _DayState Function(int day) stateOf;
  final int durationSeconds;
  final ValueChanged<int> onOpen;
  final VoidCallback onLocked;

  /// Training days in order, with a rest card (null) after every six —
  /// one rest day per plan week.
  List<int?> _entries() {
    final List<int?> out = <int?>[];
    for (int i = 0; i < count; i++) {
      final int day = first + i;
      out.add(day);
      final bool weekDone = day % DayPose.trainingDaysPerWeek == 0;
      if (weekDone && i < count - 1) {
        out.add(null);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final List<int?> entries = _entries();
    // Top padding leaves room for each figure to pop out of its card; the
    // list clips at its own edges so nothing spills outside the level card.
    return SizedBox(
      height: _DayCard.height + _DayCard.pop + 6,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: _DayCard.pop),
        itemCount: entries.length,
        separatorBuilder: (BuildContext context, int i) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int i) {
          final int? day = entries[i];
          final Duration delay =
              AppMotion.stagger(i, base: const Duration(milliseconds: 260));
          if (day == null) {
            return Reveal(
              from: RevealFrom.right,
              delay: delay,
              child: _RestDayCard(l10n: l10n),
            );
          }
          final _DayState state = stateOf(day);
          return Reveal(
            from: RevealFrom.right,
            delay: delay,
            child: _DayCard(
              l10n: l10n,
              palette: palette,
              day: day,
              state: state,
              durationSeconds: durationSeconds,
              onTap: state == _DayState.locked ? onLocked : () => onOpen(day),
            ),
          );
        },
      ),
    );
  }
}

/// Compact day card: figure popping out on the left, "Day N" and time on
/// the right, a status tab in the bottom-right corner.
class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.l10n,
    required this.palette,
    required this.day,
    required this.state,
    required this.durationSeconds,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final LevelPalette palette;
  final int day;
  final _DayState state;
  final int durationSeconds;
  final VoidCallback onTap;

  static const double width = 158;
  static const double height = 92;
  static const double pop = 26;

  @override
  Widget build(BuildContext context) {
    final DayPose pose = DayPose.forDay(day);
    final bool today = state == _DayState.today;
    final bool done = state == _DayState.done;
    final bool locked = state == _DayState.locked;
    final Color text = locked ? AppColors.textSecondary : AppColors.ink;

    return PressScale(
      onTap: onTap,
      semanticLabel: '${l10n.h2DayLabel(day)}. ${pose.label(l10n)}',
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.lgAll,
                  color: today
                      ? AppColors.surface
                      : (locked ? AppColors.surfaceMuted : palette.tint),
                  border: Border.all(
                    color: today ? AppColors.ink : AppColors.surface,
                    width: today ? 2 : 1,
                  ),
                  boxShadow: today ? AppElevation.level1 : AppElevation.none,
                ),
              ),
            ),
            // Figure on the left, rising out of the card.
            Positioned(
              left: pose.isWide ? -4 : 0,
              bottom: pose.isWide ? 14 : 4,
              child: PoseFigure(
                pose: pose,
                width: pose.isWide ? 86 : 64,
                height: pose.isWide ? 52 : height + pop - 6,
                dimmed: locked,
                glow: today,
                glowColor: palette.base,
                semanticLabel: pose.label(l10n),
              ),
            ),
            // Day number and time, inside the card.
            Positioned(
              left: pose.isWide ? 84 : 66,
              right: AppSpacing.xs,
              top: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.h2DayLabel(day),
                      maxLines: 1,
                      style: AppTypography.title.copyWith(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: locked ? AppColors.textSecondary : palette.deep,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          HomeCopy.formatDuration(l10n, durationSeconds),
                          maxLines: 1,
                          style: AppTypography.caption.copyWith(
                            color: text,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status tab in the bottom-right corner.
            Positioned(
              right: today ? -2 : 0,
              bottom: today ? -2 : 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 4, 8, 4),
                decoration: BoxDecoration(
                  color: today
                      ? AppColors.ink
                      : (done ? palette.base : AppColors.border),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadii.md),
                    bottomRight: Radius.circular(AppRadii.lg),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!locked)
                      Text(
                        today ? l10n.h1ItemStart : l10n.h2DoneTab,
                        style: AppTypography.caption.copyWith(
                          color: today ? palette.base : AppColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    if (!locked) const SizedBox(width: 3),
                    Icon(
                      today
                          ? Icons.play_circle_outline_rounded
                          : (done ? Icons.check_rounded : Icons.lock_rounded),
                      size: 14,
                      color: today
                          ? palette.base
                          : (done ? AppColors.ink : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square top-bar button (back / info) with a soft shadow.
class _TopButton extends StatelessWidget {
  const _TopButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        width: AppSpacing.minTouchTarget,
        height: AppSpacing.minTouchTarget,
        decoration: BoxDecoration(
          color: dark ? AppColors.ink : AppColors.surface,
          borderRadius: AppRadii.mdAll,
          border: dark ? null : Border.all(color: AppColors.border),
          boxShadow: AppElevation.level1,
        ),
        child: Icon(
          icon,
          size: 20,
          color: dark ? AppColors.textOnPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Small pill in the top bar naming the current level.
class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulseHalo(
            color: AppColors.accent,
            size: 8,
            child: SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark bottom action: icon chip, label, chevron chip.
class _AdjustBar extends StatelessWidget {
  const _AdjustBar({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: AppRadii.pillAll,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.lavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.ink),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                style: AppTypography.button.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const NudgeArrow(
                icon: Icons.keyboard_arrow_up_rounded,
                color: AppColors.textOnPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
          ],
        ),
      ),
    );
  }
}

/// Dark sheet with the two level adjustments as explained cards.
class _AdjustSheet extends StatelessWidget {
  const _AdjustSheet({
    required this.l10n,
    required this.level,
    required this.onRepeat,
    required this.onStepDown,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final int level;
  final VoidCallback onRepeat;
  final VoidCallback? onStepDown;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.sessionRingTrack,
                  borderRadius: AppRadii.pillAll,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              from: RevealFrom.drop,
              child: Row(
                children: [
                  FloatBob(
                    lift: 3,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.16),
                        borderRadius: AppRadii.lgAll,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.accent,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.h2ChooseActionTitle,
                          style: AppTypography.title.copyWith(
                            color: AppColors.sessionText,
                          ),
                        ),
                        Text(
                          l10n.h1LevelName(
                            level,
                            HomeCopy.levelName(l10n, level),
                          ),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              from: RevealFrom.left,
              delay: const Duration(milliseconds: 80),
              child: _AdjustOption(
                icon: Icons.replay_rounded,
                title: l10n.h2ChooseRepeat,
                body: l10n.h2RepeatMessage,
                onTap: onRepeat,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Reveal(
              from: RevealFrom.right,
              delay: const Duration(milliseconds: 140),
              child: _AdjustOption(
                icon: Icons.south_rounded,
                title: l10n.h2ChooseStepDown,
                body: onStepDown == null
                    ? l10n.h2StepDownUnavailable
                    : l10n.h2StepDownMessage,
                onTap: onStepDown,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  minimumSize: const Size(120, AppSpacing.minTouchTarget),
                ),
                child: Text(
                  l10n.commonCancel,
                  style: AppTypography.body.copyWith(
                    color: AppColors.sessionTextSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustOption extends StatelessWidget {
  const _AdjustOption({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Null shows the option disabled.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return PressScale(
      onTap: onTap,
      semanticLabel: title,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.sessionSurface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: enabled
                  ? AppColors.accent.withValues(alpha: 0.35)
                  : AppColors.sessionRingTrack,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.14),
                  borderRadius: AppRadii.mdAll,
                ),
                child: Icon(icon, color: AppColors.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: AppColors.sessionText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.sessionTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.sessionTextSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft, see-through "Rest day" label laid over a rest figure.
class _RestGlass extends StatelessWidget {
  const _RestGlass({required this.label, this.large = false});

  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? AppSpacing.md : AppSpacing.sm,
            vertical: large ? AppSpacing.xs : 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: AppRadii.pillAll,
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.9),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.nightlight_round,
                size: large ? 16 : 13,
                color: LevelPalette.rest.deep,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: LevelPalette.rest.deep,
                    fontWeight: FontWeight.w800,
                    fontSize: large ? 14 : 12,
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

/// Rest-day card in the day strip: only the calm figure and a see-through
/// "Rest day" label. Not tappable.
class _RestDayCard extends StatelessWidget {
  const _RestDayCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.g1CalRest,
      excludeSemantics: true,
      child: SizedBox(
        width: _DayCard.width,
        height: _DayCard.height,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.lgAll,
                  color: LevelPalette.rest.tint,
                  border: Border.all(color: LevelPalette.rest.base),
                ),
              ),
            ),
            const Positioned(
              bottom: 2,
              child: Opacity(
                opacity: 0.7,
                child: PoseFigure(
                  pose: DayPose.restBreathing,
                  width: 112,
                  height: _DayCard.height + _DayCard.pop - 8,
                  glow: false,
                ),
              ),
            ),
            _RestGlass(label: l10n.g1CalRest),
          ],
        ),
      ),
    );
  }
}

/// Main panel on a rest day: the calm figure, a big "Rest day" and a
/// see-through label. No button and not tappable.
class _RestCover extends StatelessWidget {
  const _RestCover({
    required this.l10n,
    required this.eyebrow,
    required this.tag,
    required this.height,
  });

  final AppLocalizations l10n;
  final String eyebrow;
  final String tag;
  final double height;

  @override
  Widget build(BuildContext context) {
    final LevelPalette rest = LevelPalette.rest;
    return Semantics(
      label: '${l10n.g1CalRest}. ${l10n.h1RestDay}',
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.xlAll,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[rest.base, rest.tint],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: rest.deep.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppRadii.xlAll,
                  child: Align(
                    alignment: const Alignment(0, 0.3),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            AppColors.surface.withValues(alpha: 0.7),
                            AppColors.surface.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    maxLines: 2,
                    style: AppTypography.caption.copyWith(
                      color: rest.deep,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    l10n.g1CalRest.toUpperCase(),
                    style: AppTypography.display.copyWith(
                      color: AppColors.ink,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.md,
              child: Center(
                child: FloatBob(
                  lift: 3,
                  period: const Duration(milliseconds: 4200),
                  child: PoseFigure(
                    pose: DayPose.restBreathing,
                    width: 200,
                    height: 170,
                    glowColor: AppColors.surface,
                    semanticLabel: DayPose.restBreathing.label(l10n),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  child: _RestGlass(label: l10n.h1RestDay, large: true),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              top: -14,
              child: _StatusTag(label: tag, completed: false, color: rest.base),
            ),
          ],
        ),
      ),
    );
  }
}
