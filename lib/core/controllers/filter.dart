import 'dart:async';
import 'package:mazadi/core/models/category.dart';
import 'package:mazadi/core/models/filter.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/auction.dart';
import '../models/location.dart';
import '../repositories/auction.dart';
import 'account.dart';

var uuid = const Uuid();

class FilterController extends GetxController {
  final auctionRepository = Get.find<AuctionRepository>();
  final accountController = Get.find<AccountController>();

  RxList<Location> allLocations = RxList<Location>();

  RxList<Category> selectedCategories = RxList<Category>();
  RxList<Category> selectedSubCategories = RxList<Category>();
  RxList<Location> selectedLocations = RxList<Location>();
  RxString minPrice = ''.obs;
  RxString maxPrice = ''.obs;
  RxBool includeMyAuctions = true.obs;

  RxBool filteredAuctionsCountLoading = false.obs;
  RxInt filteredAuctionsCount = 0.obs;

  late StreamSubscription<List<Category>> _categoriesSubscription;
  late StreamSubscription<List<Category>> _subCategoriesSubscription;
  late StreamSubscription<List<Location>> _locationsSubscription;
  late StreamSubscription<bool> _includeMyAuctionsSubscription;
  late StreamSubscription<String> _minPriceSubscription;
  late StreamSubscription<String> _maxPriceSubscription;

  @override
  void onInit() {
    super.onInit();

    _categoriesSubscription = selectedCategories.listen((_) {
      EasyDebounce.debounce(
        'load-auctions-count',
        const Duration(milliseconds: 200),
        () => loadFilteredAuctionsCount(),
      );
    });

    _subCategoriesSubscription = selectedSubCategories.listen((_) {
      EasyDebounce.debounce(
        'load-auctions-count',
        const Duration(milliseconds: 200),
        () => loadFilteredAuctionsCount(),
      );
    });

    _locationsSubscription = selectedLocations.listen((_) {
      EasyDebounce.debounce(
        'load-auctions-count',
        const Duration(milliseconds: 200),
        () => loadFilteredAuctionsCount(),
      );
    });

    _includeMyAuctionsSubscription = includeMyAuctions.listen((_) {
      EasyDebounce.debounce(
        'load-auctions-count',
        const Duration(milliseconds: 200),
        () => loadFilteredAuctionsCount(),
      );
    });

    _minPriceSubscription = minPrice.listen((_) {
      EasyDebounce.debounce(
        'load-auctions-count',
        const Duration(milliseconds: 500),
        () => loadFilteredAuctionsCount(),
      );
    });

    _maxPriceSubscription = maxPrice.listen((_) {
      EasyDebounce.debounce(
        'load-auctions-count',
        const Duration(milliseconds: 500),
        () => loadFilteredAuctionsCount(),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    resetFilter();

    _categoriesSubscription.cancel();
    _subCategoriesSubscription.cancel();
    _locationsSubscription.cancel();
    _includeMyAuctionsSubscription.cancel();
    _minPriceSubscription.cancel();
    _maxPriceSubscription.cancel();
  }

  Future<void> loadRequiredData() async {
    var auctionLocations = await auctionRepository.loadAuctionLocations();
    auctionLocations.sort((a, b) => a.name.compareTo(b.name));

    allLocations.clear();
    allLocations.addAll(auctionLocations);
  }

  bool filterActive() {
    return selectedCategories.isNotEmpty ||
        selectedSubCategories.isNotEmpty ||
        selectedLocations.isNotEmpty ||
        includeMyAuctions.value == false ||
        minPrice.value != '' ||
        maxPrice.value != '';
  }

  void resetFilter() {
    if (!filterActive()) {
      return;
    }

    selectedCategories.clear();
    selectedSubCategories.clear();
    selectedLocations.clear();
    includeMyAuctions.value = true;

    minPrice.value = '';
    maxPrice.value = '';
  }

  void unselectSubCategory(Category category) {
    selectedSubCategories.removeWhere((cat) => cat.id == category.id);
  }

  void toggleSubCategorySelection(Category mainCategory, Category category) {
    var mainCategoryIsSelected = selectedCategories.any((cat) {
      return cat.id == mainCategory.id;
    });

    if (mainCategoryIsSelected) {
      // unselect main category and select all the subcategories, extept the one given as parameter
      selectedCategories.removeWhere((cat) => cat.id == mainCategory.id);

      for (var subCategory in mainCategory.subcategories) {
        if (subCategory.value.id != category.id) {
          selectedSubCategories.add(subCategory.value);
        }
      }
      return;
    }

    var subCategoryIsSelected = selectedSubCategories.any((cat) {
      return cat.id == category.id;
    });

    if (!subCategoryIsSelected) {
      // check if the selected subcategories, together with the one given as param are all the
      // subcategories of the main category. If so, select the main category
      var allSubCategoriesSelected = mainCategory.subcategories.every((sub) {
        return selectedSubCategories.any((selectedSub) {
              return selectedSub.id == sub.value.id;
            }) ||
            sub.value.id == category.id;
      });

      if (allSubCategoriesSelected) {
        selectCategory(mainCategory);
        return;
      }

      selectedSubCategories.add(category);
      return;
    }

    selectedSubCategories.removeWhere((cat) => cat.id == category.id);
  }

  bool categoryIsSelected(Category category) =>
      selectedCategories.any((cat) => cat.id == category.id);

  void selectCategory(Category category) {
    var alreadySelected = selectedCategories.any((cat) {
      return cat.id == category.id;
    });

    if (!alreadySelected) {
      selectedCategories.add(category);
    }

    for (var subCategory in category.subcategories) {
      selectedSubCategories
          .removeWhere((sub) => sub.id == subCategory.value.id);
    }
  }

  void unselectCategory(Category category) {
    selectedCategories.removeWhere((cat) => cat.id == category.id);

    for (var subCategory in category.subcategories) {
      selectedSubCategories
          .removeWhere((sub) => sub.id == subCategory.value.id);
    }
  }

  void toggleLocationSelection(Location location) {
    var isSelected =
        selectedLocations.indexWhere((auth) => auth.name == location.name);

    if (isSelected != -1) {
      selectedLocations.removeWhere((element) => element.name == location.name);
    } else {
      selectedLocations.add(location);
    }
  }

  void resetMinPrice() {
    minPrice.value = '';
    minPrice.refresh();
  }

  void resetMaxPrice() {
    maxPrice.value = '';
    maxPrice.refresh();
  }

  void clearLocations() {
    if (selectedLocations.isEmpty) {
      return;
    }
    selectedLocations.clear();
  }

  void clearCategories() {
    selectedCategories.clear();
    selectedSubCategories.clear();
  }

  void toggleIncludeMyAuctions() {
    includeMyAuctions.value = !includeMyAuctions.value;
    includeMyAuctions.refresh();
  }

  void applySavedFilter(String filterId) {
    var filter = accountController.account.value.filters
        ?.firstWhere((element) => element.id == filterId);

    if (filter == null) {
      return;
    }

    selectedCategories.clear();
    if (filter.data.selectedCategories != null) {
      selectedCategories.addAll(filter.data.selectedCategories!);
    }

    selectedSubCategories.clear();
    if (filter.data.selectedSubCategories != null) {
      selectedSubCategories.addAll(filter.data.selectedSubCategories!);
    }

    selectedLocations.clear();
    selectedLocations.addAll(filter.data.selectedLocations);

    if (filter.data.includeMyAuctions == false) {
      includeMyAuctions.value = false;
    } else {
      includeMyAuctions.value = true;
    }

    minPrice.value = filter.data.minPrice ?? '';
    maxPrice.value = filter.data.maxPrice ?? '';
    minPrice.refresh();
    maxPrice.refresh();
  }

  Future<int> loadFilteredAuctionsCount() async {
    var categoriesIds = selectedCategories.map((e) => e.id).toList();
    var subCategoriesIds = selectedSubCategories.map((e) => e.id).toList();
    var selectedLocationsIds = selectedLocations.map((e) => e.id).toList();

    filteredAuctionsCountLoading.value = true;
    var count = await auctionRepository.countFilter(
      categoriesIds,
      subCategoriesIds,
      selectedLocationsIds,
      true,
      includeMyAuctions.value,
      minPrice.value == '' ? null : int.parse(minPrice.value),
      maxPrice.value == '' ? null : int.parse(maxPrice.value),
    );
    filteredAuctionsCountLoading.value = false;

    filteredAuctionsCount.value = count;
    return count;
  }

  Future<List<Auction>> loadFilteredAuctions(
    int page,
    int pageSize, [
    AuctionsSortBy? sortBy = AuctionsSortBy.oldest,
  ]) async {
    var categoriesIds = selectedCategories.map((e) => e.id).toList();
    var subCategoriesIds = selectedSubCategories.map((e) => e.id).toList();
    var selectedLocationsIds = selectedLocations.map((e) => e.id).toList();

    return await auctionRepository.loadFilteredAuctions(
      categoriesIds,
      subCategoriesIds,
      selectedLocationsIds,
      true,
      page,
      pageSize,
      '',
      sortBy,
      includeMyAuctions.value,
      minPrice.value == '' ? null : int.parse(minPrice.value),
      maxPrice.value == '' ? null : int.parse(maxPrice.value),
    );
  }

  Future<bool> saveCurrentFilter(String name) async {
    var filterData = FilterItemData(
      selectedCategories: [...selectedCategories],
      selectedSubCategories: [...selectedSubCategories],
      selectedLocations: [...selectedLocations],
      includeMyAuctions: includeMyAuctions.value,
      minPrice: minPrice.value,
      maxPrice: maxPrice.value,
    );

    var filterToSave = FilterItem(
      id: uuid.v4(),
      data: filterData,
      name: name,
      type: 'generic',
    );

    return await accountController.saveFilterForAccount(filterToSave);
  }
}
