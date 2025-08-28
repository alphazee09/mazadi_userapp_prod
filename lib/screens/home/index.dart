import 'dart:async';

import 'package:mazadi/core/services/event_manager.dart';
import 'package:mazadi/screens/home/categories/index.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../core/controllers/ads.dart';
import '../../core/controllers/main.dart';
import '../../core/navigator.dart';
import '../../widgets/common/banner_ad.dart';
import '../../widgets/common/no_internet_connection.dart';
import '../intro/dialogs/ask_if_user_wants_to_see.dart';
import '../intro/index.dart';
import 'app_bar.dart';
import 'auctions/index.dart';
import 'auctions/last-seen/index.dart';
import 'auctions/recommendations/index.dart';
import 'auctions/starting-soon/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final mainController = Get.find<MainController>();
  final accountController = Get.find<AccountController>();
  final navigationService = Get.find<NavigatorService>();
  final adsController = Get.find<AdsController>();

  final GlobalKey _scrollableKey = GlobalKey();
  final GlobalKey<HomeScreenAppBarState> _appBarKey =
      GlobalKey<HomeScreenAppBarState>();

  StreamSubscription<CustommazadiEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var account = accountController.account.value;
      if (account.introDone || account.introSkipped) {
        return;
      }

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AskIfUserWantsToSeeIntroDialog(
            onSubmit: () => navigationService.push(
              const IntroStepperScreen(),
              NavigationStyle.Default,
              false,
              false,
            ),
          );
        },
      );
    });

    _eventSubscription = EventManager().eventStream.listen((event) {
      try {
        if (event.type == CustomMessages.scrollHomeToTop) {
          handleScrollHomeEvent();
        }
      } catch (error) {
        // ignore: avoid_print
        print('Could not handle home custom stream events: $error');
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> handleScrollHomeEvent() async {
    Scrollable.ensureVisible(
      _scrollableKey.currentContext!,
      alignment: 0.0,
      duration: const Duration(milliseconds: 500),
    );

    EasyDebounce.debounce('refresh-data', const Duration(milliseconds: 100),
        () {
      _appBarKey.currentState?.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => mainController.connectivity.contains(ConnectivityResult.none)
          ? const NoInternetConnectionScreen()
          : HomeScreenAppBar(
              key: _appBarKey,
              child: SingleChildScrollView(
                key: _scrollableKey,
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeCategories(),
                      BannerAdCard(),
                      Container(height: 24),
                      HomeRecommendations(),
                      Container(height: 24),
                      HomeAuctionsList(),
                      BannerAdCard(),
                      Container(
                        height: 16,
                      ),
                      HomeStartingSoonAuctionsList(),
                      Container(
                        height: 16,
                      ),
                      HomeLastSeenAuctionsList(),
                      Container(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
