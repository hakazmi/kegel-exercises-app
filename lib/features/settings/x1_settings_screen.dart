import 'dart:io' show Platform;

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User, UserIdentity;
import 'package:url_launcher/url_launcher.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/cloud/auth_repository.dart';
import '../../core/cloud/cloud_config.dart';
import '../../core/cloud/cloud_providers.dart';
import '../../core/cloud/sync_coordinator.dart';
import '../../core/cloud/sync_metadata_store.dart';
import '../../core/constants/links.dart';
import '../../core/data/providers.dart';
import '../../core/diagnostics/crash_reporting.dart';
import '../../core/diagnostics/performance_traces.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/user_profile.dart';
import '../../core/entitlements/app_entitlements.dart';
import '../../core/plan/goal_routing.dart';
import '../../core/services/analytics_service.dart';
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
    try {
      if (enabled) {
        await reminders.enableReminder(
          minutesFromMidnight: next.reminderTime,
          days: next.reminderDays,
        );
      } else {
        await reminders.disableReminder();
      }
      CrashReporting.log('reminder: ${enabled ? 'on' : 'off'}');
      await ref.read(analyticsServiceProvider).logEvent(
            'reminder_change',
            parameters: <String, Object?>{'on': enabled},
          );
    } on Object catch (e, st) {
      CrashReporting.log('reminder: schedule fail');
      await CrashReporting.record(e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> _resetAllData() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool signedIn = ref.read(authRepositoryProvider).isSignedIn;
    final bool ok = await ConfirmDialog.show(
      context,
      title: l10n.x1DeleteTitle,
      message: signedIn
          ? '${l10n.x1DeleteMessage}\n\nThis also erases your cloud backup. Your account stays signed in.'
          : l10n.x1DeleteMessage,
      confirmLabel: l10n.x1DeleteConfirm,
      cancelLabel: l10n.commonCancel,
    );
    if (!ok) {
      return;
    }
    final Trace? actionTrace = PerfTraces.start('account_action');
    PerfTraces.putAttribute(actionTrace, 'action', 'reset');
    CrashReporting.log('account: reset start');
    if (signedIn) {
      final result = await ref.read(syncRepositoryProvider).resetCloudData();
      if (!result.ok && mounted) {
        PerfTraces.abandon(actionTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Couldn’t erase cloud data.'),
          ),
        );
        return;
      }
    }
    await ref.read(reminderServiceProvider).disableReminder();
    await ref.read(dataResetServiceProvider).deleteEverything();
    ref.read(onboardingControllerProvider.notifier).reset();
    ref.invalidate(sessionsProvider);
    ref.invalidate(checkInsProvider);
    await ref.read(userProfileProvider.notifier).reload();
    CrashReporting.log('account: reset done');
    await PerfTraces.stop(actionTrace);
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.welcome);
  }

  /// Debug / legacy alias.
  Future<void> _deleteAllData() => _resetAllData();

  Future<void> _signOut() async {
    final SyncCoordinator sync = ref.read(syncCoordinatorProvider);
    final int pending = await sync.pendingCount();
    await sync.flushBeforeSignOut();
    final int still = await sync.pendingCount();
    if (still > 0 && mounted) {
      final bool ok = await ConfirmDialog.show(
        context,
        title: 'Sign out?',
        message:
            '$pending changes haven’t backed up. Sign out anyway?',
        confirmLabel: 'Sign out',
        cancelLabel: 'Cancel',
      );
      if (!ok) {
        return;
      }
    } else if (mounted) {
      final bool ok = await ConfirmDialog.show(
        context,
        title: 'Sign out?',
        message: 'You’ll need to sign in again to sync.',
        confirmLabel: 'Sign out',
        cancelLabel: 'Cancel',
      );
      if (!ok) {
        return;
      }
    }
    sync.cancelPending();
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.auth);
  }

  Future<void> _deleteAccount() async {
    final bool ok = await ConfirmDialog.show(
      context,
      title: 'Delete account?',
      message:
          'This permanently deletes your account and all cloud data, and clears this phone. Type DELETE to confirm on the next step.',
      confirmLabel: 'Continue',
      cancelLabel: 'Cancel',
    );
    if (!ok || !mounted) {
      return;
    }
    final TextEditingController controller = TextEditingController();
    final bool? typed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Type DELETE'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'DELETE'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, controller.text.trim() == 'DELETE'),
              child: const Text('Delete account'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (typed != true) {
      return;
    }
    final Trace? actionTrace = PerfTraces.start('account_action');
    PerfTraces.putAttribute(actionTrace, 'action', 'delete');
    CrashReporting.log('account: delete start');
    final result = await ref.read(syncRepositoryProvider).deleteAccount();
    if (!result.ok && mounted) {
      PerfTraces.abandon(actionTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Couldn’t delete account.'),
        ),
      );
      return;
    }
    ref.read(syncCoordinatorProvider).cancelPending();
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(reminderServiceProvider).disableReminder();
    await ref
        .read(dataResetServiceProvider)
        .deleteEverything(clearAuthHint: true);
    ref.read(onboardingControllerProvider.notifier).reset();
    ref.invalidate(sessionsProvider);
    ref.invalidate(checkInsProvider);
    await ref.read(userProfileProvider.notifier).reload();
    CrashReporting.setKey('signed_in', false);
    CrashReporting.log('account: delete done');
    await PerfTraces.stop(actionTrace);
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.auth);
  }

  Future<void> _backupNow() async {
    final result = await ref.read(syncCoordinatorProvider).backupNow();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.ok
              ? 'Backup complete.'
              : (result.errorMessage ?? 'Backup failed.'),
        ),
      ),
    );
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
    final DateTime now = ref.read(appClockProvider).now();
    final UserProfile next = GoalRouting.apply(
      profile: current,
      goal: selected,
      now: now,
    );
    await _save(next);
    if (next.track != current.track &&
        next.reminderEnabled &&
        mounted) {
      await ref.read(reminderServiceProvider).reschedule();
    }
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
    final bool signedIn =
        CloudConfig.isConfigured && ref.watch(isSignedInProvider);
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
            if (signedIn) ...[
              Reveal(
                from: RevealFrom.drop,
                delay: next(),
                child: const _ProfileHeader(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
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
            if (!kAppFullyFree) ...[
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
            ],
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
            if (kDebugMode) ...[
              const SizedBox(height: AppSpacing.md),
              Reveal(
                from: RevealFrom.right,
                delay: next(),
                child: _Section(
                  title: l10n.x1SectionTesting,
                  icon: Icons.bug_report_outlined,
                  children: [
                    if (!kAppFullyFree)
                      _SettingsTile(
                        icon: Icons.workspace_premium_outlined,
                        color: AppColors.goalEjaculationFg,
                        background: AppColors.goalEjaculationBg,
                        label: l10n.x1TestingPremium,
                        trailing: _AnimatedSwitch(
                          value: premium,
                          onChanged: (bool value) {
                            ref
                                .read(isPremiumOverrideProvider.notifier)
                                .set(value);
                          },
                        ),
                      ),
                    _SettingsTile(
                      icon: Icons.storage_rounded,
                      color: AppColors.textSecondary,
                      background: AppColors.surfaceMuted,
                      label: l10n.devDataOpen,
                      onTap: () => context.push(AppRoutes.dataDebug),
                    ),
                  ],
                ),
              ),
            ],
            if (signedIn) ...[
              const SizedBox(height: AppSpacing.md),
              Reveal(
                from: RevealFrom.left,
                delay: next(),
                child: _AccountSection(
                  onBackup: _backupNow,
                  onDeleteAccount: _deleteAccount,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Reveal(
              from: RevealFrom.rise,
              delay: next(),
              child: _BottomActions(
                resetLabel: signedIn ? 'Reset all my data' : l10n.x1DeleteAll,
                onReset: _deleteAllData,
                onSignOut: signedIn ? _signOut : null,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                        if (!kAppFullyFree)
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

/// Signed-in identity read from the auth user and local sync metadata.
class _AccountInfo {
  const _AccountInfo({
    required this.name,
    required this.email,
    required this.google,
    required this.avatarUrl,
  });

  factory _AccountInfo.read(WidgetRef ref) {
    final AuthRepository auth = ref.watch(authRepositoryProvider);
    final SyncMetadataStore meta = ref.watch(syncMetadataStoreProvider);
    final User? user = auth.currentUser;
    final Map<String, dynamic> data = user?.userMetadata ?? <String, dynamic>{};
    final String? metaName = meta.displayName?.trim();
    final String? authName =
        (data['full_name'] ?? data['name']) as String?;
    final String name = (metaName?.isNotEmpty ?? false)
        ? metaName!
        : (authName?.trim().isNotEmpty ?? false)
        ? authName!.trim()
        : '';
    final bool google = user?.appMetadata['provider'] == 'google' ||
        (user?.identities?.any((UserIdentity i) => i.provider == 'google') ??
            false);
    return _AccountInfo(
      name: name,
      email: user?.email ?? '',
      google: google,
      avatarUrl: (data['avatar_url'] ?? data['picture']) as String?,
    );
  }

  final String name;
  final String email;
  final bool google;
  final String? avatarUrl;

  String get title => name.isNotEmpty ? name : email;

  String get initials {
    final String source = name.isNotEmpty ? name : email;
    final List<String> parts = source
        .split(RegExp(r'[\s@._-]+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1 || name.isEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Account card at the top of Settings: avatar, name, email, sign-in method.
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _AccountInfo info = _AccountInfo.read(ref);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          _Avatar(info: info, size: 60),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(letterSpacing: -0.3),
                ),
                if (info.name.isNotEmpty && info.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    info.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                _ProviderChip(google: info.google),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Round avatar: Google photo when available, otherwise initials.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.info, required this.size});

  final _AccountInfo info;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget initials = Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.accent, AppColors.primary],
        ),
      ),
      child: Text(
        info.initials,
        style: AppTypography.title.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: size * 0.36,
        ),
      ),
    );
    final String? url = info.avatarUrl;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.mint, width: 2),
      ),
      child: ClipOval(
        child: url == null || url.isEmpty
            ? initials
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object e, StackTrace? s) =>
                    initials,
              ),
      ),
    );
  }
}

/// "Google" or "Email" sign-in method tag.
class _ProviderChip extends StatelessWidget {
  const _ProviderChip({required this.google});

  final bool google;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (google)
            SvgPicture.asset(
              'assets/images/google_g.svg',
              width: 12,
              height: 12,
              excludeFromSemantics: true,
            )
          else
            const Icon(
              Icons.mail_outline_rounded,
              size: 13,
              color: AppColors.textSecondary,
            ),
          const SizedBox(width: 6),
          Text(
            google ? 'Signed in with Google' : 'Signed in with email',
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsed Account card at the end of Settings; tap to reveal backup
/// status, "Back up now" and "Delete account".
class _AccountSection extends ConsumerStatefulWidget {
  const _AccountSection({
    required this.onBackup,
    required this.onDeleteAccount,
  });

  final VoidCallback onBackup;
  final VoidCallback onDeleteAccount;

  @override
  ConsumerState<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<_AccountSection> {
  bool _open = false;

  static String _syncLabel(String? iso) {
    final DateTime? at = iso == null ? null : DateTime.tryParse(iso);
    if (at == null) {
      return 'Not backed up yet';
    }
    return 'Last backup ${DateFormat.MMMd().add_jm().format(at.toLocal())}';
  }

  @override
  Widget build(BuildContext context) {
    final _AccountInfo info = _AccountInfo.read(ref);
    final SyncMetadataStore meta = ref.watch(syncMetadataStoreProvider);
    final String? lastError = meta.lastError;
    final bool issue = lastError != null;

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
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'ACCOUNT',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => setState(() => _open = !_open),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        _Avatar(info: info, size: 40),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account and backup',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                info.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 240),
                sizeCurve: Curves.easeOutCubic,
                crossFadeState: _open
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1, color: AppColors.border),
                    _SettingsTile(
                      icon: issue
                          ? Icons.cloud_off_outlined
                          : Icons.cloud_done_outlined,
                      color: issue
                          ? _dangerColor
                          : AppColors.goalSurgeryFg,
                      background: issue
                          ? const Color(0xFFFFF1F4)
                          : AppColors.goalSurgeryBg,
                      label: issue ? 'Backup issue' : 'Cloud backup',
                      subtitle: lastError ?? _syncLabel(meta.lastSyncIso),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                      indent: 64,
                    ),
                    _SettingsTile(
                      icon: Icons.cloud_upload_outlined,
                      color: AppColors.primary,
                      background: AppColors.mint,
                      label: 'Back up now',
                      onTap: widget.onBackup,
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                      indent: 64,
                    ),
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      color: _dangerColor,
                      background: const Color(0xFFFFF1F4),
                      label: 'Delete account',
                      subtitle: 'Removes your account and cloud backup',
                      onTap: widget.onDeleteAccount,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Text(
                        'Backed up: plan, sessions, habits, walking, hold tests, '
                        'check-ins, reminders. Never leaves this phone: safety '
                        'answers, session feel.',
                        style: AppTypography.caption.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const Color _dangerColor = Color(0xFFB42318);

/// Bottom of Settings: reset data and, when signed in, sign out.
class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.resetLabel,
    required this.onReset,
    required this.onSignOut,
  });

  final String resetLabel;
  final VoidCallback onReset;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = <Widget>[
      _ActionPill(
        label: resetLabel,
        icon: Icons.restart_alt_rounded,
        color: AppColors.goalGeneralFg,
        background: AppColors.goalGeneralBg,
        onTap: onReset,
      ),
      if (onSignOut != null)
        _ActionPill(
          label: 'Sign out',
          icon: Icons.logout_rounded,
          color: _dangerColor,
          background: const Color(0xFFFFF1F4),
          onTap: onSignOut!,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          buttons[i],
        ],
      ],
    );
  }
}

/// Full-width tinted action button with a leading icon.
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadii.pillAll,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.button.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

