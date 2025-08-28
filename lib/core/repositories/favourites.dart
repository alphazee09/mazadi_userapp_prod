import 'package:get/get.dart';

import '../models/account.dart';
import '../models/auction.dart';
import 'base.dart';

class FavouriteRepository {
  final dio = Get.find<Api>();

  Future<List<Auction>> loadAll() async {
    try {
      var response = await dio.api.get('/favourites');
      return List<Auction>.from(
        response.data.map(
          (el) => Auction.fromJSON(el),
        ),
      );
    } catch (error) {
      print('Error loading favourite auctions: $error');
      return [];
    }
  }

  Future<void> add(String auctionId) async {
    try {
      await dio.api.put('/favourites/add/$auctionId');
    } catch (error) {
      print('error adding auction to favourites: $error');
      return;
    }
  }

  Future<void> remove(String auctionId) async {
    try {
      await dio.api.put('/favourites/remove/$auctionId');
    } catch (error) {
      print('error removing auction from favourites: $error');
      return;
    }
  }

  Future<List<Account>> loadAccountsThatHaveAuctionInFavourites(
    String auctionId, [
    int page = 0,
    int perPage = 20,
  ]) async {
    try {
      var response = await dio.api.get(
        '/favourites/accounts/$auctionId/$page/$perPage',
      );
      return List<Account>.from(
        response.data.map(
          (el) => Account.fromJSON(el),
        ),
      );
    } catch (error) {
      print('error getting accounts that have auction in favourites $error');
      return [];
    }
  }
}
