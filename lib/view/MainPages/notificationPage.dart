import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/notifications/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with WidgetsBindingObserver {
  Time selectedTime = Time(hour: 11, minute: 30);
  final NotificationService _notificationService = NotificationService();

  bool? _permissionGranted;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService.initNotifications();
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check permission when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() => _checking = true);

    // Android
    final androidStatus = await Permission.notification.status;

    final granted = androidStatus.isGranted;

    setState(() {
      _permissionGranted = granted;
      _checking = false;
    });
  }

  Future<void> _requestPermission() async {
    try {
      final granted = await _notificationService.requestPermission();
      setState(() => _permissionGranted = granted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(granted
              ? "You have given notification permission 👍"
              : "Permission denied. You can enable it in Settings."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error requesting permission: $e")),
      );
    }
  }

  Future<void> _onTimeChanged(Time newTime) async {
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
    Widget child;

    if (_checking) {
      child = const CircularProgressIndicator();
    } else if (_permissionGranted == true) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Notification Time",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            "${selectedTime.hour.toString().padLeft(2, '0')}:"
            "${selectedTime.minute.toString().padLeft(2, '0')}",
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
                  onChange: _onTimeChanged,
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
    } else {
      // not granted
      child = ElevatedButton(
        onPressed: () async {
          // if user previously denied permanently, open settings
          final status = await Permission.notification.status;
          if (status.isPermanentlyDenied) {
            openAppSettings();
          } else {
            _requestPermission();
          }
        },
        child: Text("Enable notifications in settings"),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: Center(child: child),
    );
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
