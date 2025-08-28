import 'package:mazadi/core/models/auction.dart';
import 'package:get/get.dart';

import 'base.dart';

class LastSeenAuctionsRepository {
  final dio = Get.find<Api>();

  Future<RxList<Rx<Auction>>> load([int page = 0, int perPage = 10]) async {
    try {
      var response = await dio.api.get('/lastSeen/$page/$perPage');
      return RxList<Rx<Auction>>.from(
        response.data.map(
          (auction) => Auction.fromJSON(auction).obs,
        ),
      );
    } catch (error, stacktrace) {
      print('Error loading last seen auctions: $error, $stacktrace');
      return [] as RxList<Rx<Auction>>;
    }
  }

  Future<void> store(String auctionId) async {
    try {
      await dio.api.post('/lastSeen', data: {
        'auctionId': auctionId,
      });
    } catch (error, stacktrace) {
      print('Error storing last seen auction: $error, $stacktrace');
    }
  }
}
