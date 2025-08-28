import 'package:mazadi/core/controllers/flash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/controllers/payments.dart';
import '../../../theme/colors.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/simple_button.dart';

class BuyCoinsCard extends StatefulWidget {
  final Color background;
  final StoreProduct product;

  const BuyCoinsCard({
    super.key,
    required this.background,
    required this.product,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BuyCoinsCard createState() => _BuyCoinsCard();
}

class _BuyCoinsCard extends State<BuyCoinsCard> {
  final paymentsController = Get.find<PaymentsController>();
  final flasController = Get.find<FlashController>();

  bool _paymentInProgress = false;

  Future<void> handlePayment() async {
    if (_paymentInProgress) {
      return;
    }

    setState(() {
      _paymentInProgress = true;
    });

    try {
      var result = await paymentsController.purchaseProduct(widget.product);
      if (result == PaymentResult.success) {
        flasController.showMessageFlash(
          tr('buy_coins.success_purchase'),
          FlashMessageType.success,
        );
      } else {
        flasController.showMessageFlash(
          tr('buy_coins.error_purchase'),
          FlashMessageType.error,
        );
      }
    } catch (e) {
      flasController.showMessageFlash(
        tr('buy_coins.error_purchase'),
        FlashMessageType.error,
      );
    } finally {
      setState(() {
        _paymentInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(16),
          margin: EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/coin.svg',
                        height: 24,
                        width: 24,
                        semanticsLabel: 'Coins',
                      ),
                      Container(
                        margin: EdgeInsetsDirectional.only(start: 8),
                        child: Text(
                          'buy_coins.coins_no',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(color: DarkColors.font_1),
                        ).tr(namedArgs: {
                          'no': paymentsController
                              .getPointsForProduct(widget.product)
                              .toString(),
                        }),
                      ),
                    ],
                  ),
                  Text(
                    widget.product.priceString,
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
              Container(
                height: 8,
              ),
              Text(
                'buy_coins.buy_coins_and_promote',
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ).tr(),
              Container(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 160),
                      child: SimpleButton(
                        onPressed: handlePayment,
                        isLoading: _paymentInProgress,
                        background: _paymentInProgress
                            ? LightColors.font_1
                            : DarkColors.font_1,
                        child: Text(
                          'buy_coins.buy_coins',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(color: LightColors.font_1),
                        ).tr(),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
