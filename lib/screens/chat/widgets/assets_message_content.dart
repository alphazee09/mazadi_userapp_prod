import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:get/get.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/navigator.dart';
import '../../../widgets/assets/fullscreen_assets_view.dart';
import 'assets_dynamic_layout.dart';

class AssetsMessageContent extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final Rx<ChatMessage> message;

  AssetsMessageContent({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    var serverBaseUrl = FlutterConfig.get('SERVER_URL');
    var imagesPaths = message.value.assetPaths.map((path) {
      return '$serverBaseUrl/assets/$path';
    }).toList();

    return GestureDetector(
      onTap: () {
        navigatorService.push(
          FullscreenAssetsView(
            assetPaths: imagesPaths,
            galleryAssets: message.value.galleryAssets,
            cameraAssets: message.value.cameraAssets,
            title: tr('chat.chat_images'),
          ),
          NavigationStyle.SharedAxis,
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: DynamicImageLayout(
          assetPaths: imagesPaths,
          galleryAssets: message.value.galleryAssets,
          cameraAssets: message.value.cameraAssets,
        ),
      ),
    );
  }
}
