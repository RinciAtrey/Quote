import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // only timezone + channel + initialize
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit    = DarwinInitializationSettings();
    await notificationsPlugin.initialize(
        InitializationSettings(android: androidInit, iOS: iosInit)
    );

    // create channel (no permissions)
    const channel = AndroidNotificationChannel(
      'daily_quotes_channel', 'Daily Quotes',
      description: 'Daily quote notifications',
      importance: Importance.high,
    );
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermission() async {
    final iosGranted = await notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true)
        ?? false;

    final androidGranted = await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission()
        ?? false;

    return iosGranted || androidGranted;
  }


  Future<void> cancelNotifications() async {
    await notificationsPlugin.cancelAll();
  }

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

      print(quote);
      print(author);

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
    } catch (e) {
      print("Error scheduling daily notification: $e");
    }
  }
}
