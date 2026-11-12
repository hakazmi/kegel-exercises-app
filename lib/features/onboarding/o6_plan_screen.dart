import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/plan_service.dart';
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

  int _strengtheningMinutes(int sessionsPerDay) {
    final int strengthSec = estimateStrengtheningSeconds(
      slowReps: 5,
      holdSec: 3,
      relaxSec: 3,
      quickReps: 5,
    );
    final int totalSec =
        (strengthSec * sessionsPerDay) + PlanRules.breathingDurationSeconds;
    return (totalSec / 60).ceil().clamp(3, 15);
  }

  int _relaxationMinutes(PlanService planService, OnboardingDraft draft) {
    final UserProfile profile = UserProfile.initial().copyWith(
      track: TrackId.relaxationFirst,
      sessionsPerDay: draft.sessionsPerDay,
      safetyFlags: draft.safetyFlags,
    );
    final TodayPlan plan = planService.todayPlan(
      profile: profile,
      sessions: const <SessionRecord>[],
    );
    final int totalSec = plan.items.fold<int>(
      0,
      (int sum, TodayItem item) => sum + item.durationSeconds,
    );
    return (totalSec / 60).ceil().clamp(1, 30);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final OnboardingDraft draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);
    final TrackId track = draft.resolveTrack();
    final bool relaxation = track == TrackId.relaxationFirst;
    final int restWeekday = UserProfile.initial().restWeekday;
    final PlanService planService = ref.watch(planServiceProvider);
    final int minutes = relaxation
        ? _relaxationMinutes(planService, draft)
        : _strengtheningMinutes(draft.sessionsPerDay);

    return OnboardingScaffold(
      step: 6,
      onBack: () => context.go(AppRoutes.time),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.o6Title, style: AppTypography.display),
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
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
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
                                ? l10n.o6RelaxationMeta(7, minutes)
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
                    Illustration(
                      assetPath: relaxation
                          ? 'assets/images/child.svg'
                          : 'assets/images/bridge.svg',
                      semanticLabel: relaxation
                          ? l10n.o6ChildSemantic
                          : l10n.o6BridgeSemantic,
                      width: 72,
                      height: 72,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _WeekPreview(restWeekday: restWeekday, l10n: l10n),
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
              color: AppColors.accent,
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
              color: AppColors.accent,
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

class _WeekPreview extends StatelessWidget {
  const _WeekPreview({required this.restWeekday, required this.l10n});

  final int restWeekday;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    int trainingDay = 0;
    return Row(
      children: [
        for (int weekday = 1; weekday <= 7; weekday++) ...[
          if (weekday > 1) const SizedBox(width: 6),
          Expanded(
            child: _DayBubble(
              isRest: weekday == restWeekday,
              index: weekday == restWeekday ? 0 : ++trainingDay,
              isFirst: weekday != restWeekday && trainingDay == 1,
              l10n: l10n,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
    );
  }
}
