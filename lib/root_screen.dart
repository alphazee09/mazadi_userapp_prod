import 'dart:async';

import 'package:mazadi/theme/colors.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/controllers/notifications.dart';
import 'core/navigator.dart';
import 'core/services/event_manager.dart';
import 'screens/create-auction/index.dart';
import 'tab_navigator.dart';
import 'widgets/bottom_navigation_bar.dart';

class RootScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  PageId _currentPage = PageId.home;
  int _currentIndex = 0;

  final navigatorService = Get.find<NavigatorService>();
  final notificationsController = Get.find<NotificationsController>();

  List<PageId> pageKeys = [
    PageId.home,
    PageId.favourites,
    PageId.chat,
    PageId.settings
  ];

  final Map<PageId, GlobalKey<NavigatorState>> _navigatorKeys = {
    PageId.home: GlobalKey<NavigatorState>(),
    PageId.favourites: GlobalKey<NavigatorState>(),
    PageId.chat: GlobalKey<NavigatorState>(),
    PageId.settings: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    notificationsController.initializeFirebase();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Timer(const Duration(seconds: 2), () async {
        try {
          var packageInfo = await PackageInfo.fromPlatform();
          print(
            'App name & version: ${packageInfo.appName}, ${packageInfo.version}',
          );
          // ignore: empty_catches
        } catch (err) {}
      });
    });
  }

  void _handleMenuClick(int index) {
    PageId tabItem = pageKeys[index];

    if (index == 0 && _currentIndex == 0) {
      EventManager().sendEvent(
        CustommazadiEvent(CustomMessages.scrollHomeToTop, ''),
      );
    }

    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      if (mounted) {
        setState(() {
          _currentIndex = index;
          _currentPage = tabItem;
        });
      }
    }
  }

  Widget _buildOffstageNavigator(PageId pageId) {
    return Offstage(
      offstage: _currentPage != pageId,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[pageId] as GlobalKey<NavigatorState>,
        pageId: pageId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              await _navigatorKeys[_currentPage]?.currentState!.maybePop();

          return isFirstRouteInCurrentTab ?? false;
        },
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).extension<CustomThemeFields>()!.action,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/svg/add.svg',
                semanticsLabel: 'Add',
                colorFilter:
                    ColorFilter.mode(DarkColors.font_1, BlendMode.srcIn),
                height: 32,
              ),
              onPressed: () {
                navigatorService.push(const CreateAuctionScreen());
              },
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: PopScope(
              canPop: false,
              child: Stack(
                children: [
                  _buildOffstageNavigator(PageId.home),
                  _buildOffstageNavigator(PageId.favourites),
                  _buildOffstageNavigator(PageId.chat),
                  _buildOffstageNavigator(PageId.settings),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Localizations.override(
            context: context,
            locale: EasyLocalization.of(context)!.locale,
            child: CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              onClicked: _handleMenuClick,
            ),
          ),
        ),
      ),
    );
  }
}
