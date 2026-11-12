// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kegel Exercises';

  @override
  String get tabToday => 'Today';

  @override
  String get tabProgress => 'Progress';

  @override
  String get tabLearn => 'Learn';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String placeholderScreen(String id, String name) {
    return '$id · $name';
  }

  @override
  String get placeholderHint => 'Placeholder — real UI comes in later steps.';

  @override
  String get devGalleryTitle => 'Widget gallery';

  @override
  String get devGalleryOpen => 'Open widget gallery';

  @override
  String get devDataTitle => 'Data debug';

  @override
  String get devDataOpen => 'Open data debug';

  @override
  String get o1Title => 'Train your pelvic floor in a few minutes a day';

  @override
  String get o1Body =>
      'Guided exercises for bladder control and pelvic health. No equipment.';

  @override
  String get o1BulletPlan => 'A plan that grows with you, level by level';

  @override
  String get o1BulletDiscreet => 'Discreet: train anywhere, nobody can tell';

  @override
  String get o1BulletPrivate => 'Private: your data stays on this phone';

  @override
  String get o1AgeCheckbox => 'I am 18 or older';

  @override
  String get o1Disclaimer =>
      'This app is not a medical device and does not diagnose, treat, cure or prevent any medical condition. Talk to a healthcare professional for medical advice.';

  @override
  String get o1GetStarted => 'Get started';

  @override
  String get o1Terms => 'Terms';

  @override
  String get o1Privacy => 'Privacy Policy';

  @override
  String get o1HeroSemantic =>
      'Person standing, with calendar, shield, stopwatch and target icons';

  @override
  String get o1CalendarSemantic => 'Calendar';

  @override
  String get o1ShieldSemantic => 'Shield';

  @override
  String get o1StopwatchSemantic => 'Stopwatch';

  @override
  String get o1TargetSemantic => 'Target';

  @override
  String get o2Title => 'What do you want to work on?';

  @override
  String get o2Subtitle => 'Pick one. You can change it later in Settings.';

  @override
  String get o2GoalBladder => 'Bladder control';

  @override
  String get o2GoalErection => 'Erection support';

  @override
  String get o2GoalEjaculation => 'Ejaculation control';

  @override
  String get o2GoalSurgery => 'Recovery after prostate surgery';

  @override
  String get o2GoalGeneral => 'General pelvic health';

  @override
  String get o3Title => 'Do any of these apply to you?';

  @override
  String get o3Subtitle => 'Select all that apply. This keeps your plan safe.';

  @override
  String get o3Pain => 'Pelvic, groin or genital pain';

  @override
  String get o3PainSexual => 'Pain with erection or ejaculation';

  @override
  String get o3Surgery => 'Surgery in the last 3 months';

  @override
  String get o3Catheter => 'A urinary catheter in place right now';

  @override
  String get o3None => 'None of these';

  @override
  String get o3PainMessage =>
      'Squeezing exercises can make pain worse. We will start you with relaxation only. Please see a doctor or pelvic floor physiotherapist.';

  @override
  String get o3CatheterMessage =>
      'Do not do these exercises with a catheter in place. Come back when it is removed and your care team says you can start.';

  @override
  String get o3SurgeryMessage =>
      'Check with your surgeon or physiotherapist before starting.';

  @override
  String get o3SurgeryConfirm => 'I have checked, continue';

  @override
  String get o3SurgeryUnderstand => 'I understand';

  @override
  String get o3ShieldSemantic => 'Safety shield';

  @override
  String get o3ContinueBlocked => 'Continue to Today';

  @override
  String get o4Title => 'Have you done Kegel exercises before?';

  @override
  String get o4Subtitle =>
      'This decides whether we show the muscle-finding tutorial first.';

  @override
  String get o4None => 'No';

  @override
  String get o4Unsure => 'Yes, but I am not sure I do them right';

  @override
  String get o4Confident => 'Yes, I am confident';

  @override
  String get o4TargetSemantic => 'Target';

  @override
  String get o5Title => 'How much time can you give each day?';

  @override
  String get o5Subtitle => 'Includes 2 minutes of relaxation breathing.';

  @override
  String get o5Option1Title => 'About 3 minutes';

  @override
  String get o5Option1Subtitle => '1 session';

  @override
  String get o5Option2Title => 'About 5 minutes';

  @override
  String get o5Option2Subtitle => '2 sessions';

  @override
  String get o5Option3Title => 'About 10 minutes';

  @override
  String get o5Option3Subtitle => '3 sessions';

  @override
  String get o5ReminderTitle => 'Daily reminder';

  @override
  String get o5ReminderHint => 'Discreet text, no health words.';

  @override
  String get o5TimeLabel => 'Time';

  @override
  String o5DaysPerWeek(int count) {
    return '$count days per week';
  }

  @override
  String get o5RemindMe => 'Remind me';

  @override
  String get o5NotNow => 'Not now';

  @override
  String get o5CalendarSemantic => 'Calendar';

  @override
  String get o5DayMon => 'M';

  @override
  String get o5DayTue => 'T';

  @override
  String get o5DayWed => 'W';

  @override
  String get o5DayThu => 'T';

  @override
  String get o5DayFri => 'F';

  @override
  String get o5DaySat => 'S';

  @override
  String get o5DaySun => 'S';

  @override
  String get o6Title => 'Your plan is ready';

  @override
  String o6TrackBadge(String track) {
    return '$track plan';
  }

  @override
  String get o6LevelStart => 'Level 1 · Start';

  @override
  String o6PlanMeta(int days, int sessions, int minutes) {
    return '$days days · $sessions sessions a day · about $minutes min';
  }

  @override
  String get o6RelaxationTitle => 'Relaxation · Weeks 1 to 2';

  @override
  String o6RelaxationMeta(int days, int minutes) {
    return '$days days · daily breathing and stretches · about $minutes min';
  }

  @override
  String get o6RestLabel => 'Rest';

  @override
  String o6DayLabel(int day) {
    return 'D$day';
  }

  @override
  String get o6WhatToExpect => 'What to expect';

  @override
  String get o6TimelineWeek1Title => 'Week 1';

  @override
  String get o6TimelineWeek1Body =>
      'You learn the movement. Most men feel no change yet, and that is normal.';

  @override
  String get o6TimelineWeek2Title => 'Weeks 2 to 4';

  @override
  String get o6TimelineWeek2Body => 'Holds get easier.';

  @override
  String get o6TimelineWeek6Title => 'Weeks 6 to 12';

  @override
  String get o6TimelineWeek6Body =>
      'The usual window for noticing results with daily practice. Results vary.';

  @override
  String get o6TimelineFull =>
      'Week 1: you learn the movement. Most men feel no change yet, and that is normal. Weeks 2 to 4: holds get easier. Weeks 6 to 12: the usual window for noticing results with daily practice. Results vary.';

  @override
  String get o6RelaxationTimelineWeeks12Title => 'Weeks 1 to 2';

  @override
  String get o6RelaxationTimelineWeeks12Body =>
      'Gentle breathing and stretching to let the muscles relax. No squeezing exercises.';

  @override
  String get o6RelaxationTimelineAfterTitle => 'After 2 weeks';

  @override
  String get o6RelaxationTimelineAfterBody =>
      'If the pain has settled and a clinician agrees, you can start Level 1.';

  @override
  String get o6RelaxationTimelineAlwaysTitle => 'Always';

  @override
  String get o6RelaxationTimelineAlwaysBody =>
      'Please see a doctor or pelvic floor physiotherapist if pain continues.';

  @override
  String get o6Start => 'Start my first session';

  @override
  String get o6BridgeSemantic => 'Bridge exercise illustration';

  @override
  String get o6ChildSemantic => 'Child pose illustration';

  @override
  String get o6TrackGeneralBladder => 'General and bladder';

  @override
  String get o6TrackErection => 'Erection support';

  @override
  String get o6TrackEjaculation => 'Ejaculation control';

  @override
  String get o6TrackSurgery => 'After prostate surgery';

  @override
  String get o6TrackRelaxation => 'Relaxation first';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonContinueAnyway => 'Continue anyway';

  @override
  String get t1Title => 'How to do a Kegel';

  @override
  String get t1Card1Title => 'Where the muscles are';

  @override
  String get t1Card1Body =>
      'These muscles run from the pubic bone to the tailbone and support the bladder and bowel.';

  @override
  String get t1Card2Title => 'How to find them';

  @override
  String get t1Card2Body =>
      'Tighten as if you are stopping yourself passing wind, and draw the penis slightly inward. The testicles should lift a little.';

  @override
  String get t1Card2UrineNote =>
      'You can test once by slowing your urine flow. Do not practise that way.';

  @override
  String get t1Card3Title => 'What to avoid';

  @override
  String get t1Card3Body =>
      'Keep buttocks, thighs and stomach relaxed. Keep breathing.';

  @override
  String get t1AvoidCheckBreathing => 'Keep breathing';

  @override
  String get t1AvoidCheckRelaxed => 'Buttocks, thighs and stomach stay relaxed';

  @override
  String get t1AvoidCrossButtocks => 'Do not squeeze your buttocks';

  @override
  String get t1AvoidCrossBreath => 'Do not hold your breath';

  @override
  String get t1PracticeTitle => 'Practice';

  @override
  String get t1PracticeSubtitle => '3 guided reps · squeeze 3 s, relax 3 s';

  @override
  String get t1PhaseSqueeze => 'Squeeze';

  @override
  String get t1PhaseRelax => 'Relax';

  @override
  String t1RepOf(int current, int total) {
    return 'Rep $current of $total';
  }

  @override
  String get t1FeltLiftTitle => 'Did you feel the lift?';

  @override
  String get t1FeltLiftYes => 'Yes';

  @override
  String get t1FeltLiftNotSure => 'Not sure';

  @override
  String get t1NotSureTip =>
      'Try lying down if you are not sure. Soft surfaces can make the lift easier to feel.';

  @override
  String get t1AnatomyBladder => 'Bladder';

  @override
  String get t1AnatomyPubicBone => 'Pubic bone';

  @override
  String get t1AnatomyTailbone => 'Tailbone';

  @override
  String get t1AnatomyPelvicFloor => 'Pelvic floor';

  @override
  String get t1AnatomySemantic =>
      'Side view: the pelvic floor runs from the pubic bone to the tailbone, under the bladder';

  @override
  String s1LevelDay(int level, int day) {
    return 'Level $level · Day $day';
  }

  @override
  String s1SessionOf(int number, int total) {
    return 'Session $number of $total';
  }

  @override
  String s1Meta(int seconds, int parts) {
    return '$seconds seconds · $parts parts';
  }

  @override
  String s1MetaMinutes(int minutes, int parts) {
    return '$minutes min · $parts parts';
  }

  @override
  String get s1BlockSlowHolds => 'Slow holds';

  @override
  String get s1BlockQuickSqueezes => 'Quick squeezes';

  @override
  String get s1BlockRest => 'Rest';

  @override
  String get s1BlockBreathing => 'Relaxation breathing';

  @override
  String get s1BlockReverseKegel => 'Reverse Kegel';

  @override
  String s1BlockRepsDetail(int reps, int squeeze, int relax) {
    return '$reps reps · squeeze $squeeze s, relax $relax s';
  }

  @override
  String s1BlockRestDetail(int seconds) {
    return '$seconds s';
  }

  @override
  String get s1PositionLyingOrSitting =>
      'Lie on your back with knees bent, or sit. Keep breathing.';

  @override
  String get s1PositionSitting => 'Sit upright with feet flat. Keep breathing.';

  @override
  String get s1PositionSittingAndStanding =>
      'Sit for some reps, then stand. Keep breathing.';

  @override
  String get s1PositionStanding => 'Stand with soft knees. Keep breathing.';

  @override
  String get s1PositionAny => 'Use any comfortable position. Keep breathing.';

  @override
  String get s1ShowMeHow => 'Show me how';

  @override
  String get s1Start => 'Start';

  @override
  String get s1VibrationCues => 'Vibration cues';

  @override
  String get s1VoiceCues => 'Voice cues';

  @override
  String get s1VoicePrivacy => 'Off by default for privacy';

  @override
  String get s1LyingSemantic => 'Person lying on their back with knees bent';
}
