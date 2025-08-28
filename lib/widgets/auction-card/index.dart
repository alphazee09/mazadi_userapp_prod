import 'dart:async';

import 'package:animations/animations.dart';
import 'package:mazadi/utils/constants.dart';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../core/controllers/auction.dart';
import '../../core/controllers/favourites.dart';
import '../../core/controllers/settings.dart';
import '../../core/models/auction.dart';
import '../../screens/auction-details/index.dart';
import '../common/love_button.dart';
import '../runtime/measure_size.dart';
import 'labels/bids_count.dart';
import 'widgets/auction_card_status.dart';
import 'widgets/promoted_label.dart';

class AuctionCard extends StatefulWidget {
  final Rx<Auction> auction;
  final double? height;
  final bool? ignoreUpdateOnClose;

  const AuctionCard({
    super.key,
    required this.auction,
    this.height,
    this.ignoreUpdateOnClose,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionCard createState() => _AuctionCard();
}

class _AuctionCard extends State<AuctionCard>
    with AutomaticKeepAliveClientMixin {
  final favouritesController = Get.find<FavouritesController>();
  final accountController = Get.find<AccountController>();
  final auctionsController = Get.find<AuctionController>();
  final auctionController = Get.find<AuctionController>();
  final settingsController = Get.find<SettingsController>();

  final _carouselController = CarouselSliderController();
  int _currentCarouselStep = 0;
  bool _isLiked = false;
  double carouselHeight = 0;

  @override
  bool get wantKeepAlive => true;

  late StreamSubscription<Auction> _auctionChangeSubscription;
  late StreamSubscription<List<Rx<Auction>>> _favouritesSubscription;

  @override
  void initState() {
    super.initState();
    _auctionChangeSubscription = widget.auction.listen((auction) {
      if (mounted) {
        setState(() {});
      }
    });

    _isLiked = favouritesController.isFavourite(widget.auction.value.id);

    _favouritesSubscription = favouritesController.favourites.listen((val) {
      if (!mounted) {
        return;
      }

      if (mounted) {
        setState(() {
          var newValue =
              favouritesController.isFavourite(widget.auction.value.id);
          if (newValue != _isLiked) {
            _isLiked = newValue;
          }
        });
      }
    });

    _carouselController.onReady.then((val) {
      try {
        _carouselController.jumpToPage(_currentCarouselStep);
        // ignore: empty_catches
      } catch (error) {}
    });
  }

  @override
  void dispose() {
    _auctionChangeSubscription.cancel();
    _favouritesSubscription.cancel();
    super.dispose();
  }

  void handleRefreshCard() {
    for (var auction in [
      ...favouritesController.favourites,
      ...auctionsController.auctions,
    ]) {
      if (auction.value.id == widget.auction.value.id) {
        auction.refresh();
      }
    }

    widget.auction.refresh();
  }

  String formatDouble(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

  Future<void> handleLoveTap(bool picked) async {
    if (mounted) {
      setState(() {
        _isLiked = picked;
      });
    }

    if (picked) {
      await favouritesController.addAuctionToFavourites(widget.auction);
    } else {
      await favouritesController
          .removeAuctionFromFavourites(widget.auction.value.id);
    }
    auctionController.refreshRecommendations();
  }

  Widget _renderLabels() {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return Positioned(
      left: isRTL ? null : 8,
      right: isRTL ? 8 : null,
      top: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [BidsCountAuctionLabel(auction: widget.auction.value)],
      ),
    );
  }

  Widget _renderAssetsLeftArrow() {
    var assets = widget.auction.value.assets ?? [];
    var assetsLen = assets.length;
    if (assetsLen <= 1) {
      return Container();
    }

    return Positioned(
      left: 8,
      top: 50,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context)
            .extension<CustomThemeFields>()!
            .separator
            .withOpacity(0.3),
        child: IconButton(
          padding: const EdgeInsetsDirectional.only(end: 4),
          constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
          iconSize: 32,
          splashRadius: 24,
          color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
          onPressed: () {
            _carouselController.animateToPage(_currentCarouselStep - 1);
          },
          icon: SvgPicture.asset(
            'assets/icons/svg/previous1.svg',
            semanticsLabel: 'Previous',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderPackRightArrow() {
    var assets = widget.auction.value.assets ?? [];
    var assetsLen = assets.length;
    if (assetsLen <= 1) {
      return Container();
    }

    return Positioned(
      right: 8,
      top: 50,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context)
            .extension<CustomThemeFields>()!
            .separator
            .withOpacity(0.3),
        child: IconButton(
          padding: const EdgeInsets.only(left: 4),
          constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
          splashRadius: 24,
          iconSize: 32,
          color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
          onPressed: () {
            _carouselController.animateToPage(_currentCarouselStep + 1);
          },
          icon: SvgPicture.asset(
            'assets/icons/svg/next1.svg',
            semanticsLabel: 'Next',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderAuctionAssets() {
    var assets = widget.auction.value.assets ?? [];
    var assetsLen = assets.length;
    var serverBaseUrl = FlutterConfig.get('SERVER_URL');

    if (assetsLen == 0) {
      return SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: settingsController
                      .settings.value.defaultProductImageUrl.isNotEmpty &&
                  settingsController.settings.value.defaultProductImageUrl !=
                      Constants.DEFAULT_ITEM_IMAGE
              ? Image.network(
                  settingsController.settings.value.defaultProductImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 130,
                )
              : Image.asset(
                  'assets/jpg/default-item.jpeg',
                  height: 130,
                  fit: BoxFit.cover,
                ),
        ),
      );
    }

    List<Widget> items = [];
    for (var asset in assets) {
      items.add(
        MeasureSize(
          onHeightAvailable: (double height) {
            if (mounted) {
              setState(() {
                carouselHeight = height;
              });
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              '$serverBaseUrl/assets/${asset.path}',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 130,
            ),
          ),
        ),
      );
    }

    return CarouselSlider(
      controller: _carouselController,
      options: CarouselOptions(
        height: carouselHeight,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          _currentCarouselStep = index;
        },
      ),
      items: items,
    );
  }

  Widget _renderAuctionDetails() {
    var locale = Localizations.localeOf(context).languageCode;
    var priceToDisplay =
        widget.auction.value.lastPrice ?? widget.auction.value.startingPrice;

    final formatCurrency = NumberFormat.currency(
      decimalDigits: priceToDisplay % 1 == 0 ? 0 : 2,
      locale: locale,
      symbol: settingsController.settings.value.defaultCurrency,
    );

    return Container(
      height: 134,
      padding: EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.auction.value.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smallest
                          .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 8,
              ),
              Row(
                children: [
                  Text(
                    formatCurrency.format(priceToDisplay),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller
                        .copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  )
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.auction.value.locationPretty!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smallest
                    .copyWith(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_3,
                    ),
              ),
              Container(
                height: 8,
              ),
              AuctionCardStatus(
                auction: widget.auction,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return Material(
      elevation: 0,
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          return true; // Stop scroll notification from propagating
        },
        child: OpenContainer(
          useRootNavigator: true,
          closedElevation: 0,
          openColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          closedColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          onClosed: (auction) {
            if (widget.ignoreUpdateOnClose == true) {
              return;
            }

            handleRefreshCard();
          },
          openBuilder: (_, close) => AuctionDetailsScreen(
            auctionId: widget.auction.value.id,
            assetsLen: widget.auction.value.assets?.length ?? 0,
            onBack: (Auction? auction) {
              if (auction == null) {
                return;
              }

              if (widget.ignoreUpdateOnClose == true) {
                close();
                return;
              }

              widget.auction.value.startingPrice = auction.startingPrice;
              widget.auction.value.lastPrice = auction.lastPrice;
              widget.auction.value.assets = auction.assets;
              widget.auction.value.bidsCount = auction.bids.length;
              close();
            },
          ),
          closedBuilder: (_, VoidCallback openContainer) => Obx(
            () => InkWell(
              onTap: () {
                openContainer();
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Container(
                width: double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  border: Border.all(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .separator,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _renderAuctionAssets(),
                          Container(
                            height: 8,
                          ),
                          _renderAuctionDetails(),
                        ],
                      ),
                    ),
                    _renderAssetsLeftArrow(),
                    _renderPackRightArrow(),
                    _renderLabels(),
                    Positioned(
                      right: isRTL ? null : 8,
                      left: isRTL ? 8 : null,
                      top: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .background_2
                              .withOpacity(0.9),
                        ),
                        child: LoveButton(
                          paddingBottom: 0,
                          small: true,
                          iconSelectedColor: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .action,
                          iconUnselectedColor: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          liked: _isLiked,
                          onTap: handleLoveTap,
                        ),
                      ),
                    ),
                    widget.auction.value.promotedAt != null
                        ? Positioned(
                            top: 104,
                            right: isRTL ? 8 : null,
                            left: isRTL ? null : 8,
                            child: PromotedLabel(
                              small: true,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
