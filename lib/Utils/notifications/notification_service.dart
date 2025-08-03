// lib/Utils/notifications/notification_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// ← updated to request permissions & create channel
  Future<void> initNotifications() async {
    // 1. Time zones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // 2. Initialization settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOSInit = DarwinInitializationSettings();
    final initSettings =
    InitializationSettings(android: androidInit, iOS: iOSInit);

    await notificationsPlugin.initialize(initSettings);

    // 3. Create Android channel
    const channel = AndroidNotificationChannel(
      'daily_quotes_channel',
      'Daily Quotes',
      description: 'Daily quote notifications',
      importance: Importance.high,
    );
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Request permissions
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // ← fixed here:
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }


  Future<void> cancelNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  /// ← updated to use androidScheduleMode
  Future<void> scheduleDailyQuoteNotification(TimeOfDay time) async {
    try {
      final response =
      await http.get(Uri.parse("https://zenquotes.io/api/random"));
      if (response.statusCode != 200) {
        print("Quote fetch failed: ${response.statusCode}");
        return;
      }
      final data = jsonDecode(response.body);
      final quote = data[0]["q"] as String;
      final author = data[0]["a"] as String;

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quotes_channel',
          'Daily Quotes',
          channelDescription: 'Daily quote notifications',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
          styleInformation: BigTextStyleInformation(
            quote,
            contentTitle: 'Daily Quote',
            summaryText: author,
          ),
        ),
        iOS: DarwinNotificationDetails(),
      );

      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await notificationsPlugin.zonedSchedule(
        0,
        author,
        quote,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print("Scheduled daily quote at $scheduled");
    } catch (e) {
      print("Error scheduling daily notification: $e");
    }
  }
}
