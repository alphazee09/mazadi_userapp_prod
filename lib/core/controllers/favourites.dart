import 'package:get/get.dart';

import '../models/account.dart';
import '../models/auction.dart';
import '../repositories/favourites.dart';

class FavouritesController extends GetxController {
  final favouritesRepository = Get.find<FavouriteRepository>();

  RxList<Rx<Auction>> favourites = RxList<Rx<Auction>>();

  @override
  void onClose() {
    favourites.clear();
    super.onClose();
  }

  Future<void> load() async {
    favourites.clear();
    var favouritesList = await favouritesRepository.loadAll();
    favourites.addAll(favouritesList.map((e) => e.obs));
  }

  void handleAuctionBidRemoved(String auctionId) {
    for (var auction in favourites) {
      if (auction.value.id == auctionId) {
        auction.value.bidsCount -= 1;
        auction.refresh();
      }
    }
  }

  Future<List<Account>> loadAccountsThatHaveAuctionInFavourites(
    String auctionId, [
    int page = 0,
    int perPage = 20,
  ]) async {
    return favouritesRepository.loadAccountsThatHaveAuctionInFavourites(
      auctionId,
      page,
      perPage,
    );
  }

  Future<void> addAuctionToFavourites(Rx<Auction> auction) async {
    var auctionAlreadyToFavorite = favourites.any(
      (element) => element.value.id == auction.value.id,
    );

    if (auctionAlreadyToFavorite) {
      return;
    }

    favourites.add(auction);
    await favouritesRepository.add(auction.value.id);
  }

  Future<void> removeAuctionFromFavourites(
    String auctionId, [
    bool removeOnServer = true,
  ]) async {
    favourites.removeWhere((element) => element.value.id == auctionId);

    if (removeOnServer) {
      await favouritesRepository.remove(auctionId);
    }
  }

  bool isFavourite(String id) {
    return favourites.any((element) => element.value.id == id);
  }

  List<Rx<Auction>> getAuctions([bool active = true]) {
    return favourites.where((element) {
      if (!active) {
        return !element.value.isActive || element.value.acceptedBidId != null;
      }

      return element.value.isActive && element.value.acceptedBidId == null;
    }).toList();
  }

  void clear() {
    favourites.clear();
  }
}
