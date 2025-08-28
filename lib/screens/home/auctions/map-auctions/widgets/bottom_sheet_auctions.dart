import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/models/auction.dart';
import '../../../../../theme/extensions/base.dart';
import '../../../../../widgets/auction-card/index.dart';
import '../../../../../widgets/auction-card/large_card.dart';

class MapBottomSheetAuctions extends StatelessWidget {
  final List<Rx<Auction>> auctions;
  const MapBottomSheetAuctions({super.key, required this.auctions});

  Widget _renderAuctionsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'map_auctions.auctions_count',
            style: Theme.of(context).extension<CustomThemeFields>()!.title,
          ).tr(namedArgs: {'no': auctions.length.toString()}),
          Container(
            height: 8,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var auction in auctions)
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 12),
                    width: 170,
                    child: AuctionCard(
                      auction: auction,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) {
      return Container();
    }

    if (auctions.length == 1) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: AuctionLargeCard(
          auction: auctions[0],
        ),
      );
    }

    return _renderAuctionsList(context);
  }
}
