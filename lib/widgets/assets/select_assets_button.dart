import 'dart:io';
import 'dart:typed_data';

import 'package:mazadi/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/controllers/image_picker.dart';
import '../../core/models/asset.dart';
import '../../core/navigator.dart';
import 'assets_carousel.dart';

// ignore: must_be_immutable
class SelectAssetsButton extends StatefulWidget {
  Function? onImagesSelected;

  SelectAssetsButton({
    super.key,
    this.onImagesSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SelectAssetsButton createState() => _SelectAssetsButton();
}

class _SelectAssetsButton extends State<SelectAssetsButton> {
  final imagePickerController = Get.find<ImagePickerController>();
  final navigatorService = Get.find<NavigatorService>();

  Future<void> _onImageButtonPressed(
    ImageSource source,
  ) async {
    try {
      await imagePickerController.openImageGalleryPicker();
      if (widget.onImagesSelected != null) {
        widget.onImagesSelected!();
      }
    } catch (e) {
      return;
    }
  }

  Widget _renderCameraAsset(XFile image) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.only(end: 8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              height: 65,
              width: 60,
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: SvgPicture.asset(
            'assets/icons/svg/camera.svg',
            height: 24,
            width: 24,
            semanticsLabel: 'Camera',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
        )
      ],
    );
  }

  Widget _renderGalleryAsset(AssetEntity image) {
    return FutureBuilder(
      future: image.thumbnailDataWithSize(
        const ThumbnailSize.square(200),
      ),
      builder: (BuildContext innerContext, snapshot) {
        if (snapshot.data == null) {
          return Container();
        }

        return Container(
          margin: const EdgeInsetsDirectional.only(end: 8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              height: 65,
              width: 60,
              child: Image.memory(
                snapshot.data as Uint8List,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _renderNetworkImage(Asset image) {
    var serverBaseUrl = FlutterConfig.get('SERVER_URL');

    return Container(
      margin: const EdgeInsetsDirectional.only(end: 8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          height: 65,
          width: 60,
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
  }

  Widget _renderPickedImages() {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () {
          _onImageButtonPressed(ImageSource.gallery);
        },
        child: Container(
          color: Colors.blue[500],
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'assets.selected_images',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .title
                            .copyWith(
                              color: DarkColors.font_1,
                            ),
                      ).tr(),
                      IconButton(
                        onPressed: () {
                          _onImageButtonPressed(ImageSource.gallery);
                        },
                        splashRadius: 24,
                        icon: SvgPicture.asset(
                          isRTL
                              ? 'assets/icons/svg/previous.svg'
                              : 'assets/icons/svg/next.svg',
                          colorFilter: ColorFilter.mode(
                            DarkColors.font_1,
                            BlendMode.srcIn,
                          ),
                          semanticsLabel: 'Next',
                        ),
                      ),
                    ]),
              ),
              Container(
                height: 8,
              ),
              GestureDetector(
                onTap: () {
                  navigatorService.push(
                    const AssetsCarousel(),
                    NavigationStyle.SharedAxis,
                  );
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 16,
                      ),
                      for (var image
                          // ignore: invalid_use_of_protected_member
                          in imagePickerController.cameraAssets.value)
                        _renderCameraAsset(image),
                      for (var image
                          // ignore: invalid_use_of_protected_member
                          in imagePickerController.galleryAssets.value)
                        _renderGalleryAsset(image),
                      for (var image in imagePickerController.networkAssets)
                        _renderNetworkImage(image),
                    ],
                  ),
                ),
              ),
              Container(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (imagePickerController.galleryAssets.isNotEmpty ||
          imagePickerController.cameraAssets.isNotEmpty ||
          imagePickerController.networkAssets.isNotEmpty) {
        return _renderPickedImages();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ScaleTap(
          onPressed: () {
            _onImageButtonPressed(ImageSource.gallery);
          },
          child: Container(
            height: 120,
            width: Get.width,
            decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 500,
                  width: Get.width / 1.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    color: Colors.blue[500],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller
                            .copyWith(color: DarkColors.font_1),
                      ),
                      Container(width: 8),
                      Text(
                        'assets.add_images',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller
                            .copyWith(color: DarkColors.font_1),
                      ).tr()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
