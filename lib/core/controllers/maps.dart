import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MapsController extends GetxController {
  RxString darkMapStyle = ''.obs;
  RxString lightMapStyle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    var darkMapPromise = rootBundle.loadString('assets/maps/dark.txt');
    var lightMapPromise = rootBundle.loadString('assets/maps/light.txt');

    darkMapStyle = (await darkMapPromise).obs;
    lightMapStyle = (await lightMapPromise).obs;
  }
}
