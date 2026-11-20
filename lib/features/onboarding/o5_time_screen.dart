import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/info_copy.dart';
import '../../core/motion/app_motion.dart';
import '../../core/services/reminder_service.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';
import 'widgets/onboarding_stage.dart';
import 'widgets/onboarding_scaffold.dart';

/// O5 Time and reminder.
class O5TimeScreen extends ConsumerWidget {
  const O5TimeScreen({super.key});

  String _formatTime(int minutesFromMidnight) {
    final int hour24 = minutesFromMidnight ~/ 60;
    final int minute = minutesFromMidnight % 60;
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final String period = hour24 >= 12 ? 'PM' : 'AM';
    final String mm = minute.toString().padLeft(2, '0');
    return '$hour12:$mm $period';
  }

  Future<void> _pickTime(
    BuildContext context,
    OnboardingController controller,
    OnboardingDraft draft,
  ) async {
    final TimeOfDay initial = TimeOfDay(
      hour: draft.reminderTime ~/ 60,
      minute: draft.reminderTime % 60,
    );
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      controller.setReminderTime(picked.hour * 60 + picked.minute);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final OnboardingDraft draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);

    final List<String> dayLabels = <String>[
      l10n.o5DayMon,
      l10n.o5DayTue,
      l10n.o5DayWed,
      l10n.o5DayThu,
      l10n.o5DayFri,
      l10n.o5DaySat,
      l10n.o5DaySun,
    ];

    return OnboardingScaffold(
      step: 5,
      onBack: () => context.go(AppRoutes.experience),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            from: RevealFrom.drop,
            child: Stack(
              children: [
                TimeScene(semanticLabel: l10n.o5HeroSemantic),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: InfoButton(content: InfoCopy.sessionsPerDay(l10n)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 60),
            child: Text(l10n.o5Title, style: AppTypography.display),
          ),
          const SizedBox(height: AppSpacing.xs),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 110),
            child: Text(
              l10n.o5Subtitle,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (int i, (int, String, String) option)
                  in <(int, String, String)>[
                (1, l10n.o5Option1Title, l10n.o5Option1Subtitle),
                (2, l10n.o5Option2Title, l10n.o5Option2Subtitle),
                (3, l10n.o5Option3Title, l10n.o5Option3Subtitle),
              ].indexed) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Reveal(
                    from: RevealFrom.drop,
                    delay: AppMotion.stagger(
                      i,
                      base: const Duration(milliseconds: 160),
                    ),
                    child: _TimeCard(
                      sessions: option.$1,
                      title: option.$2,
                      subtitle: option.$3,
                      selected: draft.sessionsPerDay == option.$1,
                      onTap: () => controller.setSessionsPerDay(option.$1),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Reveal(
            from: RevealFrom.rise,
            delay: const Duration(milliseconds: 320),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const FloatBob(
                        lift: 2,
                        period: Duration(milliseconds: 1600),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          l10n.o5ReminderTitle,
                          style: AppTypography.title,
                        ),
                      ),
                      Switch.adaptive(
                        value: draft.reminderEnabled,
                        activeTrackColor: AppColors.success,
                        activeThumbColor: AppColors.surface,
                        onChanged: controller.setReminderEnabled,
                      ),
                    ],
                  ),
                  Text(l10n.o5ReminderHint, style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.md),
                  PressScale(
                    onTap: () => _pickTime(context, controller, draft),
                    semanticLabel:
                        '${l10n.o5TimeLabel} ${_formatTime(draft.reminderTime)}',
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: AppRadii.lgAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(l10n.o5TimeLabel, style: AppTypography.body),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: AppMotion.quick,
                            transitionBuilder:
                                (Widget child, Animation<double> a) =>
                                    ScaleTransition(scale: a, child: child),
                            child: Text(
                              _formatTime(draft.reminderTime),
                              key: ValueKey<int>(draft.reminderTime),
                              style: AppTypography.title.copyWith(fontSize: 18),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Illustration(
                        assetPath: 'assets/images/calendar.svg',
                        semanticLabel: l10n.o5CalendarSemantic,
                        width: 36,
                        height: 36,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.o5DaysPerWeek(draft.reminderDays.length),
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      for (int i = 0; i < 7; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: _DayChip(
                            label: dayLabels[i],
                            selected: draft.reminderDays.contains(i + 1),
                            onTap: () => controller.toggleReminderDay(i + 1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      footer: Column(
        children: [
          PrimaryButton(
            label: l10n.o5RemindMe,
            icon: Icons.notifications_active_outlined,
            shimmer: draft.reminderEnabled,
            trailingArrow: true,
            onPressed: () async {
              controller.setReminderEnabled(true);
              // Permission only when the user opts in (Android 13+ / iOS).
              await ref.read(reminderServiceProvider).requestPermission();
              await controller.completeStep('O5');
              if (context.mounted) {
                context.go(AppRoutes.plan);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(
            label: l10n.o5NotNow,
            onPressed: () async {
              controller.setReminderEnabled(false);
              await controller.completeStep('O5');
              if (context.mounted) {
                context.go(AppRoutes.plan);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// One daily-time option: dots for the number of sessions, title, subtitle.
class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.sessions,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final int sessions;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: PressScale(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.03 : 1,
          duration: const Duration(milliseconds: 260),
          curve: AppMotion.dropCurve,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.mint : AppColors.surface,
              borderRadius: AppRadii.lgAll,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: AppElevation.level1,
            ),
            child: Stack(
              children: [
                if (selected)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < sessions; i++) ...[
                          if (i > 0) const SizedBox(width: 3),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200 + i * 80),
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round weekday toggle that pops when switched on.
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: PressScale(
        onTap: onTap,
        scale: 0.9,
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedScale(
            scale: selected ? 1 : 0.92,
            duration: const Duration(milliseconds: 260),
            curve: AppMotion.dropCurve,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : AppColors.surfaceMuted,
                boxShadow: selected ? AppElevation.level1 : AppElevation.none,
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: selected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
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
