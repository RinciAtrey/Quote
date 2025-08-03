import 'package:flutter/material.dart';
import 'package:quotes_daily/Utils/routes/routes_name.dart';
import 'package:quotes_daily/View/MainPages/homePage.dart';
import 'package:quotes_daily/view/CustomQuotePages/create_quote_page.dart';

import '../../View/MainPages/MainExplorePage.dart';
import '../../View/MainPages/notificationPage.dart';
import '../../view/HomepagePages/HomeExplorePage.dart';
import '../../view/MainPages/custom_quote.dart';

class Routes{


  static Route<dynamic> generateRoute(RouteSettings settings){

    switch(settings.name){
      case RoutesName.mainHomePage:
        return MaterialPageRoute(builder: (BuildContext context)=> HomePage());
      // case RoutesName.mainCustomPage:
      //   return MaterialPageRoute(builder: (BuildContext context)=> CustomQuotePage());
      case RoutesName.mainExplorePage:
        return MaterialPageRoute(builder: (BuildContext context)=> MainExplorePage());
      case RoutesName.mainNotificationPage:
        return MaterialPageRoute(builder: (BuildContext context)=> NotificationPage());
      case RoutesName.homeExplore:
        return MaterialPageRoute(builder: (BuildContext context)=> Explorepage());
      // case RoutesName.createQuotePage:
      //   return MaterialPageRoute(builder: (BuildContext context)=> CreateQuotePage());
      default:
        return MaterialPageRoute(builder: (_){
          return Scaffold(
            body: Text("No Route found"),
          );
          
        });
    }

  }
}