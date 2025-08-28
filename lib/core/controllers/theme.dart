import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'secured.dart';

class ThemeController extends GetxController {
  final securedController = Get.find<SecuredController>();

  Rx<bool> isDark = false.obs;

  void init() async {
    isDark.value = securedController.isDarkTheme() ?? false;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  _saveThemeToBox(bool isDarkMode) => securedController.setTheme(isDarkMode);

  void switchTheme(bool newThemeIsDark) async {
    isDark.value = newThemeIsDark;
    isDark.refresh();

    _saveThemeToBox(newThemeIsDark);
    Get.changeThemeMode(newThemeIsDark ? ThemeMode.dark : ThemeMode.light);
  }
}
