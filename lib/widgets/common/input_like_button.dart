import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class InputLikeButton extends StatelessWidget {
  final String placeholder;
  final Function? onTap;

  final EdgeInsetsGeometry? padding;
  final Widget? prefixIcon;
  final Widget? sufixIcon;
  final bool withPrefixIcon;

  final double? height;
  final Widget? child;
  final Color? backgroundColor;

  InputLikeButton({
    super.key,
    String? placeholder,
    this.onTap,
    this.padding,
    this.prefixIcon,
    this.sufixIcon,
    this.height = 45,
    this.child,
    this.backgroundColor,
    this.withPrefixIcon = true,
  }) : placeholder = placeholder ?? tr('generic.search');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ??
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          width: Get.width,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            // color: Theme.of(context).extension<CustomThemeFields>()!.background_2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .separator
                  .withOpacity(0.6),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    withPrefixIcon
                        ? prefixIcon ??
                            SvgPicture.asset(
                              'assets/icons/svg/search.svg',
                              semanticsLabel: 'Search',
                              colorFilter: ColorFilter.mode(
                                Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                BlendMode.srcIn,
                              ),
                              height: 20,
                            )
                        : Container(),
                    withPrefixIcon
                        ? Container(
                            width: 16,
                          )
                        : Container(),
                    Flexible(
                      child: child != null
                          ? child!
                          : Text(
                              placeholder,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                    ),
                  ],
                ),
              ),
              sufixIcon ?? Container(),
            ],
          ),
        ),
      ),
    );
  }
}
