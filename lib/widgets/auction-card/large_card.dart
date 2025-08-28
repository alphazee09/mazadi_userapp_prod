import 'dart:async';

import 'package:animations/animations.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../core/controllers/auction.dart';
import '../../core/controllers/categories.dart';
import '../../core/controllers/favourites.dart';
import '../../core/controllers/settings.dart';
import '../../core/models/auction.dart';
import '../../screens/auction-details/index.dart';
import '../../theme/extensions/base.dart';
import '../common/love_button.dart';
import 'labels/bids_count.dart';
import 'widgets/auction_card_status.dart';
import 'widgets/promoted_label.dart';

class AuctionLargeCard extends StatefulWidget {
  final Rx<Auction> auction;
  final double? height;

  const AuctionLargeCard({
    super.key,
    required this.auction,
    this.height,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionCard createState() => _AuctionCard();
}

class _AuctionCard extends State<AuctionLargeCard>
    with AutomaticKeepAliveClientMixin {
  final favouritesController = Get.find<FavouritesController>();
  final accountController = Get.find<AccountController>();
  final categoriesController = Get.find<CategoriesController>();
  final auctionsController = Get.find<AuctionController>();
  final settingsController = Get.find<SettingsController>();

  final _carouselController = CarouselSliderController();
  int _currentCarouselStep = 0;
  bool _isLiked = false;
  double carouselHeight = 0;

  late StreamSubscription<Auction> _auctionChangeSubscription;
  late StreamSubscription<List<Rx<Auction>>> _favouritesSubscription;

  @override
  bool get wantKeepAlive => true;

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

    auctionsController.refreshRecommendations();
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
          child: Image.asset(
            'assets/jpg/default-item.jpeg',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    List<Widget> items = [];
    for (var asset in assets) {
      items.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            '$serverBaseUrl/assets/${asset.path}',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
          ),
        ),
      );
    }

    return CarouselSlider(
      controller: _carouselController,
      options: CarouselOptions(
        height: 150,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          _currentCarouselStep = index;
        },
      ),
      items: items,
    );
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    var priceToDisplay =
        widget.auction.value.lastPrice ?? widget.auction.value.startingPrice;
    var locale = Localizations.localeOf(context).languageCode;

    final formatCurrency = NumberFormat.currency(
      decimalDigits: priceToDisplay % 1 == 0 ? 0 : 2,
      locale: locale,
      symbol: settingsController.settings.value.defaultCurrency,
    );

    var isStartingSoon = widget.auction.value.startAt != null &&
        widget.auction.value.startedAt == null;
    var currentLanguage = context.locale.toString();

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
            handleRefreshCard();
          },
          openBuilder: (_, close) => AuctionDetailsScreen(
            auctionId: widget.auction.value.id,
            assetsLen: widget.auction.value.assets?.length ?? 0,
            onBack: (Auction? auction) {
              if (auction == null) {
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
                padding: EdgeInsets.all(4),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _renderAuctionAssets(),
                        Container(
                          width: 8,
                        ),
                        Container(
                          height: 100,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.auction.value.title,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .smaller,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    height: 4,
                                  ),
                                  Text(
                                    widget.auction.value.locationPretty!,
                                    style: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .smallest
                                        .copyWith(
                                          color: Theme.of(context)
                                              .extension<CustomThemeFields>()!
                                              .fontColor_2,
                                        ),
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: AuctionCardStatus(
                                      auction: widget.auction,
                                    ),
                                  ),
                                  isStartingSoon
                                      ? Text(
                                          DateFormat(
                                            'd MMM',
                                            currentLanguage,
                                          ).format(
                                              widget.auction.value.startAt!),
                                          maxLines: 1,
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .extension<CustomThemeFields>()!
                                              .smaller,
                                        )
                                      : Text(
                                          formatCurrency.format(priceToDisplay),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .extension<CustomThemeFields>()!
                                              .smaller
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                            top: 120,
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
