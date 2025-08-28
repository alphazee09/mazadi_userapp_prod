// ignore_for_file: file_names
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/extensions/base.dart';

class IntroFourthStep extends StatelessWidget {
  const IntroFourthStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 16,
        ),
        SvgPicture.asset(
          'assets/icons/svg/intro/choose.svg',
          semanticsLabel: 'Choose winner',
          height: 120,
        ),
        Container(
          height: 64,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: tr('intro.chose_bid.if_you_pick'),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
              TextSpan(
                text: tr('intro.chose_bid.to_chat'),
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: tr('intro.chose_bid.to_arrange_settlement'),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
            ],
          ),
        ),
        Container(
          height: 32,
        ),
        Text(
          'intro.chose_bid.full_control',
          textAlign: TextAlign.center,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ).tr(),
      ],
    );
  }
}
