// ignore_for_file: file_names
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/extensions/base.dart';

class IntroFirstStep extends StatelessWidget {
  const IntroFirstStep({super.key});

  @override
  Widget build(BuildContext context) {
    var onMessage = tr('intro.on');
    var easilyTradeMessage = tr('intro.can_easily_trade');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 16,
        ),
        SvgPicture.asset(
          'assets/icons/svg/intro/guide.svg',
          semanticsLabel: 'Guide',
          height: 120,
        ),
        Container(
          height: 32,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: onMessage,
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ),
              TextSpan(
                text: "mazadi",
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontFamily: GoogleFonts.abrilFatface().fontFamily,
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .action,
                      fontSize: 22,
                    ),
              ),
              TextSpan(
                text: easilyTradeMessage,
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ),
            ],
          ),
        ),
        Container(
          height: 32,
        ),
      ],
    );
  }
}
