// ignore_for_file: constant_identifier_names
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
import '../../core/controllers/image_picker.dart';
import '../common/simple_button.dart';
import '../simple_app_bar.dart';

enum ImageType { Camera, Gallery, Network }

class CarouselItem {
  final Widget widget;
  final ImageType type;
  final String id;

  CarouselItem({
    required this.widget,
    required this.type,
    required this.id,
  });
}

class AssetsCarousel extends StatefulWidget {
  const AssetsCarousel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AssetsCarousel createState() => _AssetsCarousel();
}

class _AssetsCarousel extends State<AssetsCarousel> {
  final imagePickerController = Get.find<ImagePickerController>();

  int _current = 0;
  int _imagesLen = 0;

  final _controller = CarouselSliderController();

  final List<CarouselItem> _carouselItems = [];

  @override
  void initState() {
    super.initState();
    var carouselItems = buildCarouselItems();
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

  void handleRemoveItem() {
    var toRemove = _carouselItems[_current];
    if (toRemove.type == ImageType.Camera) {
      imagePickerController.removeCameraAsset(toRemove.id);
    } else if (toRemove.type == ImageType.Gallery) {
      imagePickerController.removeGalleryAsset(toRemove.id);
    } else {
      imagePickerController.removeNetworkAsset(toRemove.id);
    }
    if (mounted) {
      setState(() {
        _carouselItems.removeAt(_current);
        _imagesLen -= 1;

        if (_current > 0) {
          _current -= 1;
          _controller.animateToPage(_current,
              duration: const Duration(milliseconds: 1));
        }
      });
    }
  }

  List<CarouselItem> buildCarouselItems() {
    var cameraItems = imagePickerController.cameraAssets.map(
      ((image) {
        var widget = Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              height: double.infinity,
              width: Get.width,
              child: Image.file(
                File(image.path),
              ),
            ),
          ),
        );

        return CarouselItem(
          widget: widget,
          type: ImageType.Camera,
          id: image.path,
        );
      }),
    ).toList();

    var galleryItems = imagePickerController.galleryAssets.map(
      ((image) {
        var widget = FutureBuilder(
            future: image
                .thumbnailDataWithSize(ThumbnailSize.square(Get.width.toInt())),
            builder: (BuildContext innerContext, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }

              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    height: double.infinity,
                    width: Get.width,
                    child: Image.memory(
                      snapshot.data as Uint8List,
                    ),
                  ),
                ),
              );
            });

        return CarouselItem(
          widget: widget,
          type: ImageType.Gallery,
          id: image.id,
        );
      }),
    ).toList();

    var serverBaseUrl = FlutterConfig.get('SERVER_URL');

    var networkItems = imagePickerController.networkAssets.map((image) {
      var widget = Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  '$serverBaseUrl/assets/${image.path}',
                ),
              ),
            ),
          ),
        ),
      );

      return CarouselItem(
        widget: widget,
        type: ImageType.Network,
        id: image.id,
      );
    });

    return [...cameraItems, ...galleryItems, ...networkItems];
  }

  Widget _renderImagesCarousel() {
    if (_carouselItems.isEmpty) {
      return Center(
        child: Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "assets.no_selected",
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
                    _current = index;
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
                              .withOpacity(_current == index ? 0.9 : 0.5),
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
    var removeImage = tr('assets.remove_image');
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
                child: Text(
                  'assets.selected_images',
                  textAlign: TextAlign.start,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ).tr(),
              ),
              _imagesLen > 0
                  ? Container(
                      margin: const EdgeInsetsDirectional.only(end: 16),
                      child: Text(
                        _imagesLen > 1
                            ? 'assets.image_plural'
                            : 'assets.image_singular',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(namedArgs: {'no': _imagesLen.toString()}),
                    )
                  : Container()
            ],
          ),
        ),
        body: SafeArea(
          child: SizedBox(
            width: Get.width,
            child: _renderImagesCarousel(),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              height: 64,
              color: Colors.transparent,
              child: _carouselItems.isEmpty
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_1,
                      child: SimpleButton(
                        filled: _carouselItems.isEmpty,
                        text: removeImage,
                        onPressed: () {
                          handleRemoveItem();
                        },
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
