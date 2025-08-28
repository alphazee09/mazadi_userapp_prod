import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/models/auction.dart';
import '../../../core/models/bid.dart';
import '../../../core/navigator.dart';
import '../../profile/details/index.dart';
import '../dialogs/accept_bid.dart';
import '../dialogs/reject_bid.dart';
import '../dialogs/remove_bid.dart';
import '../dialogs/report.dart';

class BidDetailsPopupMenu extends StatelessWidget {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();

  final Rx<Bid> bid;
  final Rx<Auction> auction;
  final Function acceptBid;
  final Function rejectBid;
  final Function createBidReport;
  final Function removeBid;

  BidDetailsPopupMenu({
    super.key,
    required this.bid,
    required this.auction,
    required this.acceptBid,
    required this.rejectBid,
    required this.createBidReport,
    required this.removeBid,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(29)),
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              'assets/icons/svg/more.svg',
              height: 24,
              semanticsLabel: 'More',
              colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn),
            ),
          ),
          onSelected: (value) {
            if (value == 'profile') {
              navigatorService.push(
                ProfileDetailsScreen(
                  accountId:
                      accountController.account.value.id == bid.value.bidder?.id
                          ? accountController.account.value.id
                          : bid.value.bidder!.id,
                ),
                NavigationStyle.SharedAxis,
              );
            }

            if (value == 'reject-bid') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RejectBidDialogContent(
                      onConfirm: (description) => rejectBid(bid, description));
                },
              );
            }

            if (value == 'accept-bid') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AcceptBidDialogContent(
                    onConfirm: () => acceptBid(bid),
                  );
                },
              );
            }

            if (value == 'remove-bid') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RemoveBidDialogContent(
                    onConfirm: () {
                      return removeBid();
                    },
                  );
                },
              );
            }

            if (value == 'report-bid') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ReportDialogContent(
                    entityName: 'bid',
                    onConfirm: (String reason, String description) {
                      return createBidReport(
                        reason,
                        description,
                      );
                    },
                  );
                },
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/svg/profile.svg',
                    height: 24,
                    semanticsLabel: 'Profile',
                    colorFilter: ColorFilter.mode(
                        Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        BlendMode.srcIn),
                  ),
                  Container(
                    width: 8,
                  ),
                  Text(
                    accountController.account.value.id == bid.value.bidder?.id
                        ? 'auction_details.bids.see_your_profile'
                        : 'auction_details.bids.see_bidder',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ).tr(),
                ],
              ),
            ),
            ...(accountController.account.value.id != bid.value.bidder?.id
                ? [
                    PopupMenuItem(
                      value: 'report-bid',
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/svg/report.svg',
                            height: 24,
                            semanticsLabel: 'Report',
                            colorFilter: ColorFilter.mode(
                              Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                              BlendMode.srcIn,
                            ),
                          ),
                          Container(
                            width: 8,
                          ),
                          Text(
                            'auction_details.bids.report',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ).tr(),
                        ],
                      ),
                    )
                  ]
                : []),
            ...(accountController.account.value.id == bid.value.bidder?.id &&
                    bid.value.isAccepted != true &&
                    bid.value.isRejected != true &&
                    auction.value.isActive
                ? [
                    PopupMenuItem(
                      value: 'remove-bid',
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/svg/trash.svg',
                            height: 24,
                            semanticsLabel: 'Delete',
                            colorFilter: ColorFilter.mode(
                              Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                              BlendMode.srcIn,
                            ),
                          ),
                          Container(
                            width: 8,
                          ),
                          Text(
                            'auction_details.bids.remove',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ).tr(),
                        ],
                      ),
                    ),
                  ]
                : []),
            ...(accountController.account.value.id ==
                        auction.value.auctioneer?.id &&
                    auction.value.acceptedBidId == null
                ? [
                    PopupMenuItem(
                      value: 'accept-bid',
                      child: Row(
                        children: [
                          // Icon(
                          //   BidsTypeIcons.accepted_bid,
                          //   size: 24,
                          //   color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                          // ),
                          Container(
                            width: 8,
                          ),
                          Text(
                            'auction_details.bids.accept_bid',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ).tr(),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'reject-bid',
                      child: Row(
                        children: [
                          // Icon(
                          //   BidsTypeIcons.rejected_bid,
                          //   size: 24,
                          //   color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                          // ),
                          Container(
                            width: 8,
                          ),
                          Text(
                            'auction_details.bids.reject_bid',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ).tr(),
                        ],
                      ),
                    ),
                  ]
                : []),
          ],
        ),
      ),
    );
  }
}
