import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/settings.dart';
import '../../../core/models/auction.dart';
import 'timer.dart';

class AuctionCardStatus extends StatefulWidget {
  final Rx<Auction> auction;
  final double? fontSize;
  final Color? fontColor;
  final FontWeight? fontWeight;

  const AuctionCardStatus({
    super.key,
    required this.auction,
    this.fontSize,
    this.fontColor,
    this.fontWeight,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionCardStatus createState() => _AuctionCardStatus();
}

class _AuctionCardStatus extends State<AuctionCardStatus> {
  final settingsController = Get.find<SettingsController>();
  StreamSubscription<Auction>? auctionSubscription;

  bool countdownStarted = true;
  bool isClosed = false;
  bool startingSoon = false;
  late Duration duration;

  @override
  void initState() {
    super.initState();
    computeAuctionStatus();

    auctionSubscription = widget.auction.listen((p0) {
      computeAuctionStatus();
    });
  }

  @override
  void dispose() {
    auctionSubscription?.cancel();
    super.dispose();
  }

  void computeAuctionStatus() {
    var dateToCheck = widget.auction.value.createdAt;

    var deadline = widget.auction.value.expiresAt ??
        dateToCheck.add(
          Duration(
            hours: settingsController.settings.value.auctionActiveTimeInHours,
          ),
        );

    var durationDiff = deadline.difference(DateTime.now());

    setState(() {
      duration = deadline.difference(DateTime.now());
      startingSoon = widget.auction.value.startAt != null &&
          widget.auction.value.startedAt == null;
      isClosed = !widget.auction.value.isActive ||
          durationDiff.inSeconds < 0 ||
          widget.auction.value.acceptedBidId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (startingSoon) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                'starting_soon_auctions.starting_soon',
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(),
            )
          ],
        ),
      );
    }

    if (isClosed) {
      return Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'auction_details.closed',
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(),
          ),
          widget.auction.value.acceptedBidId != null
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'auction_details.accepted_bid',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smallest
                        .copyWith(
                          color: Colors.green,
                        ),
                  ).tr(),
                )
              : Container()
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/svg/hourglass.svg',
          height: 16,
          semanticsLabel: 'Timer',
        ),
        Container(
          width: 8,
        ),
        Countdown(
          duration: duration,
          fontSize: widget.fontSize,
          color: widget.fontColor,
          fontWeight: widget.fontWeight,
        ),
      ],
    );
  }
}
