import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/constants/links.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/user_profile.dart';
import '../../core/services/reminder_service.dart';
import '../../core/widgets/widgets.dart';
import '../onboarding/onboarding_controller.dart';
import 'settings_copy.dart';

/// X1 Settings — plan, reminders, session, privacy, subscription, about.
class X1SettingsScreen extends ConsumerStatefulWidget {
  const X1SettingsScreen({super.key});

  @override
  ConsumerState<X1SettingsScreen> createState() => _X1SettingsScreenState();
}

class _X1SettingsScreenState extends ConsumerState<X1SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (!mounted) {
        return;
      }
      setState(() => _version = info.version);
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _version = '1.0.0');
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _save(UserProfile next) async {
    await ref.read(userProfileProvider.notifier).save(next);
    ref.invalidate(todayPlanProvider);
  }

  Future<void> _setReminderEnabled(bool enabled) async {
    final UserProfile profile = ref.read(userProfileProvider);
    final ReminderService reminders = ref.read(reminderServiceProvider);
    final UserProfile next = profile.copyWith(reminderEnabled: enabled);
    await _save(next);
    if (enabled) {
      await reminders.enableReminder(
        minutesFromMidnight: next.reminderTime,
        days: next.reminderDays,
      );
    } else {
      await reminders.disableReminder();
    }
  }

  Future<void> _deleteAllData() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await ConfirmDialog.show(
      context,
      title: l10n.x1DeleteTitle,
      message: l10n.x1DeleteMessage,
      confirmLabel: l10n.x1DeleteConfirm,
      cancelLabel: l10n.commonCancel,
    );
    if (!ok) {
      return;
    }
    await ref.read(reminderServiceProvider).disableReminder();
    await ref.read(dataResetServiceProvider).deleteEverything();
    ref.read(onboardingControllerProvider.notifier).reset();
    ref.invalidate(sessionsProvider);
    ref.invalidate(checkInsProvider);
    await ref.read(userProfileProvider.notifier).reload();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.welcome);
  }

  Future<void> _pickGoal() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.read(userProfileProvider);
    final Goal? selected = await showModalBottomSheet<Goal>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.x1GoalTitle, style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                for (final Goal goal in Goal.values) ...[
                  SelectableCard(
                    title: SettingsCopy.goalLabel(l10n, goal),
                    selected: profile.goal == goal,
                    onTap: () => Navigator.of(sheetContext).pop(goal),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) {
      return;
    }
    final UserProfile current = ref.read(userProfileProvider);
    TrackId track = current.track;
    if (!current.safetyFlags.pain && !current.safetyFlags.painSexual) {
      track = trackForGoal(selected);
    }
    await _save(current.copyWith(goal: selected, track: track));
  }

  Future<void> _pickSessions() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.read(userProfileProvider);
    final int? selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.x1DailyTimeTitle, style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                for (final int n in <int>[1, 2, 3]) ...[
                  SelectableCard(
                    title: l10n.x1DailySessions(n),
                    selected: profile.sessionsPerDay == n,
                    onTap: () => Navigator.of(sheetContext).pop(n),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) {
      return;
    }
    await _save(profile.copyWith(sessionsPerDay: selected));
  }

  Future<void> _pickReminderSchedule() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.read(userProfileProvider);
    TimeOfDay time = TimeOfDay(
      hour: profile.reminderTime ~/ 60,
      minute: profile.reminderTime % 60,
    );
    final Set<int> days = profile.reminderDays.toSet();

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.x1ReminderScheduleTitle, style: AppTypography.title),
                    const SizedBox(height: AppSpacing.md),
                    SecondaryButton(
                      label: SettingsCopy.formatTime(
                        time.hour * 60 + time.minute,
                      ),
                      onPressed: () async {
                        final TimeOfDay? next = await showTimePicker(
                          context: context,
                          initialTime: time,
                        );
                        if (next != null) {
                          setModalState(() => time = next);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final int day in <int>[1, 2, 3, 4, 5, 6, 7])
                          FilterChip(
                            label: Text(_weekdayShort(l10n, day)),
                            selected: days.contains(day),
                            onSelected: (bool selected) {
                              setModalState(() {
                                if (selected) {
                                  days.add(day);
                                } else if (days.length > 1) {
                                  days.remove(day);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: l10n.commonConfirm,
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (saved != true) {
      return;
    }
    final int minutes = time.hour * 60 + time.minute;
    final List<int> sortedDays = days.toList()..sort();
    final UserProfile next = profile.copyWith(
      reminderTime: minutes,
      reminderDays: sortedDays,
    );
    await _save(next);
    if (next.reminderEnabled) {
      await ref.read(reminderServiceProvider).reschedule();
    }
  }

  String _weekdayShort(AppLocalizations l10n, int day) {
    switch (day) {
      case 1:
        return l10n.h1WeekMon;
      case 2:
        return l10n.h1WeekTue;
      case 3:
        return l10n.h1WeekWed;
      case 4:
        return l10n.h1WeekThu;
      case 5:
        return l10n.h1WeekFri;
      case 6:
        return l10n.h1WeekSat;
      default:
        return l10n.h1WeekSun;
    }
  }

  String _storeManageLabel(AppLocalizations l10n) {
    if (!kIsWeb && Platform.isIOS) {
      return l10n.x1ManageAppStore;
    }
    return l10n.x1ManagePlay;
  }

  Future<void> _openStore() async {
    final String url =
        (!kIsWeb && Platform.isIOS) ? AppLinks.appStore : AppLinks.playStore;
    await _openUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final bool premium = ref.watch(isPremiumProvider);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.commonBack,
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          bottomInset + AppSpacing.xxl,
        ),
        children: [
          Text(l10n.x1Title, style: AppTypography.display),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.x1SectionPlan),
          AppCard(
            child: Column(
              children: [
                _NavRow(
                  label: l10n.x1Goal,
                  value: SettingsCopy.goalLabel(l10n, profile.goal),
                  onTap: _pickGoal,
                ),
                const Divider(height: 1, color: AppColors.border),
                _NavRow(
                  label: l10n.x1DailyTime,
                  value: SettingsCopy.sessionsLabel(l10n, profile.sessionsPerDay),
                  onTap: _pickSessions,
                ),
                const Divider(height: 1, color: AppColors.border),
                _NavRow(
                  label: l10n.x1SafetyAnswers,
                  value: SettingsCopy.safetySummary(l10n, profile.safetyFlags),
                  onTap: () => context.push(AppRoutes.settingsSafety),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.x1SectionReminders),
          AppCard(
            child: Column(
              children: [
                _SwitchRow(
                  label: l10n.x1DailyReminder,
                  value: profile.reminderEnabled,
                  onChanged: _setReminderEnabled,
                ),
                const Divider(height: 1, color: AppColors.border),
                _NavRow(
                  label: l10n.x1TimeAndDays,
                  value: SettingsCopy.reminderSummary(l10n, profile),
                  onTap: _pickReminderSchedule,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.x1SectionSession),
          AppCard(
            child: Column(
              children: [
                _SwitchRow(
                  label: l10n.x1Vibration,
                  value: profile.vibrationOn,
                  onChanged: (bool value) =>
                      _save(profile.copyWith(vibrationOn: value)),
                ),
                const Divider(height: 1, color: AppColors.border),
                _SwitchRow(
                  label: l10n.x1Voice,
                  value: profile.voiceOn,
                  onChanged: (bool value) =>
                      _save(profile.copyWith(voiceOn: value)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.x1SectionPrivacy),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SwitchRow(
                  label: l10n.x1Discreet,
                  subtitle: l10n.x1DiscreetSubtitle,
                  value: profile.discreetNotifications,
                  onChanged: (bool value) async {
                    await _save(
                      profile.copyWith(discreetNotifications: value),
                    );
                    if (ref.read(userProfileProvider).reminderEnabled) {
                      await ref.read(reminderServiceProvider).reschedule();
                    }
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: TextLinkButton(
                    label: l10n.x1DeleteAll,
                    color: AppColors.streakFg,
                    onPressed: _deleteAllData,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.x1SectionSubscription),
          AppCard(
            child: Column(
              children: [
                _NavRow(
                  label: _storeManageLabel(l10n),
                  value: premium ? l10n.x1Premium : l10n.x1Free,
                  onTap: _openStore,
                ),
                const Divider(height: 1, color: AppColors.border),
                _NavRow(
                  label: l10n.x1Restore,
                  value: '',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.x1RestoreStub)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.x1SectionAbout),
          AppCard(
            child: Column(
              children: [
                _NavRow(
                  label: l10n.x1LegalRow,
                  value: '',
                  onTap: () => _showLegal(l10n),
                ),
                const Divider(height: 1, color: AppColors.border),
                _NavRow(
                  label: l10n.x1Contact,
                  value: AppLinks.contactEmail,
                  onTap: () => _openUrl(AppLinks.contactMailto),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              l10n.x1VersionFooter(
                _version.isEmpty ? '—' : _version,
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLegal(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.x1LegalRow, style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.o1Disclaimer, style: AppTypography.body),
                const SizedBox(height: AppSpacing.lg),
                SecondaryButton(
                  label: l10n.x1PrivacyPolicy,
                  onPressed: () => _openUrl(AppLinks.privacyPolicy),
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: l10n.x1Terms,
                  onPressed: () => _openUrl(AppLinks.terms),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (value.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
