import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/controllers/settings.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/simple_button.dart';

class PromoteAuctionDialog extends StatefulWidget {
  final Function onPromote;

  const PromoteAuctionDialog({
    super.key,
    required this.onPromote,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PromoteAuctionDialogState createState() => _PromoteAuctionDialogState();
}

class _PromoteAuctionDialogState extends State<PromoteAuctionDialog> {
  final accountController = Get.find<AccountController>();
  final flashController = Get.find<FlashController>();
  final settingsController = Get.find<SettingsController>();

  bool _promotionInProgress = false;

  Future<void> handlePromote() async {
    if (_promotionInProgress) {
      return;
    }

    var hasEnoughCoins = accountController.account.value.coins >=
        settingsController.settings.value.promotionCoinsCost;
    if (!hasEnoughCoins) {
      flashController.showMessageFlash(
        tr("promote_auction.don_t_have_enough_coins"),
        FlashMessageType.error,
      );
      return;
    }

    if (mounted) {
      setState(() {
        _promotionInProgress = true;
      });
    }

    var promoted = await widget.onPromote();
    if (mounted) {
      setState(() {
        _promotionInProgress = false;
      });
    }

    if (!promoted) {
      flashController.showMessageFlash(
        tr("promote_auction.could_not_promote"),
        FlashMessageType.error,
      );
      return;
    }

    flashController.showMessageFlash(
      tr("promote_auction.auction_promoted"),
      FlashMessageType.success,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'promote_auction.sure_you_want_to_promote',
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          Container(
            height: 16,
          ),
          Center(
            child: Text(
              "promote_auction.promoted_will_show",
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(),
          ),
          Container(
            height: 8,
          ),
          Center(
            child: Text(
              "promote_auction.can_be_pushed_down",
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smallest,
            ).tr(),
          ),
          Container(
            height: 16,
          ),
          Center(
            child: Text(
              "promote_auction.promotion_cost",
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(namedArgs: {
              'no': settingsController.settings.value.promotionCoinsCost
                  .toString()
            }),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  Navigator.pop(context);
                },
                height: 42,
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
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  handlePromote();
                },
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svg/coin.svg',
                      height: 24,
                      width: 24,
                      semanticsLabel: 'Coins',
                    ),
                    Container(
                      width: 8,
                    ),
                    Text(
                      'promote_auction.promote_auction',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
