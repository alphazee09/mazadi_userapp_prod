import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/navigator.dart';
import '../../../widgets/common/section_heading.dart';
import '../settings_item.dart';
import '../widgets/auctions_list.dart';

class ProfileBidsSection extends StatelessWidget {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    var yourAuctions = tr('profile.your_bids');

    return Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        Obx(
          () => SectionHeading(
            title: yourAuctions,
            titleSufix: '(${accountController.accountBidsCount.value})',
            withMore: false,
          ),
        ),
        Obx(
          () => SettingsItem(
            title: 'profile.all_your_bids.title',
            count: accountController.accountBidsCount.value,
            onTap: () {
              navigatorService.push(
                ProfileAuctionsListByStatus(
                  status: 'bid-all',
                  title: Text(
                    'profile.all_your_bids.all_bids',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                    maxLines: 2,
                  ).tr(namedArgs: {
                    'no': accountController.accountBidsCount.value.toString()
                  }),
                  noAuctionsMessage: tr('profile.all_your_bids.no_bids'),
                  initialAuctionsCount:
                      accountController.accountBidsCount.value,
                ),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
        Obx(
          () => SettingsItem(
            title: 'profile.accepted_bids.title',
            count: accountController.acceptedBidsCount.value,
            onTap: () {
              navigatorService.push(
                ProfileAuctionsListByStatus(
                  status: 'bid-accepted',
                  title: Text(
                    'profile.accepted_bids.accepted_bids',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                    maxLines: 2,
                  ).tr(namedArgs: {
                    'no': accountController.acceptedBidsCount.value.toString()
                  }),
                  noAuctionsMessage: tr('profile.accepted_bids.no_bids'),
                  initialAuctionsCount:
                      accountController.acceptedBidsCount.value,
                ),
                NavigationStyle.SharedAxis,
              );
            },
          ),
        ),
        Obx(
          () => SettingsItem(
            title: 'profile.rejected_bids.title',
            count: accountController.rejectedBidsCount.value,
            onTap: () {
              navigatorService.push(
                ProfileAuctionsListByStatus(
                  status: 'bid-rejected',
                  title: Text(
                    'profile.rejected_bids.rejected_bids',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                    maxLines: 2,
                  ).tr(namedArgs: {
                    'no': accountController.rejectedBidsCount.value.toString()
                  }),
                  noAuctionsMessage: tr('profile.rejected_bids.no_bids'),
                  initialAuctionsCount:
                      accountController.rejectedBidsCount.value,
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
