import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingFour(
      color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_2,
    );
  }
}
