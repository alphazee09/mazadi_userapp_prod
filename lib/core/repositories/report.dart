import 'package:get/get.dart';

import 'base.dart';

class ReportsRepository {
  var dio = Get.find<Api>();

  Future<bool> create(
    String entity,
    String entityId,
    String reason, [
    String description = '',
  ]) async {
    try {
      await dio.api.post('/report', data: {
        "entityName": entity,
        "entityId": entityId,
        "reason": reason,
        "description": description
      });

      return true;
    } catch (error) {
      print('error creating report: $error');
      return false;
    }
  }
}
