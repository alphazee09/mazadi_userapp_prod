import 'package:get/get.dart';
import '../models/account.dart';
import 'base.dart';

class FollowersRepository {
  var dio = Get.find<Api>();

  Future<bool> followAccount(String accountId) async {
    try {
      await dio.api.put('/follow/follow/$accountId');
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> unfollowAccount(String accountId) async {
    try {
      await dio.api.put('/follow/unfollow/$accountId');
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<List<Account>> getFollowers(
      String accountId, int page, int perPage) async {
    try {
      var response =
          await dio.api.get('/follow/followers/$accountId/$page/$perPage');

      return List<Account>.from(
        response.data.map(
          (el) => Account.fromJSON(el['follower']),
        ),
      );
    } catch (error) {
      print('error loading account followers: $error');
      return [];
    }
  }

  Future<List<Account>> getFollowing(
      String accountId, int page, int perPage) async {
    try {
      var response =
          await dio.api.get('/follow/following/$accountId/$page/$perPage');

      return List<Account>.from(
        response.data.map(
          (el) => Account.fromJSON(el['following']),
        ),
      );
    } catch (error) {
      print('error loading account following: $error');
      return [];
    }
  }
}
