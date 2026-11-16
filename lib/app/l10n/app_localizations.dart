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
  /// **'Do and don\'t'**
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

  /// No description provided for @s1RelaxationDay.
  ///
  /// In en, this message translates to:
  /// **'Relaxation · Day {day}'**
  String s1RelaxationDay(int day);

  /// No description provided for @s1SessionOf.
  ///
  /// In en, this message translates to:
  /// **'Session {number} of {total}'**
  String s1SessionOf(int number, int total);

  /// No description provided for @s1Meta.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds · {parts, plural, =1{1 part} other{{parts} parts}}'**
  String s1Meta(int seconds, int parts);

  /// No description provided for @s1MetaMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {parts, plural, =1{1 part} other{{parts} parts}}'**
  String s1MetaMinutes(int minutes, int parts);

  /// No description provided for @s1ReverseKegelDescription.
  ///
  /// In en, this message translates to:
  /// **'Gently release and lengthen instead of squeezing.'**
  String get s1ReverseKegelDescription;

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

  /// No description provided for @s2GetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get s2GetReady;

  /// No description provided for @s2TapToSkip.
  ///
  /// In en, this message translates to:
  /// **'Tap to skip'**
  String get s2TapToSkip;

  /// No description provided for @s3BlockRepHeader.
  ///
  /// In en, this message translates to:
  /// **'{block} · {rep} of {total}'**
  String s3BlockRepHeader(String block, int rep, int total);

  /// No description provided for @s3RepOf.
  ///
  /// In en, this message translates to:
  /// **'Rep {rep} of {total}'**
  String s3RepOf(int rep, int total);

  /// No description provided for @s3CueBreathing.
  ///
  /// In en, this message translates to:
  /// **'Keep breathing normally'**
  String get s3CueBreathing;

  /// No description provided for @s3CueRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Buttocks, thighs and stomach stay relaxed'**
  String get s3CueRelaxed;

  /// No description provided for @s3CueLetGo.
  ///
  /// In en, this message translates to:
  /// **'Let go completely'**
  String get s3CueLetGo;

  /// No description provided for @s3CueGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle effort is enough'**
  String get s3CueGentle;

  /// No description provided for @s3NowBlock.
  ///
  /// In en, this message translates to:
  /// **'Now: {block}'**
  String s3NowBlock(String block);

  /// No description provided for @s3NextBlock.
  ///
  /// In en, this message translates to:
  /// **'Next: {block}'**
  String s3NextBlock(String block);

  /// No description provided for @s3NoNextBlock.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get s3NoNextBlock;

  /// No description provided for @s3BlockStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get s3BlockStretch;

  /// No description provided for @s3Pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get s3Pause;

  /// No description provided for @s3Resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get s3Resume;

  /// No description provided for @s3Voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get s3Voice;

  /// No description provided for @s3Vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get s3Vibration;

  /// No description provided for @s3Exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get s3Exit;

  /// No description provided for @s3ExitTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get s3ExitTitle;

  /// No description provided for @s3ExitMessage.
  ///
  /// In en, this message translates to:
  /// **'A partial session is not counted.'**
  String get s3ExitMessage;

  /// No description provided for @s3ExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get s3ExitConfirm;

  /// No description provided for @s4Title.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get s4Title;

  /// No description provided for @s4TimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get s4TimeLabel;

  /// No description provided for @s4TimeSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String s4TimeSeconds(int seconds);

  /// No description provided for @s4TimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String s4TimeMinutes(int minutes);

  /// No description provided for @s4StreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get s4StreakLabel;

  /// No description provided for @s4StreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String s4StreakDays(int days);

  /// No description provided for @s4NextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next today'**
  String get s4NextLabel;

  /// No description provided for @s4NextNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing else scheduled'**
  String get s4NextNone;

  /// No description provided for @s4FeelPrompt.
  ///
  /// In en, this message translates to:
  /// **'How did that feel?'**
  String get s4FeelPrompt;

  /// No description provided for @s4FeelFine.
  ///
  /// In en, this message translates to:
  /// **'Fine'**
  String get s4FeelFine;

  /// No description provided for @s4FeelMild.
  ///
  /// In en, this message translates to:
  /// **'Mild discomfort'**
  String get s4FeelMild;

  /// No description provided for @s4FeelPain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get s4FeelPain;

  /// No description provided for @s4StepDownSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Two sessions with mild discomfort. Consider stepping down a level in Levels.'**
  String get s4StepDownSuggestion;

  /// No description provided for @h3Title.
  ///
  /// In en, this message translates to:
  /// **'Pain help'**
  String get h3Title;

  /// No description provided for @h3Headline.
  ///
  /// In en, this message translates to:
  /// **'Stop squeezing exercises for now'**
  String get h3Headline;

  /// No description provided for @h3Body.
  ///
  /// In en, this message translates to:
  /// **'Stop the squeezing exercises for now. Pain can mean the muscles are too tight, and more squeezing can make that worse.'**
  String get h3Body;

  /// No description provided for @h3BodyDetail.
  ///
  /// In en, this message translates to:
  /// **'Pain can mean the pelvic floor muscles are too tight. Squeezing more can make that worse. Relaxing them is the better starting point.'**
  String get h3BodyDetail;

  /// No description provided for @h3TrackBadge.
  ///
  /// In en, this message translates to:
  /// **'Relaxation track, daily'**
  String get h3TrackBadge;

  /// No description provided for @h3TrackBreathing.
  ///
  /// In en, this message translates to:
  /// **'Belly breathing · 2 min'**
  String get h3TrackBreathing;

  /// No description provided for @h3TrackReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse Kegel: gently let go · 2 min'**
  String get h3TrackReverse;

  /// No description provided for @h3TrackStretch.
  ///
  /// In en, this message translates to:
  /// **'Child\'s pose stretch · 1 to 3 min'**
  String get h3TrackStretch;

  /// No description provided for @h3ClinicianNote.
  ///
  /// In en, this message translates to:
  /// **'See a doctor or pelvic floor physiotherapist if the pain continues, or if you have pain with erection or ejaculation.'**
  String get h3ClinicianNote;

  /// No description provided for @h3SwitchRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Switch me to relaxation exercises'**
  String get h3SwitchRelaxation;

  /// No description provided for @h3KeepPlan.
  ///
  /// In en, this message translates to:
  /// **'Keep my plan'**
  String get h3KeepPlan;

  /// No description provided for @h3ConfirmRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Switch me to relaxation exercises'**
  String get h3ConfirmRelaxation;

  /// No description provided for @h3SwitchedConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are on relaxation exercises now. Strengthening is paused.'**
  String get h3SwitchedConfirm;

  /// No description provided for @h3IllustrationSemantic.
  ///
  /// In en, this message translates to:
  /// **'Person resting in a gentle stretch pose'**
  String get h3IllustrationSemantic;

  /// No description provided for @h1Streak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak} =1{1-day streak} other{{count}-day streak}}'**
  String h1Streak(int count);

  /// No description provided for @h1LevelDayOf.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · Day {day} of {total}'**
  String h1LevelDayOf(int level, int day, int total);

  /// No description provided for @h1RelaxationDayOf.
  ///
  /// In en, this message translates to:
  /// **'Relaxation · Day {day} of {total}'**
  String h1RelaxationDayOf(int day, int total);

  /// No description provided for @h1LevelName.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {name}'**
  String h1LevelName(int level, String name);

  /// No description provided for @h1DayProgress.
  ///
  /// In en, this message translates to:
  /// **'{done, plural, =1{1 of {total} days} other{{done} of {total} days}}'**
  String h1DayProgress(int done, int total);

  /// No description provided for @h1WeekRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get h1WeekRest;

  /// No description provided for @h1Percent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String h1Percent(int percent);

  /// No description provided for @h1SessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Session {number}'**
  String h1SessionLabel(int number);

  /// No description provided for @h1SessionOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get h1SessionOptional;

  /// No description provided for @h1BreathingLabel.
  ///
  /// In en, this message translates to:
  /// **'Relaxation breathing'**
  String get h1BreathingLabel;

  /// No description provided for @h1ReverseLabel.
  ///
  /// In en, this message translates to:
  /// **'Reverse Kegel'**
  String get h1ReverseLabel;

  /// No description provided for @h1DurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String h1DurationSeconds(int seconds);

  /// No description provided for @h1DurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min} other{{minutes} min}}'**
  String h1DurationMinutes(int minutes);

  /// No description provided for @h1ItemDoneMeta.
  ///
  /// In en, this message translates to:
  /// **'Done · {duration}'**
  String h1ItemDoneMeta(String duration);

  /// No description provided for @h1ItemPendingMeta.
  ///
  /// In en, this message translates to:
  /// **'{duration}'**
  String h1ItemPendingMeta(String duration);

  /// No description provided for @h1StartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get h1StartSession;

  /// No description provided for @h1FeltPain.
  ///
  /// In en, this message translates to:
  /// **'I felt pain'**
  String get h1FeltPain;

  /// No description provided for @h1AllDone.
  ///
  /// In en, this message translates to:
  /// **'Done for today. Rest is part of the training.'**
  String get h1AllDone;

  /// No description provided for @h1RestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest day. Your muscles recover today.'**
  String get h1RestDay;

  /// No description provided for @h1DailyCap.
  ///
  /// In en, this message translates to:
  /// **'That is enough for today. Doing more can tire the muscles and slow progress.'**
  String get h1DailyCap;

  /// No description provided for @h1UpdateCatheter.
  ///
  /// In en, this message translates to:
  /// **'Update my answer'**
  String get h1UpdateCatheter;

  /// No description provided for @h1CatheterClearedTitle.
  ///
  /// In en, this message translates to:
  /// **'Catheter removed?'**
  String get h1CatheterClearedTitle;

  /// No description provided for @h1CatheterClearedMessage.
  ///
  /// In en, this message translates to:
  /// **'Only continue if your care team says you can start these exercises.'**
  String get h1CatheterClearedMessage;

  /// No description provided for @h1CatheterClearedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, update answer'**
  String get h1CatheterClearedConfirm;

  /// No description provided for @h1WeekMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get h1WeekMon;

  /// No description provided for @h1WeekTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get h1WeekTue;

  /// No description provided for @h1WeekWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get h1WeekWed;

  /// No description provided for @h1WeekThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get h1WeekThu;

  /// No description provided for @h1WeekFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get h1WeekFri;

  /// No description provided for @h1WeekSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get h1WeekSat;

  /// No description provided for @h1WeekSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get h1WeekSun;

  /// No description provided for @h1LevelCardSemantic.
  ///
  /// In en, this message translates to:
  /// **'Open levels'**
  String get h1LevelCardSemantic;

  /// No description provided for @h2Title.
  ///
  /// In en, this message translates to:
  /// **'Your levels'**
  String get h2Title;

  /// No description provided for @h2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'{track} plan. Each level makes holds a little longer.'**
  String h2Subtitle(String track);

  /// No description provided for @h2SubtitleRelaxation.
  ///
  /// In en, this message translates to:
  /// **'{track} plan. Breathing and stretches come before strengthening.'**
  String h2SubtitleRelaxation(String track);

  /// No description provided for @h2Current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get h2Current;

  /// No description provided for @h2Premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get h2Premium;

  /// No description provided for @h2DaysOf.
  ///
  /// In en, this message translates to:
  /// **'{done, plural, =1{1 of {total} days} other{{done} of {total} days}}'**
  String h2DaysOf(int done, int total);

  /// No description provided for @h2DayRange.
  ///
  /// In en, this message translates to:
  /// **'Days {start}–{end}'**
  String h2DayRange(int start, int end);

  /// No description provided for @h2DayOnward.
  ///
  /// In en, this message translates to:
  /// **'Day {start} onward'**
  String h2DayOnward(int start);

  /// No description provided for @h2LevelMeta.
  ///
  /// In en, this message translates to:
  /// **'{range} · {holds}, {position}'**
  String h2LevelMeta(String range, String holds, String position);

  /// No description provided for @h2RelaxationName.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get h2RelaxationName;

  /// No description provided for @h2RelaxationMeta.
  ///
  /// In en, this message translates to:
  /// **'Days 1–{days} · daily breathing and stretches'**
  String h2RelaxationMeta(int days);

  /// No description provided for @h2RelaxationLevel1Note.
  ///
  /// In en, this message translates to:
  /// **'If the pain has settled and a clinician agrees, you can start Level 1.'**
  String get h2RelaxationLevel1Note;

  /// No description provided for @h2HoldsFixed.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s holds'**
  String h2HoldsFixed(int seconds);

  /// No description provided for @h2HoldsRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} s holds'**
  String h2HoldsRange(int min, int max);

  /// No description provided for @h2PositionLyingOrSitting.
  ///
  /// In en, this message translates to:
  /// **'lying or sitting'**
  String get h2PositionLyingOrSitting;

  /// No description provided for @h2PositionSitting.
  ///
  /// In en, this message translates to:
  /// **'sitting'**
  String get h2PositionSitting;

  /// No description provided for @h2PositionSittingAndStanding.
  ///
  /// In en, this message translates to:
  /// **'sitting and standing'**
  String get h2PositionSittingAndStanding;

  /// No description provided for @h2PositionStanding.
  ///
  /// In en, this message translates to:
  /// **'standing'**
  String get h2PositionStanding;

  /// No description provided for @h2PositionAny.
  ///
  /// In en, this message translates to:
  /// **'everyday moves'**
  String get h2PositionAny;

  /// No description provided for @h2PositionExtras.
  ///
  /// In en, this message translates to:
  /// **'bridge and squat'**
  String get h2PositionExtras;

  /// No description provided for @h2UnlockNote.
  ///
  /// In en, this message translates to:
  /// **'The next level unlocks when you complete 5 of the last 7 days. Missed a few days? Your plan simply waits for you.'**
  String get h2UnlockNote;

  /// No description provided for @h2UnlockNoteRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Strengthening levels stay below until the relaxation weeks are done. If the pain has settled and a clinician agrees, you can start Level 1.'**
  String get h2UnlockNoteRelaxation;

  /// No description provided for @h2StatusUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get h2StatusUnlocked;

  /// No description provided for @h2StatusUnlocksWhen.
  ///
  /// In en, this message translates to:
  /// **'Unlocks when you complete 5 of the last 7 days'**
  String get h2StatusUnlocksWhen;

  /// No description provided for @h2StartLevel.
  ///
  /// In en, this message translates to:
  /// **'Start Level {level}'**
  String h2StartLevel(int level);

  /// No description provided for @h1LevelUnlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {level} unlocked'**
  String h1LevelUnlockedTitle(int level);

  /// No description provided for @h1LevelUnlockedStart.
  ///
  /// In en, this message translates to:
  /// **'Start Level {level}'**
  String h1LevelUnlockedStart(int level);

  /// No description provided for @h1LevelUnlockedStay.
  ///
  /// In en, this message translates to:
  /// **'Stay on this level a bit longer'**
  String get h1LevelUnlockedStay;

  /// No description provided for @h1LevelStartedConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are on Level {level}.'**
  String h1LevelStartedConfirm(int level);

  /// No description provided for @h2RepeatOrStepDown.
  ///
  /// In en, this message translates to:
  /// **'Repeat or step down a level'**
  String get h2RepeatOrStepDown;

  /// No description provided for @h2RepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat this level?'**
  String get h2RepeatTitle;

  /// No description provided for @h2RepeatMessage.
  ///
  /// In en, this message translates to:
  /// **'Day progress for this level resets. Your session history stays on the device.'**
  String get h2RepeatMessage;

  /// No description provided for @h2RepeatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Repeat level'**
  String get h2RepeatConfirm;

  /// No description provided for @h2StepDownTitle.
  ///
  /// In en, this message translates to:
  /// **'Step down one level?'**
  String get h2StepDownTitle;

  /// No description provided for @h2StepDownMessage.
  ///
  /// In en, this message translates to:
  /// **'You will train at the previous level. This never happens automatically.'**
  String get h2StepDownMessage;

  /// No description provided for @h2StepDownConfirm.
  ///
  /// In en, this message translates to:
  /// **'Step down'**
  String get h2StepDownConfirm;

  /// No description provided for @h2ChooseActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust your level'**
  String get h2ChooseActionTitle;

  /// No description provided for @h2ChooseRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat current level'**
  String get h2ChooseRepeat;

  /// No description provided for @h2ChooseStepDown.
  ///
  /// In en, this message translates to:
  /// **'Step down one level'**
  String get h2ChooseStepDown;

  /// No description provided for @h2LevelNameStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get h2LevelNameStart;

  /// No description provided for @h2LevelNameBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get h2LevelNameBuild;

  /// No description provided for @h2LevelNameSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get h2LevelNameSteady;

  /// No description provided for @h2LevelNameDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get h2LevelNameDeep;

  /// No description provided for @h2LevelNameMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get h2LevelNameMaintain;

  /// No description provided for @g1SettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get g1SettingsTooltip;

  /// No description provided for @g1StatStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get g1StatStreakLabel;

  /// No description provided for @g1StatStreakValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String g1StatStreakValue(int count);

  /// No description provided for @g1StatWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get g1StatWeekLabel;

  /// No description provided for @g1StatWeekValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 sessions} =1{1 session} other{{count} sessions}}'**
  String g1StatWeekValue(int count);

  /// No description provided for @g1StatHoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest hold'**
  String get g1StatHoldLabel;

  /// No description provided for @g1StatHoldValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String g1StatHoldValue(int seconds);

  /// No description provided for @g1StatLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get g1StatLevelLabel;

  /// No description provided for @g1StatLevelDay.
  ///
  /// In en, this message translates to:
  /// **'{level} · day {day}'**
  String g1StatLevelDay(int level, int day);

  /// No description provided for @g1StatRelaxationLabel.
  ///
  /// In en, this message translates to:
  /// **'Relaxation plan'**
  String get g1StatRelaxationLabel;

  /// No description provided for @g1StatRelaxationDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String g1StatRelaxationDay(int day, int total);

  /// No description provided for @h1RelaxationWeeksTitle.
  ///
  /// In en, this message translates to:
  /// **'Weeks 1 to 2'**
  String get h1RelaxationWeeksTitle;

  /// No description provided for @g1CalPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get g1CalPrevious;

  /// No description provided for @g1CalNext.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get g1CalNext;

  /// No description provided for @g1CalTrained.
  ///
  /// In en, this message translates to:
  /// **'Trained'**
  String get g1CalTrained;

  /// No description provided for @g1CalMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String g1CalMonthYear(String month, int year);

  /// No description provided for @g1CalMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get g1CalMon;

  /// No description provided for @g1CalTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get g1CalTue;

  /// No description provided for @g1CalWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get g1CalWed;

  /// No description provided for @g1CalThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get g1CalThu;

  /// No description provided for @g1CalFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get g1CalFri;

  /// No description provided for @g1CalSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get g1CalSat;

  /// No description provided for @g1CalSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get g1CalSun;

  /// No description provided for @g1MonthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get g1MonthJanuary;

  /// No description provided for @g1MonthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get g1MonthFebruary;

  /// No description provided for @g1MonthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get g1MonthMarch;

  /// No description provided for @g1MonthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get g1MonthApril;

  /// No description provided for @g1MonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get g1MonthMay;

  /// No description provided for @g1MonthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get g1MonthJune;

  /// No description provided for @g1MonthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get g1MonthJuly;

  /// No description provided for @g1MonthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get g1MonthAugust;

  /// No description provided for @g1MonthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get g1MonthSeptember;

  /// No description provided for @g1MonthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get g1MonthOctober;

  /// No description provided for @g1MonthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get g1MonthNovember;

  /// No description provided for @g1MonthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get g1MonthDecember;

  /// No description provided for @g1CheckInBaselineTitle.
  ///
  /// In en, this message translates to:
  /// **'Baseline check-in'**
  String get g1CheckInBaselineTitle;

  /// No description provided for @g1CheckInBaselineBody.
  ///
  /// In en, this message translates to:
  /// **'One question, 10 seconds. See your own change over time.'**
  String get g1CheckInBaselineBody;

  /// No description provided for @g1CheckInFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'4-week check-in'**
  String get g1CheckInFollowUpTitle;

  /// No description provided for @g1CheckInFollowUpBody.
  ///
  /// In en, this message translates to:
  /// **'One question. Compare with your earlier answer.'**
  String get g1CheckInFollowUpBody;

  /// No description provided for @g1CheckInHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your check-ins'**
  String get g1CheckInHistoryTitle;

  /// No description provided for @g1CheckInStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get g1CheckInStart;

  /// No description provided for @g1CheckInLockedHint.
  ///
  /// In en, this message translates to:
  /// **'A short check-in unlocks after your third completed session.'**
  String get g1CheckInLockedHint;

  /// No description provided for @g1CheckInUnlockHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlock check-in history'**
  String get g1CheckInUnlockHistory;

  /// No description provided for @g2EyebrowBaseline.
  ///
  /// In en, this message translates to:
  /// **'WEEK 0 · BASELINE'**
  String get g2EyebrowBaseline;

  /// No description provided for @g2EyebrowFollowUp.
  ///
  /// In en, this message translates to:
  /// **'4-WEEK CHECK-IN'**
  String get g2EyebrowFollowUp;

  /// No description provided for @g2SubtitleBaseline.
  ///
  /// In en, this message translates to:
  /// **'We will ask again in 4 weeks and show you both answers side by side.'**
  String get g2SubtitleBaseline;

  /// No description provided for @g2SubtitleFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Your answers stay on this phone. No predictions.'**
  String get g2SubtitleFollowUp;

  /// No description provided for @g2PrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Saved only on this phone'**
  String get g2PrivacyNote;

  /// No description provided for @g2Save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get g2Save;

  /// No description provided for @g2Skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get g2Skip;

  /// No description provided for @g2Done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get g2Done;

  /// No description provided for @g2ResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your check-in'**
  String get g2ResultTitle;

  /// No description provided for @g2ResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your own numbers, side by side. Results vary.'**
  String get g2ResultSubtitle;

  /// No description provided for @g2ComparisonLine.
  ///
  /// In en, this message translates to:
  /// **'Week {week}: {score} of {max} · {label}'**
  String g2ComparisonLine(int week, int score, int max, String label);

  /// No description provided for @g2DoctorNote.
  ///
  /// In en, this message translates to:
  /// **'Exercises do not help everyone. It is worth talking to a doctor.'**
  String get g2DoctorNote;

  /// No description provided for @g2HistoryPremiumHint.
  ///
  /// In en, this message translates to:
  /// **'Full check-in history is part of Premium.'**
  String get g2HistoryPremiumHint;

  /// No description provided for @g2QuestionBladder.
  ///
  /// In en, this message translates to:
  /// **'In the last week, how often did you leak urine?'**
  String get g2QuestionBladder;

  /// No description provided for @g2OptionBladder1.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get g2OptionBladder1;

  /// No description provided for @g2OptionBladder2.
  ///
  /// In en, this message translates to:
  /// **'Once or twice'**
  String get g2OptionBladder2;

  /// No description provided for @g2OptionBladder3.
  ///
  /// In en, this message translates to:
  /// **'A few times'**
  String get g2OptionBladder3;

  /// No description provided for @g2OptionBladder4.
  ///
  /// In en, this message translates to:
  /// **'Most days'**
  String get g2OptionBladder4;

  /// No description provided for @g2OptionBladder5.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get g2OptionBladder5;

  /// No description provided for @g2QuestionErection.
  ///
  /// In en, this message translates to:
  /// **'How would you rate erection firmness in the last week?'**
  String get g2QuestionErection;

  /// No description provided for @g2OptionErection1.
  ///
  /// In en, this message translates to:
  /// **'Very soft'**
  String get g2OptionErection1;

  /// No description provided for @g2OptionErection2.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get g2OptionErection2;

  /// No description provided for @g2OptionErection3.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get g2OptionErection3;

  /// No description provided for @g2OptionErection4.
  ///
  /// In en, this message translates to:
  /// **'Firm'**
  String get g2OptionErection4;

  /// No description provided for @g2OptionErection5.
  ///
  /// In en, this message translates to:
  /// **'Very firm'**
  String get g2OptionErection5;

  /// No description provided for @g2QuestionEjaculation.
  ///
  /// In en, this message translates to:
  /// **'How much control did you feel in the last week?'**
  String get g2QuestionEjaculation;

  /// No description provided for @g2OptionEjaculation1.
  ///
  /// In en, this message translates to:
  /// **'No control'**
  String get g2OptionEjaculation1;

  /// No description provided for @g2OptionEjaculation2.
  ///
  /// In en, this message translates to:
  /// **'A little control'**
  String get g2OptionEjaculation2;

  /// No description provided for @g2OptionEjaculation3.
  ///
  /// In en, this message translates to:
  /// **'Some control'**
  String get g2OptionEjaculation3;

  /// No description provided for @g2OptionEjaculation4.
  ///
  /// In en, this message translates to:
  /// **'Good control'**
  String get g2OptionEjaculation4;

  /// No description provided for @g2OptionEjaculation5.
  ///
  /// In en, this message translates to:
  /// **'Full control'**
  String get g2OptionEjaculation5;

  /// No description provided for @g2QuestionSurgery.
  ///
  /// In en, this message translates to:
  /// **'In the last week, how well have you controlled your urine?'**
  String get g2QuestionSurgery;

  /// No description provided for @g2OptionSurgery1.
  ///
  /// In en, this message translates to:
  /// **'No control'**
  String get g2OptionSurgery1;

  /// No description provided for @g2OptionSurgery2.
  ///
  /// In en, this message translates to:
  /// **'Limited control'**
  String get g2OptionSurgery2;

  /// No description provided for @g2OptionSurgery3.
  ///
  /// In en, this message translates to:
  /// **'Some control'**
  String get g2OptionSurgery3;

  /// No description provided for @g2OptionSurgery4.
  ///
  /// In en, this message translates to:
  /// **'Good control'**
  String get g2OptionSurgery4;

  /// No description provided for @g2OptionSurgery5.
  ///
  /// In en, this message translates to:
  /// **'Full control'**
  String get g2OptionSurgery5;

  /// No description provided for @g2QuestionGeneral.
  ///
  /// In en, this message translates to:
  /// **'In the last week, how comfortable has your pelvic area felt?'**
  String get g2QuestionGeneral;

  /// No description provided for @g2OptionGeneral1.
  ///
  /// In en, this message translates to:
  /// **'Very uncomfortable'**
  String get g2OptionGeneral1;

  /// No description provided for @g2OptionGeneral2.
  ///
  /// In en, this message translates to:
  /// **'Uncomfortable'**
  String get g2OptionGeneral2;

  /// No description provided for @g2OptionGeneral3.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get g2OptionGeneral3;

  /// No description provided for @g2OptionGeneral4.
  ///
  /// In en, this message translates to:
  /// **'Mostly comfortable'**
  String get g2OptionGeneral4;

  /// No description provided for @g2OptionGeneral5.
  ///
  /// In en, this message translates to:
  /// **'Very comfortable'**
  String get g2OptionGeneral5;

  /// No description provided for @l1ArticlesHeading.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get l1ArticlesHeading;

  /// No description provided for @l1StartHere.
  ///
  /// In en, this message translates to:
  /// **'Start here · {minutes} min'**
  String l1StartHere(int minutes);

  /// No description provided for @l1ReplayTutorial.
  ///
  /// In en, this message translates to:
  /// **'Replay the tutorial anytime'**
  String get l1ReplayTutorial;

  /// No description provided for @l1Minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String l1Minutes(int minutes);

  /// No description provided for @l2MinutesRead.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String l2MinutesRead(int minutes);

  /// No description provided for @l2Sources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get l2Sources;

  /// No description provided for @l2NotFound.
  ///
  /// In en, this message translates to:
  /// **'Article not found.'**
  String get l2NotFound;

  /// No description provided for @x1Title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get x1Title;

  /// No description provided for @x1SectionPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get x1SectionPlan;

  /// No description provided for @x1SectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get x1SectionReminders;

  /// No description provided for @x1SectionSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get x1SectionSession;

  /// No description provided for @x1SectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get x1SectionPrivacy;

  /// No description provided for @x1SectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get x1SectionSubscription;

  /// No description provided for @x1SectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get x1SectionAbout;

  /// No description provided for @x1Goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get x1Goal;

  /// No description provided for @x1GoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get x1GoalTitle;

  /// No description provided for @x1DailyTime.
  ///
  /// In en, this message translates to:
  /// **'Daily time'**
  String get x1DailyTime;

  /// No description provided for @x1DailyTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions per day'**
  String get x1DailyTimeTitle;

  /// No description provided for @x1DailySessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session a day} other{{count} sessions a day}}'**
  String x1DailySessions(int count);

  /// No description provided for @x1SafetyAnswers.
  ///
  /// In en, this message translates to:
  /// **'Safety answers'**
  String get x1SafetyAnswers;

  /// No description provided for @x1SafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety answers'**
  String get x1SafetyTitle;

  /// No description provided for @x1ValueNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get x1ValueNone;

  /// No description provided for @x1SafetySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String x1SafetySelectedCount(int count);

  /// No description provided for @x1DailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get x1DailyReminder;

  /// No description provided for @x1TimeAndDays.
  ///
  /// In en, this message translates to:
  /// **'Time and days'**
  String get x1TimeAndDays;

  /// No description provided for @x1ReminderScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder time and days'**
  String get x1ReminderScheduleTitle;

  /// No description provided for @x1EveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get x1EveryDay;

  /// No description provided for @x1Daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get x1Daily;

  /// No description provided for @x1DaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String x1DaysCount(int count);

  /// No description provided for @x1Vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration cues'**
  String get x1Vibration;

  /// No description provided for @x1Voice.
  ///
  /// In en, this message translates to:
  /// **'Voice cues'**
  String get x1Voice;

  /// No description provided for @x1Discreet.
  ///
  /// In en, this message translates to:
  /// **'Discreet notifications'**
  String get x1Discreet;

  /// No description provided for @x1DiscreetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No health words on the lock screen.'**
  String get x1DiscreetSubtitle;

  /// No description provided for @x1DeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all my data'**
  String get x1DeleteAll;

  /// No description provided for @x1DeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get x1DeleteTitle;

  /// No description provided for @x1DeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes your plan, sessions and check-ins from this phone. It cannot be undone.'**
  String get x1DeleteMessage;

  /// No description provided for @x1DeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get x1DeleteConfirm;

  /// No description provided for @x1ManagePlay.
  ///
  /// In en, this message translates to:
  /// **'Manage in Google Play'**
  String get x1ManagePlay;

  /// No description provided for @x1ManageAppStore.
  ///
  /// In en, this message translates to:
  /// **'Manage in the App Store'**
  String get x1ManageAppStore;

  /// No description provided for @x1Free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get x1Free;

  /// No description provided for @x1Premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get x1Premium;

  /// No description provided for @x1Restore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get x1Restore;

  /// No description provided for @x1RestoreStub.
  ///
  /// In en, this message translates to:
  /// **'Restore will be available when subscriptions ship.'**
  String get x1RestoreStub;

  /// No description provided for @x1LegalRow.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer, privacy and terms'**
  String get x1LegalRow;

  /// No description provided for @x1PrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get x1PrivacyPolicy;

  /// No description provided for @x1Terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get x1Terms;

  /// No description provided for @x1Contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get x1Contact;

  /// No description provided for @x1VersionFooter.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · Not a medical device'**
  String x1VersionFooter(String version);
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
