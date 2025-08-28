import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class RxNullable<T> {
  Rx<T> setNull() => (null as T).obs;
}

class SecuredController extends GetxController {
  Rx<String> jwt = ''.obs;

  Rx<bool?> isDark = RxNullable<bool?>().setNull();
  late FlutterSecureStorage storage;

  @override
  void onInit() async {
    super.onInit();
    storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  }

  Future<void> init() async {
    var storedValue = await storage.read(key: 'isDarkTheme');
    if (storedValue == null) {
      return;
    }

    isDark.value = storedValue.toLowerCase() == 'true';
  }

  Future<void> loadJwtFromStorage() async {
    jwt.value = await storage.read(key: 'jwt') ?? '';
  }

  Future<void> setJwt(String value) async {
    if (jwt.value == value) {
      return;
    }

    jwt.value = value;
    await storage.write(key: 'jwt', value: value);
  }

  Future<void> setTheme(bool isDark) async {
    this.isDark.value = isDark;
    await storage.write(key: 'isDarkTheme', value: isDark.toString());
  }

  bool? isDarkTheme() {
    return isDark.value;
  }

  void clearAll() {
    jwt.value = '';
    storage.deleteAll();
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
