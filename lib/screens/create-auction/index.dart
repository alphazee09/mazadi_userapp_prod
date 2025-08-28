import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/controllers/account.dart';
import '../../core/controllers/ads.dart';
import '../../core/controllers/auction.dart';
import '../../core/controllers/flash.dart';
import '../../core/controllers/image_picker.dart';
import '../../core/controllers/location.dart';
import '../../core/controllers/main.dart';
import '../../core/controllers/settings.dart';
import '../../core/models/auction.dart';
import '../../core/navigator.dart';
import '../../theme/colors.dart';
import '../../widgets/assets/select_assets_button.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/dialogs/go_back_confirmation.dart';
import '../../widgets/simple_app_bar.dart';

import '../auction-details/index.dart';
import 'dialogs/confirm_auction_creation.dart';
import 'form-sections/category/index.dart';
import 'form-sections/condition.dart';
import 'form-sections/description.dart';
import 'form-sections/location.dart';
import 'form-sections/price.dart';
import 'form-sections/start_end.dart';
import 'form-sections/title.dart';

class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateAuctionScreenState createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();

  final mainController = Get.find<MainController>();
  final accountController = Get.find<AccountController>();
  final imagePickerController = Get.find<ImagePickerController>();
  final navigatorService = Get.find<NavigatorService>();
  final locationController = Get.find<LocationController>();
  final auctionController = Get.find<AuctionController>();
  final flashController = Get.find<FlashController>();
  final adsController = Get.find<AdsController>();
  final settingsController = Get.find<SettingsController>();

  final _descriptionController = TextEditingController();
  final RxInt _descriptionLength = 0.obs;

  final Rx<bool> _pointerDownInner = false.obs;
  bool _createInProgress = false;
  late String googleAPIKey = '';

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    _descriptionController.text = auctionController.description.value;
    _descriptionLength.value = auctionController.description.value.length;

    _descriptionController.addListener(() {
      auctionController.setDescription(_descriptionController.text);
    });

    googleAPIKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

    // If the google API KEY is empty, automatically select a location, so that the user doesn't have to do it manually
    if (googleAPIKey.isEmpty) {
      locationController.selectDefaultLocation();
    }

    loadInterstitialAd();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    if (_interstitialAd != null) {
      adsController.releaseInterstitialAd(_interstitialAd!);
    }
    super.dispose();
  }

  Future<void> loadInterstitialAd() async {
    _interstitialAd = await adsController.getInterstitialAd();
  }

  void goBack() {
    if (imagePickerController.assetsAreSelected()) {
      showGoBackConfirmationDialog(() {
        imagePickerController.clear();
      });
      return;
    }

    Navigator.of(context).pop();
  }

  bool canCreateAuction() {
    if (auctionController.title.value == '') {
      return false;
    }

    if (auctionController.mainCategoryId.value == '') {
      return false;
    }

    if (auctionController.subCategoryId.value == '') {
      return false;
    }

    if (locationController.location.value == '') {
      return false;
    }

    return true;
  }

  Future<void> handleSubmit() async {
    if (_createInProgress) {
      return;
    }

    if (auctionController.title.value == '') {
      flashController.showMessageFlash(tr('create_auction.title_required'));
      return;
    }

    if (auctionController.mainCategoryId.value == '' ||
        auctionController.subCategoryId.value == '') {
      flashController.showMessageFlash(tr('create_auction.category_required'));
      return;
    }

    if (locationController.location.value == '') {
      flashController.showMessageFlash(tr('create_auction.location_required'));
      return;
    }

    if (auctionController.startingPrice.value == 0.0) {
      flashController.showMessageFlash(tr('create_auction.price_required'));
      return;
    }

    if (!canCreateAuction()) {
      return;
    }

    if (settingsController.settings.value.freeAuctionsCount <=
        accountController.accountAuctionsCount.value) {
      showCreateAuctionConfirmDialog(context, handleCreateAuction);
      return;
    }

    handleCreateAuction();
  }

  void showCreateAuctionConfirmDialog(BuildContext context, Function onSubmit) {
    var alert = ConfirmCreateAuctionDialog(
      onSubmit: onSubmit,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> handleCreateAuction() async {
    if (mounted) {
      setState(() {
        _createInProgress = true;
      });
    }

    var createdAuction = await auctionController.create();

    if (mounted) {
      setState(() {
        _createInProgress = false;
      });
    }

    if (createdAuction == null) {
      return;
    }

    auctionController.clear();

    if (_interstitialAd == null) {
      handleAuctionCreated(createdAuction);
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          handleAuctionCreated(createdAuction);
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          handleAuctionCreated(createdAuction);
        },
      );
      _interstitialAd!.show();
    } catch (e) {
      handleAuctionCreated(createdAuction);
    }
  }

  void handleAuctionCreated(Auction createdAuction) {
    var assetsLen = imagePickerController.getSelectedAssetsCount();

    navigatorService
        .push(
            AuctionDetailsScreen(
              assetsLen: assetsLen,
              auctionId: createdAuction.id,
              isNewAuction: true,
            ),
            NavigationStyle.SharedAxis,
            true)!
        .then((dynamic data) {
      var auctionFromController = auctionController.auctions
          .firstWhereOrNull((auction) => auction.value.id == createdAuction.id);

      if (auctionFromController != null) {
        auctionFromController.refresh();
      }

      imagePickerController.clear();
    });
  }

  void showGoBackConfirmationDialog(Function onSubmit) {
    var alert = GoBackConfirmationDialog(onSubmit: onSubmit);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _renderAuctionCreationCost(bool canCreate) {
    var style = Theme.of(context)
        .extension<CustomThemeFields>()!
        .smallest
        .copyWith(
          color: canCreate
              ? DarkColors.font_1
              : Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
        );
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
            'no':
                settingsController.settings.value.auctionsCoinsCost.toString(),
          },
        ),
        Text(')', style: style)
      ],
    );
  }

  Widget? _renderBottomNavbar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          border: Border(
            top: BorderSide(
              color:
                  Theme.of(context).extension<CustomThemeFields>()!.separator,
              width: 1,
            ),
          ),
        ),
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              Flexible(
                child: Obx(
                  () {
                    var canCreate = canCreateAuction();
                    return ActionButton(
                      background: !canCreate
                          ? Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .separator
                          : Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .action,
                      height: 42,
                      onPressed: handleSubmit,
                      isLoading: _createInProgress,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'create_auction.create_auction',
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .title
                                  .copyWith(
                                    color: canCreate
                                        ? DarkColors.font_1
                                        : Theme.of(context)
                                            .extension<CustomThemeFields>()!
                                            .fontColor_1,
                                  ),
                            ).tr(),
                            settingsController
                                        .settings.value.freeAuctionsCount <=
                                    accountController.accountAuctionsCount.value
                                ? _renderAuctionCreationCost(canCreate)
                                : Container()
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderBody(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectAssetsButton(),
            AuctionFormTitleSection(
              handleTitlePointerDown: () {
                _pointerDownInner.value = true;
              },
            ),
            AuctionFormCategorySection(),
            Container(height: 16),
            AuctionFormConditionSection(),
            Container(height: 16),
            AuctionFormPriceSection(),
            Container(height: 16),
            AuctionFormLocationSection(),
            Container(
              height: 16,
            ),
            StartingAndEndingAuctionDatesSection(),
            Container(height: 16),
            AuctionFormDescriptionSection(
              handleTitlePointerDown: () {
                _pointerDownInner.value = true;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
            onBack: goBack,
            withSearch: false,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'create_auction.create_a_new_auction',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ).tr(),
                ),
              ],
            )),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            width: Get.width,
            child: _renderBody(context),
          ),
        ),
        bottomNavigationBar: _renderBottomNavbar(),
      ),
    );
  }
}
