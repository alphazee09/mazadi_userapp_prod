import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/navigator.dart';
import '../../../core/controllers/theme.dart';
import '../../../widgets/common/section_heading.dart';
import '../languages.dart';
import '../notifications/index.dart';
import '../settings_item.dart';

class ProfilePreferencesSection extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    var preferences = tr('profile.preferences');

    return Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        SectionHeading(
          title: preferences,
          withMore: false,
        ),
        SettingsItem(
          title: 'profile.languages',
          icon: SvgPicture.asset(
            'assets/icons/svg/profile/language.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Languages',
          ),
          onTap: () {
            navigatorService.push(
              const LanguagesSettingsScreen(),
              NavigationStyle.SharedAxis,
            );
          },
        ),
        SettingsItem(
          title: 'profile.notifications.notifications',
          icon: SvgPicture.asset(
            'assets/icons/svg/profile/notification.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Notifications',
          ),
          onTap: () {
            navigatorService.push(
              const NotificationsSettingsScreen(),
              NavigationStyle.SharedAxis,
            );
          },
        ),
        SettingsItem(
          title: 'profile.dark_mode',
          icon: SvgPicture.asset(
            'assets/icons/svg/profile/moon.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Dark Mode',
          ),
          sufix: Obx(() => Switch(
                value: themeController.isDark.value,
                activeColor:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                onChanged: (bool value) {
                  themeController.switchTheme(value);
                },
              )),
          onTap: () {
            return;
          },
        ),
      ],
    );
  }
}
