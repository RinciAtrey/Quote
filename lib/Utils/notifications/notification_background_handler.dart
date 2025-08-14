// lib/notification_background_handler.dart
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const int ALARM_ID_DAILY_QUOTE = 9999;

@pragma('vm:entry-point')
Future<void> dailyQuoteAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  } catch (e) {
    print('Background: tz init error $e');
  }

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  try {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(InitializationSettings(android: androidInit));
  } catch (e) {
    print('Background: notifications init failed: $e');
  }

  try {
    const channel = AndroidNotificationChannel(
      'daily_quotes_channel',
      'Daily Quotes',
      description: 'Daily quote notifications',
      importance: Importance.high,
    );
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (e) {
    print('Background: create channel failed: $e');
  }

  String quote = 'Stay motivated!';
  String author = 'QuotesDaily';

  try {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/random')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        quote = (data[0]['q'] as String?)?.trim() ?? quote;
        author = (data[0]['a'] as String?)?.trim() ?? author;
      }
    } else {
      print('Background: quote fetch non-200 ${response.statusCode}');
    }
  } catch (e) {
    print('Background: quote fetch failed: $e');
    try {
      final prefs = await SharedPreferences.getInstance();
      quote = prefs.getString('lastQuote') ?? quote;
      author = prefs.getString('lastAuthor') ?? author;
    } catch (e2) {
      print('Background: reading cached quote failed: $e2');
    }
  }

  try {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_quotes_channel',
        'Daily Quotes',
        channelDescription: 'Daily quote notifications',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation:
        BigTextStyleInformation(quote, contentTitle: 'Daily Quote', summaryText: author),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await plugin.show(ALARM_ID_DAILY_QUOTE, author, quote, details);
  } catch (e) {
    print('Background: show notification failed: $e');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('lastQuote', quote);
    await prefs.setString('lastAuthor', author);
    await prefs.setInt('lastDeliveryEpoch', now.millisecondsSinceEpoch);
  } catch (e) {
    print('Background: saving last delivered failed: $e');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('scheduledHour');
    final int? minute = prefs.getInt('scheduledMinute');
    if (hour != null && minute != null) {
      final now = DateTime.now();
      var next = DateTime(now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

      await AndroidAlarmManager.cancel(ALARM_ID_DAILY_QUOTE);
      await AndroidAlarmManager.oneShotAt(
        next,
        ALARM_ID_DAILY_QUOTE,
        dailyQuoteAlarmCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );
      print('Background: rescheduled next alarm at $next');
    }
  } catch (e) {
    print('Background: reschedule failed: $e');
  }
}
