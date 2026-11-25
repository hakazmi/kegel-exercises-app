import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
// 10-year window is all reminders need; ~6x smaller and faster to parse
// than latest_all.
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_planner.dart';

/// Abstraction over flutter_local_notifications for tests.
abstract class NotificationGateway {
  /// Channel id for Android (must match [AndroidNotificationDetails]).
  static const String androidChannelId = 'daily_reminder';

  /// Channel name shown in system settings (spec section 11).
  static const String androidChannelName = 'Daily reminder';

  Future<void> initialize();

  /// Returns the IANA time zone id currently on the device.
  Future<String> currentTimeZoneId();

  /// Applies [timeZoneId] as the timezone package local location.
  Future<void> setLocalTimeZone(String timeZoneId);

  /// Requests notification permission (Android 13+ and iOS). Returns whether granted.
  Future<bool> requestPermission();

  Future<void> cancelAll();

  Future<void> scheduleAll(List<PlannedNotification> items);
}

/// Real plugin-backed gateway for Android and iOS.
class FlutterNotificationGateway implements NotificationGateway {
  FlutterNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    tzdata.initializeTimeZones();
    final String zone = await currentTimeZoneId();
    await setLocalTimeZone(zone);

    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: darwin,
    );
    await _plugin.initialize(settings: settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationGateway.androidChannelId,
      NotificationGateway.androidChannelName,
      description: 'Daily session reminders',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  @override
  Future<String> currentTimeZoneId() async {
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      return info.identifier;
    } on Object {
      return 'UTC';
    }
  }

  @override
  Future<void> setLocalTimeZone(String timeZoneId) async {
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneId));
    } on Object {
      tz.setLocalLocation(tz.UTC);
    }
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final bool? granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final bool? granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  @override
  Future<void> scheduleAll(List<PlannedNotification> items) async {
    await initialize();
    await _plugin.cancelAll();
    for (final PlannedNotification item in items) {
      final tz.TZDateTime when = tz.TZDateTime.from(item.when, tz.local);
      if (!when.isAfter(tz.TZDateTime.now(tz.local))) {
        continue;
      }
      await _plugin.zonedSchedule(
        id: item.id,
        title: item.title,
        body: item.body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationGateway.androidChannelId,
            NotificationGateway.androidChannelName,
            channelDescription: 'Daily session reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}

/// In-memory gateway for unit tests.
class FakeNotificationGateway implements NotificationGateway {
  FakeNotificationGateway({
    this.timeZoneId = 'UTC',
    this.permissionGranted = true,
  });

  String timeZoneId;
  bool permissionGranted;
  bool initialized = false;
  final List<PlannedNotification> scheduled = <PlannedNotification>[];
  int cancelAllCount = 0;
  int permissionRequestCount = 0;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<String> currentTimeZoneId() async => timeZoneId;

  @override
  Future<void> setLocalTimeZone(String timeZoneId) async {
    this.timeZoneId = timeZoneId;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequestCount += 1;
    return permissionGranted;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount += 1;
    scheduled.clear();
  }

  @override
  Future<void> scheduleAll(List<PlannedNotification> items) async {
    scheduled
      ..clear()
      ..addAll(items);
  }
}
