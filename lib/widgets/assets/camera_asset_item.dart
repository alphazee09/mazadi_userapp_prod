import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/controllers/image_picker.dart';

class CameraAssetsPickerItem extends StatefulWidget {
  final Image image;
  final Function select;
  final XFile asset;

  const CameraAssetsPickerItem({
    super.key,
    required this.image,
    required this.select,
    required this.asset,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CameraAssetsPickerItem createState() => _CameraAssetsPickerItem();
}

class _CameraAssetsPickerItem extends State<CameraAssetsPickerItem> {
  final imagePickerController = Get.find<ImagePickerController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Stack(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: InkWell(
              onTap: () {
                widget.select();
              },
              child: widget.image,
            ),
          ),
          Positioned(
            top: 4,
            left: 12,
            child: SvgPicture.asset(
              'assets/icons/svg/camera.svg',
              height: 16,
              width: 16,
              semanticsLabel: 'Camera',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                widget.select();
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_1
                      .withOpacity(0.8),
                  border: Border.all(
                    width: 0.5,
                    color: Theme.of(context).primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Obx(
                  () => imagePickerController
                          .cameraAssetIsSelected(widget.asset.path)
                      ? SvgPicture.asset(
                          'assets/icons/svg/check.svg',
                          height: 12,
                          width: 12,
                          semanticsLabel: 'check',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                            BlendMode.srcIn,
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
