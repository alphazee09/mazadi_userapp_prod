import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/models/account.dart';
import '../../../../theme/colors.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/common/simple_button.dart';

class FollowingAccountInfoDialog extends StatelessWidget {
  final Account account;

  const FollowingAccountInfoDialog({
    super.key,
    required this.account,
  });

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
              'profile.congratulations_follow',
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
                    'profile.you_are_now_following',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ).tr(namedArgs: {
                    'name': GenericUtils.generateNameForAccount(
                      account,
                    ),
                  }),
                ],
              ),
            ),
          ],
        )),
      ),
      actions: [
        Container(),
        SimpleButton(
          background: Theme.of(context).extension<CustomThemeFields>()!.action,
          onPressed: () {
            Navigator.pop(context);
          },
          height: 42,
          width: 120,
          child: Text(
            'generic.done',
            style: Theme.of(context)
                .extension<CustomThemeFields>()!
                .smaller
                .copyWith(
                  color: DarkColors.font_1,
                ),
          ).tr(),
        ),
      ],
    );
  }
}
