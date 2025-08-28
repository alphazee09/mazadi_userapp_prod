import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../core/controllers/categories.dart';
import '../../../../../core/controllers/map_auctions.dart';
import '../../../../../core/models/category.dart';
import '../../../../../theme/extensions/base.dart';
import '../../../../../widgets/common/category_icon.dart';

// ignore: must_be_immutable
class MapAuctionsCategorySelectDropdown extends StatelessWidget {
  Color? backgroundColor;

  MapAuctionsCategorySelectDropdown({this.backgroundColor});

  final categoriesController = Get.find<CategoriesController>();
  final mapAuctionsController = Get.find<MapAuctionsController>();

  Widget renderIconForCategory(Category category, String currentLanguage) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: CategoryIcon(
        categoryId: category.id,
        size: 32,
        currentLanguage: currentLanguage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();
    var allCategoriesCategory = Category(
      id: 'all',
      icon: 'all',
      name: {
        currentLanguage: tr('home.categories.all'),
      },
    );

    return Obx(
      () {
        var sortedCategories = categoriesController.categories.toList()
          ..sort((a, b) => a.value.name[currentLanguage]!
              .compareTo(b.value.name[currentLanguage]!));

        // add all categories as first category
        sortedCategories.insert(0, Rx(allCategoriesCategory));

        var selectedCategory = sortedCategories.firstWhere(
          (element) =>
              element.value.id ==
              mapAuctionsController.categoryToDisplayOnMap.value,
          orElse: () => sortedCategories[0],
        );

        return DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            customButton: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: backgroundColor ??
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_1,
                border: Border.all(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator,
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          renderIconForCategory(
                            selectedCategory.value,
                            currentLanguage,
                          ),
                          Container(
                            width: 8,
                          ),
                          Flexible(
                            child: Text(
                              selectedCategory.value.name[currentLanguage]!,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SvgPicture.asset(
                          'assets/icons/svg/down.svg',
                          height: 18,
                          width: 18,
                          semanticsLabel: 'Down',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            value: selectedCategory.value.id,
            style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            onChanged: (value) {
              mapAuctionsController.setCategoryToDisplayOnMap(value ?? '');
            },
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              ...sortedCategories.map(
                (e) {
                  return DropdownMenuItem(
                    value: e.value.id,
                    child: Row(
                      children: [
                        renderIconForCategory(e.value, currentLanguage),
                        Container(
                          width: 8,
                        ),
                        Text(
                          e.value.name[currentLanguage]!,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
