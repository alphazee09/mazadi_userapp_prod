import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/controllers/main.dart';
import '../../../../core/models/account.dart';
import '../../../auction-details/dialogs/report.dart';
import '../dialogs/block_unblock.dart';

class ProfileDetailsMoreActionsPopup extends StatelessWidget {
  final mainController = Get.find<MainController>();
  final accountController = Get.find<AccountController>();

  final Rx<Account> account;

  ProfileDetailsMoreActionsPopup({
    super.key,
    required this.account,
  });

  Future<bool> createAuctionReport(String reason, String description) async {
    return await mainController.createReport(
      'account',
      account.value.id,
      reason,
      description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_2,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(29)),
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                'assets/icons/svg/more.svg',
                height: 24,
                semanticsLabel: 'Menu',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onSelected: (value) async {
              if (value == 'report-account') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReportDialogContent(
                      entityName: 'account',
                      onConfirm: (String reason, String description) {
                        return createAuctionReport(reason, description);
                      },
                    );
                  },
                );
              }
              if (value == 'block-account') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BlockOrUnblockAccountDialog(
                      account: account.value,
                      isBlocked:
                          accountController.account.value.blockedAccounts !=
                                  null &&
                              accountController.account.value.blockedAccounts!
                                  .contains(account.value.id),
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 'report-account',
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/svg/report.svg',
                          height: 24,
                          semanticsLabel: 'Report',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                            BlendMode.srcIn,
                          ),
                        ),
                        Container(
                          width: 8,
                        ),
                        Text(
                          'profile.report',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                        ).tr(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block-account',
                    child: Row(
                      children: [
                        Text(
                          accountController.account.value.blockedAccounts!
                                  .contains(account.value.id)
                              ? 'profile.block.unblock_2'
                              : 'profile.block.block',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                        ).tr(),
                      ],
                    ),
                  ),
                ]),
      ),
    );
  }
}
