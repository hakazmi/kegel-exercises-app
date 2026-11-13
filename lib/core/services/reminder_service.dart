import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/providers.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../plan/plan_rules.dart';
import 'notification_gateway.dart';
import 'reminder_planner.dart';

/// Schedules discreet local reminders (spec section 11).
abstract class ReminderService {
  /// Plugin + timezone init (safe to call more than once).
  Future<void> initialize();

  /// Requests OS notification permission (Android 13+ / iOS). Call only from
  /// "Remind me" or Settings reminder on.
  Future<bool> requestPermission();

  /// Requests permission (if needed) and re-plans the next 7 days.
  Future<void> enableReminder({
    required int minutesFromMidnight,
    required List<int> days,
  });

  /// Cancels every scheduled notification.
  Future<void> disableReminder();

  /// Re-plans from current profile / sessions / check-ins.
  Future<void> reschedule();
}

/// Local-notifications implementation for Android and iOS.
class LocalReminderService implements ReminderService {
  LocalReminderService({
    required this._gateway,
    required this._prefs,
    required this._loadInput,
  });

  static const String _tzPrefKey = 'reminder_last_timezone';
  static const String _levelNoticeKey = 'reminder_level_unlock_notice_level';

  final NotificationGateway _gateway;
  final SharedPreferences _prefs;
  final Future<ReminderPlanInput> Function() _loadInput;

  @override
  Future<void> initialize() async {
    await _gateway.initialize();
    final String zone = await _gateway.currentTimeZoneId();
    await _gateway.setLocalTimeZone(zone);
    final String? previous = _prefs.getString(_tzPrefKey);
    if (previous != zone) {
      await _prefs.setString(_tzPrefKey, zone);
      if (previous != null) {
        await reschedule();
      }
    }
  }

  @override
  Future<bool> requestPermission() => _gateway.requestPermission();

  @override
  Future<void> enableReminder({
    required int minutesFromMidnight,
    required List<int> days,
  }) async {
    await requestPermission();
    await reschedule();
  }

  @override
  Future<void> disableReminder() async {
    await _gateway.cancelAll();
  }

  @override
  Future<void> reschedule() async {
    await _gateway.initialize();
    final String zone = await _gateway.currentTimeZoneId();
    await _gateway.setLocalTimeZone(zone);
    await _prefs.setString(_tzPrefKey, zone);

    final ReminderPlanInput base = await _loadInput();
    if (!base.profile.reminderEnabled) {
      await _gateway.cancelAll();
      return;
    }

    final bool unlockReady = PlanRules.canUnlockNextLevel(
      level: base.profile.level,
      sessions: base.sessions,
      today: base.now,
    );
    final int? lastNotified = _prefs.getInt(_levelNoticeKey);
    final bool notifyLevelUnlock =
        unlockReady && lastNotified != base.profile.level;

    final List<PlannedNotification> planned = ReminderPlanner.plan(
      ReminderPlanInput(
        profile: base.profile,
        sessions: base.sessions,
        checkIns: base.checkIns,
        now: base.now,
        notifyLevelUnlock: notifyLevelUnlock,
      ),
    );
    await _gateway.scheduleAll(planned);

    if (notifyLevelUnlock) {
      await _prefs.setInt(_levelNoticeKey, base.profile.level);
    }
  }
}

final notificationGatewayProvider = Provider<NotificationGateway>((Ref ref) {
  return FlutterNotificationGateway();
});

final reminderServiceProvider = Provider<ReminderService>((Ref ref) {
  final NotificationGateway gateway = ref.watch(notificationGatewayProvider);
  final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
  return LocalReminderService(
    gateway: gateway,
    prefs: prefs,
    loadInput: () async {
      final UserProfile profile = ref.read(userProfileProvider);
      final List<SessionRecord> sessions =
          await ref.read(sessionRepositoryProvider).getAll();
      final List<CheckInRecord> checkIns =
          await ref.read(checkInRepositoryProvider).getAll();
      return ReminderPlanInput(
        profile: profile,
        sessions: sessions,
        checkIns: checkIns,
        now: ref.read(appClockProvider).now(),
      );
    },
  );
});
