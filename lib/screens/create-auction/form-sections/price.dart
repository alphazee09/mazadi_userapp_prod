import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masonry_grid/masonry_grid.dart';

import '../../../core/controllers/auction.dart';
import '../../../widgets/common/section_heading.dart';
import '../dialogs/custom_starting_price.dart';
import '../widgets/starting_price_item.dart';

class AuctionFormPriceSection extends StatelessWidget {
  final newAuctionController = Get.find<AuctionController>();

  void showAddCustomStartingPriceDialog(
    BuildContext context,
    Function onSubmit, [
    double? startingPrice,
  ]) {
    var alert = AddCustomStartingPriceDialog(
      onSubmit: onSubmit,
      startingPrice: startingPrice,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

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
            title: tr('create_auction.starting_price'),
            withMore: false,
            padding: 0,
          ),
          Obx(
            () => MasonryGrid(
              column: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 0,
              children: [
                StartingPriceItem(
                  price: 10,
                  selected:
                      newAuctionController.startingPriceIsSelected(10, false),
                  onTap: () {
                    newAuctionController.setStartingPrice(10, false);
                  },
                ),
                StartingPriceItem(
                  price: 15,
                  selected:
                      newAuctionController.startingPriceIsSelected(15, false),
                  onTap: () {
                    newAuctionController.setStartingPrice(15, false);
                  },
                ),
                StartingPriceItem(
                  price:
                      newAuctionController.isCustomPriceSelected.value == true
                          ? newAuctionController.startingPrice.value
                          : null,
                  selected:
                      newAuctionController.isCustomPriceSelected.value == true,
                  isCustom: true,
                  onTap: () {
                    showAddCustomStartingPriceDialog(
                      context,
                      (String startingPrice) {
                        newAuctionController.setStartingPrice(
                          double.parse(startingPrice),
                          true,
                        );
                      },
                      newAuctionController.isCustomPriceSelected.value == true
                          ? newAuctionController.startingPrice.value
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
