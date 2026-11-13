import 'reminder_kinds.dart';

/// Spec section 11 notification bodies (discreet vs full).
abstract final class ReminderCopy {
  static String body({
    required ReminderKind kind,
    required bool discreet,
    required bool restDay,
  }) {
    switch (kind) {
      case ReminderKind.daily:
        if (restDay) {
          return discreet
              ? 'Time for your breathing session'
              : 'Time for your pelvic floor breathing';
        }
        return discreet
            ? 'Time for your 2-minute session'
            : 'Time for your pelvic floor session';
      case ReminderKind.streakNudge:
        return 'Keep your streak going today';
      case ReminderKind.levelUnlocked:
        return 'New level unlocked';
      case ReminderKind.checkInDue:
        return 'Your 4-week check-in is ready';
    }
  }

  /// Neutral title — never the app display name (avoids "Kegel" on the lock screen).
  static const String title = 'Reminder';
}
