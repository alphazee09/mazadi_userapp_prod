import 'package:mazadi/core/models/auction.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/navigator.dart';
import '../../../widgets/common/account_info.dart';
import '../../../widgets/common/section_heading.dart';
import '../../profile/details/index.dart';

// ignore: must_be_immutable
class AuctionAuctioneer extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();

  Auction auction;

  AuctionAuctioneer({
    super.key,
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    if (auction.auctioneer?.id == null) {
      return Container();
    }

    var createdByMsg = tr("auction_details.details.created_by");
    return Column(
      children: [
        SectionHeading(
          title: createdByMsg,
          withMore: false,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2
                    .withOpacity(0.8),
              ),
              child: InkWell(
                onTap: () {
                  navigatorService.push(
                    ProfileDetailsScreen(
                      accountId: auction.auctioneer!.id,
                    ),
                    NavigationStyle.SharedAxis,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AccountInfo(
                          account: auction.auctioneer,
                          small: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
