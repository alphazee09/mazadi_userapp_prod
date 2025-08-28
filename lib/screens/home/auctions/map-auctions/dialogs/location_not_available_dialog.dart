import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../../../core/controllers/flash.dart';
import '../../../../../theme/extensions/base.dart';
import '../../../../../widgets/common/simple_button.dart';

class LocationNotAvailableDialog extends StatelessWidget {
  final flashControler = Get.find<FlashController>();
  final String permissionStatus;

  LocationNotAvailableDialog({
    super.key,
    required this.permissionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      title: Text(
        'location.location_denied',
        textAlign: TextAlign.center,
        style: Theme.of(context).extension<CustomThemeFields>()!.title,
      ).tr(),
      content: IntrinsicHeight(
        child: Column(
          children: [
            Text(
              'location.need_to_give_permissions',
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(),
            permissionStatus == 'PERMANENT_DISABLED'
                ? Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Text(
                      'map_auctions.need_permission_from_settings',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smallest,
                    ).tr(),
                  )
                : Container(),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            IntrinsicWidth(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                height: 42,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'generic.cancel',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ).tr(),
                ),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: IntrinsicWidth(
                child: SimpleButton(
                  borderColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_1,
                  background: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator,
                  onPressed: () async {
                    var permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied ||
                          permission == LocationPermission.deniedForever) {
                        flashControler
                            .showMessageFlash(tr('generic.permission_denied'));
                        return;
                      }

                      if (permission == LocationPermission.always ||
                          permission == LocationPermission.whileInUse) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(true);
                        return;
                      }
                    }
                    await Geolocator.openLocationSettings();
                  },
                  height: 42,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      permissionStatus == 'PERMANENT_DISABLED'
                          ? 'generic.open_settings'
                          : 'generic.give_permission',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
