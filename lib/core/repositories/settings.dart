import 'package:mazadi/core/models/settings.dart';
import 'package:get/get.dart';

import 'base.dart';

class SettingsRepository {
  final dio = Get.find<Api>();

  Future<mazadiSettings> getSettings() async {
    try {
      var response = await dio.api.get('/settings');
      return mazadiSettings.fromJSON(response.data);
    } catch (error) {
      print('error loading settings: $error');
      return mazadiSettings();
    }
  }
}
