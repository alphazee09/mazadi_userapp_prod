import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/svg/logo.svg',
          height: 32,
          semanticsLabel: 'Logo',
        ),
        Container(
          width: 8,
        ),
        Text(
          'mazadi',
          style: Theme.of(context)
              .extension<CustomThemeFields>()!
              .smaller
              .copyWith(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .fontColor_1,
                fontFamily: GoogleFonts.abrilFatface().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
        ),
      ],
    );
  }
}
