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
import '../../core/content/info_copy.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';
import '../home/home_copy.dart';
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
    int slot = 0;
    Duration next() =>
        AppMotion.stagger(slot++, base: const Duration(milliseconds: 80));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        // Short page: build every row (not lazily) so the staggered
        // entrances and "Delete all my data" are always laid out.
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            bottomInset + AppSpacing.xxl,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Reveal(
              from: RevealFrom.drop,
              child: Row(
                children: [
                  PressScale(
                    onTap: () => context.pop(),
                    semanticLabel: l10n.commonBack,
                    child: Container(
                      width: AppSpacing.minTouchTarget,
                      height: AppSpacing.minTouchTarget,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.x1Title, style: AppTypography.display),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Reveal(
              from: RevealFrom.left,
              delay: next(),
              child: _PlanHero(
                l10n: l10n,
                profile: profile,
                premium: premium,
                onTap: _pickGoal,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (kDebugMode) ...[
              Reveal(
                from: RevealFrom.right,
                delay: next(),
                child: _Section(
                  title: l10n.x1SectionTesting,
                  icon: Icons.bug_report_outlined,
                  children: [
                    _SettingsTile(
                      icon: Icons.workspace_premium_outlined,
                      color: AppColors.goalEjaculationFg,
                      background: AppColors.goalEjaculationBg,
                      label: l10n.x1TestingPremium,
                      trailing: _AnimatedSwitch(
                        value: premium,
                        onChanged: (bool value) {
                          ref.read(isPremiumOverrideProvider.notifier).set(value);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm,
                        AppSpacing.xs,
                        AppSpacing.sm,
                        AppSpacing.xxs,
                      ),
                      child: SecondaryButton(
                        label: l10n.x1TestingReset,
                        icon: Icons.restart_alt_rounded,
                        onPressed: _deleteAllData,
                      ),
                    ),
                    Center(
                      child: TextLinkButton(
                        label: l10n.devDataOpen,
                        onPressed: () => context.push(AppRoutes.dataDebug),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Reveal(
              from: RevealFrom.right,
              delay: next(),
              child: _Section(
                title: l10n.x1SectionPlan,
                icon: Icons.route_rounded,
                children: [
                  _SettingsTile(
                    icon: Icons.flag_rounded,
                    color: AppColors.primary,
                    background: AppColors.mint,
                    label: l10n.x1Goal,
                    value: SettingsCopy.goalLabel(l10n, profile.goal),
                    onTap: _pickGoal,
                  ),
                  _SettingsTile(
                    icon: Icons.schedule_rounded,
                    color: AppColors.goalEjaculationFg,
                    background: AppColors.goalEjaculationBg,
                    label: l10n.x1DailyTime,
                    info: InfoCopy.sessionsPerDay(l10n),
                    value: SettingsCopy.sessionsLabel(
                      l10n,
                      profile.sessionsPerDay,
                    ),
                    onTap: _pickSessions,
                  ),
                  _SettingsTile(
                    icon: Icons.health_and_safety_outlined,
                    color: AppColors.goalSurgeryFg,
                    background: AppColors.goalSurgeryBg,
                    label: l10n.x1SafetyAnswers,
                    info: InfoCopy.safetyWhy(l10n),
                    value: SettingsCopy.safetySummary(l10n, profile.safetyFlags),
                    onTap: () => context.push(AppRoutes.settingsSafety),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Reveal(
              from: RevealFrom.left,
              delay: next(),
              child: _Section(
                title: l10n.x1SectionReminders,
                icon: Icons.notifications_none_rounded,
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_active_outlined,
                    color: AppColors.goalBladderFg,
                    background: AppColors.goalBladderBg,
                    label: l10n.x1DailyReminder,
                    info: InfoCopy.reminders(l10n),
                    trailing: _AnimatedSwitch(
                      value: profile.reminderEnabled,
                      onChanged: _setReminderEnabled,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.access_time_rounded,
                    color: AppColors.goalBladderFg,
                    background: AppColors.goalBladderBg,
                    label: l10n.x1TimeAndDays,
                    value: SettingsCopy.reminderSummary(l10n, profile),
                    onTap: _pickReminderSchedule,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Reveal(
              from: RevealFrom.right,
              delay: next(),
              child: _Section(
                title: l10n.x1SectionSession,
                icon: Icons.play_circle_outline_rounded,
                children: [
                  _SettingsTile(
                    icon: Icons.vibration_rounded,
                    color: AppColors.primary,
                    background: AppColors.mint,
                    label: l10n.x1Vibration,
                    trailing: _AnimatedSwitch(
                      value: profile.vibrationOn,
                      onChanged: (bool value) =>
                          _save(profile.copyWith(vibrationOn: value)),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.record_voice_over_outlined,
                    color: AppColors.primary,
                    background: AppColors.mint,
                    label: l10n.x1Voice,
                    info: InfoCopy.voiceCues(l10n),
                    trailing: _AnimatedSwitch(
                      value: profile.voiceOn,
                      onChanged: (bool value) =>
                          _save(profile.copyWith(voiceOn: value)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Reveal(
              from: RevealFrom.left,
              delay: next(),
              child: _Section(
                title: l10n.x1SectionPrivacy,
                icon: Icons.lock_outline_rounded,
                children: [
                  _SettingsTile(
                    icon: Icons.visibility_off_outlined,
                    color: AppColors.goalSurgeryFg,
                    background: AppColors.goalSurgeryBg,
                    label: l10n.x1Discreet,
                    subtitle: l10n.x1DiscreetSubtitle,
                    trailing: _AnimatedSwitch(
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Reveal(
              from: RevealFrom.right,
              delay: next(),
              child: _Section(
                title: l10n.x1SectionSubscription,
                icon: Icons.workspace_premium_outlined,
                children: [
                  _SettingsTile(
                    icon: Icons.storefront_outlined,
                    color: AppColors.goalEjaculationFg,
                    background: AppColors.goalEjaculationBg,
                    label: _storeManageLabel(l10n),
                    value: premium ? l10n.x1Premium : l10n.x1Free,
                    onTap: _openStore,
                  ),
                  _SettingsTile(
                    icon: Icons.restore_rounded,
                    color: AppColors.goalEjaculationFg,
                    background: AppColors.goalEjaculationBg,
                    label: l10n.x1Restore,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.x1RestoreStub),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Reveal(
              from: RevealFrom.left,
              delay: next(),
              child: _Section(
                title: l10n.x1SectionAbout,
                icon: Icons.info_outline_rounded,
                children: [
                  _SettingsTile(
                    icon: Icons.gavel_rounded,
                    color: AppColors.textSecondary,
                    background: AppColors.surfaceMuted,
                    label: l10n.x1LegalRow,
                    onTap: () => _showLegal(l10n),
                  ),
                  _SettingsTile(
                    icon: Icons.mail_outline_rounded,
                    color: AppColors.textSecondary,
                    background: AppColors.surfaceMuted,
                    label: l10n.x1Contact,
                    value: AppLinks.contactEmail,
                    onTap: () => _openUrl(AppLinks.contactMailto),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Reveal(
              from: RevealFrom.rise,
              delay: next(),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.goalGeneralBg.withValues(alpha: 0.5),
                  borderRadius: AppRadii.lgAll,
                  border: Border.all(
                    color: AppColors.goalGeneralFg.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.x1DeleteMessage,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryButton(
                      label: l10n.x1DeleteAll,
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.goalGeneralFg,
                      onPressed: _deleteAllData,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                l10n.x1VersionFooter(_version.isEmpty ? '—' : _version),
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          ),
        ),
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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: AppRadii.mdAll,
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(l10n.x1LegalRow, style: AppTypography.title),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.o1Disclaimer, style: AppTypography.body),
                const SizedBox(height: AppSpacing.lg),
                SecondaryButton(
                  label: l10n.x1PrivacyPolicy,
                  icon: Icons.privacy_tip_outlined,
                  onPressed: () => _openUrl(AppLinks.privacyPolicy),
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: l10n.x1Terms,
                  icon: Icons.description_outlined,
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

/// Dark summary card: goal, plan track, level and daily sessions.
class _PlanHero extends StatelessWidget {
  const _PlanHero({
    required this.l10n,
    required this.profile,
    required this.premium,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final UserProfile profile;
  final bool premium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool relaxation = profile.track == TrackId.relaxationFirst;
    return PressScale(
      onTap: onTap,
      semanticLabel:
          '${l10n.x1Goal}: ${SettingsCopy.goalLabel(l10n, profile.goal)}',
      child: ClipRRect(
        borderRadius: AppRadii.xlAll,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.sessionBackground,
                AppColors.sessionSurface,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.accent.withValues(alpha: 0.3),
                        AppColors.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FloatBob(
                          lift: 3,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.16),
                              borderRadius: AppRadii.lgAll,
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n
                                    .o6TrackBadge(
                                      HomeCopy.trackName(l10n, profile.track),
                                    )
                                    .toUpperCase(),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                SettingsCopy.goalLabel(l10n, profile.goal),
                                style: AppTypography.title.copyWith(
                                  color: AppColors.sessionText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.edit_outlined,
                          color: AppColors.sessionTextSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (!relaxation)
                          _HeroChip(
                            icon: Icons.emoji_events_outlined,
                            label: l10n.h1LevelName(
                              profile.level,
                              HomeCopy.levelName(l10n, profile.level),
                            ),
                          ),
                        _HeroChip(
                          icon: Icons.schedule_rounded,
                          label: SettingsCopy.sessionsLabel(
                            l10n,
                            profile.sessionsPerDay,
                          ),
                        ),
                        _HeroChip(
                          icon: premium
                              ? Icons.workspace_premium_rounded
                              : Icons.lock_open_rounded,
                          label: premium ? l10n.x1Premium : l10n.x1Free,
                        ),
                      ],
                    ),
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.sessionText.withValues(alpha: 0.08),
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.sessionText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titled group of tiles in one rounded card.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xxs,
            bottom: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                title.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    color: AppColors.border,
                    indent: 64,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One settings row: coloured icon tile, label, value or switch, chevron.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    this.subtitle,
    this.value,
    this.onTap,
    this.trailing,
    this.info,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final InfoContent? info;

  @override
  Widget build(BuildContext context) {
    final Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: background,
                borderRadius: AppRadii.mdAll,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (info != null)
                        InfoButton(content: info!, size: 20, compact: true),
                    ],
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.caption),
                  if (value != null && value!.isNotEmpty)
                    Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
    if (onTap == null) {
      return row;
    }
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// Switch that bounces slightly when toggled.
class _AnimatedSwitch extends StatelessWidget {
  const _AnimatedSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<bool>(value),
      tween: Tween<double>(begin: AppMotion.isReduced(context) ? 1 : 0.85, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: AppMotion.dropCurve,
      builder: (BuildContext context, double s, Widget? child) =>
          Transform.scale(scale: s, child: child),
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        activeThumbColor: AppColors.textOnPrimary,
      ),
    );
  }
}
