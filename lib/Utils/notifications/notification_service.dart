// lib/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'notification_background_handler.dart'; // background handler top-level function
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const int ALARM_ID_DAILY_QUOTE = 9999;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService();

  Future<void> initNotifications() async {
    // timezone init
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (e) {
      print('tz init failed: $e');
    }

    // initialize local notifications (used on both platforms + background isolate)
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosInit = DarwinInitializationSettings();
      await notificationsPlugin.initialize(
        InitializationSettings(android: androidInit, iOS: iosInit),
      );
    } catch (e) {
      print('notifications init failed: $e');
    }

    // create channel
    try {
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
    } catch (e) {
      print('create channel failed: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final iosGranted = await notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;

      if (Platform.isAndroid) {
        // android request handled via runtime POST_NOTIFICATIONS (Android 13+),
        // but flutter_local_notifications has an API:
        final androidGranted = await notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
            false;
        return iosGranted || androidGranted;
      } else {
        return iosGranted;
      }
    } catch (e) {
      print('Permission request failed: $e');
      return false;
    }
  }

  Future<void> cancelNotifications() async {
    try {
      await notificationsPlugin.cancelAll();
    } catch (e) {
      print('cancel local notifications failed: $e');
    }
    try {
      await AndroidAlarmManager.cancel(ALARM_ID_DAILY_QUOTE);
    } catch (e) {
      print('cancel alarm failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scheduledHour');
      await prefs.remove('scheduledMinute');
      await prefs.remove('lastQuote');
      await prefs.remove('lastAuthor');
      await prefs.remove('lastDeliveryEpoch');
    } catch (e) {
      print('clear prefs failed: $e');
    }
  }

  /// Schedules the next delivery. On Android it prefers exact AlarmManager one-shot.
  /// If it fails (or on iOS) it falls back to flutter_local_notifications.zonedSchedule.
  Future<void> scheduleDailyQuoteNotification(TimeOfDay time) async {
    // persist scheduled hour/minute
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('scheduledHour', time.hour);
      await prefs.setInt('scheduledMinute', time.minute);
    } catch (e) {
      print('persist scheduled time failed: $e');
    }

    final now = DateTime.now();
    DateTime scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));

    // persist lastDeliveryEpoch immediately so UI can use it
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastDeliveryEpoch', scheduled.millisecondsSinceEpoch);
    } catch (e) {
      print('persist lastDeliveryEpoch failed: $e');
    }

    // Android path: try exact AlarmManager one-shot with background isolate
    if (Platform.isAndroid) {
      try {
        await AndroidAlarmManager.cancel(ALARM_ID_DAILY_QUOTE);

        await AndroidAlarmManager.oneShotAt(
          scheduled,
          ALARM_ID_DAILY_QUOTE,
          dailyQuoteAlarmCallback,
          exact: true,
          wakeup: true,
          allowWhileIdle: true,
          rescheduleOnReboot: true,
        );

        print('Scheduled next alarm (android_alarm_manager_plus) at $scheduled');
        return;
      } catch (e, st) {
        print('android_alarm_manager_plus scheduling failed: $e\n$st');
      }
    }

    // Fallback (or non-Android): schedule with flutter_local_notifications
    try {
      // ensure timezone
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'daily_quotes_channel',
        'Daily Quotes',
        channelDescription: 'Daily quote notifications',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation('Daily quote', contentTitle: 'Daily Quote'),
      );
      final details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

      await notificationsPlugin.zonedSchedule(
        ALARM_ID_DAILY_QUOTE,
        'Daily Quote',
        'Your daily quote will appear now.',
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Scheduled fallback zonedSchedule at $tzScheduled');
    } catch (e, st) {
      print('Fallback zonedSchedule failed: $e\n$st');
    }



  }


  Future<void> ensureAlarmScheduledFromPrefs({int throttleSeconds = 60}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? hour = prefs.getInt('scheduledHour');
      final int? minute = prefs.getInt('scheduledMinute');
      if (hour == null || minute == null) return;

      // throttle / debounce: don't reschedule more than once per `throttleSeconds`
      final int lastAttempt = prefs.getInt('lastScheduleAttemptEpoch') ?? 0;
      final int nowEpoch = DateTime.now().millisecondsSinceEpoch;
      if (nowEpoch - lastAttempt < throttleSeconds * 1000) {
        print('ensureAlarmScheduledFromPrefs: throttled, skipping re-schedule');
        return;
      }
      await prefs.setInt('lastScheduleAttemptEpoch', nowEpoch);

      // compute next occurrence
      final now = DateTime.now();
      DateTime scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));

      // persist lastDeliveryEpoch so UI can show next delivery
      try {
        await prefs.setInt('lastDeliveryEpoch', scheduled.millisecondsSinceEpoch);
      } catch (_) {}

      // Cancel and (re-)schedule to ensure alarm exists
      await AndroidAlarmManager.cancel(ALARM_ID_DAILY_QUOTE);
      await AndroidAlarmManager.oneShotAt(
        scheduled,
        ALARM_ID_DAILY_QUOTE,
        dailyQuoteAlarmCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );

      print('ensureAlarmScheduledFromPrefs: scheduled at $scheduled');
    } catch (e, st) {
      print('ensureAlarmScheduledFromPrefs failed: $e\n$st');
    }
  }

}
