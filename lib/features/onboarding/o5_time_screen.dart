import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/services/reminder_service.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';
import 'widgets/onboarding_scaffold.dart';

/// O5 Time and reminder.
class O5TimeScreen extends ConsumerWidget {
  const O5TimeScreen({super.key});

  String _formatTime(int minutesFromMidnight) {
    final int hour24 = minutesFromMidnight ~/ 60;
    final int minute = minutesFromMidnight % 60;
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final String period = hour24 >= 12 ? 'pm' : 'am';
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
          Text(l10n.o5Title, style: AppTypography.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.o5Subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  title: l10n.o5Option1Title,
                  subtitle: l10n.o5Option1Subtitle,
                  selected: draft.sessionsPerDay == 1,
                  onTap: () => controller.setSessionsPerDay(1),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _TimeCard(
                  title: l10n.o5Option2Title,
                  subtitle: l10n.o5Option2Subtitle,
                  selected: draft.sessionsPerDay == 2,
                  onTap: () => controller.setSessionsPerDay(2),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _TimeCard(
                  title: l10n.o5Option3Title,
                  subtitle: l10n.o5Option3Subtitle,
                  selected: draft.sessionsPerDay == 3,
                  onTap: () => controller.setSessionsPerDay(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.o5ReminderTitle, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xxs),
                Text(l10n.o5ReminderHint, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: () => _pickTime(context, controller, draft),
                  borderRadius: AppRadii.pillAll,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: AppRadii.pillAll,
                    ),
                    child: Row(
                      children: [
                        Text(l10n.o5TimeLabel, style: AppTypography.body),
                        const Spacer(),
                        Text(
                          _formatTime(draft.reminderTime),
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Icon(Icons.chevron_right),
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
        ],
      ),
      footer: Column(
        children: [
          PrimaryButton(
            label: l10n.o5RemindMe,
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

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: Container(
          constraints:
              const BoxConstraints(minHeight: AppSpacing.minTouchTarget * 1.5),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: selected ? AppColors.borderStrong : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption
                    .copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.primary : AppColors.surfaceMuted,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
