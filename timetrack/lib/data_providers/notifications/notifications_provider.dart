

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationsProvider {
  final FlutterLocalNotificationsPlugin _notif;
  NotificationsProvider(this._notif) : assert(_notif != null);

  static Future<NotificationsProvider> load() async {
    FlutterLocalNotificationsPlugin notif = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await notif.initialize(initializationSettings);

    return NotificationsProvider(notif);
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      bool result = await _notif
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(sound: true, alert: true, badge: true) ??
          false;
      return result;
    } else if (Platform.isMacOS) {
      bool result = await _notif
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(sound: true, alert: true, badge: true) ??
          false;
      return result;
    } else {
      return true;
    }
  }

  Future<void> displayRunningTimersNotification(
      String title, String body) async {
    print("displaying notification");
    if (!await requestPermissions()) {
      print("no permissions, quitting");
      return;
    }

    const IOSNotificationDetails ios = IOSNotificationDetails(
      presentAlert: true,
      presentSound: false,
      badgeNumber: null,
    );

    const MacOSNotificationDetails macos = MacOSNotificationDetails(
      presentAlert: true,
      presentSound: false,
      badgeNumber: null,
    );

    const AndroidNotificationDetails android = AndroidNotificationDetails(
        "ca.hamaluik.TimeTrack.runningtimersnotification",
        "Running Timers",
        "Notification indicating that timers are currently running",
        priority: Priority.low,
        importance: Importance.low,
        showWhen: true);

    NotificationDetails details =
        NotificationDetails(iOS: ios, android: android, macOS: macos);

    await _notif.show(0, title, body, details);
  }

  Future<void> removeAllNotifications() async {
    await _notif.cancelAll();
  }
}
