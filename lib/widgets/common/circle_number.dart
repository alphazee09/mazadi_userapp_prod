import 'package:mazadi/theme/colors.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

class CircleWithNumber extends StatelessWidget {
  final int? size;
  final String number;

  const CircleWithNumber({
    super.key,
    required this.number,
    this.size = 35,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: Theme.of(context)
              .extension<CustomThemeFields>()!
              .smaller
              .copyWith(color: DarkColors.font_1),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
