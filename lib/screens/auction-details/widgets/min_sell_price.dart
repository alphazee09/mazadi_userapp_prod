import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/settings.dart';
import '../../../core/models/auction.dart';

class MinSellPriceInfo extends StatelessWidget {
  final Rx<Auction> auction;
  final settingsController = Get.find<SettingsController>();

  MinSellPriceInfo({
    super.key,
    required this.auction,
  });

  num computeMinPrice() {
    num minPrice = 1;
    if (auction.value.bids.isNotEmpty) {
      var bidWithHighestPrice = auction.value.bids.reduce(
        (a, b) => (a.value.price ?? 0) > (b.value.price ?? 0) ? a : b,
      );
      minPrice = bidWithHighestPrice.value.price ?? 0;
    } else {
      minPrice = auction.value.startingPrice;
    }
    return minPrice;
  }

  @override
  Widget build(BuildContext context) {
    var minPrice = computeMinPrice();
    var locale = Localizations.localeOf(context).languageCode;

    final formatCurrency = NumberFormat.currency(
      decimalDigits: minPrice % 1 == 0 ? 0 : 2,
      locale: locale,
      symbol: settingsController.settings.value.defaultCurrency,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          auction.value.bids.isEmpty
              ? 'auction_details.create_bid.starting_price'
              : 'auction_details.create_bid.highest_bid',
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ).tr(),
        Container(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatCurrency.format(minPrice),
              style: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smaller
                  .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        // Container(
        //   height: 8,
        // ),
        // AuctionCardStatus(
        //   auction: auction,
        //   fontSize: 14,
        //   fontWeight: FontWeight.w500,
        //   fontColor:
        //       Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
        // ),
      ],
    );
  }
}
