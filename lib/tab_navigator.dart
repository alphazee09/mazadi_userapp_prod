import 'package:mazadi/screens/chat/index.dart';
import 'package:mazadi/screens/favourites/index.dart';
import 'package:mazadi/screens/home/index.dart';
import 'package:mazadi/screens/profile/index.dart';
import 'package:flutter/material.dart';

enum PageId { home, favourites, createAuction, chat, settings }

class TabNavigatorRoutes {
  static const String root = '/';
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final PageId pageId;

  const TabNavigator(
      {super.key, required this.navigatorKey, required this.pageId});

  RectTween _createRectTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const HomeScreen();

    if (pageId == PageId.home) {
      child = const HomeScreen();
    } else if (pageId == PageId.favourites) {
      child = const FavouritesScreen();
    } else if (pageId == PageId.chat) {
      child = const ChatScreen();
    } else if (pageId == PageId.settings) {
      child = const ProfileScreen();
    }

    return Navigator(
      observers: [HeroController(createRectTween: _createRectTween)],
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
