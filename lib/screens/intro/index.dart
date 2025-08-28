import 'package:mazadi/screens/intro/steps/2.dart';
import 'package:mazadi/screens/intro/steps/3.dart';
import 'package:mazadi/screens/intro/steps/5.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../theme/colors.dart';
import '../../theme/extensions/base.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/simple_app_bar.dart';
import 'dialogs/confirm_skip.dart';
import 'steps/1.dart';
import 'steps/4.dart';

class IntroStepperScreen extends StatefulWidget {
  const IntroStepperScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntroStepperScreen createState() => _IntroStepperScreen();
}

class _IntroStepperScreen extends State<IntroStepperScreen> {
  final _carouselController = CarouselSliderController();
  final accountController = Get.find<AccountController>();

  int _activeStep = 0;

  void _handleContinue() {
    if (_activeStep == 4) {
      accountController.finishIntro();
      Navigator.of(context).pop();
      Navigator.of(context).maybePop();

      return;
    }
    if (mounted) {
      setState(() {
        _activeStep += 1;
        _carouselController.nextPage();
      });
    }
  }

  void _handleBack() {
    if (_activeStep == 0) {
      _handleSkip();
      return;
    }
    if (mounted) {
      setState(() {
        _activeStep -= 1;
        _carouselController.previousPage();
      });
    }
  }

  String _getHeaderText() {
    switch (_activeStep) {
      case 0:
        return '';
      case 1:
        return tr("intro.steps.create_auction");
      case 2:
        return tr("intro.steps.wait_for_bids");
      case 3:
        return tr("intro.steps.accept_bid");
      case 4:
        return tr("intro.steps.review");
      default:
        return '';
    }
  }

  Future<dynamic> _handleSkip() {
    var alert = ConfirmSkipIntroDialog();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _renderBottomNavbar() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ScaleTap(
              onPressed: () {
                _handleBack();
              },
              child: ActionButton(
                background: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_1,
                height: 42,
                onPressed: _handleBack,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _activeStep == 0 ? 'generic.skip' : 'generic.back',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.start,
                    ).tr(),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 16),
          Expanded(
            child: ActionButton(
              background:
                  Theme.of(context).extension<CustomThemeFields>()!.action,
              height: 42,
              onPressed: _handleContinue,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _activeStep == 4 ? 'generic.finish' : 'generic.continue',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: DarkColors.font_1,
                        fontWeight: FontWeight.bold,
                      ),
                ).tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderContent() {
    List<Widget> items = [
      IntroFirstStep(),
      IntroSecondStep(),
      IntroThirdStep(),
      IntroFourthStep(),
      IntroFifthStep(),
    ];

    return Column(
      children: [
        CarouselSlider(
          items: items,
          controller: _carouselController,
          options: CarouselOptions(
            autoPlay: false,
            height: Get.height - 350,
            aspectRatio: 2,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              if (mounted) {
                setState(() {
                  _activeStep = index;
                });
              }
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [1, 2, 3, 4, 5].asMap().entries.map(
            (entry) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsetsDirectional.only(end: 4, top: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1
                        .withOpacity(
                          _activeStep == entry.key ? 0.9 : 0.5,
                        ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        bottomNavigationBar: _renderBottomNavbar(),
        appBar: SimpleAppBar(
          withBack: false,
          withSearch: false,
          elevation: 0,
          bottomHeight: 30,
          title: Container(),
          bottom: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 8,
              ),
              Text(
                'intro.how_it_works',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .title
                    .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).tr(),
              Container(
                height: 8,
              ),
              Text(
                _getHeaderText(),
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .title
                    .copyWith(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .action,
                      fontWeight: FontWeight.w500,
                    ),
              )
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _renderContent(),
        ),
      ),
    );
  }
}
