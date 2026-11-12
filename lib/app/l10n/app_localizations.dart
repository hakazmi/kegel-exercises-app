import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Temporary display name; keep in sync with AppConstants.displayName
  ///
  /// In en, this message translates to:
  /// **'Kegel Exercises'**
  String get appName;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @placeholderScreen.
  ///
  /// In en, this message translates to:
  /// **'{id} · {name}'**
  String placeholderScreen(String id, String name);

  /// No description provided for @placeholderHint.
  ///
  /// In en, this message translates to:
  /// **'Placeholder — real UI comes in later steps.'**
  String get placeholderHint;

  /// No description provided for @devGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget gallery'**
  String get devGalleryTitle;

  /// No description provided for @devGalleryOpen.
  ///
  /// In en, this message translates to:
  /// **'Open widget gallery'**
  String get devGalleryOpen;

  /// No description provided for @devDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data debug'**
  String get devDataTitle;

  /// No description provided for @devDataOpen.
  ///
  /// In en, this message translates to:
  /// **'Open data debug'**
  String get devDataOpen;

  /// No description provided for @o1Title.
  ///
  /// In en, this message translates to:
  /// **'Train your pelvic floor in a few minutes a day'**
  String get o1Title;

  /// No description provided for @o1Body.
  ///
  /// In en, this message translates to:
  /// **'Guided exercises for bladder control and pelvic health. No equipment.'**
  String get o1Body;

  /// No description provided for @o1BulletPlan.
  ///
  /// In en, this message translates to:
  /// **'A plan that grows with you, level by level'**
  String get o1BulletPlan;

  /// No description provided for @o1BulletDiscreet.
  ///
  /// In en, this message translates to:
  /// **'Discreet: train anywhere, nobody can tell'**
  String get o1BulletDiscreet;

  /// No description provided for @o1BulletPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private: your data stays on this phone'**
  String get o1BulletPrivate;

  /// No description provided for @o1AgeCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older'**
  String get o1AgeCheckbox;

  /// No description provided for @o1Disclaimer.
  ///
  /// In en, this message translates to:
  /// **'This app is not a medical device and does not diagnose, treat, cure or prevent any medical condition. Talk to a healthcare professional for medical advice.'**
  String get o1Disclaimer;

  /// No description provided for @o1GetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get o1GetStarted;

  /// No description provided for @o1Terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get o1Terms;

  /// No description provided for @o1Privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get o1Privacy;

  /// No description provided for @o1HeroSemantic.
  ///
  /// In en, this message translates to:
  /// **'Person standing, with calendar, shield, stopwatch and target icons'**
  String get o1HeroSemantic;

  /// No description provided for @o1CalendarSemantic.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get o1CalendarSemantic;

  /// No description provided for @o1ShieldSemantic.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get o1ShieldSemantic;

  /// No description provided for @o1StopwatchSemantic.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get o1StopwatchSemantic;

  /// No description provided for @o1TargetSemantic.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get o1TargetSemantic;

  /// No description provided for @o2Title.
  ///
  /// In en, this message translates to:
  /// **'What do you want to work on?'**
  String get o2Title;

  /// No description provided for @o2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one. You can change it later in Settings.'**
  String get o2Subtitle;

  /// No description provided for @o2GoalBladder.
  ///
  /// In en, this message translates to:
  /// **'Bladder control'**
  String get o2GoalBladder;

  /// No description provided for @o2GoalErection.
  ///
  /// In en, this message translates to:
  /// **'Erection support'**
  String get o2GoalErection;

  /// No description provided for @o2GoalEjaculation.
  ///
  /// In en, this message translates to:
  /// **'Ejaculation control'**
  String get o2GoalEjaculation;

  /// No description provided for @o2GoalSurgery.
  ///
  /// In en, this message translates to:
  /// **'Recovery after prostate surgery'**
  String get o2GoalSurgery;

  /// No description provided for @o2GoalGeneral.
  ///
  /// In en, this message translates to:
  /// **'General pelvic health'**
  String get o2GoalGeneral;

  /// No description provided for @o3Title.
  ///
  /// In en, this message translates to:
  /// **'Do any of these apply to you?'**
  String get o3Title;

  /// No description provided for @o3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply. This keeps your plan safe.'**
  String get o3Subtitle;

  /// No description provided for @o3Pain.
  ///
  /// In en, this message translates to:
  /// **'Pelvic, groin or genital pain'**
  String get o3Pain;

  /// No description provided for @o3PainSexual.
  ///
  /// In en, this message translates to:
  /// **'Pain with erection or ejaculation'**
  String get o3PainSexual;

  /// No description provided for @o3Surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery in the last 3 months'**
  String get o3Surgery;

  /// No description provided for @o3Catheter.
  ///
  /// In en, this message translates to:
  /// **'A urinary catheter in place right now'**
  String get o3Catheter;

  /// No description provided for @o3None.
  ///
  /// In en, this message translates to:
  /// **'None of these'**
  String get o3None;

  /// No description provided for @o3PainMessage.
  ///
  /// In en, this message translates to:
  /// **'Squeezing exercises can make pain worse. We will start you with relaxation only. Please see a doctor or pelvic floor physiotherapist.'**
  String get o3PainMessage;

  /// No description provided for @o3CatheterMessage.
  ///
  /// In en, this message translates to:
  /// **'Do not do these exercises with a catheter in place. Come back when it is removed and your care team says you can start.'**
  String get o3CatheterMessage;

  /// No description provided for @o3SurgeryMessage.
  ///
  /// In en, this message translates to:
  /// **'Check with your surgeon or physiotherapist before starting.'**
  String get o3SurgeryMessage;

  /// No description provided for @o3SurgeryConfirm.
  ///
  /// In en, this message translates to:
  /// **'I have checked, continue'**
  String get o3SurgeryConfirm;

  /// No description provided for @o3SurgeryUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get o3SurgeryUnderstand;

  /// No description provided for @o3ShieldSemantic.
  ///
  /// In en, this message translates to:
  /// **'Safety shield'**
  String get o3ShieldSemantic;

  /// No description provided for @o3ContinueBlocked.
  ///
  /// In en, this message translates to:
  /// **'Continue to Today'**
  String get o3ContinueBlocked;

  /// No description provided for @o4Title.
  ///
  /// In en, this message translates to:
  /// **'Have you done Kegel exercises before?'**
  String get o4Title;

  /// No description provided for @o4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'This decides whether we show the muscle-finding tutorial first.'**
  String get o4Subtitle;

  /// No description provided for @o4None.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get o4None;

  /// No description provided for @o4Unsure.
  ///
  /// In en, this message translates to:
  /// **'Yes, but I am not sure I do them right'**
  String get o4Unsure;

  /// No description provided for @o4Confident.
  ///
  /// In en, this message translates to:
  /// **'Yes, I am confident'**
  String get o4Confident;

  /// No description provided for @o4TargetSemantic.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get o4TargetSemantic;

  /// No description provided for @o5Title.
  ///
  /// In en, this message translates to:
  /// **'How much time can you give each day?'**
  String get o5Title;

  /// No description provided for @o5Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes 2 minutes of relaxation breathing.'**
  String get o5Subtitle;

  /// No description provided for @o5Option1Title.
  ///
  /// In en, this message translates to:
  /// **'About 3 minutes'**
  String get o5Option1Title;

  /// No description provided for @o5Option1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'1 session'**
  String get o5Option1Subtitle;

  /// No description provided for @o5Option2Title.
  ///
  /// In en, this message translates to:
  /// **'About 5 minutes'**
  String get o5Option2Title;

  /// No description provided for @o5Option2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'2 sessions'**
  String get o5Option2Subtitle;

  /// No description provided for @o5Option3Title.
  ///
  /// In en, this message translates to:
  /// **'About 10 minutes'**
  String get o5Option3Title;

  /// No description provided for @o5Option3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'3 sessions'**
  String get o5Option3Subtitle;

  /// No description provided for @o5ReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get o5ReminderTitle;

  /// No description provided for @o5ReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Discreet text, no health words.'**
  String get o5ReminderHint;

  /// No description provided for @o5TimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get o5TimeLabel;

  /// No description provided for @o5DaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} days per week'**
  String o5DaysPerWeek(int count);

  /// No description provided for @o5RemindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get o5RemindMe;

  /// No description provided for @o5NotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get o5NotNow;

  /// No description provided for @o5CalendarSemantic.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get o5CalendarSemantic;

  /// No description provided for @o5DayMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get o5DayMon;

  /// No description provided for @o5DayTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get o5DayTue;

  /// No description provided for @o5DayWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get o5DayWed;

  /// No description provided for @o5DayThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get o5DayThu;

  /// No description provided for @o5DayFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get o5DayFri;

  /// No description provided for @o5DaySat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get o5DaySat;

  /// No description provided for @o5DaySun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get o5DaySun;

  /// No description provided for @o6Title.
  ///
  /// In en, this message translates to:
  /// **'Your plan is ready'**
  String get o6Title;

  /// No description provided for @o6TrackBadge.
  ///
  /// In en, this message translates to:
  /// **'{track} plan'**
  String o6TrackBadge(String track);

  /// No description provided for @o6LevelStart.
  ///
  /// In en, this message translates to:
  /// **'Level 1 · Start'**
  String get o6LevelStart;

  /// No description provided for @o6PlanMeta.
  ///
  /// In en, this message translates to:
  /// **'{days} days · {sessions} sessions a day · about {minutes} min'**
  String o6PlanMeta(int days, int sessions, int minutes);

  /// No description provided for @o6RelaxationTitle.
  ///
  /// In en, this message translates to:
  /// **'Relaxation · Weeks 1 to 2'**
  String get o6RelaxationTitle;

  /// No description provided for @o6RelaxationMeta.
  ///
  /// In en, this message translates to:
  /// **'{days} days · daily breathing and stretches · about {minutes} min'**
  String o6RelaxationMeta(int days, int minutes);

  /// No description provided for @o6RestLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get o6RestLabel;

  /// No description provided for @o6DayLabel.
  ///
  /// In en, this message translates to:
  /// **'D{day}'**
  String o6DayLabel(int day);

  /// No description provided for @o6WhatToExpect.
  ///
  /// In en, this message translates to:
  /// **'What to expect'**
  String get o6WhatToExpect;

  /// No description provided for @o6TimelineWeek1Title.
  ///
  /// In en, this message translates to:
  /// **'Week 1'**
  String get o6TimelineWeek1Title;

  /// No description provided for @o6TimelineWeek1Body.
  ///
  /// In en, this message translates to:
  /// **'You learn the movement. Most men feel no change yet, and that is normal.'**
  String get o6TimelineWeek1Body;

  /// No description provided for @o6TimelineWeek2Title.
  ///
  /// In en, this message translates to:
  /// **'Weeks 2 to 4'**
  String get o6TimelineWeek2Title;

  /// No description provided for @o6TimelineWeek2Body.
  ///
  /// In en, this message translates to:
  /// **'Holds get easier.'**
  String get o6TimelineWeek2Body;

  /// No description provided for @o6TimelineWeek6Title.
  ///
  /// In en, this message translates to:
  /// **'Weeks 6 to 12'**
  String get o6TimelineWeek6Title;

  /// No description provided for @o6TimelineWeek6Body.
  ///
  /// In en, this message translates to:
  /// **'The usual window for noticing results with daily practice. Results vary.'**
  String get o6TimelineWeek6Body;

  /// No description provided for @o6TimelineFull.
  ///
  /// In en, this message translates to:
  /// **'Week 1: you learn the movement. Most men feel no change yet, and that is normal. Weeks 2 to 4: holds get easier. Weeks 6 to 12: the usual window for noticing results with daily practice. Results vary.'**
  String get o6TimelineFull;

  /// No description provided for @o6RelaxationTimelineWeeks12Title.
  ///
  /// In en, this message translates to:
  /// **'Weeks 1 to 2'**
  String get o6RelaxationTimelineWeeks12Title;

  /// No description provided for @o6RelaxationTimelineWeeks12Body.
  ///
  /// In en, this message translates to:
  /// **'Gentle breathing and stretching to let the muscles relax. No squeezing exercises.'**
  String get o6RelaxationTimelineWeeks12Body;

  /// No description provided for @o6RelaxationTimelineAfterTitle.
  ///
  /// In en, this message translates to:
  /// **'After 2 weeks'**
  String get o6RelaxationTimelineAfterTitle;

  /// No description provided for @o6RelaxationTimelineAfterBody.
  ///
  /// In en, this message translates to:
  /// **'If the pain has settled and a clinician agrees, you can start Level 1.'**
  String get o6RelaxationTimelineAfterBody;

  /// No description provided for @o6RelaxationTimelineAlwaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get o6RelaxationTimelineAlwaysTitle;

  /// No description provided for @o6RelaxationTimelineAlwaysBody.
  ///
  /// In en, this message translates to:
  /// **'Please see a doctor or pelvic floor physiotherapist if pain continues.'**
  String get o6RelaxationTimelineAlwaysBody;

  /// No description provided for @o6Start.
  ///
  /// In en, this message translates to:
  /// **'Start my first session'**
  String get o6Start;

  /// No description provided for @o6BridgeSemantic.
  ///
  /// In en, this message translates to:
  /// **'Bridge exercise illustration'**
  String get o6BridgeSemantic;

  /// No description provided for @o6ChildSemantic.
  ///
  /// In en, this message translates to:
  /// **'Child pose illustration'**
  String get o6ChildSemantic;

  /// No description provided for @o6TrackGeneralBladder.
  ///
  /// In en, this message translates to:
  /// **'General and bladder'**
  String get o6TrackGeneralBladder;

  /// No description provided for @o6TrackErection.
  ///
  /// In en, this message translates to:
  /// **'Erection support'**
  String get o6TrackErection;

  /// No description provided for @o6TrackEjaculation.
  ///
  /// In en, this message translates to:
  /// **'Ejaculation control'**
  String get o6TrackEjaculation;

  /// No description provided for @o6TrackSurgery.
  ///
  /// In en, this message translates to:
  /// **'After prostate surgery'**
  String get o6TrackSurgery;

  /// No description provided for @o6TrackRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Relaxation first'**
  String get o6TrackRelaxation;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonContinueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get commonContinueAnyway;

  /// No description provided for @t1Title.
  ///
  /// In en, this message translates to:
  /// **'How to do a Kegel'**
  String get t1Title;

  /// No description provided for @t1Card1Title.
  ///
  /// In en, this message translates to:
  /// **'Where the muscles are'**
  String get t1Card1Title;

  /// No description provided for @t1Card1Body.
  ///
  /// In en, this message translates to:
  /// **'These muscles run from the pubic bone to the tailbone and support the bladder and bowel.'**
  String get t1Card1Body;

  /// No description provided for @t1Card2Title.
  ///
  /// In en, this message translates to:
  /// **'How to find them'**
  String get t1Card2Title;

  /// No description provided for @t1Card2Body.
  ///
  /// In en, this message translates to:
  /// **'Tighten as if you are stopping yourself passing wind, and draw the penis slightly inward. The testicles should lift a little.'**
  String get t1Card2Body;

  /// No description provided for @t1Card2UrineNote.
  ///
  /// In en, this message translates to:
  /// **'You can test once by slowing your urine flow. Do not practise that way.'**
  String get t1Card2UrineNote;

  /// No description provided for @t1Card3Title.
  ///
  /// In en, this message translates to:
  /// **'What to avoid'**
  String get t1Card3Title;

  /// No description provided for @t1Card3Body.
  ///
  /// In en, this message translates to:
  /// **'Keep buttocks, thighs and stomach relaxed. Keep breathing.'**
  String get t1Card3Body;

  /// No description provided for @t1AvoidCheckBreathing.
  ///
  /// In en, this message translates to:
  /// **'Keep breathing'**
  String get t1AvoidCheckBreathing;

  /// No description provided for @t1AvoidCheckRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Buttocks, thighs and stomach stay relaxed'**
  String get t1AvoidCheckRelaxed;

  /// No description provided for @t1AvoidCrossButtocks.
  ///
  /// In en, this message translates to:
  /// **'Do not squeeze your buttocks'**
  String get t1AvoidCrossButtocks;

  /// No description provided for @t1AvoidCrossBreath.
  ///
  /// In en, this message translates to:
  /// **'Do not hold your breath'**
  String get t1AvoidCrossBreath;

  /// No description provided for @t1PracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get t1PracticeTitle;

  /// No description provided for @t1PracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 guided reps · squeeze 3 s, relax 3 s'**
  String get t1PracticeSubtitle;

  /// No description provided for @t1PhaseSqueeze.
  ///
  /// In en, this message translates to:
  /// **'Squeeze'**
  String get t1PhaseSqueeze;

  /// No description provided for @t1PhaseRelax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get t1PhaseRelax;

  /// No description provided for @t1RepOf.
  ///
  /// In en, this message translates to:
  /// **'Rep {current} of {total}'**
  String t1RepOf(int current, int total);

  /// No description provided for @t1FeltLiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you feel the lift?'**
  String get t1FeltLiftTitle;

  /// No description provided for @t1FeltLiftYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get t1FeltLiftYes;

  /// No description provided for @t1FeltLiftNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get t1FeltLiftNotSure;

  /// No description provided for @t1NotSureTip.
  ///
  /// In en, this message translates to:
  /// **'Try lying down if you are not sure. Soft surfaces can make the lift easier to feel.'**
  String get t1NotSureTip;

  /// No description provided for @t1AnatomyBladder.
  ///
  /// In en, this message translates to:
  /// **'Bladder'**
  String get t1AnatomyBladder;

  /// No description provided for @t1AnatomyPubicBone.
  ///
  /// In en, this message translates to:
  /// **'Pubic bone'**
  String get t1AnatomyPubicBone;

  /// No description provided for @t1AnatomyTailbone.
  ///
  /// In en, this message translates to:
  /// **'Tailbone'**
  String get t1AnatomyTailbone;

  /// No description provided for @t1AnatomyPelvicFloor.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor'**
  String get t1AnatomyPelvicFloor;

  /// No description provided for @t1AnatomySemantic.
  ///
  /// In en, this message translates to:
  /// **'Side view: the pelvic floor runs from the pubic bone to the tailbone, under the bladder'**
  String get t1AnatomySemantic;

  /// No description provided for @s1LevelDay.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · Day {day}'**
  String s1LevelDay(int level, int day);

  /// No description provided for @s1SessionOf.
  ///
  /// In en, this message translates to:
  /// **'Session {number} of {total}'**
  String s1SessionOf(int number, int total);

  /// No description provided for @s1Meta.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds · {parts} parts'**
  String s1Meta(int seconds, int parts);

  /// No description provided for @s1MetaMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {parts} parts'**
  String s1MetaMinutes(int minutes, int parts);

  /// No description provided for @s1BlockSlowHolds.
  ///
  /// In en, this message translates to:
  /// **'Slow holds'**
  String get s1BlockSlowHolds;

  /// No description provided for @s1BlockQuickSqueezes.
  ///
  /// In en, this message translates to:
  /// **'Quick squeezes'**
  String get s1BlockQuickSqueezes;

  /// No description provided for @s1BlockRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get s1BlockRest;

  /// No description provided for @s1BlockBreathing.
  ///
  /// In en, this message translates to:
  /// **'Relaxation breathing'**
  String get s1BlockBreathing;

  /// No description provided for @s1BlockReverseKegel.
  ///
  /// In en, this message translates to:
  /// **'Reverse Kegel'**
  String get s1BlockReverseKegel;

  /// No description provided for @s1BlockRepsDetail.
  ///
  /// In en, this message translates to:
  /// **'{reps} reps · squeeze {squeeze} s, relax {relax} s'**
  String s1BlockRepsDetail(int reps, int squeeze, int relax);

  /// No description provided for @s1BlockRestDetail.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String s1BlockRestDetail(int seconds);

  /// No description provided for @s1PositionLyingOrSitting.
  ///
  /// In en, this message translates to:
  /// **'Lie on your back with knees bent, or sit. Keep breathing.'**
  String get s1PositionLyingOrSitting;

  /// No description provided for @s1PositionSitting.
  ///
  /// In en, this message translates to:
  /// **'Sit upright with feet flat. Keep breathing.'**
  String get s1PositionSitting;

  /// No description provided for @s1PositionSittingAndStanding.
  ///
  /// In en, this message translates to:
  /// **'Sit for some reps, then stand. Keep breathing.'**
  String get s1PositionSittingAndStanding;

  /// No description provided for @s1PositionStanding.
  ///
  /// In en, this message translates to:
  /// **'Stand with soft knees. Keep breathing.'**
  String get s1PositionStanding;

  /// No description provided for @s1PositionAny.
  ///
  /// In en, this message translates to:
  /// **'Use any comfortable position. Keep breathing.'**
  String get s1PositionAny;

  /// No description provided for @s1ShowMeHow.
  ///
  /// In en, this message translates to:
  /// **'Show me how'**
  String get s1ShowMeHow;

  /// No description provided for @s1Start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get s1Start;

  /// No description provided for @s1VibrationCues.
  ///
  /// In en, this message translates to:
  /// **'Vibration cues'**
  String get s1VibrationCues;

  /// No description provided for @s1VoiceCues.
  ///
  /// In en, this message translates to:
  /// **'Voice cues'**
  String get s1VoiceCues;

  /// No description provided for @s1VoicePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Off by default for privacy'**
  String get s1VoicePrivacy;

  /// No description provided for @s1LyingSemantic.
  ///
  /// In en, this message translates to:
  /// **'Person lying on their back with knees bent'**
  String get s1LyingSemantic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
