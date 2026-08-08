import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';

class NotificationServices {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // --- Initialization ---
  Future<void> initNotification(bool isEnabled) async {
    if (_isInitialized) return;
    if (!isEnabled) return; // Do not boot up if user disabled them

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const initSettingAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const initSetting = InitializationSettings(
      android: initSettingAndroid,
      iOS: initSettingIOS,
    );

    await notificationPlugin.initialize(settings: initSetting);
    _isInitialized = true;
  }

  // --- Core Actions ---
  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id: id);
  }

  // --- Permission Handling ---
  /// Requests permissions and returns TRUE if granted, FALSE if denied
  Future<bool> requestAndCheckPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = notificationPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Request standard notifications
        final bool? granted = await androidPlugin.requestNotificationsPermission();

        // Request exact alarms (required for Android 12+ scheduling)
        await androidPlugin.requestExactAlarmsPermission();

        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = notificationPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final bool? granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  // --- Notification Details & Scheduling ---
  NotificationDetails _scheduleNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "maintenance_alerts_channel",
        "Maintenance Alerts",
        channelDescription: "Reminders for upcoming bike services",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return await notificationPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _scheduleNotificationDetails(),
    );
  }

  Future<void> showScheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime scheduleTime = tz.TZDateTime.from(scheduledDate, tz.local);

    if (scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await notificationPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduleTime,
      notificationDetails: _scheduleNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}