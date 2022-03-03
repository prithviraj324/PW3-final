import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:TimeTrack/data_providers/data/data_provider.dart';
import 'package:TimeTrack/data_providers/data/mock_data_provider.dart';
import 'package:TimeTrack/data_providers/notifications/notifications_provider.dart';
import 'package:TimeTrack/data_providers/settings/mock_settings_provider.dart';
import 'package:TimeTrack/data_providers/settings/settings_provider.dart';
import 'package:TimeTrack/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'dart:ui' as ui;

Future<void> main() async {
  enableFlutterDriverExtension(handler: (String query) async {
    if (query == "direction") {
      if (ui.window.locale.languageCode == "ar") {
        return "rtl";
      } else {
        return "ltr";
      }
    } else {
      return null;
    }
  });
  WidgetsApp.debugAllowBannerOverride = false; // remove debug banner

  final SettingsProvider settings = MockSettingsProvider();
  settings.setBool("collapseDays", false);
  final DataProvider data = MockDataProvider(ui.window.locale);
  final NotificationsProvider notifications =
      NotificationsProvider(FlutterLocalNotificationsPlugin());
  return runMain(settings, data, notifications);
}
