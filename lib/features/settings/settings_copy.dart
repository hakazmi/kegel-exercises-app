import 'package:intl/intl.dart';

import '../../app/l10n/app_localizations.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/safety_flags.dart';
import '../../core/domain/user_profile.dart';

/// Labels for Settings rows.
abstract final class SettingsCopy {
  static String formatTime(int minutesFromMidnight) {
    final DateTime at = DateTime(
      2026,
      1,
      1,
      minutesFromMidnight ~/ 60,
      minutesFromMidnight % 60,
    );
    // intl may insert a narrow no-break space before AM/PM; keep a normal space.
    return DateFormat.jm().format(at).replaceAll(RegExp(r'\s+'), ' ');
  }
  static String goalLabel(AppLocalizations l10n, Goal? goal) {
    switch (goal) {
      case Goal.bladderControl:
        return l10n.o2GoalBladder;
      case Goal.erectionSupport:
        return l10n.o2GoalErection;
      case Goal.ejaculationControl:
        return l10n.o2GoalEjaculation;
      case Goal.recoveryAfterProstateSurgery:
        return l10n.o2GoalSurgery;
      case Goal.generalPelvicHealth:
        return l10n.o2GoalGeneral;
      case null:
        return l10n.x1ValueNone;
    }
  }

  static String sessionsLabel(AppLocalizations l10n, int sessionsPerDay) {
    return l10n.x1DailySessions(sessionsPerDay);
  }

  static String safetySummary(AppLocalizations l10n, SafetyFlags flags) {
    int count = 0;
    if (flags.pain) {
      count += 1;
    }
    if (flags.painSexual) {
      count += 1;
    }
    if (flags.recentSurgery) {
      count += 1;
    }
    if (flags.catheter) {
      count += 1;
    }
    if (count == 0) {
      return l10n.x1ValueNone;
    }
    return l10n.x1SafetySelectedCount(count);
  }

  static String reminderSummary(AppLocalizations l10n, UserProfile profile) {
    final String time = formatTime(profile.reminderTime);
    final bool everyDay = profile.reminderDays.length >= 7;
    final String days =
        everyDay ? l10n.x1Daily : l10n.x1DaysCount(profile.reminderDays.length);
    return '$time · $days';
  }
}
