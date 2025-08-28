import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/filter.dart';
import '../../../../widgets/auctions_list_sort_popup.dart';
import '../../../../widgets/chips/filter_genre_chip.dart';
import '../../../../widgets/chips/filter_simple_chip.dart';
import '../../../../widgets/simple_app_bar.dart';

class FilteredAuctionsAppBar extends StatefulWidget {
  final Widget child;
  final bool? loadingData;

  final Function? onScrollBottom;
  final Function? onFilterUpdate;
  final Function? onSort;

  const FilteredAuctionsAppBar({
    super.key,
    required this.child,
    this.onScrollBottom,
    this.onFilterUpdate,
    this.onSort,
    this.loadingData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilteredAuctionsAppBar createState() => _FilteredAuctionsAppBar();
}

class _FilteredAuctionsAppBar extends State<FilteredAuctionsAppBar> {
  final filterController = Get.find<FilterController>();

  Widget _renderTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: FittedBox(
            child: Obx(
              () => Row(
                children: [
                  Text(
                    'home.filter.filtered_auctions',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ).tr(),
                  Container(
                    width: 4,
                  ),
                  Text(
                    filterController.filteredAuctionsCountLoading.value == true
                        ? ''
                        : '(${filterController.filteredAuctionsCount.value})',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ),
                  filterController.filteredAuctionsCountLoading.value == true
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(end: 16),
          child: Row(
            children: [
              AuctionsListSortPopup(
                handleSort: widget.onSort,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> renderCategoriesChips() {
    if (filterController.selectedCategories.isEmpty &&
        filterController.selectedSubCategories.isEmpty) {
      return [Container()];
    }

    var currentLanguage = context.locale.toString();

    return [
      for (var category in filterController.selectedCategories)
        Container(
          margin: const EdgeInsetsDirectional.only(end: 8),
          child: FilterCategoryChip(
            category: category,
            onRemove: () {
              filterController.unselectCategory(category);
              widget.onFilterUpdate?.call();
            },
          ),
        ),
      for (var subCategory in filterController.selectedSubCategories)
        Container(
          margin: const EdgeInsetsDirectional.only(end: 8),
          child: FilterSimpleChip(
            title: subCategory.name[currentLanguage] ?? '',
            onRemove: () {
              filterController.unselectSubCategory(subCategory);
              widget.onFilterUpdate?.call();
            },
          ),
        )
    ];
  }

  List<Widget> _renderLocationChips() {
    return filterController.selectedLocations.map((location) {
      return Container(
        margin: const EdgeInsetsDirectional.only(end: 8),
        child: FilterSimpleChip(
          title: location.name,
          onRemove: () {
            filterController.toggleLocationSelection(location);
            widget.onFilterUpdate?.call();
          },
        ),
      );
    }).toList();
  }

  List<Widget> _renderPriceChips() {
    return [
      ...(filterController.minPrice.value == ''
          ? []
          : [
              Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                child: FilterSimpleChip(
                  title: tr('home.filter.min_price_value', namedArgs: {
                    'no': filterController.minPrice.value.toString()
                  }),
                  onRemove: () {
                    filterController.resetMinPrice();
                    widget.onFilterUpdate?.call();
                  },
                ),
              )
            ]),
      ...(filterController.maxPrice.value == ''
          ? []
          : [
              Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                child: FilterSimpleChip(
                  title: tr('home.filter.max_price_value', namedArgs: {
                    'no': filterController.maxPrice.value.toString()
                  }),
                  onRemove: () {
                    filterController.resetMaxPrice();
                    widget.onFilterUpdate?.call();
                  },
                ),
              ),
            ]),
    ];
  }

  List<Widget> _renderWithoutMyAuctionsChip() {
    return [
      Container(
        margin: const EdgeInsetsDirectional.only(end: 8),
        child: FilterSimpleChip(
          title: tr('home.filter.without_my_auctions'),
          onRemove: () {
            filterController.toggleIncludeMyAuctions();
            widget.onFilterUpdate?.call();
          },
        ),
      ),
    ];
  }

  Widget _renderFilterBar(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: Get.width,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...renderCategoriesChips(),
              ..._renderLocationChips(),
              ..._renderPriceChips(),
              ...(filterController.includeMyAuctions.value == true
                  ? []
                  : _renderWithoutMyAuctionsChip()),
              // _renderActiveOnlyChip()
            ],
          ),
        ),
      ),
    );
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            var nextPageTrigger = 0.8 * scrollInfo.metrics.maxScrollExtent;

            if (scrollInfo.metrics.pixels > nextPageTrigger) {
              // here you update your data or load your data from network
              if (widget.onScrollBottom != null) {
                widget.onScrollBottom!();
              }
            }
            return true;
          },
          child: Scaffold(
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            resizeToAvoidBottomInset: true,
            appBar: SimpleAppBar(
              onBack: () {
                goBack();
              },
              bottomHeight: 64,
              isLoading: widget.loadingData ?? false,
              withClearSearchKey: true,
              withSearch: false,
              elevation: 0,
              title: _renderTitle(context),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _renderFilterBar(context),
                  ),
                ]),
              ),
            ),
            body: widget.child,
          ),
        ),
      ),
    );
  }
}
