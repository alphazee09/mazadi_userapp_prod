import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/controllers/image_picker.dart';

class AssetsPickerItem extends StatefulWidget {
  final ImageProvider<Object> image;
  final Function select;
  final AssetEntity asset;

  const AssetsPickerItem({
    super.key,
    required this.image,
    required this.select,
    required this.asset,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AssetsPickerItem createState() => _AssetsPickerItem();
}

class _AssetsPickerItem extends State<AssetsPickerItem> {
  final imagePickerController = Get.find<ImagePickerController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            child: Ink.image(
              fit: BoxFit.cover,
              image: widget.image,
              child: InkWell(
                onTap: () {
                  widget.select();
                },
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
                  () => imagePickerController.assetIsSelected(widget.asset)
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
