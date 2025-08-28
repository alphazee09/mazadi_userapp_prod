import 'package:mazadi/core/models/category.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../widgets/common/banner_ad.dart';
import '../../../../widgets/common/category_icon.dart';
import '../../../../widgets/common/popup_selected_item_bullet.dart';
import '../../../../widgets/simple_app_bar.dart';
import 'item.dart';

// ignore: non_constant_identifier_names
var ALPHABETICALLY = tr("home.categories.alphabetical");
// ignore: non_constant_identifier_names
var AUCTIONS_COUNT_DESC = tr("home.categories.count_desc");
// ignore: non_constant_identifier_names
var AUCTIONS_COUNT_ASC = tr("home.categories.count_asc");

// ignore: must_be_immutable
class CategoriesScreen extends StatefulWidget {
  List<Rx<Category>> categories;
  Category? parentCategory;

  CategoriesScreen({
    super.key,
    required this.categories,
    this.parentCategory,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoriesScreen createState() => _CategoriesScreen();
}

class _CategoriesScreen extends State<CategoriesScreen> {
  List<Rx<Category>> _searchedGenres = [];

  String _currentSort = ALPHABETICALLY;
  final Rx<bool> _pointerDownInner = false.obs;

  @override
  void initState() {
    super.initState();
    _searchedGenres = widget.categories;
    // sort only after the first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchedGenres = sortAlphabetically(widget.categories);
    });
  }

  List<Rx<Category>> sortAlphabetically(List<Rx<Category>> categories) {
    var currentLanguage = context.locale.toString();

    categories.sort((a, b) => a.value.name[currentLanguage]!
        .compareTo(b.value.name[currentLanguage]!));
    return categories;
  }

  List<Rx<Category>> sortAuctionsCountDesc(List<Rx<Category>> categories) {
    categories
        .sort((a, b) => b.value.auctionsCount.compareTo(a.value.auctionsCount));
    return categories;
  }

  List<Rx<Category>> sortAuctionsCountAsc(List<Rx<Category>> categories) {
    categories
        .sort((a, b) => a.value.auctionsCount.compareTo(b.value.auctionsCount));
    return categories;
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  void _handleCategoriesSearch(String keyword) {
    var currentLanguage = context.locale.toString();

    List<Rx<Category>> newCategories = [];
    if (keyword == '') {
      newCategories.clear();
      newCategories.addAll(widget.categories);
    } else {
      var searched = widget.categories.where((genre) => genre
          .value.name[currentLanguage]!
          .toLowerCase()
          .contains(keyword.toLowerCase()));

      newCategories.clear();
      newCategories.addAll(searched);
    }

    var sorted = _currentSort == ALPHABETICALLY
        ? sortAlphabetically(newCategories.toList())
        : _currentSort == AUCTIONS_COUNT_DESC
            ? sortAuctionsCountDesc(newCategories.toList())
            : sortAuctionsCountAsc(newCategories.toList());

    if (mounted) {
      setState(() {
        _searchedGenres = sorted;
      });
    }
  }

  ClipRRect _renderSortPopupMenu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(29)),
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              'assets/icons/svg/sort.svg',
              height: 28,
              semanticsLabel: 'Sort',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              onTap: () {
                if (_currentSort == ALPHABETICALLY) {
                  return;
                }
                if (mounted) {
                  setState(() {
                    _currentSort = ALPHABETICALLY;
                    _searchedGenres = sortAlphabetically(_searchedGenres);
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/alphabetic.svg',
                        height: 24,
                        semanticsLabel: 'Alphabetic',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'home.categories.alphabetical',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                  _currentSort == ALPHABETICALLY
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                if (_currentSort == AUCTIONS_COUNT_DESC) {
                  return;
                }
                if (mounted) {
                  setState(() {
                    _currentSort = AUCTIONS_COUNT_DESC;
                    _searchedGenres = sortAuctionsCountDesc(_searchedGenres);
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/sort-descending.svg',
                        height: 24,
                        semanticsLabel: 'Desc',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'home.categories.count_desc',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                  _currentSort == AUCTIONS_COUNT_DESC
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                if (_currentSort == AUCTIONS_COUNT_ASC) {
                  return;
                }
                if (mounted) {
                  setState(() {
                    _currentSort = AUCTIONS_COUNT_ASC;
                    _searchedGenres = sortAuctionsCountAsc(_searchedGenres);
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    SvgPicture.asset(
                      'assets/icons/svg/sort-ascending.svg',
                      height: 24,
                      semanticsLabel: 'Asc',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        BlendMode.srcIn,
                      ),
                    ),
                    Container(
                      width: 8,
                    ),
                    Text(
                      'home.categories.count_asc',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(),
                  ]),
                  _currentSort == AUCTIONS_COUNT_ASC
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();

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
              handleSearchInputTapDown: () {
                _pointerDownInner.value = true;
              },
              onBack: goBack,
              withClearSearchKey: true,
              withSearch: true,
              elevation: 0,
              handleSearch: _handleCategoriesSearch,
              searchPlaceholder: tr(
                  widget.parentCategory != null
                      ? 'home.categories.search_sub_categories'
                      : 'home.categories.search_categories',
                  namedArgs: {
                    'category': widget.parentCategory != null
                        ? widget
                            .parentCategory!.name[context.locale.toString()]!
                        : ''
                  }),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        widget.parentCategory != null
                            ? Container(
                                margin: EdgeInsetsDirectional.only(end: 8),
                                child: CategoryIcon(
                                  categoryId: widget.parentCategory!.id,
                                  size: 32,
                                  currentLanguage: currentLanguage,
                                ),
                              )
                            : Container(),
                        Flexible(
                          child: Text(
                            widget.parentCategory != null
                                ? widget.parentCategory!.name[currentLanguage]!
                                : tr('home.categories.categories'),
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .title,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    child: _renderSortPopupMenu(),
                  ),
                ],
              )),
          body: SingleChildScrollView(
            child: Container(
              color: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_1,
              width: Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BannerAdCard(
                    marginTop: 0,
                    marginBottom: 16,
                  ),
                  for (var category in _searchedGenres)
                    CategoriesListItem(category: category.value)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
