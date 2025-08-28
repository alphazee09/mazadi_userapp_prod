import 'package:mazadi/core/controllers/settings.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

import '../../../core/controllers/account.dart';
import '../../../core/models/auction.dart';
import '../../../core/models/bid.dart';
import '../../../core/navigator.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/user_avatar.dart';
import '../../profile/details/index.dart';
import '../dialogs/about_bid.dart';
import 'popup_menu.dart';

class AuctionDetailsBidItemContent extends StatefulWidget {
  final Rx<Bid> bid;
  final Rx<Auction> auction;
  final Function removeBid;
  final Function acceptBid;
  final Function rejectBid;
  final Function createBidReport;

  const AuctionDetailsBidItemContent({
    super.key,
    required this.bid,
    required this.auction,
    required this.removeBid,
    required this.acceptBid,
    required this.rejectBid,
    required this.createBidReport,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionDetailsBidItemContent createState() =>
      _AuctionDetailsBidItemContent();
}

class _AuctionDetailsBidItemContent
    extends State<AuctionDetailsBidItemContent> {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();
  final settingsController = Get.find<SettingsController>();

  Widget _renderPopupMenu(BuildContext context) {
    return BidDetailsPopupMenu(
      bid: widget.bid,
      auction: widget.auction,
      acceptBid: widget.acceptBid,
      rejectBid: widget.rejectBid,
      createBidReport: widget.createBidReport,
      removeBid: widget.removeBid,
    );
  }

  @override
  Widget build(BuildContext context) {
    var locale = Localizations.localeOf(context).languageCode;
    final formatCurrency = NumberFormat.currency(
      decimalDigits: widget.bid.value.price! % 1 == 0 ? 0 : 2,
      locale: locale,
      symbol: settingsController.settings.value.defaultCurrency,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              UserAvatar(
                account: widget.bid.value.bidder,
                small: true,
              ),
              Container(
                width: 8,
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    navigatorService.push(
                      ProfileDetailsScreen(
                        accountId: widget.bid.value.bidder!.id,
                      ),
                      NavigationStyle.SharedAxis,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              GenericUtils.generateNameForAccount(
                                  widget.bid.value.bidder),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 4,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.bid.value.locationPretty ??
                                  tr('auction_details.bids.unknown_location'),
                              maxLines: 1,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smallest,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              widget.bid.value.price != null && widget.bid.value.price! > 0
                  ? ScaleTap(
                      onPressed: () {
                        var alert = const AboutBidDialog();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .background_3,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              formatCurrency.format(widget.bid.value.price),
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              _renderPopupMenu(context),
            ],
          ),
          widget.bid.value.description != null &&
                  widget.bid.value.description != ''
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: ReadMoreText(
                          widget.bid.value.description!,
                          trimLines: 3,
                          trimLength: 100,
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                          trimExpandedText: tr("generic.see_less"),
                          trimCollapsedText: tr("generic.see_more"),
                          moreStyle: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                          lessStyle: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
