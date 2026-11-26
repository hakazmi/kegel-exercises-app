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

  /// No description provided for @o1TitleBefore.
  ///
  /// In en, this message translates to:
  /// **'Train your pelvic floor in a '**
  String get o1TitleBefore;

  /// No description provided for @o1TitleAccent.
  ///
  /// In en, this message translates to:
  /// **'few minutes'**
  String get o1TitleAccent;

  /// No description provided for @o1TitleAfter.
  ///
  /// In en, this message translates to:
  /// **' a day'**
  String get o1TitleAfter;

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

  /// No description provided for @o1FeatureBladder.
  ///
  /// In en, this message translates to:
  /// **'Better bladder control'**
  String get o1FeatureBladder;

  /// No description provided for @o1FeaturePlan.
  ///
  /// In en, this message translates to:
  /// **'A plan that grows with you'**
  String get o1FeaturePlan;

  /// No description provided for @o1FeaturePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private on this phone'**
  String get o1FeaturePrivate;

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
  /// **'Athletic man squatting beside a pelvic bone graphic with pelvic floor muscles highlighted in red'**
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

  /// No description provided for @o2HeroSemantic.
  ///
  /// In en, this message translates to:
  /// **'Green shield with pelvic health graphic'**
  String get o2HeroSemantic;

  /// No description provided for @o2GoalBladder.
  ///
  /// In en, this message translates to:
  /// **'Bladder control'**
  String get o2GoalBladder;

  /// No description provided for @o2GoalBladderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Holds, quick squeezes and urge habits'**
  String get o2GoalBladderSubtitle;

  /// No description provided for @o2GoalErection.
  ///
  /// In en, this message translates to:
  /// **'Erection support'**
  String get o2GoalErection;

  /// No description provided for @o2GoalErectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Holds, bridges and walking goals'**
  String get o2GoalErectionSubtitle;

  /// No description provided for @o2GoalEjaculation.
  ///
  /// In en, this message translates to:
  /// **'Ejaculation control'**
  String get o2GoalEjaculation;

  /// No description provided for @o2GoalEjaculationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Squeezes plus reverse Kegels'**
  String get o2GoalEjaculationSubtitle;

  /// No description provided for @o2GoalSurgery.
  ///
  /// In en, this message translates to:
  /// **'Recovery after prostate surgery'**
  String get o2GoalSurgery;

  /// No description provided for @o2GoalSurgerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gentler holds after catheter removal'**
  String get o2GoalSurgerySubtitle;

  /// No description provided for @o2GoalGeneral.
  ///
  /// In en, this message translates to:
  /// **'General pelvic health'**
  String get o2GoalGeneral;

  /// No description provided for @o2GoalGeneralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A balanced mix of strength and ease'**
  String get o2GoalGeneralSubtitle;

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

  /// No description provided for @o3HeroSemantic.
  ///
  /// In en, this message translates to:
  /// **'Man holding lower abdomen beside a pelvic graphic with a green check'**
  String get o3HeroSemantic;

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

  /// No description provided for @o4HeroSemantic.
  ///
  /// In en, this message translates to:
  /// **'Man thinking about his Kegel exercise experience'**
  String get o4HeroSemantic;

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

  /// No description provided for @o5HeroSemantic.
  ///
  /// In en, this message translates to:
  /// **'Man meditating beside a stopwatch showing daily training time'**
  String get o5HeroSemantic;

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
  /// **'Start my plan'**
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
  /// **'Animated pelvic floor view: red muscles squeeze, hold, then relax around the central opening between the sitting bones'**
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

  /// No description provided for @s3PhaseHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get s3PhaseHold;

  /// No description provided for @s3PhaseRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get s3PhaseRest;

  /// No description provided for @s3PhaseBreatheIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get s3PhaseBreatheIn;

  /// No description provided for @s3PhaseBreatheOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get s3PhaseBreatheOut;

  /// No description provided for @s3PhaseDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get s3PhaseDone;

  /// No description provided for @s3PhaseLift.
  ///
  /// In en, this message translates to:
  /// **'Lift'**
  String get s3PhaseLift;

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

  /// No description provided for @h1Tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get h1Tomorrow;

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
  /// **'Each level week is 6 training days and 1 rest day. The next level unlocks when you finish this level\'s training days and have trained on at least 5 of the last 7 days. Missed a few days? Your plan simply waits for you.'**
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
  /// **'Unlocks when you finish this level and train on 5 of the last 7 days'**
  String get h2StatusUnlocksWhen;

  /// No description provided for @h2StatusUnlocksTrainingLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Unlocks after 1 more training day} other{Unlocks after {count} more training days}}'**
  String h2StatusUnlocksTrainingLeft(int count);

  /// No description provided for @h2StatusUnlocksWindowLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Unlocks after 1 more trained day in the last 7} other{Unlocks after {count} more trained days in the last 7}}'**
  String h2StatusUnlocksWindowLeft(int count);

  /// No description provided for @h2StartLevel.
  ///
  /// In en, this message translates to:
  /// **'Start Level {level}'**
  String h2StartLevel(int level);

  /// No description provided for @h2TestCompleteLevel.
  ///
  /// In en, this message translates to:
  /// **'Complete level (test)'**
  String get h2TestCompleteLevel;

  /// No description provided for @h2TestCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get h2TestCompleted;

  /// No description provided for @h2TestCompleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are on Level {level}. Test jump only — remove before store release.'**
  String h2TestCompleteConfirm(int level);

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

  /// Short line on the Today level card; key is l<level><a-d> or r<a-d> for relaxation
  ///
  /// In en, this message translates to:
  /// **'{key, select, l1a{Every session counts. Squeeze gently, then fully relax.} l1b{Find the muscles, then let them fully let go.} l1c{Small, steady reps build a habit you can keep.} l1d{Keep breathing. Soften buttocks, thighs and stomach.} l2a{A little longer each hold. Quality over quantity.} l2b{Steady holds, easy breathing, full release.} l2c{You are building a routine. Keep showing up.} l2d{Rest fully between reps. The release matters too.} l3a{Consistency matters more than intensity.} l3b{Bring the squeeze into everyday moments.} l3c{Control the lift, then control the release.} l3d{Short sessions, done often, add up.} l4a{Longer holds now. Rest if it feels like strain.} l4b{Strong squeeze, slow release, steady breath.} l4c{Every rep is practice in control.} l4d{Stay tall, stay relaxed, keep breathing.} l5a{A few minutes a day keeps the habit going.} l5b{Keep the routine that got you here.} l5c{Steady practice, week after week.} l5d{Pair your session with something you already do each day.} ra{Today is about letting go, not squeezing.} rb{Slow breaths. Let the pelvic floor soften.} rc{Relaxation is training too.} other{Go gently. Stop if anything hurts.}}'**
  String h1Motivation(String key);

  /// No description provided for @l1VideoBadge.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get l1VideoBadge;

  /// No description provided for @l1GuideBadge.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get l1GuideBadge;

  /// No description provided for @l1Clips.
  ///
  /// In en, this message translates to:
  /// **'{count} clips'**
  String l1Clips(int count);

  /// No description provided for @l1Images.
  ///
  /// In en, this message translates to:
  /// **'{count} images'**
  String l1Images(int count);

  /// No description provided for @l2WatchHeading.
  ///
  /// In en, this message translates to:
  /// **'Watch and follow'**
  String get l2WatchHeading;

  /// No description provided for @l2LookHeading.
  ///
  /// In en, this message translates to:
  /// **'See how it looks'**
  String get l2LookHeading;

  /// No description provided for @l2OpenExercise.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get l2OpenExercise;

  /// No description provided for @x1Title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get x1Title;

  /// No description provided for @x1SectionTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get x1SectionTesting;

  /// No description provided for @x1TestingPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium (Levels 2–5)'**
  String get x1TestingPremium;

  /// No description provided for @x1TestingReset.
  ///
  /// In en, this message translates to:
  /// **'Reset app — start onboarding again'**
  String get x1TestingReset;

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

  /// No description provided for @h1SectionPelvicFloor.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor'**
  String get h1SectionPelvicFloor;

  /// No description provided for @h1SectionBody.
  ///
  /// In en, this message translates to:
  /// **'Body and function'**
  String get h1SectionBody;

  /// No description provided for @h1SectionBreathe.
  ///
  /// In en, this message translates to:
  /// **'Relax and breathe'**
  String get h1SectionBreathe;

  /// No description provided for @h1SectionHabits.
  ///
  /// In en, this message translates to:
  /// **'Daily habits'**
  String get h1SectionHabits;

  /// No description provided for @h1BodyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Body and function'**
  String get h1BodyCardTitle;

  /// No description provided for @h1BodyCardLocked.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Premium'**
  String get h1BodyCardLocked;

  /// No description provided for @h1HabitDone.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get h1HabitDone;

  /// No description provided for @h1HabitMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get h1HabitMarkDone;

  /// No description provided for @h1HabitClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get h1HabitClear;

  /// No description provided for @exCueButtocksRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Buttocks, thighs and stomach stay relaxed. Keep breathing.'**
  String get exCueButtocksRelaxed;

  /// No description provided for @exCueKeepBreathing.
  ///
  /// In en, this message translates to:
  /// **'Keep breathing. Do not hold your breath.'**
  String get exCueKeepBreathing;

  /// No description provided for @exCueLegsLift.
  ///
  /// In en, this message translates to:
  /// **'Let the legs do the lifting; the squeeze stays gentle. Keep breathing.'**
  String get exCueLegsLift;

  /// No description provided for @exCueReverseLetGo.
  ///
  /// In en, this message translates to:
  /// **'Let go and lengthen. Do not push down.'**
  String get exCueReverseLetGo;

  /// No description provided for @exHabitAfterDribbleTitle.
  ///
  /// In en, this message translates to:
  /// **'After-dribble squeeze'**
  String get exHabitAfterDribbleTitle;

  /// No description provided for @exHabitAfterDribbleSteps.
  ///
  /// In en, this message translates to:
  /// **'After you finish urinating, squeeze the pelvic floor firmly once, then relax, before you leave the toilet. This is not the same as stopping the urine stream mid-flow — that test is only for finding the muscles once, never as a regular exercise.'**
  String get exHabitAfterDribbleSteps;

  /// No description provided for @exHabitUrgeControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Urge-control steps'**
  String get exHabitUrgeControlTitle;

  /// No description provided for @exHabitUrgeControlSteps.
  ///
  /// In en, this message translates to:
  /// **'When a sudden urge comes: stay still. Soften the belly and breathe. If it helps, use a few gentle pelvic floor squeezes or one easy hold — not repeated hard maximum squeezes. Wait until the urgency settles, then walk calmly to the toilet.'**
  String get exHabitUrgeControlSteps;

  /// No description provided for @exWalkingCardioNote.
  ///
  /// In en, this message translates to:
  /// **'Brisk walking is general cardiovascular activity. It is not a pelvic floor (Kegel) exercise. Regular activity may support erectile function; results vary and it is not a treatment or cure.'**
  String get exWalkingCardioNote;

  /// No description provided for @exWalkingDoctorNote.
  ///
  /// In en, this message translates to:
  /// **'If you have a heart condition or have not exercised in a while, check with your doctor first.'**
  String get exWalkingDoctorNote;

  /// No description provided for @exWalkingSurgeryNote.
  ///
  /// In en, this message translates to:
  /// **'Walk only as your care team allows.'**
  String get exWalkingSurgeryNote;

  /// No description provided for @g1WalkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Brisk walking this week'**
  String get g1WalkingTitle;

  /// No description provided for @g1WalkingGoal.
  ///
  /// In en, this message translates to:
  /// **'Aim for about 40 minutes on 4 days this week'**
  String get g1WalkingGoal;

  /// No description provided for @g1WalkingProgress.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {days} of 4 days'**
  String g1WalkingProgress(int minutes, int days);

  /// No description provided for @g1WalkingAdd.
  ///
  /// In en, this message translates to:
  /// **'Add walking minutes'**
  String get g1WalkingAdd;

  /// No description provided for @g1WalkingAddConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get g1WalkingAddConfirm;

  /// No description provided for @g1WalkingMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get g1WalkingMinutesLabel;

  /// No description provided for @g1WalkingQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} min'**
  String g1WalkingQuickAdd(int minutes);

  /// No description provided for @g1WalkingCustom.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get g1WalkingCustom;

  /// No description provided for @g1HeroDaysThisWeek.
  ///
  /// In en, this message translates to:
  /// **'days this week'**
  String get g1HeroDaysThisWeek;

  /// No description provided for @g1CalTrainedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No training days yet} =1{1 training day} other{{count} training days}}'**
  String g1CalTrainedCount(int count);

  /// No description provided for @g1CalRest.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get g1CalRest;

  /// No description provided for @h1GreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get h1GreetingMorning;

  /// No description provided for @h1GreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get h1GreetingAfternoon;

  /// No description provided for @h1GreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get h1GreetingEvening;

  /// No description provided for @h1JourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get h1JourneyTitle;

  /// No description provided for @h1JourneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String h1JourneySubtitle(int done, int total);

  /// No description provided for @h1UpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get h1UpNext;

  /// No description provided for @h1ItemStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get h1ItemStart;

  /// No description provided for @h1ItemAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'Already done today.'**
  String get h1ItemAlreadyDone;

  /// No description provided for @h1HabitsHint.
  ///
  /// In en, this message translates to:
  /// **'Tick each one once you have done it today. Tap again to clear.'**
  String get h1HabitsHint;

  /// No description provided for @s1InsideTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s inside'**
  String get s1InsideTitle;

  /// No description provided for @s1RemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get s1RemindersTitle;

  /// No description provided for @s4SubtitleSession.
  ///
  /// In en, this message translates to:
  /// **'Session {number} · Day {day}'**
  String s4SubtitleSession(int number, int day);

  /// No description provided for @s4SubtitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'One more part of today done.'**
  String get s4SubtitleGeneric;

  /// No description provided for @o6RestDayNote.
  ///
  /// In en, this message translates to:
  /// **'Your weekly rest day is {weekday}.'**
  String o6RestDayNote(String weekday);

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @h1PlanWeek.
  ///
  /// In en, this message translates to:
  /// **'Plan week {week}'**
  String h1PlanWeek(int week);

  /// No description provided for @h1ThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get h1ThisWeek;

  /// No description provided for @o4GuideHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show you a short guide before your first session'**
  String get o4GuideHint;

  /// No description provided for @o4ConfidentHint.
  ///
  /// In en, this message translates to:
  /// **'Go straight to your first session'**
  String get o4ConfidentHint;

  /// No description provided for @infoButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'About {topic}'**
  String infoButtonLabel(String topic);

  /// No description provided for @infoGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get infoGotIt;

  /// No description provided for @infoWhySlowHold.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: builds endurance, so you can keep the squeeze for longer.'**
  String get infoWhySlowHold;

  /// No description provided for @infoWhyQuickSqueeze.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: builds the fast reaction you need for a sudden cough or sneeze.'**
  String get infoWhyQuickSqueeze;

  /// No description provided for @infoWhyStrongHold.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: a firmer squeeze used in the erection support plan from Level 3.'**
  String get infoWhyStrongHold;

  /// No description provided for @infoWhyStandingHolds.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: leaks often happen upright, so holds move to standing and walking as you progress.'**
  String get infoWhyStandingHolds;

  /// No description provided for @infoWhyBridge.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: pairs the pelvic floor squeeze with the hip muscles that support it.'**
  String get infoWhyBridge;

  /// No description provided for @infoWhySquat.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: practises relaxing on the way down and squeezing on the way up, the pattern of everyday movement.'**
  String get infoWhySquat;

  /// No description provided for @infoWhySitToStand.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: standing up is a common moment for leaks, so you practise the squeeze at exactly that moment.'**
  String get infoWhySitToStand;

  /// No description provided for @infoWhyKnack.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: squeezing just before a cough, sneeze or lift trains control in the moments that cause leaks.'**
  String get infoWhyKnack;

  /// No description provided for @infoWhyPillowSqueeze.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: the inner thigh muscles work together with the pelvic floor.'**
  String get infoWhyPillowSqueeze;

  /// No description provided for @infoWhyBreathing.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: teaches the pelvic floor to let go fully between squeezes.'**
  String get infoWhyBreathing;

  /// No description provided for @infoWhyReverseKegel.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: lengthens and relaxes the muscles, useful when they feel tight or squeezing is uncomfortable.'**
  String get infoWhyReverseKegel;

  /// No description provided for @infoWhyStretch.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: a gentle stretch that helps the pelvic floor relax.'**
  String get infoWhyStretch;

  /// No description provided for @infoWhyAfterDribble.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: prostate charities recommend it to clear the last drops that stay in the urethra after you finish.'**
  String get infoWhyAfterDribble;

  /// No description provided for @infoWhyUrgeControl.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: bladder guidelines include these steps; staying calm and still gives a sudden urge time to fade.'**
  String get infoWhyUrgeControl;

  /// No description provided for @infoWhyWalking.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s here: regular aerobic activity supports heart and blood vessel health.'**
  String get infoWhyWalking;

  /// No description provided for @infoPelvicTitle.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor session'**
  String get infoPelvicTitle;

  /// No description provided for @infoPelvicBody.
  ///
  /// In en, this message translates to:
  /// **'Guided slow holds and quick squeezes. Squeeze and lift as if stopping yourself passing wind, then let go fully before the next one.'**
  String get infoPelvicBody;

  /// No description provided for @infoBodyBody.
  ///
  /// In en, this message translates to:
  /// **'Short movements that add a pelvic floor squeeze to everyday actions. Today\'s moves:'**
  String get infoBodyBody;

  /// No description provided for @infoBreatheBody.
  ///
  /// In en, this message translates to:
  /// **'Slow belly breathing and gentle relaxation. Letting the muscles go is part of the training. Today\'s parts:'**
  String get infoBreatheBody;

  /// No description provided for @infoHabitsBody.
  ///
  /// In en, this message translates to:
  /// **'Small habits for during the day, not timed sessions. Tick each one when you have done it today; tap again to untick. Habits never affect your streak or level.'**
  String get infoHabitsBody;

  /// No description provided for @infoRestTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan week'**
  String get infoRestTitle;

  /// No description provided for @infoRestBody.
  ///
  /// In en, this message translates to:
  /// **'Your plan runs in 7-day weeks starting on the day you joined. Days 1 to 6 are training days and day 7 is a rest day, when only breathing is planned. Muscles recover on rest days, and a rest day never breaks your streak.'**
  String get infoRestBody;

  /// No description provided for @infoStreakBody.
  ///
  /// In en, this message translates to:
  /// **'Days in a row with at least one completed session. Your weekly rest day never breaks it, and missed days start a new streak with no penalty.'**
  String get infoStreakBody;

  /// No description provided for @infoWeekRingBody.
  ///
  /// In en, this message translates to:
  /// **'Sessions completed since Monday. The ring on the streak card shows training days this week out of 6; the 7th day is for rest.'**
  String get infoWeekRingBody;

  /// No description provided for @infoHoldBody.
  ///
  /// In en, this message translates to:
  /// **'The longest hold the app has guided you through. A phone cannot measure your muscles, so this is the programmed hold you completed, not a measurement.'**
  String get infoHoldBody;

  /// No description provided for @infoLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'How levels work'**
  String get infoLevelsTitle;

  /// No description provided for @infoLevelsBody.
  ///
  /// In en, this message translates to:
  /// **'Each level adds longer holds or more reps. A plan week is 6 training days and 1 rest day inside the week. The next level unlocks when you finish this level\'s training days and have trained on at least 5 of the last 7 days. You can repeat or step down a level any time.'**
  String get infoLevelsBody;

  /// No description provided for @infoCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'About check-ins'**
  String get infoCheckInTitle;

  /// No description provided for @infoCheckInBody.
  ///
  /// In en, this message translates to:
  /// **'One question about your goal, answered now and again every 4 weeks, so you can compare your own answers side by side. There are no predictions or scores from other people.'**
  String get infoCheckInBody;

  /// No description provided for @infoGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What this plan includes'**
  String get infoGoalTitle;

  /// No description provided for @infoGoalBladder.
  ///
  /// In en, this message translates to:
  /// **'Slow holds and quick squeezes, plus squeezing before coughs, lifts and standing up. Daily habits for after-dribble and sudden urges.'**
  String get infoGoalBladder;

  /// No description provided for @infoGoalErection.
  ///
  /// In en, this message translates to:
  /// **'Standard levels with stronger holds from Level 3, bridges and squats, and a weekly brisk walking goal.'**
  String get infoGoalErection;

  /// No description provided for @infoGoalEjaculation.
  ///
  /// In en, this message translates to:
  /// **'Standard levels with more relaxation: reverse Kegels and extra breathing every day, so you learn to let go as well as squeeze.'**
  String get infoGoalEjaculation;

  /// No description provided for @infoGoalSurgery.
  ///
  /// In en, this message translates to:
  /// **'Gentler holds of up to 10 seconds with 4 seconds of rest. Starts only after the catheter is removed and your care team agrees.'**
  String get infoGoalSurgery;

  /// No description provided for @infoGoalGeneral.
  ///
  /// In en, this message translates to:
  /// **'A balanced plan of slow holds, quick squeezes, everyday squeezes and relaxation.'**
  String get infoGoalGeneral;

  /// No description provided for @infoGoalNote.
  ///
  /// In en, this message translates to:
  /// **'You can change your goal any time in Settings.'**
  String get infoGoalNote;

  /// No description provided for @infoSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why we ask'**
  String get infoSafetyTitle;

  /// No description provided for @infoSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'Pain can mean the muscles are too tight, so squeezing may make it worse; you start with relaxation instead. Recent surgery and a catheter need your care team\'s go-ahead before you start.'**
  String get infoSafetyBody;

  /// No description provided for @infoKegelTitle.
  ///
  /// In en, this message translates to:
  /// **'What is a Kegel exercise?'**
  String get infoKegelTitle;

  /// No description provided for @infoKegelBody.
  ///
  /// In en, this message translates to:
  /// **'Squeezing and lifting your pelvic floor muscles, the ones you use to stop passing wind, then letting them go fully. It needs no equipment and nobody can see you doing it.'**
  String get infoKegelBody;

  /// No description provided for @infoRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'About reminders'**
  String get infoRemindersTitle;

  /// No description provided for @infoRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders are discreet by default: the lock screen never mentions what the app is for. At most 2 a day, never for marketing, and you can change them any time in Settings.'**
  String get infoRemindersBody;

  /// No description provided for @infoVoiceBody.
  ///
  /// In en, this message translates to:
  /// **'A spoken \"Squeeze\" and \"Relax\" during sessions. Off by default so your phone stays quiet around other people.'**
  String get infoVoiceBody;

  /// No description provided for @infoSessionsBody.
  ///
  /// In en, this message translates to:
  /// **'How many short sessions you plan each day. One is a fine start; more than 3 strengthening sessions a day is never planned, because tired muscles recover slower.'**
  String get infoSessionsBody;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor trainer'**
  String get splashTagline;

  /// No description provided for @splashMotivation.
  ///
  /// In en, this message translates to:
  /// **'{key, select, d0{Breathe in, let go. A few calm minutes a day.} d1{Steady practice, one breath at a time.} d2{Relax first, then squeeze gently.} other{Small daily steps for your pelvic health.}}'**
  String splashMotivation(String key);

  /// No description provided for @splashImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Calm breathing, with the pelvic floor highlighted'**
  String get splashImageLabel;

  /// No description provided for @h2DayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String h2DayLabel(int day);

  /// No description provided for @h2LevelShort.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String h2LevelShort(int level);

  /// No description provided for @h2DayPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Day plan'**
  String get h2DayPlanTitle;

  /// No description provided for @s3ForwardPhase.
  ///
  /// In en, this message translates to:
  /// **'Next phase'**
  String get s3ForwardPhase;

  /// No description provided for @s3ForwardExercise.
  ///
  /// In en, this message translates to:
  /// **'Next exercise'**
  String get s3ForwardExercise;

  /// No description provided for @brCycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get brCycles;

  /// No description provided for @brCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get brCycle;

  /// No description provided for @brInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get brInhale;

  /// No description provided for @brExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get brExhale;

  /// No description provided for @poseStanding.
  ///
  /// In en, this message translates to:
  /// **'Standing'**
  String get poseStanding;

  /// No description provided for @poseSitting.
  ///
  /// In en, this message translates to:
  /// **'Sitting'**
  String get poseSitting;

  /// No description provided for @poseLyingOnBack.
  ///
  /// In en, this message translates to:
  /// **'Lying on your back'**
  String get poseLyingOnBack;

  /// No description provided for @poseGluteBridge.
  ///
  /// In en, this message translates to:
  /// **'Glute bridge'**
  String get poseGluteBridge;

  /// No description provided for @poseSquatting.
  ///
  /// In en, this message translates to:
  /// **'Squatting'**
  String get poseSquatting;

  /// No description provided for @poseKneeling.
  ///
  /// In en, this message translates to:
  /// **'Kneeling'**
  String get poseKneeling;

  /// No description provided for @poseRestBreathing.
  ///
  /// In en, this message translates to:
  /// **'Calm breathing'**
  String get poseRestBreathing;

  /// No description provided for @h2LevelCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {level} complete'**
  String h2LevelCompleteTitle(int level);

  /// No description provided for @h2ReviewDays.
  ///
  /// In en, this message translates to:
  /// **'Review days'**
  String get h2ReviewDays;

  /// No description provided for @h2DoneTab.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get h2DoneTab;

  /// No description provided for @h2TagCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get h2TagCurrent;

  /// No description provided for @h2TagCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get h2TagCompleted;

  /// No description provided for @h2TagLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get h2TagLocked;

  /// No description provided for @h2TagTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get h2TagTomorrow;

  /// No description provided for @h2DayAvailableTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Available tomorrow'**
  String get h2DayAvailableTomorrow;

  /// No description provided for @h2StartDay.
  ///
  /// In en, this message translates to:
  /// **'Start day {day}'**
  String h2StartDay(int day);

  /// No description provided for @h2StepDownUnavailable.
  ///
  /// In en, this message translates to:
  /// **'You\'re on Level 1, the first level, so there is no level to step down to.'**
  String get h2StepDownUnavailable;

  /// No description provided for @h2OpenDay.
  ///
  /// In en, this message translates to:
  /// **'Open day'**
  String get h2OpenDay;

  /// No description provided for @h2FocusL1.
  ///
  /// In en, this message translates to:
  /// **'Find the right muscles. Squeeze for 3 seconds, then let go fully.'**
  String get h2FocusL1;

  /// No description provided for @h2FocusL2.
  ///
  /// In en, this message translates to:
  /// **'Squeeze for 5 seconds while sitting, plus a few quick squeezes.'**
  String get h2FocusL2;

  /// No description provided for @h2FocusL3.
  ///
  /// In en, this message translates to:
  /// **'Squeeze for 7 seconds, sitting and standing.'**
  String get h2FocusL3;

  /// No description provided for @h2FocusL4.
  ///
  /// In en, this message translates to:
  /// **'Squeeze for 8 to 10 seconds, plus bridges and squats.'**
  String get h2FocusL4;

  /// No description provided for @h2FocusL5.
  ///
  /// In en, this message translates to:
  /// **'Squeeze for 10 seconds during everyday moves.'**
  String get h2FocusL5;

  /// No description provided for @h2AchievedL1.
  ///
  /// In en, this message translates to:
  /// **'You can find, squeeze and fully relax the right muscles.'**
  String get h2AchievedL1;

  /// No description provided for @h2AchievedL2.
  ///
  /// In en, this message translates to:
  /// **'You can hold a squeeze for 5 seconds while sitting.'**
  String get h2AchievedL2;

  /// No description provided for @h2AchievedL3.
  ///
  /// In en, this message translates to:
  /// **'You can hold for 7 seconds, sitting and standing.'**
  String get h2AchievedL3;

  /// No description provided for @h2AchievedL4.
  ///
  /// In en, this message translates to:
  /// **'You can hold for 8 to 10 seconds in bridges and squats.'**
  String get h2AchievedL4;

  /// No description provided for @h2AchievedL5.
  ///
  /// In en, this message translates to:
  /// **'You keep the routine going in everyday moves.'**
  String get h2AchievedL5;

  /// No description provided for @h2StatTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get h2StatTime;

  /// No description provided for @h2StatExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get h2StatExercises;

  /// No description provided for @h2StatParts.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get h2StatParts;

  /// No description provided for @h2TimeSplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your time goes'**
  String get h2TimeSplitTitle;

  /// No description provided for @h2RhythmSqueeze.
  ///
  /// In en, this message translates to:
  /// **'Squeeze'**
  String get h2RhythmSqueeze;

  /// No description provided for @h2RhythmRelax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get h2RhythmRelax;

  /// No description provided for @h2RhythmReps.
  ///
  /// In en, this message translates to:
  /// **'{reps} rounds'**
  String h2RhythmReps(int reps);

  /// No description provided for @h2PartsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 part} other{{count} parts}}'**
  String h2PartsCount(int count);

  /// No description provided for @t1TipTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick tip'**
  String get t1TipTitle;

  /// No description provided for @pfDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch the muscles'**
  String get pfDemoTitle;

  /// No description provided for @pfDemoSemantic.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor muscles squeeze and lift, hold, then relax and lower again'**
  String get pfDemoSemantic;

  /// No description provided for @pfDemoSqueezeHint.
  ///
  /// In en, this message translates to:
  /// **'Lift in and up'**
  String get pfDemoSqueezeHint;

  /// No description provided for @pfDemoHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Stay still, breathe'**
  String get pfDemoHoldHint;

  /// No description provided for @pfDemoRelaxHint.
  ///
  /// In en, this message translates to:
  /// **'Let go fully'**
  String get pfDemoRelaxHint;

  /// No description provided for @htTitle.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor test'**
  String get htTitle;

  /// No description provided for @htPressPrompt.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the button, then squeeze'**
  String get htPressPrompt;

  /// No description provided for @htHoldPrompt.
  ///
  /// In en, this message translates to:
  /// **'Squeeze and hold. Let go of the button when you relax.'**
  String get htHoldPrompt;

  /// No description provided for @htPress.
  ///
  /// In en, this message translates to:
  /// **'Press'**
  String get htPress;

  /// No description provided for @htHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get htHold;

  /// No description provided for @htSeconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get htSeconds;

  /// No description provided for @htBest.
  ///
  /// In en, this message translates to:
  /// **'Best {seconds} s'**
  String htBest(String seconds);

  /// No description provided for @htTooShort.
  ///
  /// In en, this message translates to:
  /// **'That was very short. Press and keep holding the button for as long as you squeeze.'**
  String get htTooShort;

  /// No description provided for @htResult.
  ///
  /// In en, this message translates to:
  /// **'You held for {seconds} s'**
  String htResult(String seconds);

  /// No description provided for @htAccidentQ.
  ///
  /// In en, this message translates to:
  /// **'Did you accidentally let go or partly relax the muscle at any point during the squeeze?'**
  String get htAccidentQ;

  /// No description provided for @htNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get htNo;

  /// No description provided for @htYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get htYes;

  /// No description provided for @htAccidentNote.
  ///
  /// In en, this message translates to:
  /// **'No problem. Take a breath, relax fully, and try again. Only a steady, unbroken squeeze counts.'**
  String get htAccidentNote;

  /// No description provided for @htTestAgain.
  ///
  /// In en, this message translates to:
  /// **'Test again'**
  String get htTestAgain;

  /// No description provided for @htReasonQ.
  ///
  /// In en, this message translates to:
  /// **'Which one do you think you had trouble with?'**
  String get htReasonQ;

  /// No description provided for @htReasonStrength.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t hold it with full strength.'**
  String get htReasonStrength;

  /// No description provided for @htReasonEndurance.
  ///
  /// In en, this message translates to:
  /// **'It was hard to hold for long. I let go quickly.'**
  String get htReasonEndurance;

  /// No description provided for @htReasonNone.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t have any problems!'**
  String get htReasonNone;

  /// No description provided for @htStrengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Strength vs. endurance'**
  String get htStrengthTitle;

  /// No description provided for @htStrengthBody.
  ///
  /// In en, this message translates to:
  /// **'Strength is how hard you can squeeze: the most effort you can put into one squeeze. Endurance is how long you can keep a squeeze going without letting go.'**
  String get htStrengthBody;

  /// No description provided for @htStrengthPoint1.
  ///
  /// In en, this message translates to:
  /// **'If you can squeeze strongly but only for a short time, your strength is ahead of your endurance.'**
  String get htStrengthPoint1;

  /// No description provided for @htStrengthPoint2.
  ///
  /// In en, this message translates to:
  /// **'If you can hold a light squeeze for a long time, your endurance is ahead of your strength.'**
  String get htStrengthPoint2;

  /// No description provided for @htStrengthFooter.
  ///
  /// In en, this message translates to:
  /// **'Your plan trains both: slow holds build endurance and quick squeezes build strength.'**
  String get htStrengthFooter;

  /// No description provided for @htEnduranceTitle.
  ///
  /// In en, this message translates to:
  /// **'Holding gets easier step by step'**
  String get htEnduranceTitle;

  /// No description provided for @htEnduranceBody.
  ///
  /// In en, this message translates to:
  /// **'Letting go early is very common at the start. Holding is a skill: the muscles learn to keep working while you breathe normally.'**
  String get htEnduranceBody;

  /// No description provided for @htEndurancePoint1.
  ///
  /// In en, this message translates to:
  /// **'Squeeze at a level you can keep, not as hard as possible.'**
  String get htEndurancePoint1;

  /// No description provided for @htEndurancePoint2.
  ///
  /// In en, this message translates to:
  /// **'Keep breathing. Holding your breath makes the hold shorter.'**
  String get htEndurancePoint2;

  /// No description provided for @htEnduranceFooter.
  ///
  /// In en, this message translates to:
  /// **'Your plan starts with 3-second holds and adds a little time level by level.'**
  String get htEnduranceFooter;

  /// No description provided for @htNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Nice, steady control'**
  String get htNoneTitle;

  /// No description provided for @htNoneBody.
  ///
  /// In en, this message translates to:
  /// **'A steady squeeze with no breaks is exactly what you want. Keep your belly, buttocks and thighs relaxed so only the pelvic floor works.'**
  String get htNoneBody;

  /// No description provided for @htNonePoint1.
  ///
  /// In en, this message translates to:
  /// **'Repeat the test about once a week to see your hold time change.'**
  String get htNonePoint1;

  /// No description provided for @htNonePoint2.
  ///
  /// In en, this message translates to:
  /// **'Always relax fully after each hold, for at least as long as you held.'**
  String get htNonePoint2;

  /// No description provided for @htNoneFooter.
  ///
  /// In en, this message translates to:
  /// **'Your results are saved on this phone and shown in Progress.'**
  String get htNoneFooter;

  /// No description provided for @htGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get htGotIt;

  /// No description provided for @htSaveQ.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get htSaveQ;

  /// No description provided for @htSave.
  ///
  /// In en, this message translates to:
  /// **'Save my result'**
  String get htSave;

  /// No description provided for @htTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get htTryAgain;

  /// No description provided for @htSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. You can see it in Progress.'**
  String get htSaved;

  /// No description provided for @htDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get htDone;

  /// No description provided for @htTodayLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'How to do a Kegel'**
  String get htTodayLearnTitle;

  /// No description provided for @htTodayLearnSub.
  ///
  /// In en, this message translates to:
  /// **'Find the muscles and learn the movement'**
  String get htTodayLearnSub;

  /// No description provided for @htTodayTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor test'**
  String get htTodayTestTitle;

  /// No description provided for @htTodayTestSub.
  ///
  /// In en, this message translates to:
  /// **'See how long you can hold a squeeze'**
  String get htTodayTestSub;

  /// No description provided for @htTodayToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Technique and test'**
  String get htTodayToolsTitle;

  /// No description provided for @htProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Hold test'**
  String get htProgressTitle;

  /// No description provided for @htProgressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Do the pelvic floor test to see your hold time here.'**
  String get htProgressEmpty;

  /// No description provided for @htProgressLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get htProgressLatest;

  /// No description provided for @htProgressBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get htProgressBest;

  /// No description provided for @htProgressTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get htProgressTests;

  /// No description provided for @htProgressStart.
  ///
  /// In en, this message translates to:
  /// **'Take the test'**
  String get htProgressStart;

  /// No description provided for @htValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String htValue(String seconds);

  /// No description provided for @h2Motivation1.
  ///
  /// In en, this message translates to:
  /// **'Day one. Every routine starts here.'**
  String get h2Motivation1;

  /// No description provided for @h2Motivation2.
  ///
  /// In en, this message translates to:
  /// **'Small squeezes, done well, add up.'**
  String get h2Motivation2;

  /// No description provided for @h2Motivation3.
  ///
  /// In en, this message translates to:
  /// **'Steady breathing, steady squeeze.'**
  String get h2Motivation3;

  /// No description provided for @h2Motivation4.
  ///
  /// In en, this message translates to:
  /// **'You\'re building a habit, one day at a time.'**
  String get h2Motivation4;

  /// No description provided for @h2Motivation5.
  ///
  /// In en, this message translates to:
  /// **'Quality over quantity. Make each one count.'**
  String get h2Motivation5;

  /// No description provided for @h2Motivation6.
  ///
  /// In en, this message translates to:
  /// **'Almost a full week. Keep it going.'**
  String get h2Motivation6;

  /// No description provided for @h2Motivation7.
  ///
  /// In en, this message translates to:
  /// **'A week of practice behind you. Nice work.'**
  String get h2Motivation7;

  /// No description provided for @h2Motivation8.
  ///
  /// In en, this message translates to:
  /// **'New week, same focus.'**
  String get h2Motivation8;

  /// No description provided for @h2Motivation9.
  ///
  /// In en, this message translates to:
  /// **'Let go fully after every squeeze.'**
  String get h2Motivation9;

  /// No description provided for @h2Motivation10.
  ///
  /// In en, this message translates to:
  /// **'Showing up beats pushing hard.'**
  String get h2Motivation10;

  /// No description provided for @h2Motivation11.
  ///
  /// In en, this message translates to:
  /// **'Find the lift, hold it, let it go.'**
  String get h2Motivation11;

  /// No description provided for @h2Motivation12.
  ///
  /// In en, this message translates to:
  /// **'You know the moves now. Own them.'**
  String get h2Motivation12;

  /// No description provided for @h2Motivation13.
  ///
  /// In en, this message translates to:
  /// **'A short session still counts. Show up today.'**
  String get h2Motivation13;

  /// No description provided for @h2Motivation14.
  ///
  /// In en, this message translates to:
  /// **'Two weeks of practice. Be proud of that.'**
  String get h2Motivation14;

  /// No description provided for @h2MotivationLast.
  ///
  /// In en, this message translates to:
  /// **'Last day of this level. Finish strong.'**
  String get h2MotivationLast;

  /// No description provided for @hgHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get hgHowTitle;

  /// No description provided for @hgWhenTitle.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get hgWhenTitle;

  /// No description provided for @hgWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why it helps'**
  String get hgWhyTitle;

  /// No description provided for @hgMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done today'**
  String get hgMarkDone;

  /// No description provided for @hgDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get hgDoneToday;

  /// No description provided for @hgUndo.
  ///
  /// In en, this message translates to:
  /// **'Not done yet'**
  String get hgUndo;

  /// No description provided for @hgOpen.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get hgOpen;

  /// No description provided for @hgAdIntro.
  ///
  /// In en, this message translates to:
  /// **'A quick squeeze after you urinate, before you get dressed.'**
  String get hgAdIntro;

  /// No description provided for @hgAdStep1.
  ///
  /// In en, this message translates to:
  /// **'Finish urinating and wait a moment.'**
  String get hgAdStep1;

  /// No description provided for @hgAdStep2.
  ///
  /// In en, this message translates to:
  /// **'Squeeze your pelvic floor firmly, as if lifting the base of the penis.'**
  String get hgAdStep2;

  /// No description provided for @hgAdStep3.
  ///
  /// In en, this message translates to:
  /// **'Hold for 2 to 3 seconds, then let go fully.'**
  String get hgAdStep3;

  /// No description provided for @hgAdStep4.
  ///
  /// In en, this message translates to:
  /// **'Shake gently, then get dressed.'**
  String get hgAdStep4;

  /// No description provided for @hgAdWhen1.
  ///
  /// In en, this message translates to:
  /// **'Every time you urinate'**
  String get hgAdWhen1;

  /// No description provided for @hgAdWhen2.
  ///
  /// In en, this message translates to:
  /// **'Before you leave the toilet'**
  String get hgAdWhen2;

  /// No description provided for @hgAdWhy.
  ///
  /// In en, this message translates to:
  /// **'After urinating, a little urine can stay in the tube inside the penis. A firm squeeze helps move it out before you get dressed.'**
  String get hgAdWhy;

  /// No description provided for @hgAdCaution.
  ///
  /// In en, this message translates to:
  /// **'Do it after you finish, not while urine is flowing. Stopping the stream mid-flow is not an exercise.'**
  String get hgAdCaution;

  /// No description provided for @hgUcIntro.
  ///
  /// In en, this message translates to:
  /// **'What to do when a sudden, strong urge to urinate comes.'**
  String get hgUcIntro;

  /// No description provided for @hgUcStep1.
  ///
  /// In en, this message translates to:
  /// **'Stop and stay still. Sit or stand; don\'t rush to the toilet.'**
  String get hgUcStep1;

  /// No description provided for @hgUcStep2.
  ///
  /// In en, this message translates to:
  /// **'Breathe slowly and soften your belly.'**
  String get hgUcStep2;

  /// No description provided for @hgUcStep3.
  ///
  /// In en, this message translates to:
  /// **'Do 3 to 5 quick, gentle squeezes, or one easy hold.'**
  String get hgUcStep3;

  /// No description provided for @hgUcStep4.
  ///
  /// In en, this message translates to:
  /// **'Wait until the urge settles, then walk calmly to the toilet.'**
  String get hgUcStep4;

  /// No description provided for @hgUcWhen1.
  ///
  /// In en, this message translates to:
  /// **'A sudden strong urge'**
  String get hgUcWhen1;

  /// No description provided for @hgUcWhen2.
  ///
  /// In en, this message translates to:
  /// **'Arriving home'**
  String get hgUcWhen2;

  /// No description provided for @hgUcWhen3.
  ///
  /// In en, this message translates to:
  /// **'Hearing running water'**
  String get hgUcWhen3;

  /// No description provided for @hgUcWhy.
  ///
  /// In en, this message translates to:
  /// **'Rushing while the urge is strong makes it harder to hold on. Staying still and squeezing gently gives the urge time to settle, so you stay in control on the way.'**
  String get hgUcWhy;

  /// No description provided for @hgUcCaution.
  ///
  /// In en, this message translates to:
  /// **'Keep the squeezes gentle. Repeated hard squeezes are not needed.'**
  String get hgUcCaution;

  /// No description provided for @hgUrgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Urge'**
  String get hgUrgeLabel;

  /// No description provided for @hgCalmLabel.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get hgCalmLabel;

  /// No description provided for @s1ContentTitle.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll do'**
  String get s1ContentTitle;

  /// No description provided for @s1ContentRounds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 round} other{{count} rounds}}'**
  String s1ContentRounds(int count);

  /// No description provided for @s1ContentTiming.
  ///
  /// In en, this message translates to:
  /// **'{squeeze} s squeeze · {relax} s relax'**
  String s1ContentTiming(int squeeze, int relax);

  /// No description provided for @h1MaintenanceDay.
  ///
  /// In en, this message translates to:
  /// **'Week {week} · Day {day} of {total}'**
  String h1MaintenanceDay(int week, int day, int total);

  /// No description provided for @h1ProgramComplete.
  ///
  /// In en, this message translates to:
  /// **'Core program complete'**
  String get h1ProgramComplete;

  /// No description provided for @exdHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get exdHowTo;

  /// No description provided for @exdWhy.
  ///
  /// In en, this message translates to:
  /// **'Why it helps'**
  String get exdWhy;

  /// No description provided for @exdInsideTitle.
  ///
  /// In en, this message translates to:
  /// **'What happens inside'**
  String get exdInsideTitle;

  /// No description provided for @exdInsideHint.
  ///
  /// In en, this message translates to:
  /// **'The pelvic floor lifts on the squeeze, stays up while you hold, and lets go on the relax.'**
  String get exdInsideHint;

  /// No description provided for @exdBodyTag.
  ///
  /// In en, this message translates to:
  /// **'Your body'**
  String get exdBodyTag;

  /// No description provided for @exdInsideTag.
  ///
  /// In en, this message translates to:
  /// **'Inside'**
  String get exdInsideTag;

  /// No description provided for @exdAnyPosition.
  ///
  /// In en, this message translates to:
  /// **'Any position'**
  String get exdAnyPosition;

  /// No description provided for @exdGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get exdGotIt;

  /// No description provided for @exdOpen.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String exdOpen(String name);

  /// No description provided for @s3DoneExercise.
  ///
  /// In en, this message translates to:
  /// **'Done, next exercise'**
  String get s3DoneExercise;

  /// No description provided for @s3DoneLast.
  ///
  /// In en, this message translates to:
  /// **'Done, finish session'**
  String get s3DoneLast;

  /// No description provided for @exdReps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} reps}}'**
  String exdReps(int count);

  /// No description provided for @exdHoldSec.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s hold'**
  String exdHoldSec(int seconds);

  /// No description provided for @exdMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String exdMinutes(int minutes);

  /// No description provided for @o6GoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get o6GoHome;
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
