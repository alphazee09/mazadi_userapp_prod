import 'package:mazadi/widgets/common/simple_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:masonry_grid/masonry_grid.dart';

import '../../../core/controllers/auction.dart';
import '../../../core/navigator.dart';
import '../../../theme/colors.dart';
import '../../../widgets/auction-card/index.dart';
import '../../../widgets/common/section_heading.dart';
import '../../auction-details/index.dart';
import 'all-auctions/index.dart';

class HomeAuctionsList extends StatelessWidget {
  HomeAuctionsList({super.key});

  final navigatorService = Get.find<NavigatorService>();
  final auctionsController = Get.find<AuctionController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: SectionHeading(
            onPressed: () {
              navigatorService.push(
                const AllAuctionsScreen(),
                NavigationStyle.SharedAxis,
              );
            },
            title: tr('home.auctions.auctions'),
            withMore: true,
            onMorePressed: () {
              navigatorService.push(
                const AllAuctionsScreen(),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
        Obx(
          () => auctionsController.auctions.isEmpty
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          tr('home.auctions.no_auctions'),
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
                  child: Column(
                    children: [
                      MasonryGrid(
                        column: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          for (var auction in auctionsController.auctions)
                            GestureDetector(
                              onTap: () {
                                navigatorService.push(AuctionDetailsScreen(
                                  auctionId: auction.value.id,
                                  assetsLen: 1,
                                ));
                              },
                              child: AuctionCard(
                                auction: auction,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        height: 16,
                      ),
                      SimpleButton(
                        background: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action,
                        child: Text(
                          'home.auctions.see_all',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: DarkColors.font_1,
                              ),
                        ).tr(namedArgs: {
                          'no': auctionsController.allActiveAuctionsCount
                              .toString()
                        }),
                        onPressed: () {
                          navigatorService.push(
                            const AllAuctionsScreen(),
                            NavigationStyle.SharedAxis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
