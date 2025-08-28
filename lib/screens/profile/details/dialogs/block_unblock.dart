import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/controllers/flash.dart';
import '../../../../core/models/account.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/common/simple_button.dart';

class BlockOrUnblockAccountDialog extends StatefulWidget {
  final Account account;
  final bool isBlocked;

  const BlockOrUnblockAccountDialog({
    super.key,
    required this.account,
    required this.isBlocked,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BlockAccountDialog createState() => _BlockAccountDialog();
}

class _BlockAccountDialog extends State<BlockOrUnblockAccountDialog> {
  final accountController = Get.find<AccountController>();
  final flashController = Get.find<FlashController>();

  bool _blockInProgress = false;

  Future<void> handleBlockOrUnblock() async {
    if (_blockInProgress) {
      return;
    }

    if (mounted) {
      setState(() {
        _blockInProgress = true;
      });
    }

    var result = widget.isBlocked
        ? await accountController.unblockAccount(widget.account.id)
        : await accountController.blockAccount(widget.account.id);

    if (mounted) {
      setState(() {
        _blockInProgress = false;
      });
    }

    if (result) {
      var accountName = GenericUtils.generateNameForAccount(widget.account);

      var msg = widget.isBlocked
          ? tr('profile.block.was_unblocked', namedArgs: {'name': accountName})
          : tr('profile.block.was_blocked', namedArgs: {'name': accountName});

      flashController.showMessageFlash(msg, FlashMessageType.success);

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      flashController.showMessageFlash(
        tr('generic.something_went_wrong'),
        FlashMessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      titlePadding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              widget.isBlocked == false
                  ? 'profile.block.title'
                  : 'profile.block.unblock',
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          IconButton(
            splashRadius: 24,
            iconSize: 14,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/svg/close.svg',
              semanticsLabel: 'Close',
              height: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          )
        ],
      ),
      content: SingleChildScrollView(
        child: IntrinsicHeight(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.isBlocked == false
                        ? 'profile.block.are_you_sure'
                        : 'profile.block.are_you_sure_to_unblock',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ).tr(),
                  widget.isBlocked == false
                      ? Container(
                          height: 16,
                        )
                      : Container(),
                  widget.isBlocked == false
                      ? Text(
                          'profile.block.blocked_cannot_bid',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                        ).tr()
                      : Container(),
                ],
              ),
            ),
          ],
        )),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                background: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_3,
                onPressed: () {
                  Navigator.pop(context);
                },
                height: 42,
                child: Text(
                  'generic.cancel',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 16,
            ),
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                onPressed: () {
                  handleBlockOrUnblock();
                },
                height: 42,
                isLoading: _blockInProgress,
                child: Text(
                  widget.isBlocked == true
                      ? 'profile.block.unblock_2'
                      : 'profile.block.block',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: DarkColors.font_1,
                      ),
                ).tr(),
              ),
            ),
          ],
        )
      ],
    );
  }
}
