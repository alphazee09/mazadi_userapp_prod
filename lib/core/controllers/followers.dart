import 'package:get/get.dart';

import '../models/account.dart';
import '../repositories/followers.dart';
import 'account.dart';

class FollowersController extends GetxController {
  final followersRepository = Get.find<FollowersRepository>();
  final accountController = Get.find<AccountController>();

  Future<bool> follow(String accountId) async {
    var success = await followersRepository.followAccount(accountId);

    if (success) {
      accountController.account.value.followingCount =
          accountController.account.value.followingCount! + 1;

      accountController.account.value.followingAccountsIds!.add(accountId);
      accountController.account.refresh();
    }

    return success;
  }

  Future<bool> unfollow(String accountId) async {
    var success = await followersRepository.unfollowAccount(accountId);

    if (success) {
      accountController.account.value.followingCount =
          accountController.account.value.followingCount! - 1;

      accountController.account.value.followingAccountsIds!.remove(accountId);
      accountController.account.refresh();
    }

    return success;
  }

  Future<List<Account>> getFollowers(
    String accountId,
    int page,
    int perPage,
  ) async {
    return followersRepository.getFollowers(accountId, page, perPage);
  }

  Future<List<Account>> getFollowing(
    String accountId,
    int page,
    int perPage,
  ) async {
    return followersRepository.getFollowing(accountId, page, perPage);
  }
}
