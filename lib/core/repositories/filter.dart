import 'package:get/get.dart';

import '../models/filter.dart';
import 'base.dart';

class FiltersRepository {
  var dio = Get.find<Api>();

  Future<bool> create(FilterItem item) async {
    try {
      await dio.api.post('/filters', data: item.toJSON());

      return true;
    } catch (error) {
      print('error creating filter: $error');
      return false;
    }
  }

  Future<bool> delete(String filterId) async {
    try {
      await dio.api.delete('/filters/$filterId');
      return true;
    } catch (error) {
      print('error deleting filter: $error');
      return false;
    }
  }
}
