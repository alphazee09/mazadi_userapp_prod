import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/ads.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/controllers/location.dart';
import '../../../core/controllers/settings.dart';
import '../../../core/models/auction.dart';
import '../../../core/navigator.dart';
import '../../../theme/colors.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/input_like_button.dart';
import '../../../widgets/common/simple_button.dart';
import '../../../widgets/common/fullscreen-location-selector/index.dart';
import 'distance_too_long.dart';

class CreateBidDialog extends StatefulWidget {
  final Auction auction;
  final Function onConfirm;

  const CreateBidDialog({
    super.key,
    required this.auction,
    required this.onConfirm,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CreateBidDialogState createState() => _CreateBidDialogState();
}

class _CreateBidDialogState extends State<CreateBidDialog> {
  final locationController = Get.find<LocationController>();
  final navigatorService = Get.find<NavigatorService>();
  final flashController = Get.find<FlashController>();
  final settingsController = Get.find<SettingsController>();
  final adsController = Get.find<AdsController>();
  final accountController = Get.find<AccountController>();

  final _detailsController = TextEditingController();
  final _inputController = TextEditingController();
  final _form = GlobalKey<FormState>();

  bool actionInProgress = false;
  num minPrice = 1;
  final Rx<bool> _pointerDownInner = false.obs;
  late String googleAPIKey = '';

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    minPrice = computeMinPrice();

    googleAPIKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');
    // If the google API KEY is empty, automatically select a location, so that the user doesn't have to do it manually
    if (googleAPIKey.isEmpty) {
      locationController.selectDefaultLocation();
    }

    var inputInitialValue = minPrice + (widget.auction.bids.isEmpty ? 0 : 1);

    _inputController.text = inputInitialValue % 1 == 0
        ? inputInitialValue.toInt().toString()
        : inputInitialValue.toString();

    loadInterstitialAd();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _inputController.dispose();
    if (_interstitialAd != null) {
      adsController.releaseInterstitialAd(_interstitialAd!);
    }
    super.dispose();
  }

  Future<void> loadInterstitialAd() async {
    _interstitialAd = await adsController.getInterstitialAd();
  }

  num computeMinPrice() {
    num minPrice = 1;
    if (widget.auction.bids.isNotEmpty) {
      var bidWithHighestPrice = widget.auction.bids.reduce(
        (a, b) => (a.value.price ?? 0) > (b.value.price ?? 0) ? a : b,
      );
      minPrice = bidWithHighestPrice.value.price ?? 0;
    } else {
      minPrice = widget.auction.startingPrice;
    }
    return minPrice;
  }

  String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return '';
    }

    try {
      var value = double.parse(price);
      if (value < 1 ||
          value > settingsController.settings.value.maxProductPrice) {
        return '';
      }

      if (value < (widget.auction.bids.isEmpty ? minPrice : minPrice + 1)) {
        return '';
      }
    } catch (e) {
      return '';
    }

    return null;
  }

  void handleSubtract() {
    var price = _inputController.text;
    if (price.isEmpty) {
      return;
    }

    try {
      var value = double.parse(price);
      if (value <= (widget.auction.bids.isEmpty ? minPrice : minPrice + 1)) {
        return;
      }

      var floorNum = value.floor();
      if (floorNum == value) {
        value = value - 1;
      } else {
        value = floorNum.toDouble();
      }

      _inputController.text = value.toString();
      // ignore: empty_catches
    } catch (e) {}
  }

  void _cleanupLocation() {
    locationController.setLocation('');
    locationController.setMarkerLatLong(null);
  }

  void handleAdd() {
    var price = _inputController.text;
    if (price.isEmpty) {
      return;
    }

    try {
      var value = double.parse(price);
      if (value >= settingsController.settings.value.maxProductPrice) {
        return;
      }

      if (value < (widget.auction.bids.isEmpty ? minPrice : minPrice + 1)) {
        value =
            (widget.auction.bids.isEmpty ? minPrice : minPrice + 1).toDouble();
      } else {
        var nextInteger = value.toInt() + 1;
        value = nextInteger.toDouble();
      }

      _inputController.text = value.toString();
    } catch (e) {
      return;
    }
  }

  Future<bool> checkDistanceBetweenAuctionAndOffer() async {
    var auctionLatLng = widget.auction.location;
    var bidLocation = locationController.latLng.value;
    if (auctionLatLng != null && bidLocation != null) {
      var distanceBetweenPoints = GenericUtils.calculateDistanceBetweenPoints(
        auctionLatLng.latitude,
        auctionLatLng.longitude,
        bidLocation.latitude,
        bidLocation.longitude,
      );

      if (distanceBetweenPoints <=
          settingsController
              .settings.value.maxAllowedDistanceBetweenUsersInKM) {
        return true;
      }

      var alert = const DistanceTooLongForBidCreation();

      showDialog(
        context: navigator!.context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return false;
    }

    return true;
  }

  Future<void> _handleCreateBid() async {
    if (actionInProgress) {
      return;
    }

    if (locationController.location.value == '') {
      flashController.showMessageFlash(
        tr('auction_details.create_bid.location_is_required'),
      );
      return;
    }

    final isValid = _form.currentState?.validate();
    if (isValid == null || !isValid) {
      return;
    }

    var coinsNeeded = settingsController.settings.value.freeBidsCount <=
        accountController.accountBidsCount.value;
    if (coinsNeeded &&
        accountController.account.value.coins <
            settingsController.settings.value.bidsCoinsCost) {
      flashController
          .showMessageFlash(tr('coins_for_auction_or_bid.not_enough_for_bid'));
      return;
    }

    if (mounted) {
      setState(() {
        actionInProgress = true;
      });
    }

    var canCreate = await checkDistanceBetweenAuctionAndOffer();
    if (!canCreate) {
      if (mounted) {
        setState(() {
          actionInProgress = false;
        });
      }
      return;
    }

    await widget.onConfirm(
      double.parse(_inputController.text),
      _detailsController.text,
    );

    if (mounted) {
      setState(() {
        actionInProgress = false;
      });
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    if (_interstitialAd == null) {
      return;
    }

    // Show the interstitial ad with a 50% chance
    var random = Random().nextInt(2);
    if (random != 1) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
      },
    );

    // Delay 500ms to show the interstitial ad
    await Future.delayed(const Duration(milliseconds: 500));
    _interstitialAd!.show();
  }

  Widget _renderPriceInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ScaleTap(
            onPressed: () {
              handleSubtract();
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_3,
              ),
              child: Center(
                child: Text(
                  '-',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 8,
        ),
        Form(
          key: _form, //assigning key to form
          child: IntrinsicWidth(
            child: SizedBox(
              width: 130,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) {
                  _pointerDownInner.value = true;
                },
                child: TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  maxLength: 50,
                  keyboardType: TextInputType.number,
                  controller: _inputController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                  scrollPadding: const EdgeInsets.only(
                    bottom: 130,
                  ),
                  validator: validatePrice,
                  decoration: InputDecoration(
                    errorMaxLines: 3,
                    hintText: tr(
                      'auction_details.create_bid.price_hint',
                    ),
                    suffix: Container(
                      margin: const EdgeInsetsDirectional.only(start: 8),
                      child: Text(
                        settingsController.settings.value.defaultCurrency,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ),
                    ),
                    counterText: '',
                    fillColor: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2,
                    hintStyle: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 0.2,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        width: 1,
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    errorStyle: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smallest
                        .copyWith(
                          color: Colors.red,
                          height: 0,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 8,
        ),
        Flexible(
          child: ScaleTap(
            onPressed: () {
              handleAdd();
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_3,
              ),
              child: Center(
                child: Text(
                  '+',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderDetailsInput() {
    var hintMessage = tr("auction_details.create_bid.message_description");
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        _pointerDownInner.value = true;
      },
      child: TextField(
        maxLines: 4,
        minLines: 4,
        maxLength: 200,
        controller: _detailsController,
        style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        scrollPadding: const EdgeInsets.only(
          bottom: 130,
        ),
        decoration: InputDecoration(
          hintText: hintMessage,
          counterText: '',
          fillColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_3,
          hintStyle: Theme.of(context).extension<CustomThemeFields>()!.smaller,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2,
                width: 0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color:
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderLocationInput() {
    return Obx(
      () => InputLikeButton(
        withPrefixIcon: true,
        padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
        placeholder: locationController.location.value != ''
            ? locationController.location.value
            : tr("location.select_location"),
        prefixIcon: SvgPicture.asset(
          'assets/icons/svg/location.svg',
          semanticsLabel: 'Location',
          height: 20,
          colorFilter: ColorFilter.mode(
            Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
            BlendMode.srcIn,
          ),
        ),
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_3,
        sufixIcon: locationController.location.value != ''
            ? IconButton(
                splashRadius: 24,
                iconSize: 14,
                onPressed: () {
                  _cleanupLocation();
                },
                icon: SvgPicture.asset(
                  'assets/icons/svg/close.svg',
                  semanticsLabel: 'Close',
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : Container(),
        onTap: () {
          navigatorService.push(const FullscreenLocationSelectorScreen());
        },
      ),
    );
  }

  Widget _renderBidCreationCost() {
    var style = Theme.of(context)
        .extension<CustomThemeFields>()!
        .smallest
        .copyWith(color: DarkColors.font_1);
    return Row(
      children: [
        Container(
          width: 8,
        ),
        Text('(', style: style),
        SvgPicture.asset(
          'assets/icons/svg/coin.svg',
          height: 20,
          width: 20,
          semanticsLabel: 'Coins',
        ),
        Container(
          width: 4,
        ),
        Text(
          'buy_coins.coins_no',
          style: style,
        ).tr(
          namedArgs: {
            'no': settingsController.settings.value.bidsCoinsCost.toString(),
          },
        ),
        Text(')', style: style)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var locale = Localizations.localeOf(context).languageCode;
    final formatCurrency = NumberFormat.currency(
      decimalDigits: minPrice % 1 == 0 ? 0 : 2,
      locale: locale,
      symbol: settingsController.settings.value.defaultCurrency,
    );

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (_pointerDownInner.value) {
          _pointerDownInner.value = false;
          return;
        }

        _pointerDownInner.value = false;
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: AlertDialog(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_2,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        titlePadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'auction_details.create_bid.title',
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ).tr(),
            ),
            IconButton(
              splashRadius: 24,
              iconSize: 14,
              onPressed: () {
                if (actionInProgress) {
                  return;
                }

                Navigator.pop(context);
              },
              icon: SvgPicture.asset(
                'assets/icons/svg/close.svg',
                semanticsLabel: 'Close',
                height: 20,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
              ),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 4,
                      child: SvgPicture.asset(
                        'assets/icons/svg/payment.svg',
                        semanticsLabel: 'Price',
                        height: 40,
                        width: 40,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          widget.auction.bids.isEmpty
                              ? 'auction_details.create_bid.starting_price'
                              : 'auction_details.create_bid.highest_bid',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: DarkColors.font_1,
                              ),
                        ).tr(),
                        Container(
                          height: 8,
                        ),
                        Text(
                          formatCurrency.format(minPrice),
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: DarkColors.font_1,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Text(
                  widget.auction.bids.isEmpty
                      ? 'auction_details.create_bid.cannot_place_bid_lower'
                      : 'auction_details.create_bid.cannot_place_bid_lower_than_bid',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smallest
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_3,
                      ),
                ).tr(),
              ),
              Container(
                height: 24,
              ),
              Text(
                'auction_details.create_bid.select_price',
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ).tr(),
              Container(
                height: 16,
              ),
              _renderPriceInput(),
              Container(
                height: 24,
              ),
              Text(
                'location.your_location',
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ).tr(),
              Container(
                height: 16,
              ),
              _renderLocationInput(),
              googleAPIKey.isEmpty
                  ? Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'GOOGLE_MAPS_API_KEY not provided in the .env file. Location system might not work properly. Do not try to change it.',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smallest,
                      ),
                    )
                  : Container(),
              Container(
                height: 24,
              ),
              Text(
                'auction_details.create_bid.leave_a_message',
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ).tr(),
              Container(
                height: 16,
              ),
              _renderDetailsInput(),
              Container(
                height: 4,
              ),
            ],
          ),
        ),
        actions: [
          Container(),
          Obx(() => Column(
                children: [
                  SimpleButton(
                    isLoading: actionInProgress,
                    background: locationController.location.value == ''
                        ? Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .separator
                        : Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action,
                    onPressed: () async {
                      _handleCreateBid();
                    },
                    height: 42,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auction_details.create_bid.title',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                color: locationController.location.value != ''
                                    ? DarkColors.font_1
                                    : Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .fontColor_1,
                              ),
                        ).tr(),
                        settingsController.settings.value.freeBidsCount <=
                                accountController.accountBidsCount.value
                            ? _renderBidCreationCost()
                            : Container()
                      ],
                    ),
                  ),
                  settingsController.settings.value.freeBidsCount <=
                          accountController.accountBidsCount.value
                      ? Container(
                          margin: EdgeInsets.only(top: 4),
                          child: Text(
                            'coins_for_auction_or_bid.bid_get_back',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smallest,
                          ).tr(),
                        )
                      : Container()
                ],
              )),
        ],
      ),
    );
  }
}
