import 'package:mazadi/theme/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/filter.dart';
import '../../../core/controllers/main.dart';
import '../../../core/navigator.dart';
import '../../../widgets/chips/filter_genre_chip.dart';
import '../../../widgets/chips/filter_simple_chip.dart';
import '../../../widgets/common/action_button.dart';
import '../../../widgets/common/no_internet_connection.dart';
import '../../../widgets/common/simple_button.dart';
import '../../../widgets/simple_app_bar.dart';
import '../auctions/all-auctions/index.dart';
import '../auctions/filtered-auctions/index.dart';
import 'items/categories.dart';
import 'items/filter_item.dart';
import 'items/locations.dart';
import 'items/price.dart';
import 'widgets/save_filter_button.dart';
import 'widgets/saved_filters.dart';

class HomeFilterScreen extends StatefulWidget {
  const HomeFilterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeFilterScreenState createState() => _HomeFilterScreenState();
}

class _HomeFilterScreenState extends State<HomeFilterScreen> {
  final filterController = Get.find<FilterController>();
  final navigatorService = Get.find<NavigatorService>();
  final mainController = Get.find<MainController>();

  final RxBool _loadingData = false.obs;

  @override
  void initState() {
    super.initState();

    loadRequiredData();
    filterController.loadFilteredAuctionsCount();
  }

  Future<void> loadRequiredData() async {
    if (_loadingData.value) {
      return;
    }

    _loadingData.value = true;
    await filterController.loadRequiredData();
    _loadingData.value = false;
    _loadingData.refresh();
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  Widget renderCategoriesChips() {
    if (filterController.selectedCategories.isEmpty &&
        filterController.selectedSubCategories.isEmpty) {
      return Container();
    }

    var currentLanguage = context.locale.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var category in filterController.selectedCategories)
            FilterCategoryChip(
              category: category,
              onRemove: () {
                filterController.unselectCategory(category);
              },
            ),
          for (var subCategory in filterController.selectedSubCategories)
            FilterSimpleChip(
              title: subCategory.name[currentLanguage] ?? '',
              onRemove: () {
                filterController.unselectSubCategory(subCategory);
              },
            )
        ],
      ),
    );
  }

  Widget renderLocationChips() {
    if (filterController.selectedLocations.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var location in filterController.selectedLocations)
            FilterSimpleChip(
              title: location.name,
              onRemove: () {
                filterController.toggleLocationSelection(location);
              },
            )
        ],
      ),
    );
  }

  Widget _renderBody() {
    return Obx(
      () => mainController.connectivity.contains(ConnectivityResult.none)
          ? const NoInternetConnectionScreen()
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
                      Container(
                        height: 24,
                      ),
                      FilterItem(
                        title: tr('home.filter.categories'),
                        chips: renderCategoriesChips(),
                        onTap: () {
                          navigatorService.push(
                            const FilterCategories(),
                            NavigationStyle.SharedAxis,
                          );
                        },
                      ),
                      Obx(() => FilterItem(
                            title: tr('home.filter.location'),
                            chips: renderLocationChips(),
                            loadingData: _loadingData.value,
                            onTap: () {
                              navigatorService.push(
                                const FilterLocations(),
                                NavigationStyle.SharedAxis,
                              );
                            },
                          )),
                      Obx(
                        () => FilterItem(
                          title: tr('home.filter.include_my_auctions'),
                          loadingData: _loadingData.value,
                          sufix: Checkbox(
                            value: filterController.includeMyAuctions.value,
                            onChanged: (_) {
                              filterController.toggleIncludeMyAuctions();
                            },
                            side: BorderSide(
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                            ),
                            checkColor: DarkColors.font_1,
                            activeColor: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .action,
                          ),
                          onTap: () {
                            filterController.toggleIncludeMyAuctions();
                          },
                        ),
                      ),
                      PriceFilter(
                        onFilterChange: () {},
                      ),
                      Container(
                        height: 32,
                      ),
                      filterController.filterActive()
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SaveFilterButton(
                                    onSubmit: (name) async {
                                      return filterController
                                          .saveCurrentFilter(name);
                                    },
                                  )
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _renderBottomNavbar() {
    return Obx(
      () => mainController.connectivity.contains(ConnectivityResult.none)
          ? Container()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_1,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .separator,
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
                            navigatorService.push(
                              filterController.filterActive()
                                  ? const FilteredAuctionsScreen()
                                  : const AllAuctionsScreen(),
                            );
                          },
                          isLoading: filterController
                              .filteredAuctionsCountLoading.value,
                          background: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .action,
                          height: 42,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                filterController.filterActive()
                                    ? 'home.filter.apply_filter'
                                    : 'home.filter.see_all',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .title
                                    .copyWith(
                                      color: DarkColors.font_1,
                                    ),
                              ).tr(),
                              Container(
                                width: 8,
                              ),
                              Text(
                                'home.filter.auctions_count_parant',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .smaller
                                    .copyWith(
                                      color: DarkColors.font_1,
                                    ),
                              ).tr(namedArgs: {
                                'no': filterController
                                    .filteredAuctionsCount.value
                                    .toString()
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
          onBack: goBack,
          withSearch: false,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'home.filter.filter',
                  textAlign: TextAlign.start,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ).tr(),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(end: 16),
                child: Obx(
                  () => IntrinsicWidth(
                    child: SimpleButton(
                      filled: true,
                      height: 32,
                      borderColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .separator,
                      background: filterController.filterActive()
                          ? Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .background_1
                          : Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .separator,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('home.filter.clear_all',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .smaller)
                            .tr(),
                      ),
                      onPressed: () {
                        filterController.resetFilter();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomHeight: 48,
          bottom: SavedFiltersCard(
            applyFilter: (String filterId) =>
                filterController.applySavedFilter(filterId),
          ),
        ),
        body: _renderBody(),
        bottomNavigationBar: _renderBottomNavbar(),
      ),
    );
  }
}
