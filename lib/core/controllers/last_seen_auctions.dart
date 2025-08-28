import 'package:get/get.dart';

import '../models/auction.dart';
import '../repositories/last_seen_auctions.dart';

class LastSeenAuctionsController extends GetxController {
  final lastSeenAuctionsRepository = Get.find<LastSeenAuctionsRepository>();

  RxList<Rx<Auction>> lastSeenAuctions = RxList<Rx<Auction>>();

  void load() async {
    var loadedAuctions = await lastSeenAuctionsRepository.load();
    lastSeenAuctions.clear();
    lastSeenAuctions.addAll(loadedAuctions);
  }

  Future<RxList<Rx<Auction>>> loadByPage([int page = 1, int limit = 10]) async {
    return await lastSeenAuctionsRepository.load(page, limit);
  }

  void storeSeenAuction(Auction auction) {
    // if there is already a seen auction, remove it
    lastSeenAuctions.removeWhere((element) => element.value.id == auction.id);
    // add value to beginning of the list
    lastSeenAuctions.insert(0, auction.obs);
    // store the seen auction
    lastSeenAuctionsRepository.store(auction.id);
  }

  void removeAuctionById(String auctionId) {
    lastSeenAuctions.removeWhere((element) => element.value.id == auctionId);
  }
}
