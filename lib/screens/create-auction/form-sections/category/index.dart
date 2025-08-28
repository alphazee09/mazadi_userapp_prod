import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/auction.dart';
import '../../../../core/controllers/categories.dart';
import '../../../../core/navigator.dart';
import '../../../../widgets/common/category_icon.dart';
import '../../../../widgets/common/input_like_button.dart';
import '../../../../widgets/common/section_heading.dart';
import 'list.dart';

class AuctionFormCategorySection extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final newAuctionController = Get.find<AuctionController>();
  final categoriesController = Get.find<CategoriesController>();

  Widget getSubCategoryName(BuildContext context, String subCategoryId) {
    var subCategory = categoriesController.categories
        .expand((element) => element.value.subcategories)
        .firstWhere((element) => element.value.id == subCategoryId);

    // ignore: unnecessary_null_comparison
    if (subCategory == null) {
      return Container();
    }

    var parentCategory = categoriesController.categories.firstWhere(
        (element) => element.value.id == subCategory.value.parentCategoryId);
    // ignore: unnecessary_null_comparison
    if (parentCategory == null) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          subCategory.value.name[context.locale.toString()]!,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ),
        Container(
          height: 8,
        ),
        Text(
          parentCategory.value.name[context.locale.toString()]!,
          style: Theme.of(context).extension<CustomThemeFields>()!.smallest,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          SectionHeading(
            title: tr('create_auction.category'),
            withMore: false,
            padding: 0,
          ),
          Obx(
            () => InputLikeButton(
              withPrefixIcon: true,
              height: newAuctionController.subCategoryId.value != '' ? 64 : 45,
              padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
              placeholder: tr('create_auction.select_category'),
              prefixIcon: CategoryIcon(
                currentLanguage: currentLanguage,
                size: newAuctionController.mainCategoryId.value == '' ? 20 : 40,
                categoryId: newAuctionController.mainCategoryId.value,
              ),
              sufixIcon: newAuctionController.subCategoryId.value != ''
                  ? IconButton(
                      splashRadius: 24,
                      iconSize: 14,
                      onPressed: () {
                        newAuctionController.subCategoryId.value = '';
                        newAuctionController.mainCategoryId.value = '';
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
                    )
                  : Container(),
              onTap: () {
                navigatorService.push(
                  AuctionFormCategoriesList(
                      categories: categoriesController.categories,
                      parentCategory: null,
                      handleSelectSubCategory: (
                        String subCategoryId,
                        String categoryId,
                      ) {
                        newAuctionController.subCategoryId.value =
                            subCategoryId;
                        newAuctionController.mainCategoryId.value = categoryId;

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }),
                  NavigationStyle.SharedAxis,
                );
              },
              child: newAuctionController.subCategoryId.value != ''
                  ? getSubCategoryName(
                      context, newAuctionController.subCategoryId.value)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
