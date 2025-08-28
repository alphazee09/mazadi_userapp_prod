import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/navigator.dart';
import '../../../widgets/common/section_heading.dart';
import '../settings_item.dart';
import '../widgets/auctions_list.dart';

class ProfileAuctionsSection extends StatelessWidget {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    var yourAuctions = tr('profile.your_auctions');

    return Column(
      children: [
        Obx(
          () => SectionHeading(
            title: yourAuctions,
            titleSufix: '(${accountController.accountAuctionsCount.value})',
            withMore: false,
          ),
        ),
        Obx(
          () => SettingsItem(
            title: 'profile.active_auctions.title',
            count: accountController.activeAuctionsCount.value,
            onTap: () {
              navigatorService.push(
                ProfileAuctionsListByStatus(
                  status: 'active',
                  title: Text(
                    'profile.active_auctions.active_auctions',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                    maxLines: 2,
                  ).tr(namedArgs: {
                    'no': accountController.activeAuctionsCount.value.toString()
                  }),
                  noAuctionsMessage: tr('profile.active_auctions.no_auctions'),
                  initialAuctionsCount:
                      accountController.activeAuctionsCount.value,
                ),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
        Obx(
          () => SettingsItem(
            title: 'profile.closed_auctions.title',
            count: accountController.closedAuctionsCount.value,
            onTap: () {
              navigatorService.push(
                ProfileAuctionsListByStatus(
                  status: 'closed',
                  title: Text(
                    'profile.closed_auctions.closed_auctions',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                    maxLines: 2,
                  ).tr(namedArgs: {
                    'no': accountController.closedAuctionsCount.value.toString()
                  }),
                  noAuctionsMessage: tr('profile.closed_auctions.no_auctions'),
                  initialAuctionsCount:
                      accountController.closedAuctionsCount.value,
                ),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
      ],
    );
  }
}
