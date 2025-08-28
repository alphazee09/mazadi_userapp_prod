import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

class PopupSelectedItemBullet extends StatelessWidget {
  const PopupSelectedItemBullet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.action,
        shape: BoxShape.circle,
      ),
    );
  }
}
