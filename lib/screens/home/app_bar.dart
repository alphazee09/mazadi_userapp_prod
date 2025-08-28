import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../core/controllers/auction.dart';
import '../../core/controllers/main.dart';
import '../../core/controllers/map_auctions.dart';
import '../../core/controllers/notifications.dart';
import '../../core/navigator.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/input_like_button.dart';
import '../../widgets/common/pulsating_circle.dart';
import 'filter/index.dart';
import 'auctions/map-auctions/dialogs/category_select.dart';
import 'auctions/map-auctions/index.dart';
import 'notifications/index.dart';
import 'search/index.dart';

class HomeScreenAppBar extends StatefulWidget {
  final Widget child;

  const HomeScreenAppBar({
    super.key,
    required this.child,
  });

  @override
  // ignore: library_private_types_in_public_api
  HomeScreenAppBarState createState() => HomeScreenAppBarState();
}

class HomeScreenAppBarState extends State<HomeScreenAppBar> {
  final navigatorService = Get.find<NavigatorService>();
  final mainController = Get.find<MainController>();
  final notificationsController = Get.find<NotificationsController>();
  final mapAuctionsController = Get.find<MapAuctionsController>();
  final auctionsController = Get.find<AuctionController>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _reloadData() async {
    await auctionsController.loadAuctionsLists();
    await notificationsController.loadForAccount();
  }

  void refresh() {
    _refreshIndicatorKey.currentState?.show(atTop: true);
  }

  void openAuctionsOnMap() {
    if (mapAuctionsController.categoryToDisplayOnMap.value == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SelectCategoryToDisplayOnMapDialog();
        },
      );
      return;
    }
    navigatorService.push(const MapAuctionsScreen());
  }

  Widget _renderTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppLogo(),
          Row(
            children: [
              IconButton(
                splashRadius: 24,
                iconSize: 20,
                onPressed: () {
                  openAuctionsOnMap();
                },
                icon: SvgPicture.asset(
                  'assets/icons/svg/compass.svg',
                  height: 30,
                  semanticsLabel: 'Auctions map',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              IconButton(
                splashRadius: 24,
                iconSize: 20,
                onPressed: () {
                  navigatorService.push(const NotificationsScreen());
                },
                icon: Stack(
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/svg/notification.svg',
                        height: 24,
                        semanticsLabel: 'Notifications',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Obx(
                      () => notificationsController
                                  .unreadNotificationsCount.value >
                              0
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: PulsatingCircle(
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .action,
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSize _buildBottom(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(77),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: InputLikeButton(
                      placeholder: tr('home.search.search'),
                      padding: EdgeInsetsDirectional.only(start: 16),
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: SearchScreen(),
                          useRootNavigator: true,
                        );
                      },
                      sufixIcon: IconButton(
                        onPressed: () {
                          navigatorService.push(const HomeFilterScreen());
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/svg/filter.svg',
                          height: 26,
                          semanticsLabel: 'Filter',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverAppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            pinned: true,
            floating: true,
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            toolbarHeight: 70,
            forceElevated: innerBoxIsScrolled,
            title: _renderTitle(),
            bottom: _buildBottom(context),
          ),
        ),
      ],
      body: Builder(
        builder: (BuildContext context) {
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            color:
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.separator,
            edgeOffset: 150,
            onRefresh: () async {
              await _reloadData();
            },
            child: CustomScrollView(
              slivers: [
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverPadding(
                  padding: EdgeInsets.zero,
                  sliver: SliverToBoxAdapter(
                    child: widget.child,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
