import 'dart:async';

import 'package:get/get.dart';
import '../models/account.dart';
import '../models/review.dart';
import '../repositories/review.dart';
import 'account.dart';

class ReviewsController extends GetxController {
  final reviewRepository = Get.find<ReviewRepository>();
  final accountController = Get.find<AccountController>();

  RxList<Account> accountsWithMostReviews = <Account>[].obs;
  RxBool accountsWithMostReviewsLoading = false.obs;

  Future<List<Review>> loadForAccount(String accountId, int page, int perPage) {
    return reviewRepository.loadForAccount(accountId, page, perPage);
  }

  Future<Review?> saveReview(
    double stars,
    String auctionId, [
    String? description,
    String? id,
  ]) {
    return reviewRepository.saveReview(
      stars,
      auctionId,
      description,
      id,
    );
  }
}
