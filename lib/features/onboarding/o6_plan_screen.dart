import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/content/info_copy.dart';
import '../../core/data/providers.dart';
import '../../core/motion/app_motion.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/plan_service.dart';
import '../../core/plan/session_definition.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';
import 'widgets/onboarding_scaffold.dart';

/// O6 Your plan — summary before first session.
class O6PlanScreen extends ConsumerWidget {
  const O6PlanScreen({super.key});

  String _trackName(AppLocalizations l10n, TrackId track) {
    switch (track) {
      case TrackId.generalBladder:
        return l10n.o6TrackGeneralBladder;
      case TrackId.erectionSupport:
        return l10n.o6TrackErection;
      case TrackId.ejaculationControl:
        return l10n.o6TrackEjaculation;
      case TrackId.afterProstateSurgery:
        return l10n.o6TrackSurgery;
      case TrackId.relaxationFirst:
        return l10n.o6TrackRelaxation;
    }
  }

  /// Sum of part durations for a typical day from [PlanService.todayPlan].
  int _typicalDayMinutes({
    required PlanService planService,
    required OnboardingDraft draft,
    required TrackId track,
    required int strengtheningDurationSeconds,
  }) {
    final UserProfile profile = UserProfile.initial().copyWith(
      track: track,
      sessionsPerDay: draft.sessionsPerDay,
      safetyFlags: draft.safetyFlags,
      goal: draft.goal ?? Goal.generalPelvicHealth,
    );
    final TodayPlan plan = planService.todayPlan(
      profile: profile,
      sessions: const <SessionRecord>[],
      strengtheningDurationSeconds: strengtheningDurationSeconds,
    );
    final int totalSec = plan.items.fold<int>(
      0,
      (int sum, TodayItem item) => sum + item.durationSeconds,
    );
    return (totalSec / 60).ceil().clamp(1, 60);
  }

  int _level1StrengthSeconds(List<LevelContent>? levels) {
    if (levels == null || levels.isEmpty) {
      return 55;
    }
    final LevelContent level = levels.firstWhere(
      (LevelContent l) => l.id == 1,
      orElse: () => levels.first,
    );
    return SessionDefinitionBuilder.strengtheningDurationForLevel(level);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final OnboardingDraft draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);
    final TrackId track = draft.resolveTrack();
    final bool relaxation = track == TrackId.relaxationFirst;
    // Rest day is day 7 of the first week, counted from today.
    final DateTime startDay = ref.watch(appClockProvider).now();
    final int restWeekday = restWeekdayForStart(startDay);
    final PlanService planService = ref.watch(planServiceProvider);
    final List<LevelContent>? levels = ref.watch(levelsProvider).asData?.value;
    final int minutes = _typicalDayMinutes(
      planService: planService,
      draft: draft,
      track: track,
      strengtheningDurationSeconds: _level1StrengthSeconds(levels),
    );

    return OnboardingScaffold(
      step: 6,
      onBack: () => context.go(AppRoutes.time),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            from: RevealFrom.left,
            child: Text(l10n.o6Title, style: AppTypography.display),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.sessionBackground,
              borderRadius: AppRadii.xlAll,
            ),
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
                            l10n
                                .o6TrackBadge(_trackName(l10n, track))
                                .toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            relaxation
                                ? l10n.o6RelaxationTitle
                                : l10n.o6LevelStart,
                            style: AppTypography.title
                                .copyWith(color: AppColors.sessionText),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            relaxation
                                ? l10n.o6RelaxationMeta(
                                    PlanRules.relaxationFirstDays,
                                    minutes,
                                  )
                                : l10n.o6PlanMeta(
                                    7,
                                    draft.sessionsPerDay,
                                    minutes,
                                  ),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.sessionTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Day 1's 3D figure (calm breathing for relaxation).
                    FloatBob(
                      lift: 3,
                      period: const Duration(milliseconds: 3000),
                      child: PoseFigure(
                        pose: relaxation
                            ? DayPose.restBreathing
                            : DayPose.standing,
                        width: relaxation ? 110 : 78,
                        height: relaxation ? 90 : 118,
                        glowColor: AppColors.lavender,
                        semanticLabel: relaxation
                            ? l10n.o6ChildSemantic
                            : l10n.o6BridgeSemantic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _WeekPreview(startWeekday: startDay.weekday, l10n: l10n),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.nightlight_round,
                      size: 14,
                      color: AppColors.sessionTextSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        l10n.o6RestDayNote(_weekdayName(l10n, restWeekday)),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.sessionTextSecondary,
                        ),
                      ),
                    ),
                    InfoButton(
                      content: InfoCopy.restDay(l10n),
                      dark: true,
                      size: 22,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.o6WhatToExpect, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          if (relaxation) ...[
            _TimelineItem(
              title: l10n.o6RelaxationTimelineWeeks12Title,
              body: l10n.o6RelaxationTimelineWeeks12Body,
              color: AppColors.primary,
            ),
            _TimelineItem(
              title: l10n.o6RelaxationTimelineAfterTitle,
              body: l10n.o6RelaxationTimelineAfterBody,
              color: AppColors.primary,
            ),
            _TimelineItem(
              title: l10n.o6RelaxationTimelineAlwaysTitle,
              body: l10n.o6RelaxationTimelineAlwaysBody,
              color: AppColors.border,
            ),
          ] else ...[
            _TimelineItem(
              title: l10n.o6TimelineWeek1Title,
              body: l10n.o6TimelineWeek1Body,
              color: AppColors.primary,
            ),
            _TimelineItem(
              title: l10n.o6TimelineWeek2Title,
              body: l10n.o6TimelineWeek2Body,
              color: AppColors.primary,
            ),
            _TimelineItem(
              title: l10n.o6TimelineWeek6Title,
              body: l10n.o6TimelineWeek6Body,
              color: AppColors.border,
            ),
          ],
        ],
      ),
      footer: PrimaryButton(
        label: l10n.o6Start,
        icon: Icons.play_arrow_rounded,
        shimmer: true,
        onPressed: () async {
          await controller.completeStep('O6');
          final UserProfile profile = await controller.finish(
            reminderOn: draft.reminderEnabled,
          );
          if (!context.mounted) {
            return;
          }
          final bool needsTutorial = profile.experience == Experience.none ||
              profile.experience == Experience.unsure;
          context.go(
            needsTutorial
                ? AppRoutes.tutorial
                : '${AppRoutes.before}?itemId=strength_1',
          );
        },
      ),
    );
  }
}

String _weekdayName(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.weekdayMonday,
    DateTime.tuesday => l10n.weekdayTuesday,
    DateTime.wednesday => l10n.weekdayWednesday,
    DateTime.thursday => l10n.weekdayThursday,
    DateTime.friday => l10n.weekdayFriday,
    DateTime.saturday => l10n.weekdaySaturday,
    _ => l10n.weekdaySunday,
  };
}

/// First week from today: six training days, then the rest day.
class _WeekPreview extends StatelessWidget {
  const _WeekPreview({required this.startWeekday, required this.l10n});

  final int startWeekday;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Reveal(
              from: RevealFrom.drop,
              delay: AppMotion.stagger(i, base: const Duration(milliseconds: 200)),
              child: _DayBubble(
                isRest: i == 6,
                index: i + 1,
                isFirst: i == 0,
                l10n: l10n,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DayBubble extends StatelessWidget {
  const _DayBubble({
    required this.isRest,
    required this.index,
    required this.isFirst,
    required this.l10n,
  });

  final bool isRest;
  final int index;
  final bool isFirst;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isRest ? l10n.o6RestLabel : l10n.o6DayLabel(index),
          style: AppTypography.caption.copyWith(
            color: AppColors.sessionTextSecondary,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFirst ? AppColors.primary : AppColors.sessionSurface,
            ),
            child: Center(
              child: isRest
                  ? const Icon(
                      Icons.nightlight_round,
                      size: 14,
                      color: AppColors.sessionTextSecondary,
                    )
                  : Text(
                      '$index',
                      style: AppTypography.caption.copyWith(
                        color: isFirst
                            ? AppColors.textOnPrimary
                            : AppColors.sessionText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.body,
    required this.color,
  });

  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      from: RevealFrom.right,
      delay: const Duration(milliseconds: 320),
      child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
              boxShadow: AppElevation.level1,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  body,
                  style: AppTypography.caption,
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
