// ignore_for_file: file_names
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/extensions/base.dart';

class IntroThirdStep extends StatelessWidget {
  const IntroThirdStep({super.key});

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
          'assets/icons/svg/intro/wait.svg',
          semanticsLabel: 'Wait',
          height: 120,
        ),
        Container(
          height: 64,
        ),
        Text(
          'intro.wait_for_bid.can_wait',
          textAlign: TextAlign.center,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ).tr(),
      ],
    );
  }
}
