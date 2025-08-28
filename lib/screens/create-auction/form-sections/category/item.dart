import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/models/category.dart';
import '../../../../core/navigator.dart';
import '../../../../widgets/common/category_icon.dart';
import 'list.dart';

class AuctionFormCategoriesListItem extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();

  final Category category;
  final Function handleSelectSubCategory;

  AuctionFormCategoriesListItem({
    required this.category,
    required this.handleSelectSubCategory,
  });

  Widget _renderItem(BuildContext context, Function onTap) {
    var isSubCategory = category.subcategories.isEmpty;
    var currentLanguage = context.locale.toString();
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

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
                  isSubCategory
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
                IconButton(
                  onPressed: () {
                    onTap();
                  },
                  splashRadius: 24,
                  icon: SvgPicture.asset(
                    isRTL
                        ? 'assets/icons/svg/previous.svg'
                        : 'assets/icons/svg/next.svg',
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

  void handlePrimaryCategoryTap(BuildContext context) {
    navigatorService.push(
      AuctionFormCategoriesList(
        categories: category.subcategories,
        parentCategory: category,
        handleSelectSubCategory: handleSelectSubCategory,
      ),
      NavigationStyle.SharedAxis,
    );
  }

  @override
  Widget build(BuildContext context) {
    var isSubCategory = category.subcategories.isEmpty;

    return Column(
      children: [
        Material(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: _renderItem(context, () {
            if (isSubCategory) {
              handleSelectSubCategory(category.id, category.parentCategoryId);
              return;
            }

            navigatorService.push(
              AuctionFormCategoriesList(
                categories: [...category.subcategories],
                parentCategory: category,
                handleSelectSubCategory: handleSelectSubCategory,
              ),
              NavigationStyle.SharedAxis,
            );
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
