import 'package:mazadi/widgets/simple_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/models/category.dart';
import '../../../../widgets/common/category_icon.dart';
import 'item.dart';

// ignore: must_be_immutable
class AuctionFormCategoriesList extends StatelessWidget {
  List<Rx<Category>> categories;
  Function handleSelectSubCategory;
  Category? parentCategory;

  AuctionFormCategoriesList({
    required this.categories,
    required this.handleSelectSubCategory,
    this.parentCategory,
  });

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
          onBack: () => goBack(context),
          withClearSearchKey: true,
          withSearch: false,
          elevation: 0,
          title: Row(
            children: [
              parentCategory != null
                  ? Container(
                      margin: EdgeInsetsDirectional.only(end: 8),
                      child: CategoryIcon(
                        categoryId: parentCategory?.id,
                        size: 32,
                        currentLanguage: currentLanguage,
                      ),
                    )
                  : Container(),
              Flexible(
                child: Text(
                  parentCategory != null
                      ? parentCategory!.name[currentLanguage]!
                      : tr('home.categories.categories'),
                  textAlign: TextAlign.start,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var category in categories)
                  AuctionFormCategoriesListItem(
                    category: category.value,
                    handleSelectSubCategory: handleSelectSubCategory,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
