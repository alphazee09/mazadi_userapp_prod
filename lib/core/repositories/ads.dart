import 'package:get/get.dart';

import 'base.dart';

class AdsRepository {
  final dio = Get.find<Api>();

  Future<String?> storeRewardAd(
    String adUnitId,
    String hashCode,
  ) async {
    try {
      var result = await dio.api.post('/ad/store', data: {
        "adUnitId": adUnitId,
        "hashCode": hashCode,
      });

      return result.data['rewardAdId'];
    } catch (error) {
      print('error storing reward ad: $error');
      return null;
    }
  }

  Future<bool> giveReward(
    String rewardAdId,
  ) async {
    try {
      await dio.api.post('/ad/reward', data: {
        "rewardAdId": rewardAdId,
      });

      return true;
    } catch (error) {
      print('error giving reward for ad: $error');
      return false;
    }
  }
}
