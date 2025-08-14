import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';
import 'package:quotes_daily/view/onBoardingPages/mainBoardingPage.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'Utils/notifications/notification_service.dart';
import 'Utils/routes/routes.dart';
import 'View/MainPages/notificationPage.dart';
import 'View/MainPages/homePage.dart';
import 'View/MainPages/MainExplorePage.dart';
import 'View/MainPages/custom_quote.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // timezone init once
  try {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  } catch (e) {
    print('Timezone init failed in main: $e');
  }

  // initialize alarm manager exactly once
  try {
    await AndroidAlarmManager.initialize();
  } catch (e) {
    print('AndroidAlarmManager.initialize() failed: $e');
  }

  // init notifications and channels
  final notificationService = NotificationService();
  try {
    await notificationService.initNotifications();
  } catch (e) {
    print('NotificationService.initNotifications() failed in main: $e');
  }

  // ensure any previously scheduled alarm is (re)created BEFORE UI starts
  try {
    await notificationService.ensureAlarmScheduledFromPrefs();
  } catch (e) {
    print('ensureAlarmScheduledFromPrefs() failed in main: $e');
  }

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quotes',
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
      themeMode: ThemeMode.light,
      theme: ThemeData(
        textTheme: GoogleFonts.arimoTextTheme(                  //montserratTextTheme
          Theme.of(context).textTheme,
        ),

        // appBarTheme: AppBarTheme(
        //   titleTextStyle: GoogleFonts.lato(
        //     fontSize: 22
        //   ),
        //   // toolbarTextStyle: GoogleFonts.poppins(), // for backwards compatibility
        // ),
      ),
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onNavBarTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.appColor.withAlpha(10),
    body: SafeArea(
      child: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          MainExplorePage(),
          NotificationPage(),
          HomePage(),
          CustomQuote(),
        ],
      ),
    ),
    bottomNavigationBar: SnakeNavigationBar.color(
      behaviour: SnakeBarBehaviour.pinned,
      snakeShape: SnakeShape.indicator,
      shape: const RoundedRectangleBorder(),     //flatten the ends
      padding: EdgeInsets.zero,
      snakeViewColor: AppColors.appColor,
      selectedItemColor: AppColors.appColor,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      currentIndex: _selectedIndex,
      onTap: _onNavBarTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.home),   label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.format_paint_outlined), label: 'Custom'),
      ],
    ),
  );
}
