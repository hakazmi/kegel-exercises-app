import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/user_profile.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/reminder_service.dart';
import '../../core/time/app_clock.dart';
import 'onboarding_state.dart';

/// Holds draft onboarding answers across O1–O6.
class OnboardingController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void setAcceptedAge(bool value) {
    state = state.copyWith(acceptedAge: value);
  }

  void setGoal(Goal goal) {
    state = state.copyWith(goal: goal);
  }

  void toggleSafety({
    bool? pain,
    bool? painSexual,
    bool? recentSurgery,
    bool? catheter,
    bool? noneOfThese,
  }) {
    if (noneOfThese == true) {
      state = state.copyWith(
        noneOfThese: true,
        pain: false,
        painSexual: false,
        recentSurgery: false,
        catheter: false,
        surgeryConfirmed: false,
      );
      return;
    }

    final bool nextPain = pain ?? state.pain;
    final bool nextPainSexual = painSexual ?? state.painSexual;
    final bool nextSurgery = recentSurgery ?? state.recentSurgery;
    final bool nextCatheter = catheter ?? state.catheter;
    final bool any =
        nextPain || nextPainSexual || nextSurgery || nextCatheter;

    state = state.copyWith(
      noneOfThese: false,
      pain: nextPain,
      painSexual: nextPainSexual,
      recentSurgery: nextSurgery,
      catheter: nextCatheter,
      surgeryConfirmed: nextSurgery ? state.surgeryConfirmed : false,
    );

    if (!any && !state.noneOfThese) {
      // Keep invalid until user picks something; no force to none.
    }
  }

  void setSurgeryConfirmed(bool value) {
    state = state.copyWith(surgeryConfirmed: value);
  }

  void setExperience(Experience experience) {
    state = state.copyWith(experience: experience);
  }

  void setSessionsPerDay(int value) {
    state = state.copyWith(sessionsPerDay: value.clamp(1, 3));
  }

  void setReminderTime(int minutesFromMidnight) {
    state = state.copyWith(reminderTime: minutesFromMidnight);
  }

  void setReminderEnabled(bool value) {
    state = state.copyWith(reminderEnabled: value);
  }

  void toggleReminderDay(int weekday) {
    final Set<int> days = state.reminderDays.toSet();
    if (days.contains(weekday)) {
      if (days.length == 1) {
        return;
      }
      days.remove(weekday);
    } else {
      days.add(weekday);
    }
    final List<int> sorted = days.toList()..sort();
    state = state.copyWith(reminderDays: sorted);
  }

  Future<void> completeStep(String step) {
    return ref.read(analyticsServiceProvider).logEvent(
          'onboarding_step',
          parameters: <String, Object?>{'step': step},
        );
  }

  /// Persists the draft into [UserProfile] and marks onboarding done.
  Future<UserProfile> finish({
    required bool reminderOn,
    bool catheterExit = false,
  }) async {
    final OnboardingDraft draft = state.copyWith(reminderEnabled: reminderOn);
    final DateTime now = dateOnly(ref.read(appClockProvider).now());
    final TrackId track = draft.resolveTrack();

    final UserProfile profile = UserProfile.initial().copyWith(
      goal: draft.goal ?? Goal.generalPelvicHealth,
      safetyFlags: draft.safetyFlags,
      experience: draft.experience ?? Experience.none,
      sessionsPerDay: draft.sessionsPerDay,
      reminderEnabled: reminderOn,
      reminderTime: draft.reminderTime,
      reminderDays: draft.reminderDays,
      track: track,
      level: 1,
      levelStartedOn: now,
      onboardingDone: true,
      tutorialDone: false,
    );

    await ref.read(userProfileProvider.notifier).save(profile);

    // Schedule after profile is saved so loadInput sees reminderEnabled.
    if (reminderOn) {
      await ref.read(reminderServiceProvider).enableReminder(
            minutesFromMidnight: draft.reminderTime,
            days: draft.reminderDays,
          );
    } else {
      await ref.read(reminderServiceProvider).disableReminder();
    }

    if (!catheterExit) {
      await ref.read(analyticsServiceProvider).logEvent(
            'onboarding_done',
            parameters: <String, Object?>{
              'sessions_per_day': profile.sessionsPerDay,
              'reminder_on': reminderOn,
            },
          );
    }

    state = draft;
    return profile;
  }

  void reset() {
    state = const OnboardingDraft();
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingDraft>(
  OnboardingController.new,
);
