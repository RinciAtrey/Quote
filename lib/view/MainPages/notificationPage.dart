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
  bool _hasTimeScheduled = false;
  Time selectedTime = Time(hour: 11, minute: 30);
  final NotificationService _notificationService = NotificationService();

  PermissionStatus? _permissionStatus;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService.initNotifications();
    _checkPermission();
    _loadScheduledTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //Re-check permission when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() => _checking = true);

    final status = await Permission.notification.status;
    setState(() {
      _permissionStatus = status;
      _checking = false;
    });
  }


  Future<void> _requestPermission() async {
    try {
      final status = await Permission.notification.request();

      setState(() => _permissionStatus = status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isGranted
                ? "You have given notification permission 👍"
                : status.isPermanentlyDenied
                ? "Permission permanently denied. Please enable it in Settings."
                : "Permission denied. You can try again.",
          ),
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
    //Cancel any existing notifications
    await _notificationService.cancelNotifications();
    //Schedule the new daily notification
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scheduledHour', newTime.hour);
    await prefs.setInt('scheduledMinute', newTime.minute);

    setState(() {
      selectedTime = newTime;
      _hasTimeScheduled = true;
    });
  }

  Future<void> _loadScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('scheduledHour') && prefs.containsKey('scheduledMinute')) {
      setState(() {
        selectedTime = Time(
          hour: prefs.getInt('scheduledHour')!,
          minute: prefs.getInt('scheduledMinute')!,
        );
        _hasTimeScheduled = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_checking) {
      child = const CircularProgressIndicator();
    } else if (_permissionStatus?.isGranted == true) {
      if (_hasTimeScheduled) {
        child = const Text(
          "No quotes",
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        );
      }
      else {
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Notification Time",
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .secondary,
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
      }
    } else{
      final status = _permissionStatus!;
      child = ElevatedButton(
        onPressed: () {
          if (status.isPermanentlyDenied) {
            openAppSettings();
          } else {
            _requestPermission();
          }
        },
        child: Text(
          status.isPermanentlyDenied
              ? "Enable notifications in Settings"
              : "Enable notifications",
        ),
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
