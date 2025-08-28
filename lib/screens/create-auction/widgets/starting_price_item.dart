import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../core/controllers/settings.dart';

class StartingPriceItem extends StatelessWidget {
  final settingsController = Get.find<SettingsController>();

  final double? price;
  final bool selected;
  final bool isCustom;
  final Function onTap;

  StartingPriceItem({
    super.key,
    this.price,
    required this.selected,
    required this.onTap,
    this.isCustom = false,
  });

  Widget _renderPrice(BuildContext context) {
    var locale = Localizations.localeOf(context).languageCode;
    final formatCurrency = NumberFormat.currency(
      decimalDigits: price! % 1 == 0 ? 0 : 2,
      locale: locale,
      symbol: settingsController.settings.value.defaultCurrency,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: formatCurrency.format(price),
            style: Theme.of(context)
                .extension<CustomThemeFields>()!
                .smaller
                .copyWith(
                  fontWeight: FontWeight.w500,
                ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: () {
        onTap();
      },
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .action
                  .withOpacity(0.1)
              : Theme.of(context).extension<CustomThemeFields>()!.background_2,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: selected
                ? Theme.of(context).extension<CustomThemeFields>()!.action
                : Theme.of(context).extension<CustomThemeFields>()!.separator,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isCustom
                  ? price == null
                      ? Text(
                          'create_auction.another_starting_price',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ).tr()
                      : Expanded(
                          child: _renderPrice(context),
                        )
                  : Expanded(
                      child: _renderPrice(context),
                    ),
            ]),
      ),
    );
  }
}
