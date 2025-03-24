// notification_page.dart
import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:workmanager/workmanager.dart';

import '../../Utils/notifications/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Time selectedTime = Time(hour: 11, minute: 30);
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    notificationService.initNotifications();
  }

  /// Make this function async so we can await the cancellation and registration.
  Future<void> onTimeChanged(Time newTime) async {
    setState(() {
      selectedTime = newTime;
    });

    final now = DateTime.now();
    DateTime scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      newTime.hour,
      newTime.minute,
    );

    // If the selected time is before now, schedule for tomorrow.
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final initialDelay = scheduledDateTime.difference(now);

    // Await the cancellation of any previously scheduled task.
    await Workmanager().cancelByUniqueName("dailyQuoteTask");

    // Register the periodic background task using Workmanager.
    await Workmanager().registerPeriodicTask(
      "dailyQuoteTask", // Unique name for the task.
      "dailyQuoteTask", // Task identifier.
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Daily quote scheduled for ${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: SafeArea(
        child: Center(
          child: DatePicker(
            selectedTime: selectedTime,
            onTimeChanged: onTimeChanged, // Now an async function
          ),
        ),
      ),
    );
  }
}

class DatePicker extends StatelessWidget {
  final Time selectedTime;
  final Future<void> Function(Time) onTimeChanged;
  const DatePicker({
    Key? key,
    required this.selectedTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Select Notification Time",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            Navigator.of(context).push(
              showPicker(
                context: context,
                value: selectedTime,
                sunrise: const TimeOfDay(hour: 6, minute: 0),
                sunset: const TimeOfDay(hour: 18, minute: 0),
                onChange: onTimeChanged,
                minuteInterval: TimePickerInterval.FIVE,
              ),
            );
          },
          child: const Text(
            "Pick Time & Schedule",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
