import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/extensions/base.dart';

class LoveButton extends StatefulWidget {
  final Duration duration;
  final double containerPaddingLeft;

  final double paddingTop;
  final double paddingBottom;
  final double iconSize;

  final Color? iconSelectedColor;
  final Color? iconUnselectedColor;
  final Function? onTap;
  final Function? onLongTap;

  final bool? withLikesCount;
  final int? likesCount;

  final bool liked;
  final bool small;

  const LoveButton({
    super.key,
    this.duration = const Duration(milliseconds: 150),
    this.containerPaddingLeft = 0,
    this.paddingTop = 2,
    this.iconSize = 20,
    this.paddingBottom = 0,
    this.iconSelectedColor,
    this.iconUnselectedColor,
    this.onTap,
    this.liked = false,
    this.small = false,
    this.withLikesCount = false,
    this.likesCount = 0,
    this.onLongTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LoveButton createState() => _LoveButton();
}

class _LoveButton extends State<LoveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    final halfDuration = widget.duration.inMilliseconds ~/ 2;
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: halfDuration));

    scale = Tween<double>(begin: 1, end: 1.3).animate(controller);
  }

  Future handleTap() async {
    if (!mounted) {
      return;
    }

    await controller.forward();
    await controller.reverse();
  }

  void setStateOnTap() {
    if (widget.onTap != null) {
      widget.onTap!(!widget.liked);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget selectedIcon() => SvgPicture.asset(
        'assets/icons/svg/heart-filled.svg',
        height: widget.iconSize,
        width: widget.iconSize,
        colorFilter: ColorFilter.mode(
          widget.iconSelectedColor ?? Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
        semanticsLabel: 'Heart filled',
      );

  Widget unselectedIcon() => SvgPicture.asset(
        'assets/icons/svg/heart.svg',
        height: widget.iconSize,
        width: widget.iconSize,
        colorFilter: ColorFilter.mode(
          widget.iconUnselectedColor ?? Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
        semanticsLabel: 'Heart',
      );

  Widget _renderLoveIcon() {
    return Padding(
      padding: EdgeInsets.only(top: widget.small ? 0 : 4),
      child: widget.liked
          ? Padding(
              padding: EdgeInsets.only(
                  top: widget.paddingTop, bottom: widget.paddingBottom),
              child: widget.liked ? selectedIcon() : unselectedIcon(),
            )
          : Padding(
              padding: EdgeInsets.only(
                  top: widget.paddingTop, bottom: widget.paddingBottom),
              child: widget.liked ? selectedIcon() : unselectedIcon(),
            ),
    );
  }

  @override
  Widget build(BuildContext cntext) => ScaleTransition(
        scale: scale,
        child: Material(
          color: Colors.transparent,
          child: widget.withLikesCount == true
              ? InkWell(
                  onTap: () {
                    handleTap();
                    setStateOnTap();
                  },
                  onLongPress: () {
                    if (widget.onLongTap != null) {
                      widget.onLongTap!();
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _renderLoveIcon(),
                        SizedBox(width: 3),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Text(
                            widget.likesCount.toString(),
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : IconButton(
                  padding: EdgeInsets.zero,
                  constraints: widget.small
                      ? const BoxConstraints(maxHeight: 38, maxWidth: 38)
                      : null,
                  splashRadius: widget.small ? 24 : 24,
                  iconSize: widget.small ? 24 : 24,
                  onPressed: () {
                    handleTap();
                    setStateOnTap();
                  },
                  icon: _renderLoveIcon(),
                ),
        ),
      );
}
