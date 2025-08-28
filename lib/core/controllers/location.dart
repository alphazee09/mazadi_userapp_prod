import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'secured.dart';

class LocationController extends GetxController {
  Rx<LatLng?> latLng = RxNullable<LatLng?>().setNull();
  Rx<String> location = ''.obs;

  void setMarkerLatLong(LatLng? latLng) {
    this.latLng.value = latLng;
  }

  void setLocation(String location) {
    this.location.value = location;
  }

  void selectDefaultLocation() {
    latLng.value ??= LatLng(0, 0);

    if (location.value.isEmpty) {
      location.value = 'Unnamed location';
    }

    latLng.refresh();
    location.refresh();
  }
}
