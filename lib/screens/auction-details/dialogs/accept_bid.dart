import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/controllers/ads.dart';
import '../../../core/controllers/flash.dart';
import '../../../widgets/common/simple_button.dart';

class AcceptBidDialogContent extends StatefulWidget {
  final Function onConfirm;

  const AcceptBidDialogContent({
    super.key,
    required this.onConfirm,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AcceptBidDialogContent createState() => _AcceptBidDialogContent();
}

class _AcceptBidDialogContent extends State<AcceptBidDialogContent> {
  final flashController = Get.find<FlashController>();
  final adsController = Get.find<AdsController>();

  bool _acceptInProgress = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    loadInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    if (_interstitialAd != null) {
      adsController.releaseInterstitialAd(_interstitialAd!);
    }
    super.dispose();
  }

  Future<void> loadInterstitialAd() async {
    _interstitialAd = await adsController.getInterstitialAd();
  }

  Future<void> handleAccept() async {
    if (_acceptInProgress) {
      return;
    }
    if (mounted) {
      setState(() {
        _acceptInProgress = true;
      });
    }

    var accepted = await widget.onConfirm();
    if (mounted) {
      setState(() {
        _acceptInProgress = false;
      });
    }

    if (!accepted) {
      flashController.showMessageFlash(
        tr("generic.something_went_wrong"),
        FlashMessageType.error,
      );
      return;
    }
    flashController.showMessageFlash(
      tr("auction_details.bids.bid_accepted"),
      FlashMessageType.success,
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    if (_interstitialAd == null) {
      return;
    }

    // Show the interstitial ad with a 50% chance and a 1s delay
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      await Future.delayed(const Duration(seconds: 1));
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
        },
      );
      _interstitialAd!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'auction_details.bids.sure_to_accept',
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          Container(
            height: 16,
          ),
          Center(
            child: Text(
              "auction_details.bids.auction_will_be_closed",
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(),
          ),
          Container(
            height: 16,
          ),
          Center(
            child: Text(
              "auction_details.bids.cannot_undo",
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smallest,
            ).tr(),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  Navigator.pop(context);
                },
                height: 42,
                child: Text(
                  'generic.cancel',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: SimpleButton(
                borderColor: Colors.green,
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                isLoading: _acceptInProgress,
                onPressed: () {
                  handleAccept();
                },
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auction_details.bids.accept_bid',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
