import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';

class ConditionItem extends StatelessWidget {
  final String title;
  final bool selected;
  final Function onTap;
  final String icon;

  const ConditionItem({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: () {
        onTap();
      },
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .action
                  .withOpacity(0.1)
              : Theme.of(context).extension<CustomThemeFields>()!.background_2,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: selected
                ? Theme.of(context).extension<CustomThemeFields>()!.action
                : Theme.of(context).extension<CustomThemeFields>()!.separator,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: 32,
              semanticsLabel: 'Auction condition',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
            Container(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
