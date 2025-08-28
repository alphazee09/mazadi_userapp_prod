import 'dart:async';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/settings.dart';
import '../repositories/ads.dart';

const maxAllowedAdsInPool = 50;

class AdsController extends GetxController {
  final adsRepository = Get.find<AdsRepository>();

  List<BannerAd> _bannerAdsPool = [];
  List<InterstitialAd> _interstitialAdsPool = [];
  List<RewardedAd> _rewardedAdsPool = [];

  List<Completer<BannerAd?>> _pendingBannerAdsRequests = [];
  List<Completer<InterstitialAd?>> _pendingInterstitialAdsRequests = [];
  List<Completer<RewardedAd?>> _pendingRewardedAdsRequests = [];

  AdsCredentials? credentials;
  bool adsEnabled = true;

  Set<int> _handledAds = {};

  @override
  void onClose() {
    for (var ad in _bannerAdsPool) {
      ad.dispose();
    }

    for (var ad in _interstitialAdsPool) {
      ad.dispose();
    }

    for (var ad in _rewardedAdsPool) {
      ad.dispose();
    }

    _bannerAdsPool.clear();
    _pendingBannerAdsRequests.clear();

    _interstitialAdsPool.clear();
    _pendingInterstitialAdsRequests.clear();

    _rewardedAdsPool.clear();
    _pendingRewardedAdsRequests.clear();
  }

  void initCredentials(mazadiSettings settings) {
    credentials = AdsCredentials(
      banner: settings.adsCredentials!.banner,
      interstitial: settings.adsCredentials!.interstitial,
      rewarded: settings.adsCredentials!.rewarded,
    );
    adsEnabled = settings.adsEnabled;
  }

  Future<String?> storeRewardAd(String adUnitId, String hashCode) async {
    return await adsRepository.storeRewardAd(adUnitId, hashCode);
  }

  Future<bool> giveReward(String rewardAdId) async {
    return await adsRepository.giveReward(rewardAdId);
  }

  void preloadRewardedAds({int count = 1}) {
    if (credentials == null || credentials?.interstitial == null) {
      throw Exception('Ads credentials are not set');
    }

    for (int i = 0; i < count; i++) {
      RewardedAd.load(
        adUnitId: credentials!.rewarded,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            if (_handledAds.contains(ad.hashCode)) {
              return;
            }

            if (_rewardedAdsPool.length <= maxAllowedAdsInPool) {
              _handledAds.add(ad.hashCode);
              _rewardedAdsPool.add(ad);
            } else {
              ad.dispose();
            }
            _resolvePendingRewardedRequests();
          },
          onAdFailedToLoad: (LoadAdError error) {},
        ),
      );
    }
  }

  void preloadInterstitialAds({int count = 1}) {
    if (credentials == null || credentials?.interstitial == null) {
      throw Exception('Ads credentials are not set');
    }

    for (int i = 0; i < count; i++) {
      InterstitialAd.load(
        adUnitId: credentials!.interstitial,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (_handledAds.contains(ad.hashCode)) {
              return;
            }

            if (_interstitialAdsPool.length <= maxAllowedAdsInPool) {
              _handledAds.add(ad.hashCode);
              _interstitialAdsPool.add(ad);
            } else {
              ad.dispose();
            }
            _resolvePendingInterstitialRequests();
          },
          onAdFailedToLoad: (LoadAdError error) {},
        ),
      );
    }
  }

  void preloadBannerAds({int count = 1}) {
    if (credentials == null || credentials?.banner == null) {
      throw Exception('Ads credentials are not set');
    }

    for (int i = 0; i < count; i++) {
      BannerAd ad = BannerAd(
        adUnitId: credentials!.banner,
        size: AdSize.fullBanner,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (_handledAds.contains(ad.hashCode)) {
              return;
            }

            if (_bannerAdsPool.length <= maxAllowedAdsInPool) {
              _handledAds.add(ad.hashCode);
              _bannerAdsPool.add(ad as BannerAd);
            } else {
              ad.dispose();
            }
            _resolvePendingBannerRequests();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
          },
        ),
      );
      ad.load();
    }
  }

  Future<RewardedAd?> getRewardedAd() async {
    if (!adsEnabled) {
      return null;
    }

    if (_rewardedAdsPool.isNotEmpty) {
      var availableAd = _rewardedAdsPool.removeAt(0);
      if (_rewardedAdsPool.length < 20) {
        preloadRewardedAds();
      }

      return availableAd;
    }

    // If no ads are ready, create a pending request
    final Completer<RewardedAd> completer = Completer<RewardedAd>();
    _pendingRewardedAdsRequests.add(completer);

    preloadRewardedAds();
    return completer.future;
  }

  Future<InterstitialAd?> getInterstitialAd() async {
    if (!adsEnabled) {
      return null;
    }

    // Find an ad that is not in use
    if (_interstitialAdsPool.isNotEmpty) {
      var availableAd = _interstitialAdsPool.removeAt(0);
      _interstitialAdsPool.remove(availableAd);

      if (_interstitialAdsPool.length < 20) {
        preloadInterstitialAds();
      }
      return availableAd;
    }

    // If no ads are ready, create a pending request
    final Completer<InterstitialAd> completer = Completer<InterstitialAd>();
    _pendingInterstitialAdsRequests.add(completer);

    preloadInterstitialAds();

    return completer.future;
  }

  Future<BannerAd?> getBannerAd() async {
    if (!adsEnabled) {
      return null;
    }

    if (_bannerAdsPool.isNotEmpty) {
      var availableAd = _bannerAdsPool.removeAt(0);
      if (_bannerAdsPool.length < 10) {
        preloadBannerAds();
      }

      return availableAd;
    }

    // If no ads are ready, create a pending request
    final Completer<BannerAd> completer = Completer<BannerAd>();
    _pendingBannerAdsRequests.add(completer);

    preloadBannerAds();
    return completer.future;
  }

  void releaseBannerAd(BannerAd ad) {
    var adAlreadyExists =
        _bannerAdsPool.any((element) => element.hashCode == ad.hashCode);

    if (!adAlreadyExists) {
      _bannerAdsPool.add(ad);
    }
  }

  void releaseInterstitialAd(InterstitialAd ad) {
    var adAlreadyExists =
        _interstitialAdsPool.any((element) => element.hashCode == ad.hashCode);

    if (!adAlreadyExists) {
      _interstitialAdsPool.add(ad);
    }
  }

  void _resolvePendingRewardedRequests() {
    if (_pendingRewardedAdsRequests.isEmpty) {
      return;
    }

    while (
        _pendingRewardedAdsRequests.isNotEmpty && _rewardedAdsPool.isNotEmpty) {
      Completer<RewardedAd?> completer =
          _pendingRewardedAdsRequests.removeAt(0);
      var ad = _rewardedAdsPool.first;
      _rewardedAdsPool.remove(ad);
      completer.complete(ad);

      if (_rewardedAdsPool.length < 20) {
        preloadRewardedAds();
      }
    }

    while (_pendingRewardedAdsRequests.isNotEmpty) {
      Completer<RewardedAd?> completer =
          _pendingRewardedAdsRequests.removeAt(0);
      completer.complete(null);
    }
  }

  void _resolvePendingInterstitialRequests() {
    if (_pendingInterstitialAdsRequests.isEmpty) {
      return;
    }

    while (_pendingInterstitialAdsRequests.isNotEmpty &&
        _interstitialAdsPool.isNotEmpty) {
      Completer<InterstitialAd?> completer =
          _pendingInterstitialAdsRequests.removeAt(0);

      var ad = _interstitialAdsPool.first;
      _interstitialAdsPool.remove(ad);
      completer.complete(ad);

      if (_interstitialAdsPool.length < 20) {
        preloadInterstitialAds();
      }
    }

    while (_pendingInterstitialAdsRequests.isNotEmpty) {
      Completer<InterstitialAd?> completer =
          _pendingInterstitialAdsRequests.removeAt(0);
      completer.complete(null);
    }
  }

  void _resolvePendingBannerRequests() {
    if (_pendingBannerAdsRequests.isEmpty) {
      return;
    }

    while (_pendingBannerAdsRequests.isNotEmpty && _bannerAdsPool.isNotEmpty) {
      Completer<BannerAd?> completer = _pendingBannerAdsRequests.removeAt(0);
      var ad = _bannerAdsPool.first;
      _bannerAdsPool.remove(ad);
      completer.complete(ad);

      if (_bannerAdsPool.length < 20) {
        preloadBannerAds();
      }
    }

    while (_pendingBannerAdsRequests.isNotEmpty) {
      Completer<BannerAd?> completer = _pendingBannerAdsRequests.removeAt(0);
      completer.complete(null);
    }
  }
}

class AdsCredentials {
  final String banner;
  final String interstitial;
  final String rewarded;

  AdsCredentials({
    required this.banner,
    required this.interstitial,
    required this.rewarded,
  });
}
