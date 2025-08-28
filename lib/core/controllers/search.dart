import 'package:get/get.dart';
import '../models/search_history_item.dart';
import '../repositories/account.dart';
import '../repositories/auction.dart';
import '../repositories/search_history.dart';

class SearchController extends GetxController {
  var accountsRepository = Get.find<AccountsRepository>();
  var auctionRepository = Get.find<AuctionRepository>();
  var searchHistoryRepository = Get.find<SearchHistoryRepository>();

  RxBool searchInProgress = false.obs;
  RxList<SearchHistoryItem> userSearches = RxList<SearchHistoryItem>();

  Future<void> load() async {
    var searchItems = await searchHistoryRepository.loadForAccount();
    userSearches.clear();
    userSearches.addAll(searchItems);
  }

  Future<List<SearchHistoryItem>> loadHistorySearches([
    String keyword = '',
    int page = 0,
    int perPage = 5,
  ]) {
    return searchHistoryRepository.loadForAccount(keyword, page, perPage);
  }

  void removeUserSearch(String id) {
    userSearches.removeWhere((element) => element.id == id);
  }

  Future triggerSuggestionsBuild(String keyword) async {
    searchInProgress.value = true;

    var accountsPromise = accountsRepository.search(keyword);
    var auctionsPromise = auctionRepository.search(keyword);

    var accounts = await accountsPromise;
    var auctions = await auctionsPromise;

    searchInProgress.value = false;
    return [accounts, auctions];
  }

  Future addSearchHistoryItem(
    SearchHistoryItemType type,
    String searchKey, [
    String? data,
    String? entityId,
  ]) async {
    var historyItem = await searchHistoryRepository.addSearchHistoryItem(
      type,
      searchKey,
      data,
      entityId,
    );

    if (historyItem != null) {
      if (entityId != null) {
        userSearches.removeWhere(
          (element) => element.entityId == entityId && element.type == type,
        );
      } else {
        userSearches.removeWhere(
          (element) => element.searchKey == searchKey,
        );
      }

      userSearches.insert(0, historyItem);
    }
  }
}
