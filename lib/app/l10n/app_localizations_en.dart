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
}
