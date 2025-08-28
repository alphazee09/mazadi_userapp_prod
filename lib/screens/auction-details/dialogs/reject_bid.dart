import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/controllers/ads.dart';
import '../../../core/controllers/flash.dart';
import '../../../widgets/common/simple_button.dart';

class RejectBidDialogContent extends StatefulWidget {
  final Function onConfirm;

  const RejectBidDialogContent({
    super.key,
    required this.onConfirm,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RejectBidDialogContent createState() => _RejectBidDialogContent();
}

class _RejectBidDialogContent extends State<RejectBidDialogContent> {
  final _descriptionController = TextEditingController();
  final flashController = Get.find<FlashController>();
  final adsController = Get.find<AdsController>();

  int _descriptionLength = 0;
  bool _rejectInProgress = false;
  final Rx<bool> _pointerDownInner = false.obs;

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    loadInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    if (_interstitialAd != null) {
      adsController.releaseInterstitialAd(_interstitialAd!);
    }
    super.dispose();
  }

  Future<void> loadInterstitialAd() async {
    _interstitialAd = await adsController.getInterstitialAd();
  }

  Future<void> handleReject() async {
    if (_rejectInProgress) {
      return;
    }
    if (mounted) {
      setState(() {
        _rejectInProgress = true;
      });
    }

    var rejected = await widget.onConfirm(_descriptionController.text);
    if (mounted) {
      setState(() {
        _rejectInProgress = false;
      });
    }

    if (!rejected) {
      flashController.showMessageFlash(
        tr("generic.something_went_wrong"),
        FlashMessageType.error,
      );
      return;
    }

    flashController.showMessageFlash(
      tr("auction_details.bids.bid_rejected"),
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
    var rejectionReason = tr("auction_details.bids.enter_rejection_reason");
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      content: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          if (_pointerDownInner.value) {
            _pointerDownInner.value = false;
            return;
          }

          _pointerDownInner.value = false;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'auction_details.bids.sure_to_reject',
                textAlign: TextAlign.center,
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ).tr(),
            ),
            Container(
              height: 16,
            ),
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) {
                _pointerDownInner.value = true;
              },
              child: TextField(
                maxLines: 8,
                minLines: 4,
                maxLength: 300,
                controller: _descriptionController,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
                scrollPadding: const EdgeInsets.only(
                  bottom: 130,
                ),
                onChanged: ((value) {
                  if (mounted) {
                    setState(() {
                      _descriptionLength = value.length;
                    });
                  }
                }),
                decoration: InputDecoration(
                  hintText: rejectionReason,
                  counterText: '',
                  fillColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_3,
                  hintStyle:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2,
                        width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$_descriptionLength/300',
                    textAlign: TextAlign.right,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smallest)
              ],
            ),
            Container(
              height: 16,
            ),
            Center(
              child: Text(
                "auction_details.bids.cannot_undo_or_see",
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smallest,
              ).tr(),
            ),
          ],
        ),
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
                borderColor: Colors.red,
                isLoading: _rejectInProgress,
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  handleReject();
                },
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auction_details.bids.reject_bid',
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
