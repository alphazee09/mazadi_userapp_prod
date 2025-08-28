import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../core/controllers/image_picker.dart';
import '../../../../../core/navigator.dart';
import '../../../core/models/asset.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/assets/fullscreen_assets_view.dart';
import '../../../widgets/runtime/measure_size.dart';

class PreviewAssetsScreen extends StatefulWidget {
  final List<Asset> assets;

  const PreviewAssetsScreen({
    super.key,
    required this.assets,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PreviewAssetsScreen createState() => _PreviewAssetsScreen();
}

class _PreviewAssetsScreen extends State<PreviewAssetsScreen> {
  final imagePickerController = Get.find<ImagePickerController>();
  final navigatorService = Get.find<NavigatorService>();

  double carouselHeight = 0;
  final _carouselController = CarouselSliderController();
  int _currentCarouselStep = 0;

  Widget _renderAuctionAssets() {
    var assets = widget.assets;
    var assetsLen = assets.length;
    var serverBaseUrl = FlutterConfig.get('SERVER_URL');

    if (assetsLen == 0) {
      return SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset('assets/jpg/default-item.jpeg'),
        ),
      );
    }

    List<Widget> items = [];
    for (var asset in assets) {
      items.add(
        MeasureSize(
          onHeightAvailable: (double height) {
            if (mounted) {
              setState(() {
                carouselHeight = height;
              });
            }
          },
          child: ScaleTap(
            onPressed: () {
              navigatorService.push(
                FullscreenAssetsView(
                  assets: widget.assets,
                  step: assets.indexOf(asset),
                ),
                NavigationStyle.SharedAxis,
              );
            },
            child: ClipRRect(
              child: Image.network(
                asset.fullPath != null && asset.fullPath!.isNotEmpty
                    ? asset.fullPath!
                    : '$serverBaseUrl/assets/${asset.path}',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 350,
              ),
            ),
          ),
        ),
      );
    }

    return CarouselSlider(
      controller: _carouselController,
      options: CarouselOptions(
        height: 350,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          if (mounted) {
            setState(() {
              _currentCarouselStep = index;
            });
          }
        },
      ),
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) {
      return Container();
    }

    var arrayOfNumbers =
        List<int>.generate(widget.assets.length, (index) => index);

    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          _renderAuctionAssets(),
          arrayOfNumbers.length > 1
              ? Positioned(
                  bottom: 8,
                  child: SizedBox(
                    width: Get.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: arrayOfNumbers.asMap().entries.map(
                        (entry) {
                          return GestureDetector(
                            onTap: () =>
                                _carouselController.animateToPage(entry.key),
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsetsDirectional.only(
                                end: 4,
                                top: 8,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1
                                    .withOpacity(
                                      _currentCarouselStep == entry.key
                                          ? 0.9
                                          : 0.5,
                                    ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
