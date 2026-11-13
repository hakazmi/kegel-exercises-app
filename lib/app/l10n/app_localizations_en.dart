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
  String get t1Card3Title => 'Do and don\'t';

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
  String s1RelaxationDay(int day) {
    return 'Relaxation · Day $day';
  }

  @override
  String s1SessionOf(int number, int total) {
    return 'Session $number of $total';
  }

  @override
  String s1Meta(int seconds, int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: '$parts parts',
      one: '1 part',
    );
    return '$seconds seconds · $_temp0';
  }

  @override
  String s1MetaMinutes(int minutes, int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: '$parts parts',
      one: '1 part',
    );
    return '$minutes min · $_temp0';
  }

  @override
  String get s1ReverseKegelDescription =>
      'Gently release and lengthen instead of squeezing.';

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

  @override
  String get s2GetReady => 'Get ready';

  @override
  String get s2TapToSkip => 'Tap to skip';

  @override
  String s3BlockRepHeader(String block, int rep, int total) {
    return '$block · $rep of $total';
  }

  @override
  String s3RepOf(int rep, int total) {
    return 'Rep $rep of $total';
  }

  @override
  String get s3CueBreathing => 'Keep breathing normally';

  @override
  String get s3CueRelaxed => 'Buttocks, thighs and stomach stay relaxed';

  @override
  String get s3CueLetGo => 'Let go completely';

  @override
  String get s3CueGentle => 'Gentle effort is enough';

  @override
  String s3NowBlock(String block) {
    return 'Now: $block';
  }

  @override
  String s3NextBlock(String block) {
    return 'Next: $block';
  }

  @override
  String get s3NoNextBlock => 'Finish';

  @override
  String get s3BlockStretch => 'Stretch';

  @override
  String get s3Pause => 'Pause';

  @override
  String get s3Resume => 'Resume';

  @override
  String get s3Voice => 'Voice';

  @override
  String get s3Vibration => 'Vibrate';

  @override
  String get s3Exit => 'Exit';

  @override
  String get s3ExitTitle => 'End this session?';

  @override
  String get s3ExitMessage => 'A partial session is not counted.';

  @override
  String get s3ExitConfirm => 'End session';

  @override
  String get s4Title => 'Session complete';

  @override
  String get s4TimeLabel => 'Time';

  @override
  String s4TimeSeconds(int seconds) {
    return '$seconds seconds';
  }

  @override
  String s4TimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get s4StreakLabel => 'Streak';

  @override
  String s4StreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get s4NextLabel => 'Next today';

  @override
  String get s4NextNone => 'Nothing else scheduled';

  @override
  String get s4FeelPrompt => 'How did that feel?';

  @override
  String get s4FeelFine => 'Fine';

  @override
  String get s4FeelMild => 'Mild discomfort';

  @override
  String get s4FeelPain => 'Pain';

  @override
  String get s4StepDownSuggestion =>
      'Two sessions with mild discomfort. Consider stepping down a level in Levels.';

  @override
  String get h3Title => 'Pain help';

  @override
  String get h3Headline => 'Stop squeezing exercises for now';

  @override
  String get h3Body =>
      'Stop the squeezing exercises for now. Pain can mean the muscles are too tight, and more squeezing can make that worse.';

  @override
  String get h3BodyDetail =>
      'Pain can mean the pelvic floor muscles are too tight. Squeezing more can make that worse. Relaxing them is the better starting point.';

  @override
  String get h3TrackBadge => 'Relaxation track, daily';

  @override
  String get h3TrackBreathing => 'Belly breathing · 2 min';

  @override
  String get h3TrackReverse => 'Reverse Kegel: gently let go · 2 min';

  @override
  String get h3TrackStretch => 'Child\'s pose stretch · 1 to 3 min';

  @override
  String get h3ClinicianNote =>
      'See a doctor or pelvic floor physiotherapist if the pain continues, or if you have pain with erection or ejaculation.';

  @override
  String get h3SwitchRelaxation => 'Switch me to relaxation exercises';

  @override
  String get h3KeepPlan => 'Keep my plan';

  @override
  String get h3ConfirmRelaxation => 'Switch me to relaxation exercises';

  @override
  String get h3SwitchedConfirm =>
      'You are on relaxation exercises now. Strengthening is paused.';

  @override
  String get h3IllustrationSemantic =>
      'Person resting in a gentle stretch pose';

  @override
  String h1Streak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
      zero: 'No streak',
    );
    return '$_temp0';
  }

  @override
  String h1LevelDayOf(int level, int day, int total) {
    return 'Level $level · Day $day of $total';
  }

  @override
  String h1RelaxationDayOf(int day, int total) {
    return 'Relaxation · Day $day of $total';
  }

  @override
  String h1LevelName(int level, String name) {
    return 'Level $level · $name';
  }

  @override
  String h1DayProgress(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      done,
      locale: localeName,
      other: '$done of $total days',
      one: '1 of $total days',
    );
    return '$_temp0';
  }

  @override
  String get h1WeekRest => 'Rest';

  @override
  String h1Percent(int percent) {
    return '$percent%';
  }

  @override
  String h1SessionLabel(int number) {
    return 'Session $number';
  }

  @override
  String get h1SessionOptional => 'Optional';

  @override
  String get h1BreathingLabel => 'Relaxation breathing';

  @override
  String get h1ReverseLabel => 'Reverse Kegel';

  @override
  String h1DurationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String h1DurationMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String h1ItemDoneMeta(String duration) {
    return 'Done · $duration';
  }

  @override
  String h1ItemPendingMeta(String duration) {
    return '$duration';
  }

  @override
  String get h1StartSession => 'Start session';

  @override
  String get h1FeltPain => 'I felt pain';

  @override
  String get h1AllDone => 'Done for today. Rest is part of the training.';

  @override
  String get h1RestDay => 'Rest day. Your muscles recover today.';

  @override
  String get h1DailyCap =>
      'That is enough for today. Doing more can tire the muscles and slow progress.';

  @override
  String get h1UpdateCatheter => 'Update my answer';

  @override
  String get h1CatheterClearedTitle => 'Catheter removed?';

  @override
  String get h1CatheterClearedMessage =>
      'Only continue if your care team says you can start these exercises.';

  @override
  String get h1CatheterClearedConfirm => 'Yes, update answer';

  @override
  String get h1WeekMon => 'Mon';

  @override
  String get h1WeekTue => 'Tue';

  @override
  String get h1WeekWed => 'Wed';

  @override
  String get h1WeekThu => 'Thu';

  @override
  String get h1WeekFri => 'Fri';

  @override
  String get h1WeekSat => 'Sat';

  @override
  String get h1WeekSun => 'Sun';

  @override
  String get h1LevelCardSemantic => 'Open levels';

  @override
  String get h2Title => 'Your levels';

  @override
  String h2Subtitle(String track) {
    return '$track plan. Each level makes holds a little longer.';
  }

  @override
  String h2SubtitleRelaxation(String track) {
    return '$track plan. Breathing and stretches come before strengthening.';
  }

  @override
  String get h2Current => 'Current';

  @override
  String get h2Premium => 'Premium';

  @override
  String h2DaysOf(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      done,
      locale: localeName,
      other: '$done of $total days',
      one: '1 of $total days',
    );
    return '$_temp0';
  }

  @override
  String h2DayRange(int start, int end) {
    return 'Days $start–$end';
  }

  @override
  String h2DayOnward(int start) {
    return 'Day $start onward';
  }

  @override
  String h2LevelMeta(String range, String holds, String position) {
    return '$range · $holds, $position';
  }

  @override
  String get h2RelaxationName => 'Relaxation';

  @override
  String h2RelaxationMeta(int days) {
    return 'Days 1–$days · daily breathing and stretches';
  }

  @override
  String get h2RelaxationLevel1Note =>
      'If the pain has settled and a clinician agrees, you can start Level 1.';

  @override
  String h2HoldsFixed(int seconds) {
    return '$seconds s holds';
  }

  @override
  String h2HoldsRange(int min, int max) {
    return '$min–$max s holds';
  }

  @override
  String get h2PositionLyingOrSitting => 'lying or sitting';

  @override
  String get h2PositionSitting => 'sitting';

  @override
  String get h2PositionSittingAndStanding => 'sitting and standing';

  @override
  String get h2PositionStanding => 'standing';

  @override
  String get h2PositionAny => 'everyday moves';

  @override
  String get h2PositionExtras => 'bridge and squat';

  @override
  String get h2UnlockNote =>
      'The next level unlocks when you complete 5 of the last 7 days. Missed a few days? Your plan simply waits for you.';

  @override
  String get h2UnlockNoteRelaxation =>
      'Strengthening levels stay below until the relaxation weeks are done. If the pain has settled and a clinician agrees, you can start Level 1.';

  @override
  String get h2RepeatOrStepDown => 'Repeat or step down a level';

  @override
  String get h2RepeatTitle => 'Repeat this level?';

  @override
  String get h2RepeatMessage =>
      'Day progress for this level resets. Your session history stays on the device.';

  @override
  String get h2RepeatConfirm => 'Repeat level';

  @override
  String get h2StepDownTitle => 'Step down one level?';

  @override
  String get h2StepDownMessage =>
      'You will train at the previous level. This never happens automatically.';

  @override
  String get h2StepDownConfirm => 'Step down';

  @override
  String get h2ChooseActionTitle => 'Adjust your level';

  @override
  String get h2ChooseRepeat => 'Repeat current level';

  @override
  String get h2ChooseStepDown => 'Step down one level';

  @override
  String get h2LevelNameStart => 'Start';

  @override
  String get h2LevelNameBuild => 'Build';

  @override
  String get h2LevelNameSteady => 'Steady';

  @override
  String get h2LevelNameDeep => 'Deep';

  @override
  String get h2LevelNameMaintain => 'Maintain';

  @override
  String get g1SettingsTooltip => 'Settings';

  @override
  String get g1StatStreakLabel => 'Streak';

  @override
  String g1StatStreakValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get g1StatWeekLabel => 'This week';

  @override
  String g1StatWeekValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: '0 sessions',
    );
    return '$_temp0';
  }

  @override
  String get g1StatHoldLabel => 'Longest hold';

  @override
  String g1StatHoldValue(int seconds) {
    return '$seconds s';
  }

  @override
  String get g1StatLevelLabel => 'Level';

  @override
  String g1StatLevelDay(int level, int day) {
    return '$level · day $day';
  }

  @override
  String get g1StatRelaxationLabel => 'Relaxation plan';

  @override
  String g1StatRelaxationDay(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get h1RelaxationWeeksTitle => 'Weeks 1 to 2';

  @override
  String get g1CalPrevious => 'Previous month';

  @override
  String get g1CalNext => 'Next month';

  @override
  String get g1CalTrained => 'Trained';

  @override
  String g1CalMonthYear(String month, int year) {
    return '$month $year';
  }

  @override
  String get g1CalMon => 'M';

  @override
  String get g1CalTue => 'T';

  @override
  String get g1CalWed => 'W';

  @override
  String get g1CalThu => 'T';

  @override
  String get g1CalFri => 'F';

  @override
  String get g1CalSat => 'S';

  @override
  String get g1CalSun => 'S';

  @override
  String get g1MonthJanuary => 'January';

  @override
  String get g1MonthFebruary => 'February';

  @override
  String get g1MonthMarch => 'March';

  @override
  String get g1MonthApril => 'April';

  @override
  String get g1MonthMay => 'May';

  @override
  String get g1MonthJune => 'June';

  @override
  String get g1MonthJuly => 'July';

  @override
  String get g1MonthAugust => 'August';

  @override
  String get g1MonthSeptember => 'September';

  @override
  String get g1MonthOctober => 'October';

  @override
  String get g1MonthNovember => 'November';

  @override
  String get g1MonthDecember => 'December';

  @override
  String get g1CheckInBaselineTitle => 'Baseline check-in';

  @override
  String get g1CheckInBaselineBody =>
      'One question, 10 seconds. See your own change over time.';

  @override
  String get g1CheckInFollowUpTitle => '4-week check-in';

  @override
  String get g1CheckInFollowUpBody =>
      'One question. Compare with your earlier answer.';

  @override
  String get g1CheckInHistoryTitle => 'Your check-ins';

  @override
  String get g1CheckInStart => 'Start';

  @override
  String get g1CheckInLockedHint =>
      'A short check-in unlocks after your third completed session.';

  @override
  String get g1CheckInUnlockHistory => 'Unlock check-in history';

  @override
  String get g2EyebrowBaseline => 'WEEK 0 · BASELINE';

  @override
  String get g2EyebrowFollowUp => '4-WEEK CHECK-IN';

  @override
  String get g2SubtitleBaseline =>
      'We will ask again in 4 weeks and show you both answers side by side.';

  @override
  String get g2SubtitleFollowUp =>
      'Your answers stay on this phone. No predictions.';

  @override
  String get g2PrivacyNote => 'Saved only on this phone';

  @override
  String get g2Save => 'Save';

  @override
  String get g2Skip => 'Skip for now';

  @override
  String get g2Done => 'Done';

  @override
  String get g2ResultTitle => 'Your check-in';

  @override
  String get g2ResultSubtitle =>
      'Your own numbers, side by side. Results vary.';

  @override
  String g2ComparisonLine(int week, int score, int max, String label) {
    return 'Week $week: $score of $max · $label';
  }

  @override
  String get g2DoctorNote =>
      'Exercises do not help everyone. It is worth talking to a doctor.';

  @override
  String get g2HistoryPremiumHint =>
      'Full check-in history is part of Premium.';

  @override
  String get g2QuestionBladder =>
      'In the last week, how often did you leak urine?';

  @override
  String get g2OptionBladder1 => 'Never';

  @override
  String get g2OptionBladder2 => 'Once or twice';

  @override
  String get g2OptionBladder3 => 'A few times';

  @override
  String get g2OptionBladder4 => 'Most days';

  @override
  String get g2OptionBladder5 => 'Every day';

  @override
  String get g2QuestionErection =>
      'How would you rate erection firmness in the last week?';

  @override
  String get g2OptionErection1 => 'Very soft';

  @override
  String get g2OptionErection2 => 'Soft';

  @override
  String get g2OptionErection3 => 'Moderate';

  @override
  String get g2OptionErection4 => 'Firm';

  @override
  String get g2OptionErection5 => 'Very firm';

  @override
  String get g2QuestionEjaculation =>
      'How much control did you feel in the last week?';

  @override
  String get g2OptionEjaculation1 => 'No control';

  @override
  String get g2OptionEjaculation2 => 'A little control';

  @override
  String get g2OptionEjaculation3 => 'Some control';

  @override
  String get g2OptionEjaculation4 => 'Good control';

  @override
  String get g2OptionEjaculation5 => 'Full control';

  @override
  String get g2QuestionSurgery =>
      'In the last week, how well have you controlled your urine?';

  @override
  String get g2OptionSurgery1 => 'No control';

  @override
  String get g2OptionSurgery2 => 'Limited control';

  @override
  String get g2OptionSurgery3 => 'Some control';

  @override
  String get g2OptionSurgery4 => 'Good control';

  @override
  String get g2OptionSurgery5 => 'Full control';

  @override
  String get g2QuestionGeneral =>
      'In the last week, how comfortable has your pelvic area felt?';

  @override
  String get g2OptionGeneral1 => 'Very uncomfortable';

  @override
  String get g2OptionGeneral2 => 'Uncomfortable';

  @override
  String get g2OptionGeneral3 => 'Mixed';

  @override
  String get g2OptionGeneral4 => 'Mostly comfortable';

  @override
  String get g2OptionGeneral5 => 'Very comfortable';

  @override
  String get l1ArticlesHeading => 'Articles';

  @override
  String l1StartHere(int minutes) {
    return 'Start here · $minutes min';
  }

  @override
  String get l1ReplayTutorial => 'Replay the tutorial anytime';

  @override
  String l1Minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String l2MinutesRead(int minutes) {
    return '$minutes min read';
  }

  @override
  String get l2Sources => 'Sources';

  @override
  String get l2NotFound => 'Article not found.';

  @override
  String get x1Title => 'Settings';

  @override
  String get x1SectionPlan => 'Plan';

  @override
  String get x1SectionReminders => 'Reminders';

  @override
  String get x1SectionSession => 'Session';

  @override
  String get x1SectionPrivacy => 'Privacy';

  @override
  String get x1SectionSubscription => 'Subscription';

  @override
  String get x1SectionAbout => 'About';

  @override
  String get x1Goal => 'Goal';

  @override
  String get x1GoalTitle => 'Your goal';

  @override
  String get x1DailyTime => 'Daily time';

  @override
  String get x1DailyTimeTitle => 'Sessions per day';

  @override
  String x1DailySessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions a day',
      one: '1 session a day',
    );
    return '$_temp0';
  }

  @override
  String get x1SafetyAnswers => 'Safety answers';

  @override
  String get x1SafetyTitle => 'Safety answers';

  @override
  String get x1ValueNone => 'None';

  @override
  String x1SafetySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get x1DailyReminder => 'Daily reminder';

  @override
  String get x1TimeAndDays => 'Time and days';

  @override
  String get x1ReminderScheduleTitle => 'Reminder time and days';

  @override
  String get x1EveryDay => 'Every day';

  @override
  String get x1Daily => 'Daily';

  @override
  String x1DaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get x1Vibration => 'Vibration cues';

  @override
  String get x1Voice => 'Voice cues';

  @override
  String get x1Discreet => 'Discreet notifications';

  @override
  String get x1DiscreetSubtitle => 'No health words on the lock screen.';

  @override
  String get x1DeleteAll => 'Delete all my data';

  @override
  String get x1DeleteTitle => 'Delete all data?';

  @override
  String get x1DeleteMessage =>
      'This removes your plan, sessions and check-ins from this phone. It cannot be undone.';

  @override
  String get x1DeleteConfirm => 'Delete everything';

  @override
  String get x1ManagePlay => 'Manage in Google Play';

  @override
  String get x1ManageAppStore => 'Manage in the App Store';

  @override
  String get x1Free => 'Free';

  @override
  String get x1Premium => 'Premium';

  @override
  String get x1Restore => 'Restore purchase';

  @override
  String get x1RestoreStub =>
      'Restore will be available when subscriptions ship.';

  @override
  String get x1LegalRow => 'Disclaimer, privacy and terms';

  @override
  String get x1PrivacyPolicy => 'Privacy Policy';

  @override
  String get x1Terms => 'Terms';

  @override
  String get x1Contact => 'Contact';

  @override
  String x1VersionFooter(String version) {
    return 'Version $version · Not a medical device';
  }
}
