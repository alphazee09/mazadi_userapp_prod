import 'package:mazadi/theme/colors.dart';
import 'package:diacritic/diacritic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/filter.dart';
import '../../../../core/controllers/flash.dart';
import '../../../../core/models/location.dart';
import '../../../../widgets/common/action_button.dart';
import '../../../../widgets/common/simple_button.dart';
import '../../../../widgets/simple_app_bar.dart';

class FilterLocations extends StatefulWidget {
  final RxBool? dataLoading;

  const FilterLocations({
    super.key,
    this.dataLoading,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterLocations createState() => _FilterLocations();
}

class _FilterLocations extends State<FilterLocations> {
  final filterController = Get.find<FilterController>();
  final flashController = Get.find<FlashController>();

  List<Location> _searchedLocations = [];
  final Rx<bool> _pointerDownInner = false.obs;

  @override
  void initState() {
    _searchedLocations = filterController.allLocations;
    super.initState();
  }

  void goBack(bool applySubFilter) {
    if (applySubFilter) {
      Navigator.of(context).pop();
      return;
    }

    filterController.clearLocations();
    Navigator.of(context).pop();
  }

  void _handleLocationSearch(String keyword) {
    List<Location> newLocations = [];
    if (keyword == '') {
      newLocations.clear();
      newLocations.addAll(filterController.allLocations);
    }

    var searched = filterController.allLocations.where((lang) =>
        removeDiacritics(lang.name)
            .toLowerCase()
            .contains(removeDiacritics(keyword).toLowerCase()));

    newLocations.clear();
    newLocations.addAll(searched);
    if (mounted) {
      setState(() {
        _searchedLocations = newLocations;
      });
    }
  }

  void toggleLocationSelection(Location location) {
    var isSelected = filterController.selectedLocations
        .indexWhere((g) => g.name == location.name);

    if (isSelected != -1 || filterController.selectedLocations.length < 3) {
      filterController.toggleLocationSelection(location);
      return;
    }

    flashController.showMessageFlash(
      tr('home.filter.max_locations_error', namedArgs: {'no': '3'}),
    );
  }

  Widget _renderLocation(Location location) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: InkWell(
            onTap: () {
              toggleLocationSelection(location);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      location.name,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .subtitle
                          .copyWith(fontWeight: FontWeight.w300),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                      ),
                      Text(
                        'home.filter.auctions_count',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smallest,
                      ).tr(namedArgs: {
                        'no': location.auctionsCount.toString(),
                      }),
                      Container(
                        width: 8,
                      ),
                      Obx(
                        () => Checkbox(
                          side: BorderSide(
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                          ),
                          checkColor: DarkColors.font_1,
                          activeColor: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .action,
                          value: filterController.selectedLocations.indexWhere(
                                  (auth) => auth.name == location.name) !=
                              -1,
                          onChanged: (bool? value) {
                            toggleLocationSelection(location);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
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
                    if (filterController.selectedLocations.isNotEmpty) {
                      goBack(true);
                    }
                  },
                  background: filterController.selectedLocations.isNotEmpty
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
                              color:
                                  filterController.selectedLocations.isNotEmpty
                                      ? DarkColors.font_1
                                      : Theme.of(context)
                                          .extension<CustomThemeFields>()!
                                          .fontColor_1,
                            ),
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
              handleSearch: _handleLocationSearch,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'home.filter.locations',
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
                            'no': filterController.selectedLocations.length
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
                            filterController.selectedLocations.isNotEmpty
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
                          filterController.clearLocations();
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
                          for (var genre in _searchedLocations)
                            _renderLocation(genre),
                          _searchedLocations.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    'home.filter.no_locations_for_criteria',
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
