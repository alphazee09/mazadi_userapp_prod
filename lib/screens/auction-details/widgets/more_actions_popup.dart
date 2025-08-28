import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/auction.dart';
import '../../../core/controllers/main.dart';
import '../../../core/models/auction.dart';
import '../../../core/navigator.dart';
import '../dialogs/remove_auction.dart';
import '../dialogs/report.dart';
import '../update/index.dart';

class AuctionDetailsMoreActionsPopup extends StatelessWidget {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();
  final mainController = Get.find<MainController>();
  final auctionController = Get.find<AuctionController>();

  final Rx<Auction> auction;
  final Function refreshData;

  AuctionDetailsMoreActionsPopup({
    super.key,
    required this.auction,
    required this.refreshData,
  });

  Future<bool> createAuctionReport(String reason, String description) async {
    return await mainController.createReport(
      'auction',
      auction.value.id,
      reason,
      description,
    );
  }

  Future<bool> removeAuction() async {
    return await auctionController.deleteAuction(auction);
  }

  @override
  Widget build(BuildContext context) {
    var isAuctionOwner =
        auction.value.auctioneer?.id == accountController.account.value.id;

    if (isAuctionOwner &&
        (!auction.value.isActive || auction.value.acceptedBidId != null)) {
      return Container();
    }

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
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              'assets/icons/svg/more.svg',
              height: 24,
              semanticsLabel: 'Menu',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          ),
          onSelected: (value) async {
            if (value == 'remove-auction') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RemoveAuctionDialogContent(
                    onConfirm: () {
                      return removeAuction();
                    },
                  );
                },
              );
            }

            if (value == 'report-auction') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ReportDialogContent(
                    entityName: 'auction',
                    onConfirm: (String reason, String description) {
                      return createAuctionReport(reason, description);
                    },
                  );
                },
              );
            }

            if (value == 'update-auction') {
              var result = await navigatorService.push(
                UpdateAuctionScreen(
                  auction: auction.value,
                ),
                NavigationStyle.SharedAxis,
              );

              if (result == true) {
                refreshData();
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            ...(!isAuctionOwner
                ? [
                    PopupMenuItem(
                      value: 'report-auction',
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
                            'auction_details.app_bar.report_auction',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ).tr(),
                        ],
                      ),
                    )
                  ]
                : []),
            ...(isAuctionOwner &&
                    auction.value.acceptedBidAt == null &&
                    auction.value.isActive != false
                ? [
                    PopupMenuItem(
                      value: 'update-auction',
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/svg/edit.svg',
                            height: 24,
                            semanticsLabel: 'Edit',
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
                            'auction_details.app_bar.update_auction',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ).tr(),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove-auction',
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
                            'auction_details.app_bar.remove_auction',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ).tr(),
                        ],
                      ),
                    )
                  ]
                : [])
          ],
        ),
      ),
    );
  }
}
