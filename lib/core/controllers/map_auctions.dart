import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/auction.dart';

class MapAuctionsController extends GetxController {
  Rx<LatLng> currentMapPosition = const LatLng(0, 0).obs;
  Rx<Auction?> selectedAuction = null.obs;
  RxString categoryToDisplayOnMap = ''.obs;

  void updateCurrentMapPosition(LatLng position) {
    currentMapPosition.value = position;
  }

  void setCategoryToDisplayOnMap(String category) {
    categoryToDisplayOnMap.value = category;
  }
}
