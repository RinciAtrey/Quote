import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Utils/notifications/notification_service.dart';
import '../NotificationPages/widgets_notifications.dart';
import '../../Utils/customSnackBar.dart';

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

    CustomSnackBar.show(context,  status.isGranted
        ? "Notification permission granted"
        : status.isPermanentlyDenied
        ? "Permanently denied—enable in Settings."
        : "Permission denied.", Icons.notifications_active, AppColors.appColor);
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
      final quote = prefs.getString('lastQuote')!;
      final author = prefs.getString('lastAuthor')!;
      final delivery = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('lastDeliveryEpoch')!,
      );
      final now = DateTime.now();

      if (now.isAfter(delivery) &&
          now.isBefore(delivery.add(const Duration(hours: 12)))) {
        setState(() {
          _lastQuote = quote;
          _lastAuthor = author;
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
      _lastQuote = null;
      _lastAuthor = null;
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

    final untilClear =
    delivery.add(const Duration(hours: 12)).difference(now);
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
        _lastQuote = prefs.getString('lastQuote');
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
      _lastQuote = null;
      _lastAuthor = null;
      _lastDelivery = null;
    });
  }

  Future<void> _onTimeChanged(Time newTime) async {
    setState(() => selectedTime = newTime);

    CustomSnackBar.show(context, "Daily quote scheduled for ${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}", Icons.check, AppColors.appColor);

    await _notificationService.cancelNotifications();
    await _notificationService.scheduleDailyQuoteNotification(
      TimeOfDay(hour: newTime.hour, minute: newTime.minute),
    );

    final prefs = await SharedPreferences.getInstance();
    final storedEpoch = prefs.getInt('lastDeliveryEpoch');
    if (storedEpoch != null) {
      _lastDelivery = DateTime.fromMillisecondsSinceEpoch(storedEpoch);
    } else {
      final now = DateTime.now();
      var delivery = DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute);
      if (!delivery.isAfter(now)) delivery = delivery.add(const Duration(days: 1));
      _lastDelivery = delivery;
      await prefs.setInt('lastDeliveryEpoch', delivery.millisecondsSinceEpoch);
    }

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {

      _notificationService.ensureAlarmScheduledFromPrefs().then((_) {
        print('NotificationPage: ensureAlarmScheduledFromPrefs called on resume');
      }).catchError((e) {
        print('NotificationPage: ensureAlarmScheduledFromPrefs error: $e');
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final isTablet = width > 600;
    final horizontalPadding = isTablet ? 24.0 : 14.0;
    final cardRadius = isTablet ? 16.0 : 14.0;
    final headerIconSize = isTablet ? 26.0 : 22.0;
    final contentMaxWidth = isTablet ? 700.0 : double.infinity;

    if (_checking) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            "assets/animations/loadingTeddy.json",
            height: isTablet ? 260 : 200,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 6,
        foregroundColor: Colors.white,
        // increases height (responsive)
        toolbarHeight: isTablet ? 80 : 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.appColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        leading: Icon(Icons.notifications_active_outlined,
            color: Colors.white, size: headerIconSize),
      ),
      body: Padding(
        padding: EdgeInsets.all(isTablet ? 12.0 : 5.0),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isTablet ? 22 : 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card(
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(cardRadius)),
                      //   elevation: 2,
                      //   child: Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isTablet ? 16 : 14),
                      //     child: Row(
                      //       crossAxisAlignment: CrossAxisAlignment.center,
                      //       children: [
                      //         Container(
                      //           padding: EdgeInsets.all(isTablet ? 12 : 10),
                      //           decoration: BoxDecoration(
                      //             color: AppColors.appColor.withAlpha(20),
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           child: Icon(
                      //             Icons.lightbulb_outline,
                      //             size: headerIconSize,
                      //             color: AppColors.appColor,
                      //           ),
                      //         ),
                      //         SizedBox(width: isTablet ? 14 : 12),
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Text(
                      //                 "Daily Quote",
                      //                 style: TextStyle(
                      //                     fontSize: isTablet ? 18 : 16,
                      //                     fontWeight: FontWeight.bold),
                      //               ),
                      //               const SizedBox(height: 6),
                      //               Text(
                      //                 "Receive one inspiring quote each day at a time you choose.",
                      //                 style: TextStyle(
                      //                     fontSize: isTablet ? 15 : 13,
                      //                     color: Colors.black54,
                      //                     height: 1.2),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //         // small status chip
                      //         const SizedBox(width: 8),
                      //         Container(
                      //           padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8, vertical: 6),
                      //           decoration: BoxDecoration(
                      //             color: _hasTimeScheduled
                      //                 ? AppColors.appColor.withOpacity(0.14)
                      //                 : Colors.grey.withOpacity(0.08),
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           child: Text(
                      //             _hasTimeScheduled ? 'Scheduled' : 'Not scheduled',
                      //             style: TextStyle(
                      //                 color: _hasTimeScheduled
                      //                     ? AppColors.appColor
                      //                     : Colors.black54,
                      //                 fontWeight: FontWeight.w600,
                      //                 fontSize: isTablet ? 13 : 12),
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      SizedBox(height: isTablet ? 18 : 14),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isTablet ? 20 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: AppColors.appColor,
                                    size: headerIconSize - 2,
                                  ),
                                  SizedBox(width: isTablet ? 12 : 10),
                                  Text(
                                    "Previously",
                                    style: TextStyle(
                                        fontSize: isTablet ? 16 : 15,
                                        color: AppColors.appColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),

                              SizedBox(height: isTablet ? 14 : 12),
                              _buildBodyContent(context),
                              SizedBox(height: isTablet ? 18 : 14),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 18 : 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              _hasTimeScheduled
                                  ? "Next delivery"
                                  : "No schedule set yet",
                              style: TextStyle(
                                  fontSize: isTablet ? 14 : 13,
                                  color: Colors.black54),
                            ),
                          ),
                          if (_hasTimeScheduled)
                            Text(
                              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                  fontSize: isTablet ? 15 : 14,
                                  fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),

                      SizedBox(height: isTablet ? 28 : 22),
                      Center(
                        child: Text(
                          "You can reschedule or cancel anytime.",
                          style: TextStyle(
                              fontSize: isTablet ? 13 : 12, color: Colors.black45),
                        ),
                      ),

                      SizedBox(height: isTablet ? 28 : 24),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
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

    final buttonRow = Container(
      child: Row(
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
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        topSection,
        const SizedBox(height: 24),
        buttonRow,
      ],
    );
  }
}
