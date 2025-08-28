import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../theme/extensions/base.dart';

// ignore: must_be_immutable
class PromotedLabel extends StatelessWidget {
  bool small;

  PromotedLabel({
    super.key,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 4 : 8, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .extension<CustomThemeFields>()!
            .background_2
            .withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_3,
        ),
      ),
      child: Text(
        'promote_auction.promoted',
        style: small
            ? Theme.of(context)
                .extension<CustomThemeFields>()!
                .smallest
                .copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_1,
                )
            : Theme.of(context)
                .extension<CustomThemeFields>()!
                .smaller
                .copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_1,
                ),
      ).tr(),
    );
  }
}
