import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/info_copy.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/check_in_rules.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/progress_stats.dart';
import '../../core/time/app_clock.dart';
import '../../core/widgets/widgets.dart';
import '../home/today_journey.dart' show RingPainter;
import 'check_in_copy.dart';
import 'hold_test_card.dart';
import 'month_calendar.dart';

/// G1 Progress — streak hero, stat tiles, calendar, walking, check-in.
///
/// Panels slide in from alternating sides, numbers count up and rings fill.
class G1ProgressScreen extends ConsumerStatefulWidget {
  const G1ProgressScreen({super.key});

  @override
  ConsumerState<G1ProgressScreen> createState() => _G1ProgressScreenState();
}

class _G1ProgressScreenState extends ConsumerState<G1ProgressScreen> {
  DateTime? _visibleMonth;

  /// +1 when moving to a later month, -1 for earlier (calendar slide).
  int _monthDirection = 1;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final bool isPremium = ref.watch(isPremiumProvider);
    final DateTime today = ref.watch(appClockProvider).now();
    final AsyncValue<List<SessionRecord>> sessionsAsync =
        ref.watch(sessionsProvider);
    final AsyncValue<List<CheckInRecord>> checkInsAsync =
        ref.watch(checkInsProvider);

    final DateTime visibleMonth =
        _visibleMonth ?? DateTime(today.year, today.month);

    final List<SessionRecord> sessions =
        sessionsAsync.asData?.value ?? const <SessionRecord>[];
    final List<CheckInRecord> checkIns =
        checkInsAsync.asData?.value ?? const <CheckInRecord>[];
    final ProgressStats stats = ProgressStats.from(
      profile: profile,
      sessions: sessions,
      today: today,
    );
    final bool checkInDue = CheckInRules.isDue(
      sessions: sessions,
      checkIns: checkIns,
      today: today,
    );
    final List<CheckInRecord> visible = CheckInRules.visibleHistory(
      checkIns: checkIns,
      isPremium: isPremium,
    );
    final bool showWalking = profile.track == TrackId.erectionSupport ||
        profile.track == TrackId.generalBladder ||
        profile.track == TrackId.afterProstateSurgery;

    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    int slot = 0;
    Duration next() =>
        AppMotion.stagger(slot++, base: const Duration(milliseconds: 60));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            bottomInset + AppSpacing.xxl,
          ),
          children: [
            Reveal(
              from: RevealFrom.drop,
              delay: next(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.tabProgress, style: AppTypography.display),
                  ),
                  PressScale(
                    onTap: () => context.push(AppRoutes.settings),
                    semanticLabel: l10n.g1SettingsTooltip,
                    child: Container(
                      width: AppSpacing.minTouchTarget,
                      height: AppSpacing.minTouchTarget,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              from: RevealFrom.left,
              delay: next(),
              child: _StreakHero(
                l10n: l10n,
                stats: stats,
                today: today,
                restWeekday: profile.restWeekday,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Reveal(
                    from: RevealFrom.left,
                    delay: next(),
                    child: _StatTile(
                      label: l10n.g1StatWeekLabel,
                      info: InfoCopy.weekRing(l10n),
                      icon: Icons.event_available_rounded,
                      bg: AppColors.mint,
                      fg: AppColors.primary,
                      value: CountUpText(
                        value: stats.sessionsThisWeek,
                        delay: const Duration(milliseconds: 300),
                        format: l10n.g1StatWeekValue,
                        style: AppTypography.title,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Reveal(
                    from: RevealFrom.right,
                    delay: next(),
                    child: _StatTile(
                      label: l10n.g1StatHoldLabel,
                      info: InfoCopy.longestHold(l10n),
                      icon: Icons.timer_outlined,
                      bg: AppColors.goalEjaculationBg,
                      fg: AppColors.goalEjaculationFg,
                      value: CountUpText(
                        value: stats.longestHoldSeconds,
                        delay: const Duration(milliseconds: 360),
                        format: l10n.g1StatHoldValue,
                        style: AppTypography.title,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Reveal(
              from: RevealFrom.right,
              delay: next(),
              child: _LevelTile(l10n: l10n, stats: stats),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              from: RevealFrom.left,
              delay: next(),
              child: MonthCalendar(
                month: visibleMonth,
                today: today,
                completedDays: stats.completedDays,
                restWeekday: profile.restWeekday,
                planStart: profile.planStartedOn,
                direction: _monthDirection,
                onPreviousMonth: () {
                  setState(() {
                    _monthDirection = -1;
                    _visibleMonth = DateTime(
                      visibleMonth.year,
                      visibleMonth.month - 1,
                    );
                  });
                },
                onNextMonth: () {
                  setState(() {
                    _monthDirection = 1;
                    _visibleMonth = DateTime(
                      visibleMonth.year,
                      visibleMonth.month + 1,
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              from: RevealFrom.left,
              delay: next(),
              child: HoldTestCard(
                l10n: l10n,
                results: ref.watch(holdTestsProvider),
                onStart: () => context.push(AppRoutes.holdTest),
              ),
            ),
            if (showWalking) ...[
              const SizedBox(height: AppSpacing.lg),
              Reveal(
                from: RevealFrom.right,
                delay: next(),
                child: _WalkingCard(
                  l10n: l10n,
                  track: profile.track,
                  week: ref.watch(walkingWeekProvider),
                  onAdd: (int minutes) async {
                    await ref.read(walkingRepositoryProvider).addMinutes(
                          day: today,
                          minutes: minutes,
                        );
                    ref.invalidate(walkingWeekProvider);
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              from: RevealFrom.rise,
              delay: next(),
              child: _CheckInCard(
                l10n: l10n,
                due: checkInDue,
                hasBaseline: checkIns.isNotEmpty,
                isPremium: isPremium,
                visible: visible,
                allCount: checkIns.length,
                onStart: () => context.push(AppRoutes.checkin),
                onUnlockHistory: () => context.push(
                  '${AppRoutes.paywall}?source=checkin_history',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dark streak card with a floating flame and this week's training ring.
class _StreakHero extends StatelessWidget {
  const _StreakHero({
    required this.l10n,
    required this.stats,
    required this.today,
    required this.restWeekday,
  });

  final AppLocalizations l10n;
  final ProgressStats stats;
  final DateTime today;
  final int restWeekday;

  /// Unique Mon–Sun training days this week. The weekly rest day never counts
  /// toward the 6-day ring, matching the calendar.
  int _trainedDaysThisWeek() {
    final DateTime todayDate = dateOnly(today);
    final DateTime start = todayDate.subtract(
      Duration(days: todayDate.weekday - DateTime.monday),
    );
    return stats.completedDays
        .where((DateTime d) {
          if (d.isBefore(start) || !d.isBefore(start.add(const Duration(days: 7)))) {
            return false;
          }
          return d.weekday != restWeekday;
        })
        .length;
  }

  @override
  Widget build(BuildContext context) {
    const int weeklyTarget = 6; // one rest day a week
    final int trained = _trainedDaysThisWeek().clamp(0, weeklyTarget);
    return ClipRRect(
      borderRadius: AppRadii.xlAll,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.lavender,
              Color.lerp(AppColors.lavender, AppColors.surface, 0.5)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -70,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface.withValues(alpha: 0.35),
                    width: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  FloatBob(
                    lift: 4,
                    period: const Duration(milliseconds: 1600),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Illustration(
                        assetPath: 'assets/images/flame.svg',
                        semanticLabel: l10n.g1StatStreakLabel,
                        width: 28,
                        height: 28,
                        color: AppColors.streakFg,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                l10n.g1StatStreakLabel,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              height: 20,
                              child: OverflowBox(
                                maxWidth: AppSpacing.minTouchTarget,
                                maxHeight: AppSpacing.minTouchTarget,
                                child: InfoButton(
                                  content: InfoCopy.streak(l10n),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        CountUpText(
                          value: stats.streakDays,
                          delay: const Duration(milliseconds: 250),
                          format: l10n.g1StatStreakValue,
                          style: AppTypography.display.copyWith(
                            color: AppColors.ink,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: AnimatedFraction(
                          value: trained / weeklyTarget,
                          delay: const Duration(milliseconds: 300),
                          builder: (BuildContext context, double v) =>
                              CustomPaint(
                            painter: RingPainter(
                              progress: v,
                              track: AppColors.surface.withValues(alpha: 0.6),
                              fill: AppColors.ink,
                              stroke: 6,
                            ),
                            child: Center(
                              child: Text(
                                '$trained/$weeklyTarget',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.g1HeroDaysThisWeek,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.fg,
    this.info,
  });

  final String label;
  final Widget value;
  final IconData icon;
  final Color bg;
  final Color fg;
  final InfoContent? info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(color: bg, borderRadius: AppRadii.mdAll),
                child: Icon(icon, size: 20, color: fg),
              ),
              const Spacer(),
              if (info != null)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: OverflowBox(
                    maxWidth: AppSpacing.minTouchTarget,
                    maxHeight: AppSpacing.minTouchTarget,
                    child: InfoButton(content: info!, size: 24),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          value,
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final int span = stats.isRelaxationFirst
        ? PlanRules.relaxationFirstDays
        : PlanRules.levelDaySpan(stats.level);
    final double progress =
        span == 0 ? 0 : ((stats.dayInLevel - 1) / span).clamp(0.0, 1.0);
    final String value = stats.isRelaxationFirst
        ? l10n.g1StatRelaxationDay(
            stats.dayInLevel,
            PlanRules.relaxationFirstDays,
          )
        : l10n.g1StatLevelDay(stats.level, stats.dayInLevel);
    final String label = stats.isRelaxationFirst
        ? l10n.g1StatRelaxationLabel
        : l10n.g1StatLevelLabel;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.goalSurgeryBg,
              borderRadius: AppRadii.mdAll,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 20,
              color: AppColors.goalSurgeryFg,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTypography.caption),
                    SizedBox(
                      width: 28,
                      height: 20,
                      child: OverflowBox(
                        maxWidth: AppSpacing.minTouchTarget,
                        maxHeight: AppSpacing.minTouchTarget,
                        child: InfoButton(
                          content: InfoCopy.levels(l10n),
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppRadii.pillAll,
                  child: SizedBox(
                    height: 6,
                    child: ColoredBox(
                      color: AppColors.surfaceMuted,
                      child: AnimatedFraction(
                        value: progress,
                        delay: const Duration(milliseconds: 400),
                        builder: (BuildContext context, double v) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: v,
                            heightFactor: 1,
                            child: const ColoredBox(
                              color: AppColors.goalSurgeryFg,
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
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.l10n,
    required this.due,
    required this.hasBaseline,
    required this.isPremium,
    required this.visible,
    required this.allCount,
    required this.onStart,
    required this.onUnlockHistory,
  });

  final AppLocalizations l10n;
  final bool due;
  final bool hasBaseline;
  final bool isPremium;
  final List<CheckInRecord> visible;
  final int allCount;
  final VoidCallback onStart;
  final VoidCallback onUnlockHistory;

  @override
  Widget build(BuildContext context) {
    if (!due && !hasBaseline) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.g1CheckInLockedHint,
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      );
    }

    final String title = !hasBaseline
        ? l10n.g1CheckInBaselineTitle
        : (due ? l10n.g1CheckInFollowUpTitle : l10n.g1CheckInHistoryTitle);
    final String? body = !hasBaseline
        ? l10n.g1CheckInBaselineBody
        : (due ? l10n.g1CheckInFollowUpBody : null);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.mint, AppColors.surface],
        ),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PulseHalo(
                color: AppColors.accent,
                size: 40,
                active: due,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 22,
                          child: OverflowBox(
                            maxWidth: AppSpacing.minTouchTarget,
                            maxHeight: AppSpacing.minTouchTarget,
                            child: InfoButton(
                              content: InfoCopy.checkIn(l10n),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (body != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(body, style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (hasBaseline && visible.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ScoreBars(l10n: l10n, records: visible),
          ],
          if (due) ...[
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: l10n.g1CheckInStart,
              icon: Icons.edit_note_rounded,
              trailingArrow: true,
              height: 48,
              onPressed: onStart,
            ),
          ],
          if (!due && hasBaseline && !isPremium && allCount > 1) ...[
            const SizedBox(height: AppSpacing.xs),
            TextLinkButton(
              label: l10n.g1CheckInUnlockHistory,
              onPressed: onUnlockHistory,
            ),
          ],
        ],
      ),
    );
  }
}

/// The user's own check-in scores side by side (baseline first), with the
/// spec's "Week n: x of 5" line under each bar. No predictions.
class _ScoreBars extends StatelessWidget {
  const _ScoreBars({required this.l10n, required this.records});

  final AppLocalizations l10n;
  final List<CheckInRecord> records;

  @override
  Widget build(BuildContext context) {
    final CheckInRecord baseline = records.first;
    final List<CheckInRecord> shown = records.length <= 4
        ? records
        : <CheckInRecord>[records.first, ...records.sublist(records.length - 3)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < shown.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AnimatedFraction(
                    value: shown[i].score / 5,
                    delay: AppMotion.stagger(
                      i,
                      base: const Duration(milliseconds: 400),
                    ),
                    builder: (BuildContext context, double v) => Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${shown[i].score}',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 66 * v,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: i == shown.length - 1
                                  ? const <Color>[
                                      AppColors.primary,
                                      AppColors.accent,
                                    ]
                                  : const <Color>[
                                      AppColors.border,
                                      AppColors.surfaceMuted,
                                    ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadii.md),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final CheckInRecord row in shown)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              CheckInCopy.comparisonLine(
                l10n,
                week: CheckInRules.weekIndex(
                  baselineDate: baseline.date,
                  at: row.date,
                ),
                score: row.score,
                goal: row.goal,
              ),
              style: AppTypography.caption,
            ),
          ),
      ],
    );
  }
}

class _WalkingCard extends StatelessWidget {
  const _WalkingCard({
    required this.l10n,
    required this.track,
    required this.week,
    required this.onAdd,
  });

  /// Weekly goal from the research doc: about 40 minutes on 4 days.
  static const int _goalMinutes = 160;
  static const int _goalDays = 4;

  final AppLocalizations l10n;
  final TrackId track;
  final AsyncValue<({int minutes, int days})> week;
  final Future<void> Function(int minutes) onAdd;

  @override
  Widget build(BuildContext context) {
    final ({int minutes, int days}) stats =
        week.asData?.value ?? (minutes: 0, days: 0);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: AnimatedFraction(
                  value: stats.minutes / _goalMinutes,
                  delay: const Duration(milliseconds: 350),
                  builder: (BuildContext context, double v) => CustomPaint(
                    painter: RingPainter(
                      progress: v,
                      track: AppColors.surfaceMuted,
                      fill: AppColors.goalBladderFg,
                      stroke: 6,
                    ),
                    child: const Center(
                      child: FloatBob(
                        lift: 2,
                        child: Icon(
                          Icons.directions_walk_rounded,
                          color: AppColors.goalBladderFg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.g1WalkingTitle,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 22,
                          child: OverflowBox(
                            maxWidth: AppSpacing.minTouchTarget,
                            maxHeight: AppSpacing.minTouchTarget,
                            child: InfoButton(
                              content: InfoCopy.walking(l10n),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(l10n.g1WalkingGoal, style: AppTypography.caption),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l10n.g1WalkingProgress(stats.minutes, stats.days),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.goalBladderFg,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (int d = 0; d < _goalDays; d++) ...[
                if (d > 0) const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: AnimatedContainer(
                    duration: AppMotion.slide,
                    height: 6,
                    decoration: BoxDecoration(
                      color: d < stats.days
                          ? AppColors.goalBladderFg
                          : AppColors.surfaceMuted,
                      borderRadius: AppRadii.pillAll,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final int m in <int>[10, 20, 30]) ...[
                Expanded(
                  child: _QuickAddChip(
                    label: l10n.g1WalkingQuickAdd(m),
                    onTap: () => onAdd(m),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: _QuickAddChip(
                  label: l10n.g1WalkingCustom,
                  icon: Icons.edit_rounded,
                  onTap: () => _openSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.exWalkingCardioNote, style: AppTypography.caption),
          if (track == TrackId.afterProstateSurgery) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(l10n.exWalkingSurgeryNote, style: AppTypography.caption),
          ],
          const SizedBox(height: AppSpacing.xxs),
          Text(l10n.exWalkingDoctorNote, style: AppTypography.caption),
        ],
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final int? minutes = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext ctx) => _WalkingSheet(l10n: l10n),
    );
    if (minutes != null && minutes > 0) {
      await onAdd(minutes);
    }
  }
}

class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({required this.label, required this.onTap, this.icon});

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        decoration: const BoxDecoration(
          color: AppColors.goalBladderBg,
          borderRadius: AppRadii.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.goalBladderFg),
              const SizedBox(width: 2),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.goalBladderFg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for a custom walking entry. Owns its text controller so it
/// is disposed only after the sheet has fully closed.
class _WalkingSheet extends StatefulWidget {
  const _WalkingSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_WalkingSheet> createState() => _WalkingSheetState();
}

class _WalkingSheetState extends State<_WalkingSheet> {
  final TextEditingController _controller = TextEditingController(text: '20');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final int? value = int.tryParse(_controller.text.trim());
    // Cap one entry at 6 hours so a typo cannot fill the week.
    Navigator.pop(context, value?.clamp(1, 360));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
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
                color: AppColors.border,
                borderRadius: AppRadii.pillAll,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.g1WalkingAdd, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.g1WalkingMinutesLabel,
              prefixIcon: const Icon(Icons.directions_walk_rounded),
              border: const OutlineInputBorder(borderRadius: AppRadii.lgAll),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: l10n.g1WalkingAddConfirm, onPressed: _submit),
        ],
      ),
    );
  }
}
