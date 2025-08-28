import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/asset.dart';
import '../../../widgets/assets/assets_carousel.dart';
import '../../../widgets/common/image_error.dart';
import '../../../widgets/simple_app_bar.dart';

class FullscreenAssetsView extends StatefulWidget {
  final List<Asset>? assets;
  final List<String>? assetPaths;
  final List<XFile>? cameraAssets;
  final List<AssetEntity>? galleryAssets;
  final int? step;
  final String? title;

  const FullscreenAssetsView({
    super.key,
    this.assets,
    this.assetPaths,
    this.cameraAssets,
    this.galleryAssets,
    this.step = 0,
    this.title,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FullscreenAssetsView createState() => _FullscreenAssetsView();
}

class _FullscreenAssetsView extends State<FullscreenAssetsView> {
  final List<CarouselItem> _carouselItems = [];
  final _controller = CarouselSliderController();
  int _imagesLen = 0;
  int _currentCarouselStep = 0;

  @override
  void initState() {
    super.initState();
    var carouselItems = buildCarouselItems();

    _controller.onReady.then((_) => _controller.jumpToPage(widget.step ?? 0));
    if (mounted) {
      setState(() {
        _carouselItems.addAll(carouselItems);
        _imagesLen = carouselItems.length;
      });
    }
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  List<CarouselItem> buildCarouselItems() {
    List<CarouselItem> items = [];

    // Handle assets from server
    if (widget.assets != null) {
      var serverBaseUrl = FlutterConfig.get('SERVER_URL');
      items.addAll(widget.assets!.map((asset) {
        var assetPath = asset.fullPath ?? '$serverBaseUrl/assets/${asset.path}';
        return _buildCarouselItemFromWidget(
            _buildNetworkImage(assetPath), asset.id);
      }));
    }

    // Handle asset paths (URLs)
    if (widget.assetPaths != null) {
      items.addAll(widget.assetPaths!.map((path) {
        return _buildCarouselItemFromWidget(_buildNetworkImage(path), path);
      }));
    }

    // Handle camera assets
    if (widget.cameraAssets != null) {
      items.addAll(widget.cameraAssets!.map((asset) {
        return _buildCarouselItemFromWidget(
            _buildCameraImage(asset), asset.path);
      }));
    }

    // Handle gallery assets
    if (widget.galleryAssets != null) {
      items.addAll(widget.galleryAssets!.map((asset) {
        return _buildCarouselItemFromWidget(
            _buildGalleryImage(asset), asset.id);
      }));
    }

    return items;
  }

  CarouselItem _buildCarouselItemFromWidget(Widget widget, String id) {
    return CarouselItem(
      widget: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            height: double.infinity,
            width: Get.width,
            child: widget,
          ),
        ),
      ),
      type: ImageType.Camera,
      id: id,
    );
  }

  Widget _buildNetworkImage(String path) {
    return CachedNetworkImage(
      imageUrl: path,
      maxWidthDiskCache: Get.width.toInt(),
      maxHeightDiskCache: Get.height.toInt(),
      placeholder: (context, url) => const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          )
        ],
      ),
      errorWidget: (context, url, error) => const ImageErrorWidget(),
    );
  }

  Widget _buildCameraImage(XFile asset) {
    return Image.file(
      File(asset.path),
      fit: BoxFit.cover,
    );
  }

  Widget _buildGalleryImage(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _renderImagesCarousel() {
    if (_carouselItems.isEmpty) {
      return Center(
        child: Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "auction_details.does_not_have_images",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .title
                  .copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 22,
                  ),
            ).tr(),
          ),
        ),
      );
    }

    var items = _carouselItems.map((el) => el.widget).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
            child: CarouselSlider(
          controller: _controller,
          items: items,
          options: CarouselOptions(
              autoPlay: false,
              height: Get.height,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                if (mounted) {
                  setState(() {
                    _currentCarouselStep = index;
                  });
                }
              }),
        )),
        SizedBox(
          height: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _carouselItems
                .asMap()
                .map(
                  (index, item) {
                    return MapEntry(
                      index,
                      Container(
                        height: 12,
                        width: 12,
                        margin: const EdgeInsetsDirectional.only(end: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_2
                              .withOpacity(
                                  _currentCarouselStep == index ? 0.9 : 0.5),
                        ),
                      ),
                    );
                  },
                )
                .values
                .toList(),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
          onBack: goBack,
          withSearch: false,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: widget.title != null
                    ? Text(
                        widget.title!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .title,
                      )
                    : Text(
                        "auction_details.auction_images",
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .title,
                      ).tr(),
              ),
              _imagesLen > 0
                  ? Container(
                      margin: const EdgeInsetsDirectional.only(end: 16),
                      child: Text(
                              _imagesLen > 1
                                  ? "assets.image_plural"
                                  : "assets.image_singular",
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller)
                          .tr(namedArgs: {'no': _imagesLen.toString()}),
                    )
                  : Container()
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _renderImagesCarousel(),
          ),
        ),
      ),
    );
  }
}
