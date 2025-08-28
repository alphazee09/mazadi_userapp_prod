import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../widgets/common/simple_button.dart';

class DistanceTooLongForBidCreation extends StatelessWidget {
  const DistanceTooLongForBidCreation({super.key});

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
              'auction_details.long_distance.title',
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          IconButton(
            splashRadius: 24,
            iconSize: 14,
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: SvgPicture.asset(
              'assets/icons/svg/close.svg',
              semanticsLabel: 'Close',
              height: 20,
              // ignore: deprecated_member_use
              color:
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
            ),
          )
        ],
      ),
      content: IntrinsicHeight(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'auction_details.long_distance.description',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ],
            )),
      ),
      actions: [
        Row(
          children: [
            SimpleButton(
              background: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_3,
              onPressed: () {
                Navigator.pop(context, false);
              },
              height: 42,
              width: 120,
              child: Text(
                'generic.cancel',
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(),
            ),
          ],
        ),
      ],
    );
  }
}
