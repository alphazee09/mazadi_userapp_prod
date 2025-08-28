import 'package:mazadi/core/controllers/auction.dart';
import 'package:mazadi/theme/colors.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/flash.dart';
import '../../../core/controllers/location.dart';
import '../../../core/models/auction.dart';
import '../../../widgets/assets/select_assets_button.dart';
import '../../../widgets/common/action_button.dart';
import '../../../widgets/dialogs/go_back_confirmation.dart';
import '../../../widgets/simple_app_bar.dart';
import '../../create-auction/form-sections/category/index.dart';
import '../../create-auction/form-sections/condition.dart';
import '../../create-auction/form-sections/description.dart';
import '../../create-auction/form-sections/location.dart';
import '../../create-auction/form-sections/price.dart';
import '../../create-auction/form-sections/start_end.dart';
import '../../create-auction/form-sections/title.dart';

class UpdateAuctionScreen extends StatefulWidget {
  final Auction auction;
  const UpdateAuctionScreen({
    super.key,
    required this.auction,
  });

  @override
  State<UpdateAuctionScreen> createState() => _UpdateAuctionScreenState();
}

class _UpdateAuctionScreenState extends State<UpdateAuctionScreen> {
  final auctionController = Get.find<AuctionController>();
  final locationController = Get.find<LocationController>();
  final flashController = Get.find<FlashController>();

  final Rx<bool> _pointerDownInner = false.obs;
  bool _updateInProgress = false;

  @override
  void initState() {
    auctionController.initForUpdate(widget.auction);
    super.initState();
  }

  void goBack() {
    showGoBackConfirmationDialog(() {
      auctionController.clear();
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

  bool canUpdateAuction() {
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

  Future updateAuction() async {
    if (mounted) {
      setState(() {
        _updateInProgress = true;
      });
    }

    var updatedAuction = await auctionController.updateAuction(widget.auction);
    if (mounted) {
      setState(() {
        _updateInProgress = false;
      });
    }

    if (updatedAuction != null && mounted) {
      flashController.showMessageFlash(
        tr("auction_details.update.update_successful"),
        FlashMessageType.success,
      );

      Navigator.of(context).pop(true);
    }
  }

  Widget _renderBody() {
    return Column(
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
        widget.auction.startAt == null || widget.auction.startedAt != null
            ? Container()
            : Container(
                margin: EdgeInsets.only(top: 16),
                child: StartingAndEndingAuctionDatesSection(
                  forEdit: true,
                ),
              ),
        Container(height: 16),
        AuctionFormDescriptionSection(
          handleTitlePointerDown: () {
            _pointerDownInner.value = true;
          },
        ),
        Container(height: 50),
      ],
    );
  }

  Widget _renderBottomNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
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
                  var canUpdate = canUpdateAuction();

                  return ActionButton(
                    isLoading: _updateInProgress,
                    onPressed: () {
                      if (!canUpdate) {
                        return;
                      }
                      updateAuction();
                    },
                    background: canUpdate
                        ? Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action
                        : Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .separator,
                    height: 42,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'auction_details.update.update',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .title
                              .copyWith(
                                color: canUpdate
                                    ? DarkColors.font_1
                                    : Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .fontColor_1,
                              ),
                        ).tr(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          if (_pointerDownInner.value) {
            _pointerDownInner.value = false;
            return;
          }

          _pointerDownInner.value = false;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            resizeToAvoidBottomInset: true,
            appBar: SimpleAppBar(
              onBack: () => goBack(),
              withSearch: false,
              elevation: 0,
              title: Row(
                children: [
                  Text(
                    'auction_details.update.title',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ).tr()
                ],
              ),
            ),
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_1,
                width: Get.width,
                child: _renderBody(),
              ),
            ),
            bottomNavigationBar: _renderBottomNavbar(),
          ),
        ),
      ),
    );
  }
}
