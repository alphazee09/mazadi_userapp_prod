import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/controllers/ads.dart';

class BannerAdCard extends StatefulWidget {
  final double marginTop;
  final double marginBottom;

  BannerAdCard({this.marginTop = 24, this.marginBottom = 0, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BannerAdCardState createState() => _BannerAdCardState();
}

class _BannerAdCardState extends State<BannerAdCard> {
  final adsController = Get.find<AdsController>();
  BannerAd? bannerAd;

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    if (bannerAd != null) {
      adsController.releaseBannerAd(bannerAd!);
    }

    super.dispose();
  }

  Future<void> loadAd() async {
    bannerAd = await adsController.getBannerAd();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (bannerAd == null) {
      return Container();
    }

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(
          top: widget.marginTop,
          bottom: widget.marginBottom,
        ),
        width: bannerAd!.size.width.toDouble(),
        height: bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: bannerAd!),
      ),
    );
  }
}
