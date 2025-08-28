import 'package:mazadi/core/controllers/bid.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/account.dart';
import '../../../core/controllers/chat.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/models/auction.dart';
import '../../../core/models/bid.dart';
import '../../../core/navigator.dart';
import '../../../theme/colors.dart';
import '../../../widgets/common/action_button.dart';
import '../../../widgets/common/simple_button.dart';
import '../../chat/channel.dart';
import '../dialogs/accept_bid.dart';
import '../dialogs/reject_bid.dart';
import 'bid_item_content.dart';

class AuctionDetailBidItem extends StatefulWidget {
  final Rx<Bid> bid;
  final Rx<Auction> auction;

  final Function removeBid;
  final Function createBidReport;

  const AuctionDetailBidItem({
    super.key,
    required this.bid,
    required this.auction,
    required this.removeBid,
    required this.createBidReport,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionDetailBidItem createState() => _AuctionDetailBidItem();
}

class _AuctionDetailBidItem extends State<AuctionDetailBidItem> {
  final accountController = Get.find<AccountController>();
  final bidController = Get.find<BidController>();
  final navigationService = Get.find<NavigatorService>();
  final chatController = Get.find<ChatController>();
  final flashController = Get.find<FlashController>();
  final navigatorService = Get.find<NavigatorService>();

  bool _acceptInProgress = false;
  bool _rejectInProgress = false;
  bool _loadingDirectChat = false;

  double _bidHeight = 0;
  double _bidWidth = 0;

  final GlobalKey _bidKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getWidgetInfo);
  }

  void _getWidgetInfo(_) {
    final renderBox =
        _bidKey.currentState?.context.findRenderObject() as RenderBox;

    if (mounted) {
      setState(() {
        _bidHeight = renderBox.size.height;
        _bidWidth = renderBox.size.width;
      });
    }
  }

  Future<bool> _acceptBid(Bid bid) async {
    if (_acceptInProgress) {
      return false;
    }
    if (mounted) {
      setState(() {
        _acceptInProgress = true;
      });
    }

    var accepted = await bidController.updateBid(
      bid.id!,
      null,
      false,
      true,
    );

    if (!accepted) {
      if (mounted) {
        setState(() {
          _acceptInProgress = false;
        });
      }
      return false;
    }

    var auction = widget.auction;
    var bidToUpdate =
        auction.value.bids.firstWhere((b) => b.value.id == bid.id);
    bidToUpdate.value.isAccepted = true;
    bidToUpdate.refresh();

    auction.value.acceptedBidId = bid.id;
    auction.value.acceptedBidAt = DateTime.now();
    auction.refresh();

    if (mounted) {
      setState(() {
        _acceptInProgress = false;
      });
    }

    return true;
  }

  Future<bool> _rejectBid(Bid bid, String rejectionReason) async {
    if (_rejectInProgress) {
      return false;
    }
    if (mounted) {
      setState(() {
        _rejectInProgress = true;
      });
    }

    var updated = await bidController.updateBid(
      bid.id!,
      rejectionReason,
      true,
      null,
    );

    if (!updated) {
      if (mounted) {
        setState(() {
          _rejectInProgress = false;
        });
      }
      return false;
    }

    var auction = widget.auction;
    var bidToUpdate =
        auction.value.bids.firstWhere((b) => b.value.id == bid.id);
    bidToUpdate.value.isRejected = true;
    bidToUpdate.value.rejectionReason = rejectionReason;

    if (mounted) {
      setState(() {
        _rejectInProgress = false;
      });
    }
    return true;
  }

  Future<bool> _removeBid() async {
    return await widget.removeBid(widget.bid.value.id);
  }

  Future<void> openDirectChatWithAccount() async {
    if (_loadingDirectChat || widget.bid.value.bidder?.id == null) {
      return;
    }

    setState(() {
      _loadingDirectChat = true;
    });

    try {
      var chatGroup = await chatController
          .getChatGroupWithAccount(widget.bid.value.bidder!.id);
      if (chatGroup == null) {
        flashController.showMessageFlash(tr('profile.cannot_load_chat_group'));
        return;
      }

      navigatorService.push(
        ChatChannel(chatGroup: chatGroup),
        NavigationStyle.SharedAxis,
      );
    } catch (error) {
      flashController.showMessageFlash(tr('profile.cannot_load_chat_group'));
    } finally {
      if (mounted) {
        setState(() {
          _loadingDirectChat = false;
        });
      }
    }
  }

  Widget _renderSendMessageButton() {
    if (widget.bid.value.isAccepted != true) {
      return Container();
    }

    var isAuctionOwner = widget.auction.value.auctioneer?.id ==
        accountController.account.value.id;

    if (!isAuctionOwner) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ActionButton(
        background: Colors.green,
        onPressed: () {
          openDirectChatWithAccount();
        },
        height: 42,
        width: 280,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/svg/chat.svg',
                height: 18,
                semanticsLabel: 'Send message',
                // ignore: deprecated_member_use
                color: DarkColors.font_1,
              ),
              Container(
                width: 8,
              ),
              Flexible(
                child: Text(
                  'profile.send_message',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: DarkColors.font_1,
                      ),
                ).tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderActions() {
    if (widget.bid.value.isAccepted == true ||
        widget.bid.value.isRejected == true) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RejectBidDialogContent(
                    onConfirm: (String rejectionReason) => _rejectBid(
                      widget.bid.value,
                      rejectionReason,
                    ),
                  );
                },
              );
            },
            isLoading: _rejectInProgress,
            height: 40,
            background:
                Theme.of(context).extension<CustomThemeFields>()!.separator,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'auction_details.bids.reject_bid',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ],
            ),
          ),
        ),
        Container(
          width: 8,
        ),
        Expanded(
          child: SimpleButton(
            background:
                Theme.of(context).extension<CustomThemeFields>()!.action,
            isLoading: _acceptInProgress,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AcceptBidDialogContent(
                    onConfirm: () => _acceptBid(widget.bid.value),
                  );
                },
              );
            },
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/svg/bid-types/accepted.svg',
                  height: 24,
                  semanticsLabel: 'Accepted bid',
                ),
                Container(
                  width: 8,
                ),
                Text(
                  'auction_details.bids.accept_bid',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(color: DarkColors.font_1),
                ).tr(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context)
              .extension<CustomThemeFields>()!
              .background_2
              .withOpacity(0.8),
          border: widget.auction.value.acceptedBidId == widget.bid.value.id
              ? Border.all(
                  color: Colors.green,
                  width: 1,
                )
              : Border.all(
                  color: Colors.transparent,
                ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                AuctionDetailsBidItemContent(
                  bid: widget.bid,
                  auction: widget.auction,
                  removeBid: _removeBid,
                  acceptBid: _acceptBid,
                  rejectBid: _rejectBid,
                  createBidReport: widget.createBidReport,
                  key: _bidKey,
                ),
                widget.bid.value.isRejected == true
                    ? Container(
                        height: _bidHeight,
                        width: _bidWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .background_1
                              .withOpacity(0.7),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'auction_details.bids.rejected',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .title
                                    .copyWith(
                                      color: Theme.of(context)
                                          .extension<CustomThemeFields>()!
                                          .action,
                                      fontFamily:
                                          GoogleFonts.caveatBrush().fontFamily,
                                      fontSize: 24,
                                    ),
                              ).tr(),
                              Flexible(
                                child: Text(
                                  widget.bid.value.rejectionReason ?? '',
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .smaller,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            widget.auction.value.auctioneer?.id ==
                        accountController.account.value.id &&
                    widget.auction.value.acceptedBidId == null &&
                    widget.bid.value.isAccepted != true &&
                    widget.bid.value.isRejected != true
                ? Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      top: 8,
                    ),
                    child: _renderActions(),
                  )
                : Container(),
            _renderSendMessageButton(),
          ],
        ),
      ),
    );
  }
}
