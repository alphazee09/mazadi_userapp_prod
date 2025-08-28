import 'package:animations/animations.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/categories.dart';
import '../../../../core/controllers/filter.dart';
import '../../../../core/models/category.dart';
import '../../../../core/navigator.dart';
import '../../../../widgets/common/category_icon.dart';
import '../../../../widgets/common/circle_number.dart';
import '../../auctions/filtered-auctions/index.dart';
import 'index.dart';

class CategoriesListItem extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final filterController = Get.find<FilterController>();
  final categoriesController = Get.find<CategoriesController>();

  final Category category;

  CategoriesListItem({
    super.key,
    required this.category,
  });

  void handlePrimaryCategoryTap(BuildContext context) {
    var allSubCategories = Category(
      id: category.id,
      name: {context.locale.toString(): tr('home.categories.all')},
      subcategories: [],
      auctionsCount: category.auctionsCount,
    );

    navigatorService.push(
      CategoriesScreen(
        categories: [allSubCategories.obs, ...category.subcategories],
        parentCategory: category,
      ),
      NavigationStyle.SharedAxis,
    );
  }

  Widget _renderItem(BuildContext context, Function onTap) {
    var isSubCategory = category.subcategories.isEmpty;
    var currentLanguage = context.locale.toString();

    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                children: [
                  isSubCategory && category.assetId == null
                      ? Container()
                      : CategoryIcon(
                          categoryId: category.id,
                          size: 40,
                          currentLanguage: currentLanguage,
                        ),
                  Container(
                    width: isSubCategory ? 0 : 8,
                  ),
                  Flexible(
                    child: Text(
                      category.name[currentLanguage]!,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                CircleWithNumber(
                  number: category.auctionsCount.toString(),
                ),
                IconButton(
                  onPressed: () {
                    onTap();
                  },
                  splashRadius: 24,
                  icon: SvgPicture.asset(
                    'assets/icons/svg/next.svg',
                    height: 20,
                    semanticsLabel: 'See details',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isSubCategory = category.subcategories.isEmpty;

    return Column(
      children: [
        Material(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: isSubCategory
              ? OpenContainer(
                  closedElevation: 0,
                  useRootNavigator: true,
                  openColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_1,
                  closedColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_1,
                  closedBuilder: (_, VoidCallback openContainer) =>
                      _renderItem(context, openContainer),
                  openBuilder: (_, close) {
                    filterController.resetFilter();

                    var mainCategory = categoriesController.categories
                        .firstWhereOrNull((cat) => cat.value.id == category.id);

                    if (mainCategory != null) {
                      filterController.selectCategory(mainCategory.value);
                    } else {
                      var parentCategory = categoriesController.categories
                          .firstWhereOrNull((element) =>
                              element.value.id == category.parentCategoryId);

                      filterController.toggleSubCategorySelection(
                        parentCategory!.value,
                        category,
                      );
                    }

                    return FilteredAuctionsScreen();
                  },
                )
              : _renderItem(context, () {
                  handlePrimaryCategoryTap(context);
                }),
        ),
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
