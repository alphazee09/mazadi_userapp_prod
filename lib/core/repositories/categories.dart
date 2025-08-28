import 'package:mazadi/core/repositories/base.dart';
import 'package:get/get.dart';

import '../models/category.dart';

class CategoriesRepository {
  final dio = Get.find<Api>();

  Future<RxList<Rx<Category>>> loadAll() async {
    try {
      var response = await dio.api.get('/category');
      return RxList<Rx<Category>>.from(
        response.data.map(
          (category) => Category.fromJSON(category).obs,
        ),
      );
    } catch (error, stacktrace) {
      print('Error loading categories: $error, $stacktrace');
      return [] as RxList<Rx<Category>>;
    }
  }
}
