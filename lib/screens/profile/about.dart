import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../widgets/common/app_logo.dart';
import '../../widgets/simple_app_bar.dart';

class AboutSettingsScreen extends StatefulWidget {
  const AboutSettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutSettingsScreen createState() => _AboutSettingsScreen();
}

class _AboutSettingsScreen extends State<AboutSettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  Future getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          resizeToAvoidBottomInset: true,
          appBar: SimpleAppBar(
            onBack: goBack,
            withSearch: false,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'profile.about',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ).tr(),
                ),
              ],
            ),
          ),
          body: SizedBox(
            height: Get.height,
            width: Get.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                  ),
                  AppLogo(),
                  Container(
                    height: 16,
                  ),
                  Text('profile.version',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller)
                      .tr(
                    namedArgs: {'no': _version},
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
