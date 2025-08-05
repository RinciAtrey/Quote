import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'Utils/notifications/notification_service.dart';
import 'Utils/routes/routes.dart';
import 'View/MainPages/notificationPage.dart';
import 'View/MainPages/homePage.dart';
import 'View/MainPages/MainExplorePage.dart';
import 'View/MainPages/custom_quote.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quotes',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
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
      shape: const RoundedRectangleBorder(),     // flatten the ends
      padding: EdgeInsets.zero,
      snakeViewColor: Colors.white,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black,
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
