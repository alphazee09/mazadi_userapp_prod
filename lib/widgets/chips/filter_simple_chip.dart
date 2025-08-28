import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';

class FilterSimpleChip extends StatelessWidget {
  final String title;
  final Function onRemove;
  final Function? onTap;
  final Color? background;

  final bool? removeInProgress;

  const FilterSimpleChip({
    super.key,
    required this.title,
    required this.onRemove,
    this.background,
    this.onTap,
    this.removeInProgress = false,
  });

  Widget _renderActualChip(BuildContext context) {
    return Chip(
      elevation: 0,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: background ??
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      label: Text(
        title,
        style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
      ),
      onDeleted: () {},
      deleteIcon: GestureDetector(
        onTap: () {
          if (removeInProgress == true) {
            return;
          }
          onRemove();
        },
        child: SizedBox(
          height: 16,
          width: 16,
          child: removeInProgress == true
              ? SizedBox(
                  height: 12,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                  ),
                )
              : SvgPicture.asset(
                  'assets/icons/svg/close.svg',
                  semanticsLabel: 'Close',
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return onTap != null
        ? ScaleTap(
            onPressed: () {
              onTap!();
            },
            child: _renderActualChip(context),
          )
        : _renderActualChip(context);
  }
}
