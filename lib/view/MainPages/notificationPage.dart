import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Utils/notifications/notification_service.dart';
import '../NotificationPages/widgets_notifications.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with WidgetsBindingObserver {
  Timer? _showTimer, _clearTimer;
  bool _hasTimeScheduled = false;
  Time selectedTime = Time(hour: 11, minute: 30);
  String? _lastQuote, _lastAuthor;
  DateTime? _lastDelivery;
  final _notificationService = NotificationService();

  PermissionStatus? _permissionStatus;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService.initNotifications();
    _initializePage();
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _clearTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializePage() async {
    await _checkPermission();
    await _loadScheduledTime();
    await _loadLastNotification();
    _scheduleTimers();
  }

  Future<void> _checkPermission() async {
    setState(() => _checking = true);
    _permissionStatus = await Permission.notification.status;
    setState(() => _checking = false);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    setState(() => _permissionStatus = status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status.isGranted
              ? "Notification permission granted 👍"
              : status.isPermanentlyDenied
              ? "Permanently denied—enable in Settings."
              : "Permission denied.",
        ),
      ),
    );
  }

  Future<void> _loadScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('scheduledHour') &&
        prefs.containsKey('scheduledMinute')) {
      selectedTime = Time(
        hour: prefs.getInt('scheduledHour')!,
        minute: prefs.getInt('scheduledMinute')!,
      );
      setState(() => _hasTimeScheduled = true);
    } else {
      setState(() => _hasTimeScheduled = false);
    }
  }

  Future<void> _loadLastNotification() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('lastQuote') &&
        prefs.containsKey('lastAuthor') &&
        prefs.containsKey('lastDeliveryEpoch')) {
      final quote    = prefs.getString('lastQuote')!;
      final author   = prefs.getString('lastAuthor')!;
      final delivery = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('lastDeliveryEpoch')!,
      );
      final now = DateTime.now();

      if (now.isAfter(delivery) &&
          now.isBefore(delivery.add(const Duration(hours: 12)))) {
        setState(() {
          _lastQuote    = quote;
          _lastAuthor   = author;
          _lastDelivery = delivery;
        });
        return;
      }
      // expired
      await prefs
        ..remove('lastQuote')
        ..remove('lastAuthor')
        ..remove('lastDeliveryEpoch');
    }

    setState(() {
      _lastQuote    = null;
      _lastAuthor   = null;
      _lastDelivery = null;
    });
  }

  void _scheduleTimers() {
    _showTimer?.cancel();
    _clearTimer?.cancel();
    if (_lastDelivery == null) return;

    final now = DateTime.now();
    final delivery = _lastDelivery!;

    final untilShow = delivery.difference(now);
    if (untilShow.isNegative) {
      _setQuoteFromPrefs();
    } else {
      _showTimer = Timer(untilShow, _setQuoteFromPrefs);
    }

    final untilClear = delivery.add(const Duration(hours: 12)).difference(now);
    if (untilClear.isNegative) {
      _clearQuote();
    } else {
      _clearTimer = Timer(untilClear, _clearQuote);
    }
  }

  Future<void> _setQuoteFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('lastQuote') &&
        prefs.containsKey('lastAuthor') &&
        prefs.containsKey('lastDeliveryEpoch')) {
      setState(() {
        _lastQuote  = prefs.getString('lastQuote');
        _lastAuthor = prefs.getString('lastAuthor');
      });
    }
  }

  void _clearQuote() {
    SharedPreferences.getInstance().then((prefs) {
      prefs
        ..remove('lastQuote')
        ..remove('lastAuthor')
        ..remove('lastDeliveryEpoch');
    });
    setState(() {
      _lastQuote    = null;
      _lastAuthor   = null;
      _lastDelivery = null;
    });
  }

  Future<void> _onTimeChanged(Time newTime) async {
    setState(() => selectedTime = newTime);

    // immediate SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Daily quote scheduled for "
              "${newTime.hour.toString().padLeft(2, '0')}:"
              "${newTime.minute.toString().padLeft(2, '0')}",
        ),
      ),
    );

    await _notificationService.cancelNotifications();
    await _notificationService.scheduleDailyQuoteNotification(
      TimeOfDay(hour: newTime.hour, minute: newTime.minute),
    );

    final prefs = await SharedPreferences.getInstance();
    // read back the delivery epoch your service wrote
    final storedEpoch = prefs.getInt('lastDeliveryEpoch')!;
    _lastDelivery = DateTime.fromMillisecondsSinceEpoch(storedEpoch);

    await prefs
      ..setInt('scheduledHour', newTime.hour)
      ..setInt('scheduledMinute', newTime.minute);

    setState(() => _hasTimeScheduled = true);
    _scheduleTimers();
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationService.cancelNotifications();
    final prefs = await SharedPreferences.getInstance();
    await prefs
      ..remove('scheduledHour')
      ..remove('scheduledMinute')
      ..remove('lastQuote')
      ..remove('lastAuthor')
      ..remove('lastDeliveryEpoch');
    _showTimer?.cancel();
    _clearTimer?.cancel();
    setState(() {
      _hasTimeScheduled = false;
      _lastQuote = null;
      _lastAuthor = null;
      _lastDelivery = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications",
        style: TextStyle(color: AppColors.appColor, fontWeight: FontWeight.bold),), ),
      body: Padding(
          padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Previously", style: TextStyle(fontSize: 15, color: AppColors.appColor),)
              ],
            ),
          ),
          SizedBox(height: 12,),
          Column(
              children:[ _buildBodyContent(context)]
          ),
        ],
      ),
    )
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    if (_permissionStatus?.isGranted != true) {
      return buildPermissionButton(
        context,
        status: _permissionStatus!,
        onRequest: _requestPermission,
      );
    }

    final topSection = _hasTimeScheduled
        ? (_lastQuote != null
        ? buildLatestQuote(context, _lastQuote!, _lastAuthor!)
        : buildNoQuotes())
        : const SizedBox.shrink();

    final buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimePickerButton(
          context,
          label: _hasTimeScheduled ? "Reschedule" : "Schedule",
          initialTime: selectedTime,
          onTimeChanged: _onTimeChanged,
        ),
        if (_hasTimeScheduled) ...[
          const SizedBox(width: 12),
          buildCancelButton(onCancel: _cancelAllNotifications),
        ],
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        topSection,
        const SizedBox(height: 24),
        buttonRow,
      ],
    );
  }
}
