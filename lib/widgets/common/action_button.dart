import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../theme/colors.dart';

class ActionButton extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color? background;
  final bool filled;
  final double radius;
  final Function? onPressed;
  final Widget? trailingButton;
  final Border? border;
  final double trailingWidth;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = 42,
    this.radius = 8,
    this.filled = false,
    this.trailingButton,
    this.onPressed,
    this.border,
    this.isLoading = false,
    this.trailingWidth = 35,
    this.background,
  });

  BoxDecoration _generateDecoration(BuildContext context,
      {bool isTrailing = false}) {
    return filled
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          )
        : BoxDecoration(
            color: background ??
                Theme.of(context).extension<CustomThemeFields>()!.background_2,
            borderRadius: isTrailing
                ? BorderRadius.horizontal(
                    left: Radius.zero,
                    right: Radius.circular(radius),
                  )
                : trailingButton != null && !isTrailing
                    ? BorderRadius.horizontal(
                        left: Radius.circular(radius),
                        right: Radius.zero,
                      )
                    : BorderRadius.circular(radius),
          );
  }

  ScaleTap _generateMainButton(BuildContext context) {
    return ScaleTap(
      onPressed: () {
        onPressed!();
      },
      onLongPress: () {},
      child: Container(
        decoration: BoxDecoration(
          border: border ??
              Border.all(
                color: background ??
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2,
              ),
          borderRadius: trailingButton != null
              ? BorderRadius.horizontal(
                  left: Radius.circular(radius),
                  right: Radius.zero,
                )
              : BorderRadius.circular(radius),
        ),
        padding: trailingButton != null
            ? const EdgeInsets.only(
                left: 1,
                top: 1,
                bottom: 1,
                right: 0.5,
              )
            : const EdgeInsets.all(1),
        child: Container(
          width: width,
          height: height,
          decoration: _generateDecoration(context),
          child: Center(
            child: isLoading
                ? const SpinKitThreeBounce(
                    color: DarkColors.font_1,
                    size: 20,
                  )
                : child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: trailingButton != null
          ? Row(
              children: [
                Expanded(child: _generateMainButton(context)),
                ScaleTap(
                  onPressed: () {
                    onPressed!();
                  },
                  onLongPress: () {},
                  child: Container(
                    width: trailingWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.zero,
                        right: Radius.circular(radius),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 0.5,
                      top: 1,
                      right: 1,
                      bottom: 1,
                    ),
                    child: Container(
                      width: width,
                      height: height,
                      decoration: _generateDecoration(
                        context,
                        isTrailing: true,
                      ),
                      child: Center(
                        child: trailingButton,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _generateMainButton(context),
    );
  }
}
