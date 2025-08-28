import 'package:mazadi/core/controllers/last_seen_auctions.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/main.dart';
import '../../../../core/navigator.dart';
import '../../../../widgets/auction-card/index.dart';
import '../../../../widgets/common/section_heading.dart';
import '../../../auction-details/index.dart';
import 'list.dart';

class HomeLastSeenAuctionsList extends StatelessWidget {
  HomeLastSeenAuctionsList({super.key});

  final lastSeenAuctionsController = Get.find<LastSeenAuctionsController>();
  final mainController = Get.find<MainController>();
  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: SectionHeading(
            onPressed: () {
              navigatorService.push(
                const LastSeenAuctionScreen(),
                NavigationStyle.SharedAxis,
              );
            },
            title: tr('home.auctions.last_seen'),
            withMore: true,
            onMorePressed: () {
              navigatorService.push(
                const LastSeenAuctionScreen(),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
        Obx(
          () => lastSeenAuctionsController.lastSeenAuctions.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/categories/all.svg',
                        height: 32,
                        semanticsLabel: 'No search result',
                      ),
                      Container(
                        width: 16,
                      ),
                      Flexible(
                        child: Text(
                          tr('home.auctions.no_last_seen'),
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 16,
                      ),
                      for (var auction
                          in lastSeenAuctionsController.lastSeenAuctions)
                        Container(
                          width: 170,
                          margin: EdgeInsetsDirectional.only(end: 8),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: GestureDetector(
                            onTap: () {
                              navigatorService.push(AuctionDetailsScreen(
                                auctionId: auction.value.id,
                                assetsLen: 1,
                              ));
                            },
                            child: AuctionCard(
                              auction: auction,
                              ignoreUpdateOnClose: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
