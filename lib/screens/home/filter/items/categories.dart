import 'package:mazadi/core/models/category.dart';
import 'package:mazadi/theme/colors.dart';

import 'package:diacritic/diacritic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/categories.dart';
import '../../../../core/controllers/filter.dart';
import '../../../../core/controllers/flash.dart';
import '../../../../widgets/common/action_button.dart';
import '../../../../widgets/common/category_icon.dart';
import '../../../../widgets/common/simple_button.dart';
import '../../../../widgets/simple_app_bar.dart';

class FilterCategories extends StatefulWidget {
  final RxBool? dataLoading;

  const FilterCategories({
    super.key,
    this.dataLoading,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterCategories createState() => _FilterCategories();
}

class _FilterCategories extends State<FilterCategories> {
  final filterController = Get.find<FilterController>();
  final flashController = Get.find<FlashController>();
  final categoriesController = Get.find<CategoriesController>();

  List<Rx<Category>> _searchedCategories = [];
  final Rx<bool> _pointerDownInner = false.obs;

  @override
  void initState() {
    _searchedCategories = categoriesController.categories;
    super.initState();
  }

  void goBack(bool applySubFilter) {
    if (applySubFilter) {
      Navigator.of(context).pop();
      return;
    }

    filterController.clearCategories();
    Navigator.of(context).pop();
  }

  void _handleCategoriesSearch(String keyword) {
    if (!mounted) {
      return;
    }

    List<Rx<Category>> newCategories = [];
    newCategories.addAll(categoriesController.categories);

    if (keyword == '') {
      setState(() {
        _searchedCategories = newCategories;
      });
      return;
    }

    var currentLanguage = context.locale.languageCode;
    List<Rx<Category>> searchedCategories = [];
    for (var category in newCategories) {
      var categoryContainsKeyword =
          removeDiacritics(category.value.name[currentLanguage] ?? '')
              .toLowerCase()
              .contains(removeDiacritics(keyword).toLowerCase());

      if (categoryContainsKeyword) {
        searchedCategories.add(category);
        continue;
      }

      // Search subcategories if main category does not match
      var searchedSubCategories = category.value.subcategories
          .where((subCategory) =>
              removeDiacritics(subCategory.value.name[currentLanguage] ?? '')
                  .toLowerCase()
                  .contains(removeDiacritics(keyword).toLowerCase()))
          .toList();

      if (searchedSubCategories.isNotEmpty) {
        var categoryClone = Category.fromJSON(category.value.toJSON());
        categoryClone.subcategories.clear();
        categoryClone.subcategories.addAll(searchedSubCategories);
        searchedCategories.add(categoryClone.obs);
        continue;
      }
    }

    setState(() {
      _searchedCategories = searchedCategories;
    });
  }

  void toggleCategorySelection(Category category) {
    if (filterController.categoryIsSelected(category)) {
      filterController.unselectCategory(category);
      return;
    }

    filterController.selectCategory(category);
  }

  void toggleSubCategorySelection(Category mainCategory, Category category) {
    filterController.toggleSubCategorySelection(mainCategory, category);
  }

  bool atLeastOnSubCategoryIsSelected(Category category) {
    return category.subcategories.any((subCategory) =>
        filterController.selectedSubCategories
            .indexWhere((auth) => auth.id == subCategory.value.id) !=
        -1);
  }

  bool allSubCategoriesAreSelected(Category category) {
    return category.subcategories.every((subCategory) =>
        filterController.selectedSubCategories
            .indexWhere((auth) => auth.id == subCategory.value.id) !=
        -1);
  }

  bool onlyAPartOfSubCategoriesAreSelected(Category category) {
    return category.subcategories.any((subCategory) =>
            filterController.selectedSubCategories
                .indexWhere((auth) => auth.id == subCategory.value.id) !=
            -1) &&
        !allSubCategoriesAreSelected(category);
  }

  Widget _renderSubCategories(Category category) {
    return Column(
      children: [
        for (var subCategory in category.subcategories)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                toggleSubCategorySelection(category, subCategory.value);
              },
              child: Container(
                padding: const EdgeInsetsDirectional.only(
                  start: 66,
                  end: 56,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              subCategory
                                  .value.name[context.locale.toString()]!,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .subtitle,
                            ),
                          )
                        ],
                      ),
                    ),
                    Obx(
                      () => Checkbox(
                        tristate: true,
                        side: BorderSide(
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                        ),
                        checkColor: DarkColors.font_1,
                        activeColor: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action,
                        value: filterController.selectedCategories.indexWhere(
                                    (cat) => cat.id == category.id) !=
                                -1 ||
                            filterController.selectedSubCategories.indexWhere(
                                    (auth) =>
                                        auth.id == subCategory.value.id) !=
                                -1,
                        onChanged: (bool? value) {
                          toggleSubCategorySelection(
                            category,
                            subCategory.value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _renderCategory(Category category) {
    var currentLanguage = context.locale.languageCode;

    return Column(
      children: [
        Obx(
          () => ExpansionTile(
            iconColor: Theme.of(context).extension<CustomThemeFields>()!.action,
            tilePadding: EdgeInsetsDirectional.only(end: 16),
            title: Container(
              padding: const EdgeInsetsDirectional.only(
                  start: 16, top: 4, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        CategoryIcon(
                          categoryId: category.id,
                          size: 40,
                          currentLanguage: currentLanguage,
                        ),
                        Container(
                          width: 8,
                        ),
                        Flexible(
                          child: Text(
                            category.name[currentLanguage] ?? '',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .subtitle
                                .copyWith(fontWeight: FontWeight.w300),
                          ),
                        )
                      ],
                    ),
                  ),
                  Obx(
                    () => Checkbox(
                      tristate: onlyAPartOfSubCategoriesAreSelected(category)
                          ? true
                          : false,
                      side: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                      ),
                      checkColor: DarkColors.font_1,
                      activeColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .action,
                      value: onlyAPartOfSubCategoriesAreSelected(category)
                          ? null
                          : filterController.selectedCategories.indexWhere(
                                  (auth) => auth.id == category.id) !=
                              -1,
                      onChanged: (bool? value) {
                        toggleCategorySelection(category);
                      },
                    ),
                  ),
                ],
              ),
            ),
            expandedAlignment: Alignment.topLeft,
            children: [
              _renderSubCategories(category),
              Container(
                height: 16,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderBottomNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Flexible(
              child: Obx(
                () => ActionButton(
                  onPressed: () {
                    if (filterController.selectedCategories.isNotEmpty ||
                        filterController.selectedSubCategories.isNotEmpty) {
                      goBack(true);
                    }
                  },
                  background: filterController.selectedCategories.isNotEmpty ||
                          filterController.selectedSubCategories.isNotEmpty
                      ? Theme.of(context).extension<CustomThemeFields>()!.action
                      : Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .separator,
                  height: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'home.filter.apply_sub_filter',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .subtitle
                            .copyWith(
                                color: filterController
                                            .selectedCategories.isNotEmpty ||
                                        filterController
                                            .selectedSubCategories.isNotEmpty
                                    ? DarkColors.font_1
                                    : Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .fontColor_1),
                      ).tr(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  build(BuildContext context) {
    return SafeArea(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          if (_pointerDownInner.value) {
            _pointerDownInner.value = false;
            return;
          }

          _pointerDownInner.value = false;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          resizeToAvoidBottomInset: true,
          appBar: SimpleAppBar(
              onBack: () => goBack(false),
              withClearSearchKey: true,
              withSearch: true,
              elevation: 0,
              handleSearchInputTapDown: () {
                _pointerDownInner.value = true;
              },
              handleSearch: _handleCategoriesSearch,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'home.filter.categories',
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .title,
                        ).tr(),
                        Container(
                          width: 8,
                        ),
                        Obx(
                          () => Text(
                            'home.filter.selected_items',
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smallest,
                          ).tr(namedArgs: {
                            'no': filterController.selectedCategories.length
                                .toString()
                          }),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    child: Obx(
                      () => SimpleButton(
                        filled: true,
                        height: 32,
                        borderColor: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .separator,
                        background:
                            filterController.selectedCategories.isNotEmpty ||
                                    filterController
                                        .selectedSubCategories.isNotEmpty
                                ? Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .background_1
                                : Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .separator,
                        width: 80,
                        child: Text('generic.clear',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .smaller)
                            .tr(),
                        onPressed: () {
                          filterController.clearCategories();
                        },
                      ),
                    ),
                  ),
                ],
              )),
          body: widget.dataLoading?.value == true
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_1,
                    width: Get.width,
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var category in _searchedCategories)
                            _renderCategory(category.value),
                          _searchedCategories.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    'home.filter.no_categories_for_criteria',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .subtitle,
                                  ).tr(),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                ),
          bottomNavigationBar: _renderBottomNavbar(),
        ),
      ),
    );
  }
}
