import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/models/auction.dart';

// ignore: must_be_immutable
class BidsCountAuctionLabel extends StatelessWidget {
  final accountController = Get.find<AccountController>();
  Auction auction;

  BidsCountAuctionLabel({required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .extension<CustomThemeFields>()!
            .background_2
            .withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_3,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 16,
      ),
      child: Center(
        child: Text(
          auction.bidsCount == 1
              ? 'generic.bids_count_singular'
              : 'generic.bids_count_plural',
          style: Theme.of(context)
              .extension<CustomThemeFields>()!
              .smallest
              .copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).tr(
          namedArgs: {
            'no': auction.bidsCount.toString(),
          },
        ),
      ),
    );
  }
}
