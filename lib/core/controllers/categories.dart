import 'dart:math';

import 'package:get/get.dart';

import '../models/category.dart';
import '../repositories/categories.dart';
import 'account.dart';

class CategoriesController extends GetxController {
  final categoriesRepository = Get.find<CategoriesRepository>();
  final accountController = Get.find<AccountController>();

  final RxList<Rx<Category>> categories = <Rx<Category>>[].obs;

  @override
  void onInit() async {
    super.onInit();
    categories.clear();
  }

  @override
  void onClose() {
    super.onClose();
    categories.clear();
  }

  void incrementCategoryAuctionCount(String categoryId) {
    var category = categories.firstWhereOrNull(
      (element) => element.value.id == categoryId,
    );
    if (category == null) {
      return;
    }
    category.value.auctionsCount += 1;
    category.refresh();
  }

  void decrementCategoryAuctionCount(String categoryId) {
    var category = categories.firstWhereOrNull(
      (element) => element.value.id == categoryId,
    );
    if (category == null) {
      return;
    }
    category.value.auctionsCount -= 1;
    category.refresh();
  }

  Future<void> load() async {
    var categoriesList = await categoriesRepository.loadAll();
    categories.clear();
    categories.addAll(categoriesList.map((category) => category));
  }

  List<Rx<Category>> getPersonalizedCategoriesForHome() {
    if (categories.isEmpty) {
      return [];
    }

    var account = accountController.account.value;
    if (account.preferredCategoriesIds.isEmpty) {
      return getRandomCategories(6);
    }

    if (account.preferredCategoriesIds.length > 6) {
      return getPreferredCategoriesWithCount(6);
    }

    var neededCount = 6 - account.preferredCategoriesIds.length;
    var newCategories =
        getNextCategories(neededCount, account.preferredCategoriesIds);
    return [...newCategories, ...getPreferredCategoriesWithCount()];
  }

  Category? findById(String id) {
    var category =
        categories.firstWhereOrNull((category) => category.value.id == id);

    if (category == null) {
      // search in subcategories
      return categories
          .map((category) => category.value.subcategories)
          .expand((element) => element)
          .firstWhere((subcategory) => subcategory.value.id == id)
          .value;
    }

    return category.value;
  }

  List<Rx<Category>> getRandomCategories(int n, [bool? fromAllCategories]) {
    if (fromAllCategories == true) {
      return getRandomFromList(n, categories);
    }

    var categoriesWithAuctions =
        categories.where((element) => element.value.auctionsCount > 0).toList();

    if (categoriesWithAuctions.isEmpty) {
      return getRandomFromList(n, categories);
    }

    if (categoriesWithAuctions.length == n) {
      return categoriesWithAuctions;
    }

    if (categoriesWithAuctions.length > n) {
      return getRandomFromList(n, categoriesWithAuctions);
    }

    var restOfCategories = getRandomFromList(
      n - categoriesWithAuctions.length,
      categories,
      categoriesWithAuctions,
    );

    return [...categoriesWithAuctions, ...restOfCategories];
  }

  List<Rx<Category>> getRandomFromList(
    int n,
    List<Rx<Category>> categoriesList, [
    List<Rx<Category>> except = const [],
  ]) {
    List<Rx<Category>> result = [];

    for (var i = 0; i < n; i++) {
      Random rand = Random();
      var randomCategory = categoriesList[rand.nextInt(categoriesList.length)];

      var exists = result
          .where((element) => element.value.id == randomCategory.value.id);
      var existsInExcept = except
          .where((element) => element.value.id == randomCategory.value.id);

      if (exists.isEmpty && existsInExcept.isEmpty) {
        result.add(randomCategory);
      } else {
        i -= 1;
      }
    }
    return result;
  }

  List<Rx<Category>> getPreferredCategoriesWithCount([int? limit]) {
    var preferredCategories =
        accountController.account.value.preferredCategoriesIds;
    var categoriesWithAuctionCount = categories
        .where(
          (category) => preferredCategories.any(
            (element) => element == category.value.id,
          ),
        )
        .toList();

    if (limit == null) {
      return categoriesWithAuctionCount;
    }

    categoriesWithAuctionCount.sort((a, b) {
      if (a.value.auctionsCount > b.value.auctionsCount) {
        return -1;
      }

      if (a.value.auctionsCount < b.value.auctionsCount) {
        return 1;
      }
      return 0;
    });

    return categoriesWithAuctionCount.take(limit).toList();
  }

  List<Rx<Category>> getNextCategories(int n, List<String> except) {
    if (n > (categories.length - except.length)) {
      throw Exception('given param is too big');
    }

    List<Rx<Category>> result = [];
    var foundCategoriesCount = 0;

    while (foundCategoriesCount < n) {
      var randomCategory = getRandomCategories(1, true)[0];

      var existsInExcept =
          except.any((element) => element == randomCategory.value.id);
      var existsInResult =
          result.any((element) => element.value.id == randomCategory.value.id);
      if (existsInExcept || existsInResult) {
        continue;
      }

      result.add(randomCategory);
      foundCategoriesCount += 1;
    }

    return result;
  }
}
