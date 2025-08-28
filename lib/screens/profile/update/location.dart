import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/location.dart';
import '../../../core/navigator.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/input_like_button.dart';
import '../../../widgets/common/fullscreen-location-selector/index.dart';

class ProfileUpdateLocation extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ProfileUpdateLocation createState() => _ProfileUpdateLocation();
}

class _ProfileUpdateLocation extends State<ProfileUpdateLocation> {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();
  final locationController = Get.find<LocationController>();

  late StreamSubscription<LatLng?> _locationSubscription;

  var _locationSaveInProgress = false;

  @override
  void initState() {
    super.initState();
    _locationSaveInProgress = false;

    _locationSubscription = locationController.latLng.listen((value) {
      EasyDebounce.debounce(
          'save-account-location', const Duration(milliseconds: 800), () {
        handleSaveNewLocationToAccount();
      });
    });
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  Future<void> handleSaveNewLocationToAccount() async {
    if (_locationSaveInProgress) {
      return Future.value();
    }

    setState(() {
      _locationSaveInProgress = true;
    });

    try {
      await accountController.saveLocationToAccount(
        locationController.latLng.value,
        locationController.location.value,
      );

      if (_locationSaveInProgress) {
        setState(() {
          _locationSaveInProgress = false;
        });
      }
    } finally {
      if (_locationSaveInProgress) {
        setState(() {
          _locationSaveInProgress = false;
        });
      }
    }
  }

  void _cleanupLocation() {
    if (_locationSaveInProgress) {
      return;
    }

    locationController.setLocation('');
    locationController.setMarkerLatLong(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => InputLikeButton(
            withPrefixIcon: true,
            padding: const EdgeInsets.only(left: 16, right: 8),
            placeholder:
                accountController.account.value.locationPretty != null &&
                        accountController.account.value.locationPretty != ''
                    ? accountController.account.value.locationPretty
                    : tr('profile.update.add_location'),
            prefixIcon: SvgPicture.asset(
              'assets/icons/svg/location.svg',
              semanticsLabel: 'Location',
              height: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
            sufixIcon: accountController.account.value.locationPretty != null &&
                    accountController.account.value.locationPretty != ''
                ? _locationSaveInProgress
                    ? Container(
                        height: 20,
                        width: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                          ),
                        ),
                      )
                    : IconButton(
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
              navigatorService.push(const FullscreenLocationSelectorScreen());
            },
          ),
        ),
        Container(
          height: 8,
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                'profile.update.save_location_to',
                textAlign: TextAlign.start,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(),
            ),
          ],
        ),
      ],
    );
  }
}
