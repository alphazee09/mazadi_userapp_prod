import 'package:mazadi/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../core/controllers/notifications.dart';
import '../../theme/colors.dart';
import '../../widgets/simple_app_bar.dart';

class LanguagesSettingsScreen extends StatefulWidget {
  const LanguagesSettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LanguagesSettingsScreen createState() => _LanguagesSettingsScreen();
}

class _LanguagesSettingsScreen extends State<LanguagesSettingsScreen> {
  final accountController = Get.find<AccountController>();
  final notificationsController = Get.find<NotificationsController>();

  void goBack() {
    Navigator.of(context).pop();
  }

  bool _languageChanging = false;

  Future handleChange(Locale locale) async {
    if (_languageChanging) {
      return;
    }

    var currentLocale = EasyLocalization.of(context)?.currentLocale;
    if (currentLocale.toString() == locale.toString()) {
      return;
    }

    setState(() {
      _languageChanging = true;
    });

    await context.setLocale(locale);
    if (!mounted) {
      return;
    }

    await EasyLocalization.of(context)!.setLocale(locale);
    await Get.updateLocale(locale);
    updateAccountLanguage(locale);

    notificationsController.loadForAccount();

    setState(() {
      _languageChanging = false;
    });
  }

  Future updateAccountLanguage(Locale locale) async {
    var account = accountController.account.value;
    if (account.isAnonymous) {
      return;
    }

    var meta = account.meta;
    if (meta == null) {
      return;
    }

    if (meta.appLanguage == locale.toString()) {
      return;
    }

    meta.appLanguage = locale.toString();
    await accountController.updateAccountMeta(meta);
  }

  Widget _renderLanguage(
    String icon,
    String title,
    bool isSelected,
    Function onChange,
  ) {
    return InkWell(
      onTap: () {
        onChange();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/svg/flags/$icon.svg',
                    height: 40,
                    semanticsLabel: icon,
                  ),
                  Container(
                    width: 8,
                  ),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: 8,
            ),
            Checkbox(
              side: BorderSide(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .fontColor_1,
              ),
              checkColor: DarkColors.font_1,
              activeColor:
                  Theme.of(context).extension<CustomThemeFields>()!.action,
              value: isSelected,
              onChanged: (bool? value) {
                onChange();
              },
            ),
          ],
        ),
      ),
    );
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
                      'profile.language',
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title,
                    ).tr(),
                  ),
                ],
              )),
          body: Column(
            children: Constants.LANGUAGES.map((language) {
              return _renderLanguage(
                language['icon']!,
                language['name']!,
                EasyLocalization.of(context)!.locale ==
                    Locale(language['code']!),
                () => handleChange(Locale(language['code']!)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
