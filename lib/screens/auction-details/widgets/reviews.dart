import 'package:mazadi/core/models/auction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import 'auction_review_form.dart';
import 'auction_review.dart';

class AuctionDetailsReviews extends StatelessWidget {
  final accountController = Get.find<AccountController>();

  final Rx<Auction> auction;

  AuctionDetailsReviews({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    var auctionWinnerAccount = auction.value.bids
        .firstWhereOrNull(
          (element) => element.value.id == auction.value.acceptedBidId,
        )
        ?.value
        .bidder;

    var reviewForAuctionOwner = auction.value.reviews?.firstWhereOrNull(
      (rev) => rev.reviewed?.id == auction.value.auctioneer?.id,
    );

    var reviewForAuctionWinner = auction.value.reviews?.firstWhereOrNull(
      (rev) => rev.reviewed?.id == auctionWinnerAccount?.id,
    );

    var accountIsWinner = auction.value.acceptedBidId != null &&
        auction.value.bids.any(
          (element) =>
              element.value.bidder?.id == accountController.account.value.id &&
              auction.value.acceptedBidId == element.value.id,
        );
    var accountIsAuctionOwner =
        accountController.account.value.id == auction.value.auctioneer?.id;

    var accountWinnerWidget = accountIsWinner
        ? AuctionReviewForm(
            auction: auction,
            review: reviewForAuctionOwner,
            leaveReviewFor: auction.value.auctioneer!,
          )
        : AuctionReview(auction: auction, review: reviewForAuctionOwner);

    var accountAuctionOwnerWidget = accountIsAuctionOwner
        ? AuctionReviewForm(
            auction: auction,
            review: reviewForAuctionWinner,
            leaveReviewFor: auctionWinnerAccount!,
          )
        : AuctionReview(auction: auction, review: reviewForAuctionWinner);

    var children = accountIsWinner
        ? [accountWinnerWidget, accountAuctionOwnerWidget]
        : [accountAuctionOwnerWidget, accountWinnerWidget];

    return Column(
      children: children,
    );
  }
}
