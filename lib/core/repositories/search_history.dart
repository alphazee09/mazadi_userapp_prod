import 'dart:convert';

import 'package:get/get.dart';

import '../models/search_history_item.dart';
import 'base.dart';

class SearchHistoryRepository {
  var dio = Get.find<Api>();

  Future<List<SearchHistoryItem>> loadForAccount([
    String keyword = '',
    int page = 0,
    int perPage = 5,
  ]) async {
    try {
      var response = await dio.api.post(
        '/searchHistory/search',
        data: jsonEncode(
          {
            'query': keyword,
            'page': page,
            'perPage': perPage,
          },
        ),
      );

      return List<SearchHistoryItem>.from(
          response.data.map((el) => SearchHistoryItem.fromJSON(el)));
    } catch (error) {
      print('error loading search history items: $error');
      return [];
    }
  }

  Future<SearchHistoryItem?> addSearchHistoryItem(
    SearchHistoryItemType type,
    String searchKey, [
    String? data,
    String? entityId,
  ]) async {
    try {
      var response = await dio.api.post(
        '/searchHistory',
        data: jsonEncode({
          'type': type.name,
          'searchKey': searchKey,
          'data': data,
          'entityId': entityId,
        }),
      );

      return SearchHistoryItem.fromJSON(response.data);
    } catch (error) {
      print('error adding search history item: $error');
      return null;
    }
  }
}
