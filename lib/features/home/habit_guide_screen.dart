import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/plan_models.dart';
import '../../core/time/app_clock.dart';
import '../../core/widgets/widgets.dart';
import '../tutorial/side_pelvic_demo.dart';

/// Guide for one daily habit (after-dribble squeeze, urge control): a live
/// side-view animation of what it does, the steps, when to use it, why it
/// helps, and a button to tick it off for today.
class HabitGuideScreen extends ConsumerWidget {
  const HabitGuideScreen({super.key, required this.habitId});

  /// [TodayHabitItem.id] of the habit.
  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TodayPlan? plan = ref.watch(todayPlanProvider).asData?.value;
    TodayHabitItem? habit;
    for (final TodayHabitItem h in plan?.habits ?? const <TodayHabitItem>[]) {
      if (h.id == habitId) {
        habit = h;
      }
    }
    final String exerciseId = habit?.exerciseId ?? habitId;
    final bool urge = exerciseId == 'urge_control_squeeze';
    final _Guide g = urge ? _Guide.urge(l10n) : _Guide.dribble(l10n);
    final bool done = habit?.done ?? false;

    final TodayHabitItem? current = habit;
    Future<void> toggle() async {
      if (current == null) {
        return;
      }
      await HapticFeedback.selectionClick();
      await ref
          .read(habitRepositoryProvider)
          .toggle(
            habitId: current.id,
            day: dateOnly(ref.read(appClockProvider).now()),
          );
      ref.invalidate(todayPlanProvider);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightScreen,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  children: [
                    PressScale(
                      onTap: () => context.pop(),
                      semanticLabel: l10n.commonBack,
                      child: Container(
                        width: AppSpacing.minTouchTarget,
                        height: AppSpacing.minTouchTarget,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: AppElevation.level1,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        g.title,
                        textAlign: TextAlign.center,
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.minTouchTarget),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    final double demo = math.min(box.maxWidth - 48, 320);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      children: [
                        Reveal(
                          from: RevealFrom.drop,
                          child: Center(
                            child: SidePelvicDemoLoop(
                              size: demo,
                              mode: urge
                                  ? SideDemoMode.urgeControl
                                  : SideDemoMode.afterDribble,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          g.intro,
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Section(
                          icon: Icons.format_list_numbered_rounded,
                          title: l10n.hgHowTitle,
                          tint: AppColors.lavender,
                          child: Column(
                            children: [
                              for (int i = 0; i < g.steps.length; i++)
                                _Step(number: i + 1, text: g.steps[i]),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _Section(
                          icon: Icons.schedule_rounded,
                          title: l10n.hgWhenTitle,
                          tint: AppColors.sky,
                          child: Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              for (final String w in g.when)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 6,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.goalBladderBg,
                                    borderRadius: AppRadii.pillAll,
                                  ),
                                  child: Text(
                                    w,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.goalBladderFg,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _Section(
                          icon: Icons.lightbulb_rounded,
                          title: l10n.hgWhyTitle,
                          tint: AppColors.pistachio,
                          child: Text(g.why, style: AppTypography.body),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: const BoxDecoration(
                            color: AppColors.streakBg,
                            borderRadius: AppRadii.lgAll,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_rounded,
                                color: AppColors.streakFg,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  g.caution,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (habit != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xs,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: done
                      ? SecondaryButton(
                          label: l10n.hgDoneToday,
                          icon: Icons.check_circle_rounded,
                          onPressed: toggle,
                        )
                      : PrimaryButton(
                          label: l10n.hgMarkDone,
                          icon: Icons.check_rounded,
                          onPressed: toggle,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Guide {
  const _Guide({
    required this.title,
    required this.intro,
    required this.steps,
    required this.when,
    required this.why,
    required this.caution,
  });

  factory _Guide.dribble(AppLocalizations l10n) => _Guide(
    title: l10n.exHabitAfterDribbleTitle,
    intro: l10n.hgAdIntro,
    steps: <String>[
      l10n.hgAdStep1,
      l10n.hgAdStep2,
      l10n.hgAdStep3,
      l10n.hgAdStep4,
    ],
    when: <String>[l10n.hgAdWhen1, l10n.hgAdWhen2],
    why: l10n.hgAdWhy,
    caution: l10n.hgAdCaution,
  );

  factory _Guide.urge(AppLocalizations l10n) => _Guide(
    title: l10n.exHabitUrgeControlTitle,
    intro: l10n.hgUcIntro,
    steps: <String>[
      l10n.hgUcStep1,
      l10n.hgUcStep2,
      l10n.hgUcStep3,
      l10n.hgUcStep4,
    ],
    when: <String>[l10n.hgUcWhen1, l10n.hgUcWhen2, l10n.hgUcWhen3],
    why: l10n.hgUcWhy,
    caution: l10n.hgUcCaution,
  );

  final String title;
  final String intro;
  final List<String> steps;
  final List<String> when;
  final String why;
  final String caution;
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.tint,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Icon(icon, size: 19, color: AppColors.ink),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
