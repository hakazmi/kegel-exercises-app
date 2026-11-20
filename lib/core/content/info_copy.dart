import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../domain/enums.dart';
import '../widgets/info_sheet.dart';
import 'content_models.dart';

/// Builds the "i" explanations used across the app. All text is in the ARB
/// file; exercise names and descriptions come from `exercises.json`.
abstract final class InfoCopy {
  /// Cue string for an ARB key listed in an exercise's `cues`.
  static String? cue(AppLocalizations l10n, String key) {
    return switch (key) {
      'exCueButtocksRelaxed' => l10n.exCueButtocksRelaxed,
      'exCueKeepBreathing' => l10n.exCueKeepBreathing,
      'exCueLegsLift' => l10n.exCueLegsLift,
      'exCueReverseLetGo' => l10n.exCueReverseLetGo,
      'exHabitAfterDribbleSteps' => l10n.exHabitAfterDribbleSteps,
      'exHabitUrgeControlSteps' => l10n.exHabitUrgeControlSteps,
      'exWalkingCardioNote' => l10n.exWalkingCardioNote,
      'exWalkingDoctorNote' => l10n.exWalkingDoctorNote,
      _ => null,
    };
  }

  /// Why the exercise is in the plan (patient-guidance wording, no promises).
  static String? why(AppLocalizations l10n, String exerciseId) {
    return switch (exerciseId) {
      'slow_hold' => l10n.infoWhySlowHold,
      'quick_squeeze' => l10n.infoWhyQuickSqueeze,
      'strong_hold' => l10n.infoWhyStrongHold,
      'standing_walking_holds' => l10n.infoWhyStandingHolds,
      'bridge_with_hold' => l10n.infoWhyBridge,
      'squat_with_coordination' => l10n.infoWhySquat,
      'sit_to_stand_squeeze' => l10n.infoWhySitToStand,
      'the_knack' => l10n.infoWhyKnack,
      'pillow_squeeze_lift' => l10n.infoWhyPillowSqueeze,
      'diaphragmatic_breathing' => l10n.infoWhyBreathing,
      'reverse_kegel' => l10n.infoWhyReverseKegel,
      'childs_pose' ||
      'happy_baby' ||
      'supported_back_release' =>
        l10n.infoWhyStretch,
      'after_dribble_squeeze' => l10n.infoWhyAfterDribble,
      'urge_control_squeeze' => l10n.infoWhyUrgeControl,
      'brisk_walking' => l10n.infoWhyWalking,
      _ => null,
    };
  }

  /// Explanation of one exercise: what it is, how to do it, why it is here.
  static InfoContent exercise(AppLocalizations l10n, ExerciseContent ex) {
    final List<String> points = <String>[
      for (final String key in ex.cues)
        if (cue(l10n, key) case final String text) text,
    ];
    final String? reason = why(l10n, ex.id);
    final ({IconData icon, Color bg, Color fg}) style = _styleForType(ex.type);
    return InfoContent(
      title: ex.name,
      body: '${ex.description}.',
      points: points,
      note: reason,
      icon: style.icon,
      iconBackground: style.bg,
      iconForeground: style.fg,
    );
  }

  static ({IconData icon, Color bg, Color fg}) _styleForType(String type) {
    return switch (type) {
      'function' => (
          icon: Icons.accessibility_new_rounded,
          bg: AppColors.goalBladderBg,
          fg: AppColors.goalBladderFg,
        ),
      'relaxation' => (
          icon: Icons.spa_outlined,
          bg: AppColors.goalSurgeryBg,
          fg: AppColors.goalSurgeryFg,
        ),
      'habit' => (
          icon: Icons.repeat_rounded,
          bg: AppColors.mint,
          fg: AppColors.primary,
        ),
      'activity' => (
          icon: Icons.directions_walk_rounded,
          bg: AppColors.goalBladderBg,
          fg: AppColors.goalBladderFg,
        ),
      _ => (
          icon: Icons.adjust_rounded,
          bg: AppColors.mint,
          fg: AppColors.primary,
        ),
    };
  }

  /// What a Today card is for, by kind. [exerciseNames] lists body moves.
  static InfoContent todayKind(
    AppLocalizations l10n,
    SessionKind kind, {
    List<String> exerciseNames = const <String>[],
  }) {
    switch (kind) {
      case SessionKind.strengthening:
        return InfoContent(
          title: l10n.infoPelvicTitle,
          body: l10n.infoPelvicBody,
          points: <String>[
            l10n.exCueButtocksRelaxed,
            l10n.exCueKeepBreathing,
            l10n.s3CueGentle,
          ],
          icon: Icons.adjust_rounded,
        );
      case SessionKind.body:
        return InfoContent(
          title: l10n.h1BodyCardTitle,
          body: l10n.infoBodyBody,
          points: exerciseNames,
          icon: Icons.accessibility_new_rounded,
          iconBackground: AppColors.goalBladderBg,
          iconForeground: AppColors.goalBladderFg,
        );
      case SessionKind.breathing:
      case SessionKind.relaxation:
        return InfoContent(
          title: l10n.h1SectionBreathe,
          body: l10n.infoBreatheBody,
          points: exerciseNames,
          icon: Icons.air_rounded,
          iconBackground: AppColors.goalSurgeryBg,
          iconForeground: AppColors.goalSurgeryFg,
        );
    }
  }

  static InfoContent habits(AppLocalizations l10n) => InfoContent(
        title: l10n.h1SectionHabits,
        body: l10n.infoHabitsBody,
        icon: Icons.repeat_rounded,
      );

  static InfoContent restDay(AppLocalizations l10n) => InfoContent(
        title: l10n.infoRestTitle,
        body: l10n.infoRestBody,
        icon: Icons.nightlight_round,
        iconBackground: AppColors.goalSurgeryBg,
        iconForeground: AppColors.goalSurgeryFg,
      );

  static InfoContent streak(AppLocalizations l10n) => InfoContent(
        title: l10n.g1StatStreakLabel,
        body: l10n.infoStreakBody,
        icon: Icons.local_fire_department_outlined,
        iconBackground: AppColors.streakBg,
        iconForeground: AppColors.streakFg,
      );

  static InfoContent weekRing(AppLocalizations l10n) => InfoContent(
        title: l10n.g1StatWeekLabel,
        body: l10n.infoWeekRingBody,
        icon: Icons.event_available_rounded,
      );

  static InfoContent longestHold(AppLocalizations l10n) => InfoContent(
        title: l10n.g1StatHoldLabel,
        body: l10n.infoHoldBody,
        icon: Icons.timer_outlined,
        iconBackground: AppColors.goalEjaculationBg,
        iconForeground: AppColors.goalEjaculationFg,
      );

  static InfoContent levels(AppLocalizations l10n) => InfoContent(
        title: l10n.infoLevelsTitle,
        body: l10n.infoLevelsBody,
        icon: Icons.emoji_events_outlined,
        iconBackground: AppColors.goalSurgeryBg,
        iconForeground: AppColors.goalSurgeryFg,
      );

  static InfoContent checkIn(AppLocalizations l10n) => InfoContent(
        title: l10n.infoCheckInTitle,
        body: l10n.infoCheckInBody,
        icon: Icons.insights_rounded,
        note: l10n.g2PrivacyNote,
      );

  static InfoContent walking(AppLocalizations l10n) => InfoContent(
        title: l10n.g1WalkingTitle,
        body: l10n.exWalkingCardioNote,
        points: <String>[l10n.g1WalkingGoal],
        note: l10n.exWalkingDoctorNote,
        icon: Icons.directions_walk_rounded,
        iconBackground: AppColors.goalBladderBg,
        iconForeground: AppColors.goalBladderFg,
      );

  static InfoContent goal(AppLocalizations l10n, Goal goal) {
    final String body = switch (goal) {
      Goal.bladderControl => l10n.infoGoalBladder,
      Goal.erectionSupport => l10n.infoGoalErection,
      Goal.ejaculationControl => l10n.infoGoalEjaculation,
      Goal.recoveryAfterProstateSurgery => l10n.infoGoalSurgery,
      Goal.generalPelvicHealth => l10n.infoGoalGeneral,
    };
    return InfoContent(
      title: l10n.infoGoalTitle,
      body: body,
      icon: Icons.route_rounded,
      note: l10n.infoGoalNote,
    );
  }

  static InfoContent safetyWhy(AppLocalizations l10n) => InfoContent(
        title: l10n.infoSafetyTitle,
        body: l10n.infoSafetyBody,
        icon: Icons.health_and_safety_outlined,
        iconBackground: AppColors.goalSurgeryBg,
        iconForeground: AppColors.goalSurgeryFg,
        note: l10n.g2PrivacyNote,
      );

  static InfoContent kegel(AppLocalizations l10n) => InfoContent(
        title: l10n.infoKegelTitle,
        body: l10n.infoKegelBody,
        points: <String>[l10n.exCueButtocksRelaxed, l10n.exCueKeepBreathing],
        icon: Icons.adjust_rounded,
      );

  static InfoContent reminders(AppLocalizations l10n) => InfoContent(
        title: l10n.infoRemindersTitle,
        body: l10n.infoRemindersBody,
        icon: Icons.notifications_none_rounded,
      );

  static InfoContent voiceCues(AppLocalizations l10n) => InfoContent(
        title: l10n.x1Voice,
        body: l10n.infoVoiceBody,
        icon: Icons.record_voice_over_outlined,
      );

  static InfoContent sessionsPerDay(AppLocalizations l10n) => InfoContent(
        title: l10n.x1DailyTime,
        body: l10n.infoSessionsBody,
        icon: Icons.schedule_rounded,
      );
}
