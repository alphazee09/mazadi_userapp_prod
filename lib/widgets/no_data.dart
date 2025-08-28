import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoDataMessage extends StatelessWidget {
  final String? message;
  final Widget? messageWidget;

  const NoDataMessage({
    super.key,
    this.message,
    this.messageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/categories/all.svg',
            height: 120,
            semanticsLabel: 'No search result',
          ),
          Container(
            height: 32,
          ),
          messageWidget != null
              ? messageWidget!
              : message != null
                  ? Text(
                      message!,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title,
                      textAlign: TextAlign.center,
                    )
                  : Container(),
          Container(
            height: 32,
          ),
        ],
      ),
    );
  }
}
