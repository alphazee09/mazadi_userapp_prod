import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/controllers/settings.dart';
import '../../../core/navigator.dart';
import '../../../theme/colors.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/simple_button.dart';
import '../../profile/buy-coins/index.dart';

class ConfirmCreateAuctionDialog extends StatelessWidget {
  final Function onSubmit;

  final settingsController = Get.find<SettingsController>();
  final accountController = Get.find<AccountController>();
  final flashController = Get.find<FlashController>();
  final navigatorService = Get.find<NavigatorService>();

  ConfirmCreateAuctionDialog({
    super.key,
    required this.onSubmit,
  });

  void handleSubmit() {
    if (accountController.account.value.coins <
        settingsController.settings.value.auctionsCoinsCost) {
      flashController.showMessageFlash(
          tr('coins_for_auction_or_bid.not_enough_for_auction'));
      return;
    }

    onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      titlePadding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'create_auction.create_auction',
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          IconButton(
            splashRadius: 24,
            iconSize: 14,
            onPressed: () {
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
      content: IntrinsicHeight(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'coins_for_auction_or_bid.reached_max_auctions',
                textAlign: TextAlign.start,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(
                namedArgs: {
                  'no': settingsController.settings.value.freeAuctionsCount
                      .toString(),
                },
              ),
              Container(
                height: 8,
              ),
              Text(
                'coins_for_auction_or_bid.reached_max_auctions_1',
                textAlign: TextAlign.start,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(
                namedArgs: {
                  'no': settingsController.settings.value.auctionsCoinsCost
                      .toString(),
                },
              ),
              Container(
                height: 8,
              ),
              Text(
                'coins_for_auction_or_bid.auction_get_back',
                textAlign: TextAlign.start,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(),
              Container(
                height: 8,
              ),
              Text(
                'coins_for_auction_or_bid.you_have_coins_no',
                textAlign: TextAlign.start,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(
                namedArgs: {
                  'no': accountController.account.value.coins.toString(),
                },
              ),
              Container(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      navigatorService.push(
                        BuyCoinsScreen(),
                        NavigationStyle.SharedAxis,
                      );
                    },
                    child: Text(
                      'buy_coins.buy_coins',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(
                            color: Colors.blue,
                          ),
                    ).tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                background: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_3,
                onPressed: () async {
                  Navigator.pop(context);
                },
                height: 42,
                width: 120,
                child: Text(
                  'generic.cancel',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                onPressed: () {
                  handleSubmit();
                },
                height: 42,
                width: 120,
                child: Text(
                  'create_auction.create_auction',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(color: DarkColors.font_1),
                ).tr(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
