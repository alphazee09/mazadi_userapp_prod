import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/controllers/flash.dart';
import '../../../core/controllers/settings.dart';
import '../../../core/navigator.dart';
import '../../../widgets/common/section_heading.dart';
import '../about.dart';
import '../settings_item.dart';

class ProfileLegalSection extends StatelessWidget {
  final flashController = Get.find<FlashController>();
  final navigatorService = Get.find<NavigatorService>();
  final settingsController = Get.find<SettingsController>();

  Future<void> openConfidentiality() async {
    var url = Uri.parse(settingsController.settings.value.confidentialityLink);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      flashController.showMessageFlash('Could not open link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeading(
          title: tr('profile.legal_info'),
          withMore: false,
        ),
        SettingsItem(
          title: 'profile.terms_of_service',
          icon: SvgPicture.asset(
            'assets/icons/svg/profile/terms.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Terms',
          ),
          onTap: () {
            openConfidentiality();
          },
        ),
        SettingsItem(
          title: 'profile.privacy_policy',
          icon: SvgPicture.asset(
            'assets/icons/svg/profile/confidentiality.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Confidentiality',
          ),
          onTap: () {
            openConfidentiality();
          },
        ),
        SettingsItem(
          title: 'profile.cookies_policy',
          icon: SvgPicture.asset(
            'assets/icons/svg/profile/cookie.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Cookie',
          ),
          onTap: () {
            openConfidentiality();
          },
        ),
        SettingsItem(
          title: 'profile.about',
          icon: SvgPicture.asset(
            'assets/icons/svg/profile/info.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Info',
          ),
          onTap: () {
            navigatorService.push(
              const AboutSettingsScreen(),
              NavigationStyle.SharedAxis,
            );
          },
        ),
      ],
    );
  }
}
