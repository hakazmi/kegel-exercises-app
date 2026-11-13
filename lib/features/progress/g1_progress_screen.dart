import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/check_in_rules.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/progress_stats.dart';
import '../../core/widgets/widgets.dart';
import 'check_in_copy.dart';
import 'month_calendar.dart';

/// G1 Progress — streak, week count, level/day, longest hold, calendar, check-in.
class G1ProgressScreen extends ConsumerStatefulWidget {
  const G1ProgressScreen({super.key});

  @override
  ConsumerState<G1ProgressScreen> createState() => _G1ProgressScreenState();
}

class _G1ProgressScreenState extends ConsumerState<G1ProgressScreen> {
  DateTime? _visibleMonth;

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

    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            bottomInset + AppSpacing.xxl,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.tabProgress, style: AppTypography.display),
                ),
                IconButton(
                  tooltip: l10n.g1SettingsTooltip,
                  onPressed: () => context.push(AppRoutes.settings),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceMuted,
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatsGrid(l10n: l10n, stats: stats),
            const SizedBox(height: AppSpacing.lg),
            MonthCalendar(
              month: visibleMonth,
              today: today,
              completedDays: stats.completedDays,
              onPreviousMonth: () {
                setState(() {
                  _visibleMonth = DateTime(
                    visibleMonth.year,
                    visibleMonth.month - 1,
                  );
                });
              },
              onNextMonth: () {
                setState(() {
                  _visibleMonth = DateTime(
                    visibleMonth.year,
                    visibleMonth.month + 1,
                  );
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _CheckInCard(
              l10n: l10n,
              due: checkInDue,
              hasBaseline: checkIns.isNotEmpty,
              isPremium: isPremium,
              visible: visible,
              allCount: checkIns.length,
              today: today,
              onStart: () => context.push(AppRoutes.checkin),
              onUnlockHistory: () => context.push(
                '${AppRoutes.paywall}?source=checkin_history',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final String levelValue = stats.isRelaxationFirst
        ? l10n.g1StatRelaxationDay(
            stats.dayInLevel,
            PlanRules.relaxationFirstDays,
          )
        : l10n.g1StatLevelDay(stats.level, stats.dayInLevel);
    final String levelLabel =
        stats.isRelaxationFirst ? l10n.g1StatRelaxationLabel : l10n.g1StatLevelLabel;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ProgressStatCard(
                label: l10n.g1StatStreakLabel,
                value: l10n.g1StatStreakValue(stats.streakDays),
                icon: Icons.local_fire_department_outlined,
                iconBackground: AppColors.streakBg,
                iconForeground: AppColors.streakFg,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ProgressStatCard(
                label: l10n.g1StatWeekLabel,
                value: l10n.g1StatWeekValue(stats.sessionsThisWeek),
                icon: Icons.calendar_today_outlined,
                iconBackground: AppColors.mint,
                iconForeground: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _ProgressStatCard(
                label: l10n.g1StatHoldLabel,
                value: l10n.g1StatHoldValue(stats.longestHoldSeconds),
                icon: Icons.timer_outlined,
                iconBackground: AppColors.goalEjaculationBg,
                iconForeground: AppColors.goalEjaculationFg,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ProgressStatCard(
                label: levelLabel,
                value: levelValue,
                icon: Icons.emoji_events_outlined,
                iconBackground: AppColors.goalSurgeryBg,
                iconForeground: AppColors.goalSurgeryFg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  const _ProgressStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBackground,
    required this.iconForeground,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBackground;
  final Color iconForeground;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  child: Icon(icon, size: 18, color: iconForeground),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
    required this.today,
    required this.onStart,
    required this.onUnlockHistory,
  });

  final AppLocalizations l10n;
  final bool due;
  final bool hasBaseline;
  final bool isPremium;
  final List<CheckInRecord> visible;
  final int allCount;
  final DateTime today;
  final VoidCallback onStart;
  final VoidCallback onUnlockHistory;

  @override
  Widget build(BuildContext context) {
    if (!due && !hasBaseline) {
      return AppCard(
        backgroundColor: AppColors.mint,
        child: Text(
          l10n.g1CheckInLockedHint,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final String title = !hasBaseline
        ? l10n.g1CheckInBaselineTitle
        : (due ? l10n.g1CheckInFollowUpTitle : l10n.g1CheckInHistoryTitle);
    final String body = !hasBaseline
        ? l10n.g1CheckInBaselineBody
        : (due ? l10n.g1CheckInFollowUpBody : _historyBody());

    return AppCard(
      backgroundColor: AppColors.mint,
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
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      body,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (due) ...[
                const SizedBox(width: AppSpacing.sm),
                _PillButton(label: l10n.g1CheckInStart, onPressed: onStart),
              ],
            ],
          ),
          if (!due && hasBaseline && !isPremium && allCount > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            TextLinkButton(
              label: l10n.g1CheckInUnlockHistory,
              onPressed: onUnlockHistory,
            ),
          ],
        ],
      ),
    );
  }

  String _historyBody() {
    if (visible.isEmpty) {
      return l10n.g1CheckInBaselineBody;
    }
    final CheckInRecord baseline = visible.first;
    if (visible.length == 1) {
      return CheckInCopy.comparisonLine(
        l10n,
        week: 0,
        score: baseline.score,
        goal: baseline.goal,
      );
    }
    final CheckInRecord latest = visible.last;
    final int week = CheckInRules.weekIndex(
      baselineDate: baseline.date,
      at: latest.date,
    );
    return '${CheckInCopy.comparisonLine(l10n, week: 0, score: baseline.score, goal: baseline.goal)} '
        '${CheckInCopy.comparisonLine(l10n, week: week, score: latest.score, goal: latest.goal)}';
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: AppRadii.pillAll,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
