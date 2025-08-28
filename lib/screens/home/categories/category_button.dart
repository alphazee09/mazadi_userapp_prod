import 'package:animations/animations.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../core/controllers/categories.dart';
import '../../../core/controllers/filter.dart';
import '../../../core/models/category.dart';
import '../../../widgets/common/category_icon.dart';
import '../auctions/filtered-auctions/index.dart';

class CategoryButton extends StatelessWidget {
  final filterController = Get.find<FilterController>();
  final categoriesController = Get.find<CategoriesController>();

  final Category category;
  final bool isSubCategory;
  final double? width;
  final double? height;

  CategoryButton({
    super.key,
    required this.category,
    this.width,
    this.height,
    this.isSubCategory = false,
  });

  Widget _renderButton(BuildContext context, Function onTap) {
    var currentLanguage = context.locale.toString();

    return ScaleTap(
      onPressed: () {
        onTap();
      },
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 120,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color:
                  Theme.of(context).extension<CustomThemeFields>()!.separator,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 8,
              ),
              SizedBox(
                height: 38,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Text(
                      category.name[currentLanguage] ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                elevation: 0,
                child: CategoryIcon(
                  categoryId: category.id,
                  size: 48,
                  currentLanguage: currentLanguage,
                ),
              ),
              Material(
                color: Colors.transparent,
                elevation: 0,
                child: Text(
                  category.auctionsCount == 1
                      ? 'generic.auction_count_singular'
                      : 'generic.auction_count_plural',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(fontSize: 14, height: 1.2),
                ).tr(namedArgs: {'no': category.auctionsCount.toString()}),
              ),
              Container(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      useRootNavigator: true,
      closedElevation: 0,
      openColor: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      closedColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      closedBuilder: (_, VoidCallback openContainer) => _renderButton(
        context,
        openContainer,
      ),
      openBuilder: (_, close) {
        filterController.resetFilter();

        if (isSubCategory) {
          var mainCategory = categoriesController.categories
              .firstWhereOrNull((cat) => cat.value.id == category.id);

          if (mainCategory != null) {
            filterController.selectCategory(mainCategory.value);
          } else {
            var parentCategory = categoriesController.categories
                .firstWhereOrNull(
                    (element) => element.value.id == category.parentCategoryId);

            filterController.toggleSubCategorySelection(
              parentCategory!.value,
              category,
            );
          }
        } else {
          filterController.selectCategory(category);
        }

        return FilteredAuctionsScreen();
      },
    );
  }
}
