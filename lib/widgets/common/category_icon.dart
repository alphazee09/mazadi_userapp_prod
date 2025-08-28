import 'package:mazadi/widgets/common/image_error.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/categories.dart';
import '../../theme/extensions/base.dart';

// ignore: must_be_immutable
class CategoryIcon extends StatelessWidget {
  final categoriesController = Get.find<CategoriesController>();

  String currentLanguage;
  String? categoryId;
  int? size;

  CategoryIcon({
    super.key,
    required this.currentLanguage,
    required this.categoryId,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryId == null || categoryId == '') {
      return SvgPicture.asset(
        'assets/icons/svg/category.svg',
        semanticsLabel: 'Category',
        height: size!.toDouble(),
        colorFilter: ColorFilter.mode(
          Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
          BlendMode.srcIn,
        ),
      );
    }

    var categoryData = categoriesController.categories
        .firstWhereOrNull((element) => element.value.id == categoryId);
    if (categoryData == null) {
      return Container();
    }

    var category = categoryData.value;

    if (category.asset != null && category.asset!.id.isNotEmpty) {
      var serverBaseUrl = FlutterConfig.get('SERVER_URL');
      var assetPath = '$serverBaseUrl/assets/${category.asset!.path}';
      var widgetSize = size!.toDouble();

      return SizedBox(
        height: widgetSize,
        width: widgetSize,
        child: CachedNetworkImage(
          imageUrl: assetPath,
          maxWidthDiskCache: 100,
          maxHeightDiskCache: 100,
          placeholder: (context, url) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: widgetSize,
                width: widgetSize,
                child: CircularProgressIndicator(),
              )
            ],
          ),
          errorWidget: (context, url, error) => const ImageErrorWidget(),
        ),
      );
    }

    if (category.remoteIconUrl != null && category.remoteIconUrl!.isNotEmpty) {
      return SvgPicture.network(
        category.remoteIconUrl!,
        height: size!.toDouble(),
        semanticsLabel: category.name[currentLanguage],
      );
    }

    if (category.icon == null || category.icon!.isEmpty) {
      return Container();
    }

    return SvgPicture.asset(
      'assets/icons/categories/${category.icon}.svg',
      height: size!.toDouble(),
      width: size!.toDouble(),
      semanticsLabel: category.name[currentLanguage],
    );
  }
}
