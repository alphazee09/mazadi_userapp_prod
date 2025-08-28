import 'dart:async';
import 'dart:convert';

import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/controllers/maps.dart';
import '../../../widgets/common/simple_button.dart';

// ignore: must_be_immutable
class LocationPreview extends StatefulWidget {
  LatLng latLng;
  LocationPreview({super.key, required this.latLng});

  @override
  // ignore: library_private_types_in_public_api
  _LocationPreview createState() => _LocationPreview();
}

var uuid = const Uuid();

class _LocationPreview extends State<LocationPreview> {
  final mapsController = Get.find<MapsController>();
  final flashControler = Get.find<FlashController>();

  Future<Object?> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  String convertJsonStylesToUrlParameter(List<dynamic> jsonStyles) {
    List<String> urlStyles = [];

    for (var style in jsonStyles) {
      List<String> styleComponents = [];

      if (style.containsKey('featureType')) {
        styleComponents.add('feature:${style['featureType']}');
      }

      if (style.containsKey('elementType')) {
        styleComponents.add('element:${style['elementType']}');
      }

      if (style.containsKey('stylers')) {
        for (var styler in style['stylers']) {
          styler.forEach((key, value) {
            // Convert color from #RRGGBB to 0xRRGGBB
            if (key == 'color') {
              // ignore: prefer_interpolation_to_compose_strings
              value = '0x' + value.substring(1);
            }
            styleComponents.add('$key:$value');
          });
        }
      }

      urlStyles.add('style=${styleComponents.join('|')}');
    }

    return urlStyles.join('&');
  }

  Future<String> constructStyledMapUrl(
      String filePath, double width, double height) async {
    // Read the .txt file containing the JSON styling
    String fileContent = await rootBundle.loadString(filePath);

    List<dynamic> styles = jsonDecode(fileContent);

    var covertedStyles = convertJsonStylesToUrlParameter(styles);
    var apiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');
    if (apiKey == '') {
      print('GOOGLE_MAPS_API_KEY is not set in .env file');
    }

    String url =
        'https://maps.googleapis.com/maps/api/staticmap?center=${widget.latLng.latitude},${widget.latLng.longitude}&zoom=15&size=${width.round()}x${height.round()}&key=${apiKey ?? ''}&$covertedStyles';

    return url;
  }

  Widget _renderGoogleMaps() {
    var apiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');
    if (apiKey == '' || apiKey.isEmpty) {
      return SizedBox(
        width: Get.width,
        child: Text(
          'GOOGLE_MAPS_API_KEY not provided in the .env file. Location system might not work properly. Do not try to change it.',
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ),
      );
    }

    return FutureBuilder(
        future: checkLocationPermission(),
        builder: (ctx, snapshot) {
          if (snapshot.data == null) {
            return SizedBox(
              width: Get.width,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2,
                highlightColor: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_1,
                child: Container(
                  height: 24,
                  width: Get.width * 0.5,
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_3,
                ),
              ),
            );
          }

          if (snapshot.data == LocationPermission.denied ||
              snapshot.data == LocationPermission.deniedForever) {
            return Container(
              width: Get.width,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue[500],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'location.map_not_available',
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .subtitle
                        .copyWith(color: DarkColors.font_1),
                  ).tr(),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'location.need_to_give_permissions',
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(color: DarkColors.font_1),
                        ).tr(),
                      ),
                    ],
                  ),
                  SimpleButton(
                    background: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .action,
                    onPressed: () async {
                      var permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.denied ||
                            permission == LocationPermission.deniedForever) {
                          flashControler.showMessageFlash(
                              tr('generic.permission_denied'));
                          return;
                        }

                        if (permission == LocationPermission.always ||
                            permission == LocationPermission.whileInUse) {
                          if (mounted) {
                            setState(() {});
                          }
                          return;
                        }
                      }
                      await Geolocator.openLocationSettings();
                    },
                    height: 42,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        snapshot.data == LocationPermission.deniedForever
                            ? 'generic.open_settings'
                            : 'generic.give_permission',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: DarkColors.font_1,
                            ),
                      ).tr(),
                    ),
                  )
                ],
              ),
            );
          }

          return SizedBox(
            width: Get.width,
            height: 300,
            child: LayoutBuilder(builder: (context, constraints) {
              double containerWidth = constraints.maxWidth;
              double containerHeight = constraints.maxHeight;

              return FutureBuilder<String>(
                future: constructStyledMapUrl(
                    Get.isDarkMode
                        ? 'assets/maps/dark.txt'
                        : 'assets/maps/light.txt',
                    containerWidth,
                    containerHeight), // your Future function here
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Image.network(
                      snapshot.data!,
                    ); // Here, snapshot.data contains the URL
                  }
                },
              );
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: _renderGoogleMaps(),
    );
  }
}
