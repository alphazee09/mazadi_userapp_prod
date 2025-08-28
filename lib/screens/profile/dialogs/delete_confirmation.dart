import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../widgets/common/simple_button.dart';

class DeleteAccountConfirmationDialog extends StatefulWidget {
  final Function onSubmit;

  const DeleteAccountConfirmationDialog({super.key, required this.onSubmit});

  @override
  // ignore: library_private_types_in_public_api
  _ReactivateAuctionDialog createState() => _ReactivateAuctionDialog();
}

class _ReactivateAuctionDialog extends State<DeleteAccountConfirmationDialog> {
  bool _delteInProgress = false;

  Future<void> handleDelete() async {
    if (mounted) {
      setState(() {
        _delteInProgress = true;
      });
    }

    await widget.onSubmit();

    if (mounted) {
      setState(() {
        _delteInProgress = false;
      });
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
              'profile.update.delete_account',
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
      content: IntrinsicHeight(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'profile.update.are_you_sure_to_delete',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
                Container(
                  height: 16,
                ),
                Text(
                  'profile.update.delete_account_details',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
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
                onPressed: () async {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                height: 42,
                width: 120,
                child: Text(
                  'generic.no',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: SimpleButton(
                isLoading: _delteInProgress,
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                onPressed: () async {
                  await handleDelete();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                height: 42,
                width: 120,
                child: Text(
                  'generic.yes',
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
        ),
      ],
    );
  }
}
