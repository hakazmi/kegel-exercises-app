import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/content/info_copy.dart';
import '../../core/data/providers.dart';
import '../../core/data/repositories/hold_test_repository.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/level_progression.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/time/app_clock.dart';
import '../../core/widgets/widgets.dart';
import 'home_copy.dart';
import 'level_unlock_actions.dart';
import 'level_unlock_card.dart';
import 'today_celebration.dart';
import 'today_journey.dart';
import 'today_prep.dart';
import 'week_strip_builder.dart';

/// H1 Today — header, week strip, level hero, today's journey, habits, CTA.
///
/// Today's items form one connected journey. Tapping any open item starts
/// it; after a session the finished step animates and the line flows to the
/// next one.
class H1TodayScreen extends ConsumerStatefulWidget {
  const H1TodayScreen({super.key});

  @override
  ConsumerState<H1TodayScreen> createState() => _H1TodayScreenState();
}

class _H1TodayScreenState extends ConsumerState<H1TodayScreen> {
  /// Item currently playing its completion animation.
  String? _celebrating;
  Timer? _celebrationTimer;

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }

  /// Starts the pending celebration once this screen is visible (tickers on),
  /// so the animation is not spent while a session route covers Today.
  void _maybeStartCelebration(String? pending, bool visible) {
    if (pending == null || !visible || pending == _celebrating) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _celebrating = pending);
      ref.read(todayCelebrationProvider.notifier).clear();
      _celebrationTimer?.cancel();
      _celebrationTimer = Timer(const Duration(milliseconds: 2600), () {
        if (mounted) {
          setState(() => _celebrating = null);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final AsyncValue<TodayPlan> planAsync = ref.watch(todayPlanProvider);
    final AsyncValue<List<SessionRecord>> sessionsAsync =
        ref.watch(sessionsProvider);
    final AsyncValue<List<LevelContent>> levelsAsync =
        ref.watch(levelsProvider);
    final DateTime now = ref.watch(appClockProvider).now();
    final DateTime today = dateOnly(now);
    final DateTime? guideSeen = ref.watch(guideSeenOnProvider);
    final bool guideDoneToday =
        guideSeen != null && dateOnly(guideSeen) == today;
    final bool testDoneToday = ref
        .watch(holdTestsProvider)
        .any((HoldTestResult r) => dateOnly(r.at) == today);
    final Map<String, ExerciseContent> exercisesById = <String, ExerciseContent>{
      for (final ExerciseContent e
          in ref.watch(exercisesProvider).asData?.value ??
              const <ExerciseContent>[])
        e.id: e,
    };
    final String? pendingCelebration = ref.watch(todayCelebrationProvider);
    _maybeStartCelebration(pendingCelebration, TickerMode.valuesOf(context).enabled);

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

            final bool showUnlock = LevelProgression.shouldShowUnlockCard(
              profile: profile,
              sessions: sessions,
              today: now,
              daySpan: levelContent == null
                  ? null
                  : HomeCopy.daysInLevel(levelContent),
            );
            final int? nextLevel = LevelProgression.offeredLevel(profile);
            final bool canStart = _canStart(plan);
            // Technique guide and hold test: not for the relaxation-first
            // plan or while a catheter is in place (no squeezing).
            final bool prepVisible =
                plan.track != TrackId.relaxationFirst &&
                    plan.state != TodayPlanState.catheterBlocked &&
                    !profile.safetyFlags.catheter;
            final List<JourneyStatus> statuses = _statuses(plan, canStart);
            final int doneCount =
                plan.items.where((TodayItem i) => i.done).length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Reveal(
                    from: RevealFrom.drop,
                    child: _TodayHeader(
                      l10n: l10n,
                      now: now,
                      streak: streak,
                      onSettings: () => context.push(AppRoutes.settings),
                    ),
                  ),
                  if (showUnlock && nextLevel != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Reveal(
                      from: RevealFrom.drop,
                      delay: const Duration(milliseconds: 120),
                      child: LevelUnlockCard(
                        l10n: l10n,
                        nextLevel: nextLevel,
                        onStart: () async {
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
                        },
                        onStay: () => LevelUnlockActions.snooze(ref),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Reveal(
                    from: RevealFrom.left,
                    delay: const Duration(milliseconds: 60),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            switch (planWeekNumber(
                              today: now,
                              planStart: profile.planStartedOn,
                            )) {
                              final int week => l10n.h1PlanWeek(week),
                              null => l10n.h1ThisWeek,
                            },
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        InfoButton(content: InfoCopy.restDay(l10n)),
                      ],
                    ),
                  ),
                  WeekStrip(
                    days: buildTodayWeekStrip(
                      l10n: l10n,
                      today: now,
                      restWeekday: profile.restWeekday,
                      sessions: sessions,
                      planStart: profile.planStartedOn,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Reveal(
                    from: RevealFrom.left,
                    delay: const Duration(milliseconds: 140),
                    child: _LevelHero(
                      l10n: l10n,
                      plan: plan,
                      levelContent: levelContent,
                      onTap: () => context.push(AppRoutes.levels),
                    ),
                  ),
                  if (_stateBanner(l10n, plan) case final _Banner banner) ...[
                    const SizedBox(height: AppSpacing.md),
                    Reveal(
                      from: RevealFrom.right,
                      delay: const Duration(milliseconds: 200),
                      child: _StateBannerCard(banner: banner),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Reveal(
                    from: RevealFrom.left,
                    delay: const Duration(milliseconds: 220),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.h1JourneyTitle,
                                style: AppTypography.title,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.h1JourneySubtitle(doneCount, plan.items.length),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        TodayProgressRing(
                          done: doneCount,
                          total: plan.items.length,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Level 1: learn the technique and test the hold first.
                  if (prepVisible && plan.level == 1)
                    TodayPrepSteps(
                      l10n: l10n,
                      guideDone: guideDoneToday,
                      testDone: testDoneToday,
                    ),
                  TodayJourney(
                    l10n: l10n,
                    items: plan.items,
                    statuses: statuses,
                    celebrateId: _celebrating,
                    infoFor: (TodayItem item) => InfoCopy.todayKind(
                      l10n,
                      item.kind,
                      exerciseNames: <String>[
                        for (final String id in item.exerciseIds)
                          if (exercisesById[id] case final ExerciseContent ex)
                            ex.name,
                      ],
                    ),
                    onTapItem: (TodayItem item) =>
                        _onTapItem(context, l10n, plan, item, canStart),
                  ),
                  if (plan.habits.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Reveal(
                      from: RevealFrom.rise,
                      delay: const Duration(milliseconds: 420),
                      child: _HabitsSection(
                        l10n: l10n,
                        habits: plan.habits,
                        exercisesById: exercisesById,
                        onToggle: (TodayHabitItem habit) async {
                          await ref.read(habitRepositoryProvider).toggle(
                                habitId: habit.id,
                                day: dateOnly(now),
                              );
                          ref.invalidate(todayPlanProvider);
                          await ref.read(todayPlanProvider.future);
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Reveal(
                    from: RevealFrom.rise,
                    delay: const Duration(milliseconds: 480),
                    child: PrimaryButton(
                      label: l10n.h1StartSession,
                      icon: Icons.play_arrow_rounded,
                      trailingArrow: canStart,
                      shimmer: canStart,
                      enabled: canStart,
                      onPressed:
                          canStart ? () => _startNext(context, plan) : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: TextLinkButton(
                      label: l10n.h1FeltPain,
                      color: AppColors.textSecondary,
                      onPressed: () => context.push(AppRoutes.painHelp),
                    ),
                  ),
                  // After Level 1 the guide and test stay one tap away.
                  if (prepVisible && plan.level > 1) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Reveal(
                      from: RevealFrom.rise,
                      delay: const Duration(milliseconds: 520),
                      child: TodayToolsRow(l10n: l10n),
                    ),
                  ],
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
    return plan.items.any((TodayItem i) => !i.done && !i.locked);
  }

  List<JourneyStatus> _statuses(TodayPlan plan, bool canStart) {
    bool nextAssigned = false;
    final List<JourneyStatus> out = <JourneyStatus>[];
    for (final TodayItem item in plan.items) {
      if (item.done) {
        out.add(JourneyStatus.done);
      } else if (item.locked) {
        out.add(JourneyStatus.locked);
      } else if (!canStart) {
        out.add(JourneyStatus.blocked);
      } else if (!nextAssigned) {
        nextAssigned = true;
        out.add(JourneyStatus.next);
      } else {
        out.add(JourneyStatus.upcoming);
      }
    }
    return out;
  }

  _Banner? _stateBanner(AppLocalizations l10n, TodayPlan plan) {
    return switch (plan.state) {
      TodayPlanState.restDay =>
        _Banner(Icons.bedtime_outlined, l10n.h1RestDay, AppColors.goalSurgeryBg,
            AppColors.goalSurgeryFg),
      TodayPlanState.allDone =>
        _Banner(Icons.verified_outlined, l10n.h1AllDone, AppColors.mint,
            AppColors.primary),
      TodayPlanState.dailyCapReached => _Banner(Icons.hourglass_bottom_rounded,
          l10n.h1DailyCap, AppColors.streakBg, AppColors.streakFg),
      _ => null,
    };
  }

  void _onTapItem(
    BuildContext context,
    AppLocalizations l10n,
    TodayPlan plan,
    TodayItem item,
    bool canStart,
  ) {
    if (item.locked) {
      context.push('${AppRoutes.paywall}?source=locked_content');
      return;
    }
    if (item.done) {
      _toast(context, l10n.h1ItemAlreadyDone);
      return;
    }
    if (!canStart) {
      _toast(
        context,
        plan.state == TodayPlanState.dailyCapReached
            ? l10n.h1DailyCap
            : l10n.h1AllDone,
      );
      return;
    }
    context.push('${AppRoutes.before}?itemId=${Uri.encodeComponent(item.id)}');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        ),
      );
  }

  void _startNext(BuildContext context, TodayPlan plan) {
    for (final TodayItem item in plan.items) {
      if (!item.done && !item.locked) {
        context.push(
          '${AppRoutes.before}?itemId=${Uri.encodeComponent(item.id)}',
        );
        return;
      }
    }
  }
}

class _Banner {
  const _Banner(this.icon, this.text, this.bg, this.fg);

  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
}

class _StateBannerCard extends StatelessWidget {
  const _StateBannerCard({required this.banner});

  final _Banner banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: banner.bg,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          FloatBob(
            lift: 3,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(banner.icon, color: banner.fg, size: 22),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              banner.text,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({
    required this.l10n,
    required this.now,
    required this.streak,
    required this.onSettings,
  });

  final AppLocalizations l10n;
  final DateTime now;
  final int streak;
  final VoidCallback onSettings;

  String _greeting() {
    final int hour = now.hour;
    if (hour < 12) {
      return l10n.h1GreetingMorning;
    }
    if (hour < 18) {
      return l10n.h1GreetingAfternoon;
    }
    return l10n.h1GreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(l10n.tabToday, style: AppTypography.display),
            ],
          ),
        ),
        if (streak > 0) ...[
          _StreakChip(label: l10n.h1Streak(streak)),
          const SizedBox(width: AppSpacing.xs),
        ],
        PressScale(
          onTap: onSettings,
          semanticLabel: l10n.g1SettingsTooltip,
          child: Container(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.streakBg,
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatBob(
            lift: 2,
            period: const Duration(milliseconds: 1400),
            child: Illustration(
              assetPath: 'assets/images/flame.svg',
              semanticLabel: label,
              width: 16,
              height: 16,
              color: AppColors.streakFg,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.streakFg,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Level card in the level's colour (like the reference "Daily challenge"
/// card): track badge, level title, progress, and today's 3D figure whose
/// head rises above the card's top edge.
class _LevelHero extends StatelessWidget {
  const _LevelHero({
    required this.l10n,
    required this.plan,
    required this.levelContent,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final TodayPlan plan;
  final LevelContent? levelContent;
  final VoidCallback onTap;

  static const double _rise = 34;
  static const double _height = 172;

  @override
  Widget build(BuildContext context) {
    final bool relaxation = plan.track == TrackId.relaxationFirst;
    final int totalDays = HomeCopy.planTotalDays(
      track: plan.track,
      level: levelContent,
    );
    final int doneDays = (plan.dayInLevel - 1).clamp(0, totalDays);
    final int percent = totalDays == 0
        ? 0
        : (doneDays / totalDays * 100).round().clamp(0, 100);
    // Big level name, with "Level N · Day D of T" as the progress line.
    final String title = relaxation
        ? l10n.h1RelaxationWeeksTitle
        : HomeCopy.levelName(l10n, plan.level);
    final String progressLine = relaxation
        ? l10n.h1DayProgress(doneDays, totalDays)
        : l10n.h1LevelDayOf(
            plan.level,
            plan.dayInLevel.clamp(1, totalDays == 0 ? 1 : totalDays),
            totalDays,
          );
    final String badge = l10n
        .o6TrackBadge(HomeCopy.trackName(l10n, plan.track))
        .toUpperCase();
    final LevelPalette palette =
        relaxation ? LevelPalette.rest : LevelPalette.of(plan.level);
    final DayPose pose = relaxation
        ? DayPose.restBreathing
        : DayPose.forDay(plan.dayInLevel);
    final bool wide = pose.isWide || pose == DayPose.restBreathing;

    return PressScale(
      onTap: onTap,
      semanticLabel: '${l10n.h1LevelCardSemantic}. $title',
      child: Padding(
        padding: const EdgeInsets.only(top: _rise),
        child: SizedBox(
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.xlAll,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        palette.base,
                        Color.lerp(palette.base, AppColors.surface, 0.45)!,
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: palette.deep.withValues(alpha: 0.16),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadii.xlAll,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          bottom: -80,
                          child: Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface.withValues(alpha: 0.4),
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: wide ? AppSpacing.xxs : AppSpacing.md,
                bottom: wide ? 70 : 66,
                child: FloatBob(
                  lift: 3,
                  period: const Duration(milliseconds: 3000),
                  child: PoseFigure(
                    pose: pose,
                    width: wide ? 140 : 96,
                    height: wide ? 80 : _height + _rise - 66,
                    glowColor: AppColors.surface,
                    semanticLabel: pose.label(l10n),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: wide ? 150 : 118,
                top: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.75),
                        borderRadius: AppRadii.pillAll,
                      ),
                      child: Text(
                        badge,
                        maxLines: 2,
                        style: AppTypography.caption.copyWith(
                          color: palette.deep,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      maxLines: 2,
                      style: AppTypography.title.copyWith(
                        color: AppColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            progressLine,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        CountUpText(
                          value: percent,
                          delay: const Duration(milliseconds: 350),
                          format: l10n.h1Percent,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.ink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _GlowBar(progress: percent / 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowBar extends StatelessWidget {
  const _GlowBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: AppColors.surface.withValues(alpha: 0.6),
          child: AnimatedFraction(
            value: progress,
            delay: const Duration(milliseconds: 350),
            builder: (BuildContext context, double v) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: AppRadii.pillAll,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _HabitsSection extends StatelessWidget {
  const _HabitsSection({
    required this.l10n,
    required this.habits,
    required this.exercisesById,
    required this.onToggle,
  });

  final AppLocalizations l10n;
  final List<TodayHabitItem> habits;
  final Map<String, ExerciseContent> exercisesById;
  final ValueChanged<TodayHabitItem> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.h1SectionHabits, style: AppTypography.title),
            ),
            InfoButton(content: InfoCopy.habits(l10n)),
          ],
        ),
        Text(l10n.h1HabitsHint, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sm),
        for (final TodayHabitItem habit in habits) ...[
          _HabitTile(
            l10n: l10n,
            habit: habit,
            info: switch (exercisesById[habit.exerciseId]) {
              final ExerciseContent ex => InfoCopy.exercise(l10n, ex),
              null => null,
            },
            onToggle: () => onToggle(habit),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.l10n,
    required this.habit,
    required this.onToggle,
    this.info,
  });

  final AppLocalizations l10n;
  final TodayHabitItem habit;
  final VoidCallback onToggle;
  final InfoContent? info;

  IconData get _icon => switch (habit.exerciseId) {
        'after_dribble_squeeze' => Icons.water_drop_outlined,
        'urge_control_squeeze' => Icons.front_hand_outlined,
        _ => Icons.repeat_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final bool done = habit.done;
    return PressScale(
      onTap: onToggle,
      semanticLabel:
          '${habit.label}. ${done ? l10n.h1HabitClear : l10n.h1HabitMarkDone}',
      child: AnimatedContainer(
        duration: AppMotion.quick,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: done ? AppColors.mint : AppColors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: done ? AppColors.mint : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                habit.label,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (info != null) InfoButton(content: info!, size: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (Widget child, Animation<double> a) =>
                  ScaleTransition(scale: a, child: child),
              child: done
                  ? Row(
                      key: const ValueKey<String>('done'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.h1HabitDone,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        const AnimatedCheckBadge(
                          size: 22,
                          color: AppColors.primary,
                          checkColor: AppColors.textOnPrimary,
                          strokeWidth: 2.5,
                        ),
                      ],
                    )
                  : Container(
                      key: const ValueKey<String>('todo'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs + 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.pillAll,
                        border: Border.all(color: AppColors.borderStrong),
                      ),
                      child: Text(
                        l10n.h1HabitMarkDone,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
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
          Reveal(
            from: RevealFrom.drop,
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.goalSurgeryBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  size: 36,
                  color: AppColors.goalSurgeryFg,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
