import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masonry_grid/masonry_grid.dart';

import '../../../core/controllers/auction.dart';
import '../../../core/models/auction.dart';
import '../../../widgets/common/section_heading.dart';
import '../widgets/condition_item.dart';

class AuctionFormConditionSection extends StatelessWidget {
  final newAuctionController = Get.find<AuctionController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          SectionHeading(
            title: tr('create_auction.condition'),
            withMore: false,
            padding: 0,
          ),
          Obx(
            () => MasonryGrid(
              column: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 0,
              children: [
                ConditionItem(
                  title: tr('create_auction.new'),
                  selected: newAuctionController.condition.value ==
                      AuctionProductCondition.newProduct,
                  onTap: () {
                    newAuctionController
                        .setCondition(AuctionProductCondition.newProduct);
                  },
                  icon: 'assets/icons/svg/auction-new.svg',
                ),
                ConditionItem(
                  title: tr('create_auction.used'),
                  selected: newAuctionController.condition.value ==
                      AuctionProductCondition.used,
                  onTap: () {
                    newAuctionController
                        .setCondition(AuctionProductCondition.used);
                  },
                  icon: 'assets/icons/svg/auction-used.svg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
