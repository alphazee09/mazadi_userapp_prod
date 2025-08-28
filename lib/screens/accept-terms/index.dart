import 'package:mazadi/widgets/simple_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../core/controllers/terms.dart';
import '../../core/navigator.dart';
import '../../theme/colors.dart';
import '../../widgets/common/action_button.dart';
import '../auth/terms_and_conditions.dart';

class AcceptsTermsOfServiceScreen extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final accountController = Get.find<AccountController>();
  final termsAndConditionController = Get.find<TermsAndConditionController>();

  void _handleContinue() {
    if (!termsAndConditionController.acceptedTermsAndConditions.value) {
      return;
    }

    termsAndConditionController.commit();
  }

  Widget? _renderBottomNavbar(BuildContext context) {
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
            Obx(
              () => Flexible(
                child: ActionButton(
                  background: !termsAndConditionController
                          .acceptedTermsAndConditions.value
                      ? Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .separator
                      : Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .action,
                  height: 42,
                  onPressed: _handleContinue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'auth.terms.continue',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title
                          .copyWith(
                            color: !termsAndConditionController
                                    .acceptedTermsAndConditions.value
                                ? Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1
                                : DarkColors.font_1,
                          ),
                    ).tr(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        appBar: SimpleAppBar(
          withBack: false,
          withSearch: false,
          elevation: 0,
          title: Container(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'auth.terms.almost_there',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ).tr(),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 32,
            horizontal: 24,
          ),
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 24,
                ),
                SvgPicture.asset(
                  'assets/icons/svg/terms-and-conditions.svg',
                  height: 100,
                  semanticsLabel: 'Terms & Conditions',
                ),
                Container(
                  height: 32,
                ),
                Obx(() => TermsAndConditionsCheck(
                      onChange: () {
                        termsAndConditionController.toggleTermsAndConditions();
                      },
                      value: termsAndConditionController
                          .acceptedTermsAndConditions.value,
                    )),
                Container(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _renderBottomNavbar(context),
      ),
    );
  }
}
