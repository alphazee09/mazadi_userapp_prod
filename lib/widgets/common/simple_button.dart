import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../theme/colors.dart';

class SimpleButton extends StatelessWidget {
  final double height;
  final double? width;

  final String? text;
  final Widget? child;

  final bool? filled;
  final Color? background;
  final Color? borderColor;
  final bool? withShadow;
  final bool isLoading;
  final double? borderRadius;

  final Function? onPressed;

  const SimpleButton({
    super.key,
    this.text,
    this.width,
    this.child,
    this.onPressed,
    this.height = 42,
    this.background,
    this.borderColor,
    this.withShadow = false,
    this.filled = true,
    this.isLoading = false,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 8)),
          border: Border.all(
            color: filled == true
                ? borderColor ?? Colors.transparent
                : borderColor ??
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
          ),
          color: filled == true
              ? background ??
                  Theme.of(context).extension<CustomThemeFields>()!.background_2
              : Colors.transparent,
        ),
        child: Center(
          child: isLoading
              ? const SpinKitThreeBounce(
                  color: DarkColors.font_1,
                  size: 20,
                )
              : text != null
                  ? Text(
                      text ?? '',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title,
                    )
                  : child ?? Container(),
        ),
      ),
    );
  }
}
