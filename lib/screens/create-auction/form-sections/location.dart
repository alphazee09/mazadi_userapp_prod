import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/auction.dart';
import '../../../core/controllers/location.dart';
import '../../../core/navigator.dart';
import '../../../widgets/common/input_like_button.dart';
import '../../../widgets/common/section_heading.dart';
import '../widgets/location_preview.dart';
import '../../../widgets/common/fullscreen-location-selector/index.dart';

class AuctionFormLocationSection extends StatelessWidget {
  final newAuctionController = Get.find<AuctionController>();
  final locationController = Get.find<LocationController>();
  final navigatorService = Get.find<NavigatorService>();

  void _cleanupLocation() {
    locationController.setLocation('');
    locationController.setMarkerLatLong(null);
  }

  @override
  Widget build(BuildContext context) {
    var locationMsg = tr("location.location");
    var selectLocationMsg = tr("location.select_location");

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              title: locationMsg,
              withMore: false,
              padding: 0,
            ),
            Obx(
              () => InputLikeButton(
                withPrefixIcon: true,
                padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                placeholder: locationController.location.value != ''
                    ? locationController.location.value
                    : selectLocationMsg,
                prefixIcon: SvgPicture.asset(
                  'assets/icons/svg/location.svg',
                  semanticsLabel: 'Location',
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    BlendMode.srcIn,
                  ),
                ),
                sufixIcon: locationController.location.value != ''
                    ? IconButton(
                        splashRadius: 24,
                        iconSize: 14,
                        onPressed: () {
                          _cleanupLocation();
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/svg/close.svg',
                          semanticsLabel: 'Close',
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : Container(),
                onTap: () {
                  navigatorService
                      .push(const FullscreenLocationSelectorScreen());
                },
              ),
            ),
            Obx(
              () => locationController.location.isEmpty ||
                      locationController.latLng.value == null
                  ? Container()
                  : Container(
                      height: 170,
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: LocationPreview(
                          latLng: locationController.latLng.value!,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
