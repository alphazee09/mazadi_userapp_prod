import 'package:mazadi/core/models/settings.dart';
import 'package:get/get.dart';

import '../repositories/settings.dart';

class SettingsController extends GetxController {
  final settingsRepository = Get.find<SettingsRepository>();

  late Rx<mazadiSettings> settings;

  Future<mazadiSettings> load() async {
    var settingsData = await settingsRepository.getSettings();
    settings = settingsData.obs;
    return settings.value;
  }
}
