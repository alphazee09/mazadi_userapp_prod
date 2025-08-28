import 'package:mazadi/core/controllers/auction.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/main.dart';
import '../../../../core/navigator.dart';
import '../../../../widgets/auction-card/large_card.dart';
import '../../../../widgets/common/section_heading.dart';
import 'list.dart';

class HomeStartingSoonAuctionsList extends StatelessWidget {
  HomeStartingSoonAuctionsList({super.key});

  final auctionController = Get.find<AuctionController>();
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
                const StartingSoonAuctionScreen(),
                NavigationStyle.SharedAxis,
              );
            },
            title: tr('starting_soon_auctions.starting_soon_plural'),
            withMore: true,
            onMorePressed: () {
              navigatorService.push(
                const StartingSoonAuctionScreen(),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
        Obx(
          () => auctionController.startingSoonAuctions.isEmpty
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
                          tr('starting_soon_auctions.no_starting_soon'),
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var auction
                            in auctionController.startingSoonAuctions)
                          Container(
                            width: Get.width * 0.7,
                            margin: EdgeInsetsDirectional.only(end: 8),
                            child: AuctionLargeCard(
                              auction: auction,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
        Obx(
          () => auctionController.startingSoonAuctions.isEmpty
              ? Container()
              : Container(
                  width: Get.width,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .separator,
                    ),
                  ),
                  child: Text(
                    'starting_soon_auctions.add_to_fav_multiple',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smallest,
                  ).tr(),
                ),
        )
      ],
    );
  }
}
