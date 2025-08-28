import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterItem extends StatelessWidget {
  final String title;
  final Function? onTap;
  final Widget? sufix;
  final Widget? chips;
  final bool? loadingData;

  const FilterItem({
    super.key,
    required this.title,
    this.onTap,
    this.sufix,
    this.chips,
    this.loadingData,
  });

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .subtitle
                            .copyWith(fontWeight: FontWeight.w300),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      loadingData == true
                          ? Container(
                              margin: const EdgeInsetsDirectional.only(end: 8),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .fontColor_1,
                                ),
                              ),
                            )
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
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                BlendMode.srcIn,
                              ),
                              semanticsLabel: 'Details',
                            ),
                          ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        chips ?? Container(),
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
