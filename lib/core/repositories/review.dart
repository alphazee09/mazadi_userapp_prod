import 'package:get/get.dart';
import '../models/review.dart';
import 'base.dart';

class ReviewRepository {
  var dio = Get.find<Api>();

  Future<List<Review>> loadForAccount(
      String accountId, int page, int perPage) async {
    try {
      var response = await dio.api.get('/review/$accountId/$page/$perPage');
      return List<Review>.from(response.data.map((el) => Review.fromJSON(el)));
    } catch (error) {
      return [];
    }
  }

  Future<Review?> saveReview(
    double stars,
    String auctionId, [
    String? description,
    String? id,
  ]) async {
    try {
      var result = await dio.api.post('/review', data: {
        'id': id,
        'stars': stars,
        'description': description,
        'auctionId': auctionId,
      });

      return Review.fromJSON(result.data);
    } catch (error) {
      return null;
    }
  }
}
