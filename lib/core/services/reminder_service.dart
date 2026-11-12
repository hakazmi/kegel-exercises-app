import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reminder scheduling. Real notifications land in Prompt 9.
abstract class ReminderService {
  /// Requests permission and schedules the daily reminder (no-op for now).
  Future<void> enableReminder({
    required int minutesFromMidnight,
    required List<int> days,
  });

  /// Clears scheduled reminders (no-op for now).
  Future<void> disableReminder();
}

/// No-op implementation used until Prompt 9.
class NoOpReminderService implements ReminderService {
  @override
  Future<void> disableReminder() async {}

  @override
  Future<void> enableReminder({
    required int minutesFromMidnight,
    required List<int> days,
  }) async {}
}

final reminderServiceProvider = Provider<ReminderService>((Ref ref) {
  return NoOpReminderService();
});
