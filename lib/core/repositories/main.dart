import 'package:get/get.dart';
import 'base.dart';

class MainRepository {
  var dio = Get.find<Api>();

  Future<bool> serverIsRunning() async {
    try {
      await dio.api.get('/');
      return true;
    } catch (error) {
      return false;
    }
  }
}
