import 'package:mazadi/core/models/category.dart';

import 'location.dart';

class FilterItem {
  String id;
  FilterItemData data;
  String name;
  String type;

  DateTime? createdAt;
  DateTime? updatedAt;

  FilterItem({
    required this.id,
    required this.data,
    required this.name,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  static FilterItem fromJSON(dynamic data) {
    return FilterItem(
      id: data['id'],
      data: FilterItemData.fromJSON(data['data']),
      name: data['name'],
      type: data['type'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'data': data.toJSON(),
      'name': name,
      'type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class FilterItemData {
  List<Category>? selectedCategories;
  List<Category>? selectedSubCategories;

  List<Location> selectedLocations;
  bool? includeMyAuctions;

  String? minPrice;
  String? maxPrice;

  FilterItemData({
    required this.selectedCategories,
    required this.selectedSubCategories,
    required this.selectedLocations,
    this.includeMyAuctions = true,
    this.minPrice,
    this.maxPrice,
  });

  static FilterItemData fromJSON(Map<String, dynamic> json) {
    return FilterItemData(
      selectedCategories: List<Category>.from(
        json['selectedCategories'].map((x) => Category.fromJSON(x)),
      ),
      selectedSubCategories: List<Category>.from(
        json['selectedCategories'].map((x) => Category.fromJSON(x)),
      ),
      selectedLocations: List<Location>.from(
        json['selectedLocations'].map((x) => Location.fromJSON(x)),
      ),
      includeMyAuctions: json['includeMyAuctions'] ?? true,
      minPrice: json['minPrice'] ?? '',
      maxPrice: json['maxPrice'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'selectedCategories': selectedCategories!.map((x) => x.toJSON()).toList(),
      'selectedSubCategories':
          selectedSubCategories!.map((x) => x.toJSON()).toList(),
      'selectedLocations': selectedLocations.map((x) => x.toJSON()).toList(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'includeMyAuctions': includeMyAuctions,
    };
  }
}
