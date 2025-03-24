// main.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'Utils/notifications/notification_service.dart';
import 'Utils/routes/routes.dart';
import 'View/MainPages/notificationPage.dart';
import 'View/MainPages/homePage.dart';
import 'View/MainPages/MainExplorePage.dart';
import 'View/MainPages/custom_quote.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "dailyQuoteTask") {
      // Call the static method that fetches the quote and displays a notification.
      await NotificationService.fetchAndShowNotification();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // IMPORTANT: Set isInDebugMode to false to prevent debug notifications.
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Change this from true to false.
  );


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quotes',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
        onGenerateRoute: Routes.generateRoute
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
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey =
  GlobalKey();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          children: [
            HomePage(),
            NotificationPage(),
            MainExplorePage(),
            CustomQuotePage(),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.notifications, size: 30, color: Colors.white),
          Icon(Icons.explore, size: 30, color: Colors.white),
          Icon(Icons.format_paint_outlined, size: 30, color: Colors.white),
        ],
        color: Colors.deepPurple,
        buttonBackgroundColor: Colors.deepPurple,
        backgroundColor: Colors.purple.withAlpha(100),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) => _onItemTapped(index),
      ),
    );
  }
}
