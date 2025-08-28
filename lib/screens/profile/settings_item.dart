import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../widgets/common/circle_number.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final Widget? icon;
  final int? count;
  final Function? onTap;
  final Widget? sufix;

  const SettingsItem({
    super.key,
    required this.title,
    this.icon,
    this.count,
    this.onTap,
    this.sufix,
  });

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return Column(
      children: [
        Material(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap!();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        icon != null
                            ? Container(
                                margin:
                                    const EdgeInsetsDirectional.only(end: 8),
                                child: icon,
                              )
                            : Container(),
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller
                                .copyWith(fontWeight: FontWeight.w300),
                          ).tr(),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      (count != null)
                          ? CircleWithNumber(number: count.toString())
                          : Container(),
                      sufix ??
                          IconButton(
                            onPressed: () {
                              if (onTap != null) {
                                onTap!();
                              }
                            },
                            splashRadius: 24,
                            icon: SvgPicture.asset(
                              isRTL
                                  ? 'assets/icons/svg/previous.svg'
                                  : 'assets/icons/svg/next.svg',
                              colorFilter: ColorFilter.mode(
                                Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                BlendMode.srcIn,
                              ),
                              semanticsLabel: 'Next',
                            ),
                          ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).extension<CustomThemeFields>()!.separator,
          height: 8,
          indent: 16,
          endIndent: 16,
          thickness: 1,
        )
      ],
    );
  }
}
