import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:get/get.dart';

import '../../../../../core/controllers/categories.dart';
import '../../../../../core/controllers/map_auctions.dart';
import '../../../../../core/navigator.dart';
import '../../../../../theme/extensions/base.dart';
import '../../../../../widgets/common/simple_button.dart';
import '../index.dart';
import '../widgets/category_select_dropdown.dart';

class SelectCategoryToDisplayOnMapDialog extends StatelessWidget {
  final categoriesController = Get.find<CategoriesController>();
  final mapAuctionsController = Get.find<MapAuctionsController>();
  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    var apiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'map_auctions.select_category',
            style: Theme.of(context).extension<CustomThemeFields>()!.title,
          ).tr(),
          SizedBox(height: 16),
          MapAuctionsCategorySelectDropdown(
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_3,
          ),
          apiKey == null || apiKey.isEmpty
              ? Container(
                  margin: EdgeInsets.only(top: 8),
                  width: Get.width,
                  child: Text(
                    'GOOGLE_MAPS_API_KEY not provided in the .env file. Location system might not work properly.',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smallest,
                  ),
                )
              : Container(),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  Navigator.pop(context);
                },
                height: 42,
                child: Text(
                  'generic.cancel',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                onPressed: () {
                  Navigator.pop(context);
                  if (mapAuctionsController.categoryToDisplayOnMap.value ==
                      '') {
                    mapAuctionsController.setCategoryToDisplayOnMap('all');
                  }

                  navigatorService.push(const MapAuctionsScreen());
                },
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'map_auctions.show_on_map',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(color: DarkColors.font_1),
                    ).tr(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
