import 'package:mazadi/theme/extensions/base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../core/controllers/auction.dart';
import '../../core/controllers/bid.dart';
import '../../core/controllers/favourites.dart';
import '../../core/controllers/settings.dart';
import '../../core/models/asset.dart';
import '../../core/models/auction.dart';
import '../../widgets/common/love_button.dart';
import 'widgets/auction_assets_preview.dart';
import 'widgets/favourite_auction_accounts.dart';
import 'widgets/more_actions_popup.dart';

class AuctionDetailsAppBar extends StatefulWidget {
  final Rx<Auction> auction;
  final Function refreshData;
  final Widget content;
  final Function? onBack;
  final Function? onLikeTap;

  const AuctionDetailsAppBar({
    super.key,
    required this.auction,
    required this.refreshData,
    required this.content,
    this.onBack,
    this.onLikeTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionDetailsAppBar createState() => _AuctionDetailsAppBar();
}

class _AuctionDetailsAppBar extends State<AuctionDetailsAppBar>
    with SingleTickerProviderStateMixin {
  final favouritesController = Get.find<FavouritesController>();
  final auctionController = Get.find<AuctionController>();
  final accountController = Get.find<AccountController>();
  final bidsController = Get.find<BidController>();
  final settingsController = Get.find<SettingsController>();

  RxBool _isLiked = false.obs;
  RxInt _likesCount = 0.obs;

  @override
  void initState() {
    super.initState();
    _isLiked.value = favouritesController.isFavourite(widget.auction.value.id);
    _likesCount.value = widget.auction.value.likesCount ?? 0;

    var isOwnerOfAuction = widget.auction.value.auctioneer?.id ==
        accountController.account.value.id;
    if (!isOwnerOfAuction) {
      return;
    }

    bidsController.markBidsFromAuctionAsSeen(widget.auction.value.id);
  }

  Future<void> handleLoveTap(bool picked) async {
    if (mounted) {
      _isLiked.value = picked;
    }

    if (widget.onLikeTap != null) {
      widget.onLikeTap!(picked);
    }

    if (picked) {
      _likesCount.value += 1;
    } else {
      _likesCount.value -= 1;
    }
  }

  void handleShowAccountsWhoLikedAuction() {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: AuctionsWhoAddedAuctionAsFavouriteList(
              auctionId: widget.auction.value.id,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var isAuctionOwner = widget.auction.value.auctioneer?.id ==
        accountController.account.value.id;
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());
    var currentLanguage = context.locale.toString();

    return NestedScrollView(
      headerSliverBuilder: ((context, innerBoxIsScrolled) {
        return [
          ExtendedSliverAppbar(
            statusbarHeight: 1,
            toolBarColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            actions: Container(
              margin: EdgeInsetsDirectional.only(end: 16),
              child: Row(children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 46,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(
                            () => LoveButton(
                              paddingBottom: 2,
                              paddingTop: 0,
                              withLikesCount: true,
                              likesCount: _likesCount.value,
                              iconSelectedColor: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .action,
                              iconUnselectedColor: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                              iconSize: 25,
                              liked: _isLiked.value,
                              onTap: handleLoveTap,
                              onLongTap: handleShowAccountsWhoLikedAuction,
                            ),
                          ),
                        ],
                      ),
                    ),
                    isAuctionOwner &&
                            (!widget.auction.value.isActive ||
                                widget.auction.value.acceptedBidId != null)
                        ? Container()
                        : Container(
                            width: 46,
                            height: 46,
                            margin: EdgeInsetsDirectional.only(start: 8),
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .background_2
                                  .withOpacity(0.9),
                            ),
                            child: AuctionDetailsMoreActionsPopup(
                              auction: widget.auction,
                              refreshData: widget.refreshData,
                            ),
                          ),
                  ],
                )
              ]),
            ),
            leading: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Material(
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2
                            .withOpacity(0.9),
                      ),
                      child: IconButton(
                        splashRadius: 24,
                        icon: SvgPicture.asset(
                          isRTL
                              ? 'assets/icons/svg/next.svg'
                              : 'assets/icons/svg/previous.svg',
                          // ignore: deprecated_member_use
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          semanticsLabel: 'Previous',
                        ),
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            background: IntrinsicHeight(
              child: Stack(
                children: [
                  PreviewAssetsScreen(
                    assets: widget.auction.value.assets != null &&
                            widget.auction.value.assets!.isNotEmpty
                        ? widget.auction.value.assets!
                        : [
                            Asset(
                              size: 10,
                              id: 'custom_asset',
                              path: '',
                              fullPath: settingsController
                                  .settings.value.defaultProductImageUrl,
                            )
                          ],
                  ),
                  Positioned(
                    bottom: 8,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: isRTL
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .background_2
                                .withOpacity(0.99),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                widget.auction.value.condition ==
                                        AuctionProductCondition.newProduct
                                    ? 'assets/icons/svg/auction-new.svg'
                                    : 'assets/icons/svg/auction-used.svg',
                                height: 22,
                                semanticsLabel: 'Auction condition',
                                // ignore: deprecated_member_use
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                              ),
                              Container(
                                width: 8,
                              ),
                              Text(
                                widget.auction.value.condition ==
                                        AuctionProductCondition.newProduct
                                    ? tr('create_auction.new')
                                    : tr('create_auction.used'),
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .smallest
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .extension<CustomThemeFields>()!
                                          .fontColor_1,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 8,
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .background_2
                                .withOpacity(0.99),
                          ),
                          child: Text(
                            DateFormat('d MMM, h:mm a', currentLanguage)
                                .format(widget.auction.value.createdAt),
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smallest
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .fontColor_1,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2
                            .withOpacity(0.99),
                      ),
                      child: Text(
                        tr('auction_details.details.views') +
                            widget.auction.value.views.toString(),
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smallest
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                            ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ];
      }),
      body: RefreshIndicator(
        color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.separator,
        edgeOffset: 150,
        onRefresh: () async {
          await widget.refreshData();
        },
        child: SingleChildScrollView(
          child: Container(
              color: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_1,
              child: widget.content),
        ),
      ),
    );
  }
}
