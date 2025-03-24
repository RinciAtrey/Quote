// notification_service.dart
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Call this during app startup (or from your NotificationPage) to initialize notifications.
  Future<void> initNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Do nothing on tap (or log it), so no extra notifications are triggered.
        print("Notification tapped – no additional action.");
      },
    );
  }

  /// Instead of a constant NotificationDetails, we now create them dynamically
  /// so that we can set a BigTextStyle that shows the full quote.
  static NotificationDetails _buildNotificationDetails(String fullText) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_quotes_channel', // Channel ID
        'Daily Quotes',         // Channel Name
        channelDescription: 'Daily quote notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false,        // Hide the timestamp
        // BigTextStyleInformation allows the full quote to be shown when expanded.
        styleInformation: BigTextStyleInformation(
          fullText,
          contentTitle: 'Daily Quote',
          summaryText: 'Tap to view more',
        ),
      ),
    );
  }

  /// This method is invoked in the background to fetch a new quote and display it.
  static Future<void> fetchAndShowNotification() async {
    tz.initializeTimeZones();

    // Initialize the plugin (in a background isolate, this might be required)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings);

    try {
      final response =
      await http.get(Uri.parse("https://zenquotes.io/api/random"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quote = data[0]["q"];
        final author = data[0]["a"];

        // Build notification details with the quote as the big text.
        final details = _buildNotificationDetails(quote);

        // Show the notification.
        await notificationsPlugin.show(
          0,        // Notification ID
          author,   // Title (author)
          quote,    // Body (the quote; it may be truncated unless expanded)
          details,
        );
        print("Notification displayed: $quote - $author");
      } else {
        print("Failed to fetch quote. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching quote: $e");
    }
  }
}
