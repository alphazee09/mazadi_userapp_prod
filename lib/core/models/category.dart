import 'package:mazadi/utils/constants.dart';
import 'package:get/get.dart';

import 'asset.dart';

class Category {
  String id;
  Map<String, String> name;
  String? icon;
  String? remoteIconUrl;
  String? assetId;
  Asset? asset;

  String? parentCategoryId;
  int auctionsCount;

  List<Rx<Category>> subcategories = [];

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.remoteIconUrl,
    this.assetId,
    this.asset,
    this.auctionsCount = 0,
    this.parentCategoryId,
    this.subcategories = const [],
  });

  static Category fromJSON(dynamic data) {
    return Category(
        id: data['id'],
        auctionsCount: data['auctionsCount'] != null
            ? int.parse(data['auctionsCount'].toString())
            : 0,
        icon: data['icon'] ?? '',
        remoteIconUrl: data['remoteIconUrl'] ?? '',
        assetId: data['assetId'] ?? '',
        parentCategoryId: data['parentCategoryId'],
        subcategories: data['subcategories'] != null
            ? (data['subcategories'] as List)
                .map((e) => Category.fromJSON(e).obs)
                .toList()
            : [],
        asset: data['asset'] != null ? Asset.fromJSON(data['asset']) : null,
        name: Map.fromEntries(
          Constants.LANGUAGES.map((lang) => MapEntry(
                lang['code']!,
                data['name'][lang['code']] ?? '',
              )),
        ));
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'auctionsCount': auctionsCount,
      'parentCategoryId': parentCategoryId,
      'remoteIconUrl': remoteIconUrl,
      'assetId': assetId,
      'icon': icon,
      'subcategories': subcategories.map((e) => e.value.toJSON()).toList(),
      'asset': asset?.toJson(),
    };
  }
}
