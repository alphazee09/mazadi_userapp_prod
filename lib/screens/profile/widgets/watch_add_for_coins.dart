import 'package:mazadi/widgets/common/simple_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/controllers/ads.dart';
import '../../../core/controllers/settings.dart';
import '../../../theme/colors.dart';
import '../../../theme/extensions/base.dart';

class WatchAddForCoinsCard extends StatefulWidget {
  const WatchAddForCoinsCard({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _WatchAddForCoins createState() => _WatchAddForCoins();
}

class _WatchAddForCoins extends State<WatchAddForCoinsCard> {
  final adsController = Get.find<AdsController>();
  final settingsController = Get.find<SettingsController>();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  @override
  void initState() {
    loadRewardedAd();
    super.initState();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> loadRewardedAd() async {
    var ad = await adsController.getRewardedAd();
    if (ad == null) {
      setState(() {
        _rewardedAd = null;
      });
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        setState(() {
          ad.dispose();
          _rewardedAd = null;
        });
        loadRewardedAd();
      },
    );

    setState(() {
      _rewardedAd = ad;
    });
  }

  Future<void> _handleWatchAdd() async {
    if (_rewardedAd == null || _isLoading) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    var rewardId = await adsController.storeRewardAd(
      _rewardedAd!.adUnitId,
      _rewardedAd!.hashCode.toString(),
    );

    if (rewardId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        adsController.giveReward(rewardId);
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rewardedAd == null) {
      return Container();
    }

    return Container(
      margin: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16),
      child: ScaleTap(
        onPressed: () {
          _handleWatchAdd();
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .extension<CustomThemeFields>()!
                .background_3
                .withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svg/coin.svg',
                      height: 24,
                      width: 24,
                      semanticsLabel: 'Coins',
                    ),
                    Container(
                      width: 16,
                    ),
                    Flexible(
                      child: Text(
                        'ads.win_coins',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(
                        namedArgs: {
                          'no': settingsController
                              .settings.value.rewardCoinsForWatchingAd
                              .toString(),
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SimpleButton(
                onPressed: () async {
                  _handleWatchAdd();
                },
                isLoading: _isLoading,
                background: Colors.blue,
                child: Text(
                  'ads.watch_ad',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: DarkColors.font_1,
                        fontWeight: FontWeight.w500,
                      ),
                ).tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
