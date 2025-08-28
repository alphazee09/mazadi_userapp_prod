import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/navigator.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/simple_button.dart';
import '../buy-coins/index.dart';

class ProfileBuyCoinsCard extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16),
      child: ScaleTap(
        onPressed: () {
          navigatorService.push(
            BuyCoinsScreen(),
            NavigationStyle.SharedAxis,
          );
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .extension<CustomThemeFields>()!
                .background_3
                .withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_3,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/svg/coin.svg',
                          height: 24,
                          width: 24,
                          semanticsLabel: 'Coins',
                        ),
                        Container(
                          margin: EdgeInsetsDirectional.only(start: 8),
                          child: Obx(
                            () => Text(
                              'buy_coins.coins_no',
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller,
                            ).tr(namedArgs: {
                              'no': accountController.account.value.coins
                                  .toString(),
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150, minWidth: 100),
                    child: SimpleButton(
                      onPressed: () {
                        navigatorService.push(
                          BuyCoinsScreen(),
                          NavigationStyle.SharedAxis,
                        );
                      },
                      background: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .action,
                      child: Text(
                        'buy_coins.buy_coins',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller
                            .copyWith(color: DarkColors.font_1),
                      ).tr(),
                    ),
                  ),
                ],
              ),
              Container(
                height: 8,
              ),
              Text(
                'buy_coins.buy_coins_and_promote',
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(),
            ],
          ),
        ),
      ),
    );
  }
}
