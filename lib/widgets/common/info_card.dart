import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uuid/uuid.dart';

import '../../theme/extensions/base.dart';

class InfoCard extends StatefulWidget {
  final Widget child;
  final Color background;
  final bool dismissible;
  final void Function() handleClose;

  const InfoCard({
    super.key,
    required this.child,
    required this.handleClose,
    this.dismissible = true,
    this.background = Colors.transparent,
  });

  @override
  // ignore: library_private_types_in_public_api
  _InfoCard createState() => _InfoCard();
}

class _InfoCard extends State<InfoCard> {
  var uuid = const Uuid();

  Widget _renderInfo() {
    return Container(
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: Theme.of(context).extension<CustomThemeFields>()!.separator,
        ),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 24,
              top: 16,
              end: 60,
              bottom: 16,
            ),
            child: widget.child,
          ),
          widget.dismissible
              ? Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.only(top: 6, right: 6),
                    child: IconButton(
                      splashRadius: 24,
                      iconSize: 14,
                      onPressed: () {
                        widget.handleClose();
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/svg/close.svg',
                        semanticsLabel: 'Close',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var key = Key(uuid.v4());

    return widget.dismissible
        ? Dismissible(
            key: key,
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              widget.handleClose();
            },
            dismissThresholds: const {DismissDirection.endToStart: 0.4},
            background: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'generic.cancel',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action,
                      ),
                ).tr(),
              ],
            ),
            child: _renderInfo(),
          )
        : _renderInfo();
  }
}
