import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/auction.dart';
import '../../../../core/navigator.dart';
import '../../../../theme/extensions/base.dart';
import '../../../../widgets/auction-card/large_card.dart';
import '../../../../widgets/common/section_heading.dart';
import 'list.dart';

class HomeRecommendations extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final auctionsController = Get.find<AuctionController>();

  Widget renderNoRecommendationsMessage(BuildContext context) {
    return Column(
      children: [
        Row(
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
                tr('recommendations.no_recommendations_for_you'),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        Container(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                tr('recommendations.no_recommendation_details'),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smallest,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget renderRecommendations(BuildContext context) {
    return Obx(() {
      return auctionsController.recommended.isEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              child: renderNoRecommendationsMessage(context),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var recommendation in auctionsController.recommended)
                      Container(
                        margin: EdgeInsetsDirectional.only(end: 8),
                        width: Get.width * 0.7,
                        child: AuctionLargeCard(auction: recommendation),
                      )
                  ],
                ),
              ),
            );
    });
  }

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
                const RecommendationsListScreen(),
                NavigationStyle.SharedAxis,
              );
            },
            title: tr('recommendations.you_might_like'),
            withMore: true,
            onMorePressed: () {
              navigatorService.push(
                const RecommendationsListScreen(),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
        renderRecommendations(context),
      ],
    );
  }
}
