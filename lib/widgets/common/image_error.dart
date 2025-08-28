import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

class ImageErrorWidget extends StatelessWidget {
  const ImageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          border: Border.all(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'generic.image_not_found',
            style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            textAlign: TextAlign.center,
          ).tr(),
          Container(
            height: 8,
          ),
          Icon(
            Icons.error,
            color:
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
          ),
        ],
      ),
    );
  }
}
