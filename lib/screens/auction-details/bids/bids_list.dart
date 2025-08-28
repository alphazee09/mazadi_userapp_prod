import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../core/controllers/main.dart';
import '../../../core/models/auction.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/section_heading.dart';
import 'bid_item.dart';

class AuctionBidsList extends StatefulWidget {
  final Rx<Auction>? auction;
  final Function removeBidFromAuction;

  const AuctionBidsList({
    super.key,
    required this.auction,
    required this.removeBidFromAuction,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionBidsList createState() => _AuctionBidsList();
}

class _AuctionBidsList extends State<AuctionBidsList> {
  final mainController = Get.find<MainController>();

  bool _seeAllBids = false;

  Future<bool> createBidReport(
    String bidId,
    String reason,
    String description,
  ) async {
    return await mainController.createReport(
      'bid',
      bidId,
      reason,
      description,
    );
  }

  @override
  Widget build(BuildContext context) {
    var bids = widget.auction!.value.bids;
    bids.sort((a, b) => (b.value.price ?? 0).compareTo((a.value.price ?? 0)));

    // If seeAllBids is true and the bids count is more than 2, we will show all the bids
    // If not, we will show only the first 2 bids and a button to see all the bids
    var bidsToDisplay =
        _seeAllBids || bids.length <= 2 ? bids : bids.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: tr(
            'auction_details.bids_count',
            namedArgs: {
              'no': widget.auction!.value.bids.length.toString(),
            },
          ),
          withMore: false,
        ),
        bids.isEmpty
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'auction_details.no_active_bids',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                  textAlign: TextAlign.center,
                ).tr(),
              )
            : Column(
                children: [
                  for (var bid in bidsToDisplay)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AuctionDetailBidItem(
                        bid: bid,
                        auction: widget.auction!,
                        removeBid: widget.removeBidFromAuction,
                        createBidReport: (reason, description) =>
                            createBidReport(
                          bid.value.id!,
                          reason,
                          description,
                        ),
                      ),
                    ),
                ],
              ),
        bids.length > 2
            ? Container(
                margin: EdgeInsetsDirectional.only(start: 16),
                child: ScaleTap(
                  onPressed: () {
                    setState(() {
                      _seeAllBids = !_seeAllBids;
                    });
                  },
                  child: Text(
                    _seeAllBids == true
                        ? 'generic.see_less'
                        : 'generic.see_more',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller
                        .copyWith(
                          color: Colors.blue,
                        ),
                  ).tr(),
                ),
              )
            : Container()
      ],
    );
  }
}
