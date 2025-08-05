import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Utils/notifications/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Time selectedTime = Time(hour: 11, minute: 30);
  final NotificationService _notificationService = NotificationService();
  bool _hasAsked = false;
  bool? _permissionGranted;

  Future<void> _onEnablePressed() async {
    setState(() => _hasAsked = true);
    final granted = await NotificationService().requestPermission();
    setState(() => _permissionGranted = granted);
    if (granted) print("user allowed");
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> onTimeChanged(Time newTime) async {
    setState(() => selectedTime = newTime);

    // Cancel any existing notifications
    await _notificationService.cancelNotifications();

    // Schedule the new daily notification
    await _notificationService.scheduleDailyQuoteNotification(
      TimeOfDay(hour: newTime.hour, minute: newTime.minute),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Daily quote scheduled for "
              "${newTime.hour.toString().padLeft(2, '0')}:"
              "${newTime.minute.toString().padLeft(2, '0')}",
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (!_hasAsked || _permissionGranted == null) {
      return ElevatedButton(
        onPressed: _onEnablePressed,
        child: Text("Enable notifications to get quotes"),
      );
    } else if (_permissionGranted == false) {
      return ElevatedButton(
        onPressed: () => openAppSettings(),
        child: Text("Open Settings to enable"),
      );
    } else {
      return SizedBox.shrink(); // or another UI when already allowed
    }
  }
}


// Text(
//   "Select Notification Time",
//   style: Theme.of(context).textTheme.titleLarge,
// ),
// Text(
//   "${selectedTime.hour.toString().padLeft(2, '0')}:"
//       "${selectedTime.minute.toString().padLeft(2, '0')}",
//   style: Theme.of(context).textTheme.displayLarge,
// ),
// const SizedBox(height: 10),
// TextButton(
//   style: TextButton.styleFrom(
//     backgroundColor: Theme.of(context).colorScheme.secondary,
//   ),
//   onPressed: () {
//     Navigator.of(context).push(
//       showPicker(
//         context: context,
//         value: selectedTime,
//         sunrise: const TimeOfDay(hour: 6, minute: 0),
//         sunset: const TimeOfDay(hour: 18, minute: 0),
//         onChange: onTimeChanged,
//         minuteInterval: TimePickerInterval.FIVE,
//       ),
//     );
//   },
//   child: const Text(
//     "Pick Time & Schedule",
//     style: TextStyle(color: Colors.white),
//   ),
// ),