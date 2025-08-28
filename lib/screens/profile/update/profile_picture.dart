import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/image_picker.dart';
import '../../../widgets/common/image_error.dart';
import '../../../widgets/common/simple_button.dart';

class ProfileUpdateProfilePicture extends StatelessWidget {
  final accountController = Get.find<AccountController>();
  final imagePickerController = Get.find<ImagePickerController>();

  Future<void> _openImagePicker() async {
    try {
      await imagePickerController.openImageGalleryPicker(false);
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Obx(() {
            if (imagePickerController.assetsAreSelected()) {
              return ClipOval(
                child: FutureBuilder(
                  future: imagePickerController.galleryAssets.first
                      .thumbnailDataWithSize(
                    const ThumbnailSize.square(250),
                  ),
                  builder: (BuildContext innerContext, snapshot) {
                    if (snapshot.data == null) {
                      return Container();
                    }

                    return ClipRRect(
                      child: SizedBox(
                        height: 65,
                        width: 60,
                        child: Image.memory(
                          snapshot.data as Uint8List,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return Obx(
              () => ClipOval(
                child: accountController.account.value.picture == ''
                    ? SvgPicture.asset(
                        'assets/icons/svg/user.svg',
                        semanticsLabel: 'User picture',
                      )
                    : CachedNetworkImage(
                        imageUrl: accountController.account.value.picture,
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        maxWidthDiskCache: Get.width.toInt(),
                        maxHeightDiskCache: Get.height.toInt(),
                        errorWidget: (context, url, error) =>
                            const ImageErrorWidget(),
                      ),
              ),
            );
          }),
        ),
        Container(
          height: 16,
        ),
        IntrinsicWidth(
          child: SimpleButton(
            onPressed: () {
              _openImagePicker();
            },
            borderColor:
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'profile.update.change_profile_picture',
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(),
            ),
          ),
        )
      ],
    );
  }
}
