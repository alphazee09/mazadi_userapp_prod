import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/colors.dart';
import '../common/action_button.dart';
import '../simple_app_bar.dart';

class AskStoragePermissions extends StatefulWidget {
  final bool isPermanent;
  final VoidCallback onPressed;

  const AskStoragePermissions({
    super.key,
    required this.isPermanent,
    required this.onPressed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AskStoragePermissions createState() => _AskStoragePermissions();
}

class _AskStoragePermissions extends State<AskStoragePermissions> {
  void goBack() {
    Navigator.of(context).pop();
  }

  void askAgainForPermission() {
    goBack();
    widget.onPressed();
  }

  Widget _renderBottomNavbar() {
    if (widget.isPermanent == false) {
      return Container(height: 2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Flexible(
              child: ActionButton(
                onPressed: () {
                  goBack();
                },
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'generic.done',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title
                          .copyWith(color: DarkColors.font_1),
                    ).tr(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: SafeArea(
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          appBar: SimpleAppBar(
              onBack: goBack,
              withSearch: false,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'widgets.permissions.storage_permissions',
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title,
                    ).tr(),
                  ),
                ],
              )),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                    top: 24.0,
                    right: 32.0,
                  ),
                  child: Text(
                    'widgets.permissions.need_to_request_files',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .title
                        .copyWith(
                          fontWeight: FontWeight.w300,
                          fontSize: 22,
                        ),
                  ).tr(),
                ),
                if (widget.isPermanent)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'widgets.permissions.from_settings',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title
                          .copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: 20,
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_2),
                    ).tr(),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: ActionButton(
                    filled: false,
                    child: Text(
                      widget.isPermanent
                          ? 'widgets.permissions.open_settings'
                          : 'widgets.permissions.allow_access',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                    ).tr(),
                    onPressed: () => widget.isPermanent
                        ? openAppSettings()
                        : askAgainForPermission(),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _renderBottomNavbar(),
        ),
      ),
    );
  }
}
