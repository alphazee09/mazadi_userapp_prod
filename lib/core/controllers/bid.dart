import 'package:mazadi/core/repositories/bid.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/bid.dart';
import 'account.dart';
import 'location.dart';
import 'main.dart';

class BidController extends GetxController {
  // These properties are used inside the forms from the create and update bid screens
  Rx<String> description = ''.obs;
  Rx<double> price = 0.0.obs;

  final locationController = Get.find<LocationController>();
  final accountController = Get.find<AccountController>();
  final mainController = Get.find<MainController>();
  final bidRepository = Get.find<BidRepository>();

  Future<Bid?> create(String auctionId) async {
    var createdBid = await bidRepository.create(
      auctionId,
      CreateBidParams(
        latLng: locationController.latLng.value!,
        location: locationController.location.value,
        description: description.value,
        price: price.value,
      ),
    );

    if (createdBid == null) {
      return null;
    }

    clear();

    accountController.saveLocationToAccount(
      locationController.latLng.value as LatLng,
      locationController.location.value,
    );

    accountController.accountBidsCount.value += 1;
    return createdBid;
  }

  Future<bool> updateBid(
    String bidId, [
    String? rejectionReason,
    bool? isRejected,
    bool? isAccepted,
  ]) async {
    if (isAccepted == true) {
      accountController.activeAuctionsCount.value -= 1;
      accountController.activeAuctionsCount.refresh();

      accountController.closedAuctionsCount.value += 1;
      accountController.closedAuctionsCount.refresh();
    }

    return await bidRepository.update(
      bidId,
      rejectionReason,
      isRejected,
      isAccepted,
    );
  }

  Future<bool> markBidsFromAuctionAsSeen(String auctionId) async {
    return await bidRepository.markBidsFromAuctionAsSeen(auctionId);
  }

  Future<bool> removeBid(String auctionId, String bidId) async {
    accountController.accountBidsCount.value -= 1;
    accountController.accountBidsCount.refresh();

    return await bidRepository.delete(bidId);
  }

  void clear() {
    description.value = '';
    price.value = 0;
  }

  void setPrice(double newPrice) {
    price.value = newPrice;
  }

  void setDescription(String newDescription) {
    description.value = newDescription;
  }
}
