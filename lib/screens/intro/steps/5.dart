// ignore_for_file: file_names
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/extensions/base.dart';

class IntroFifthStep extends StatelessWidget {
  const IntroFifthStep({super.key});

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
          'assets/icons/svg/intro/rate.svg',
          semanticsLabel: 'Review',
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
                text: tr('intro.review.after_the_auction'),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
              TextSpan(
                text: tr('intro.review.leave_a_review'),
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: tr('intro.review.for_the_winner'),
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
          'intro.review.help_other_users',
          textAlign: TextAlign.center,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ).tr(),
      ],
    );
  }
}
