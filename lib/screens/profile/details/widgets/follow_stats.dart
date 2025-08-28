import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../../core/models/account.dart';
import 'followers_following_list.dart';

class AccountFollowStats extends StatelessWidget {
  final Rx<Account> account;

  const AccountFollowStats({
    super.key,
    required this.account,
  });

  void openFollowingFollowersSheet(BuildContext context,
      [bool isFollowing = false]) {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: AccountFollowersOrFollowingList(
              account: account.value,
              isFollowing: isFollowing,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTap(
          onPressed: () {
            openFollowingFollowersSheet(context);
          },
          child: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Obx(
                  () => Text(
                    account.value.followersCount.toString(),
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .title
                        .copyWith(),
                  ),
                ),
                Container(
                  height: 4,
                ),
                Text(
                  'profile.followers',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ],
            ),
          ),
        ),
        Container(
          width: 16,
        ),
        ScaleTap(
          onPressed: () {
            openFollowingFollowersSheet(context, true);
          },
          child: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Obx(
                  () => Text(
                    account.value.followingCount.toString(),
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .title
                        .copyWith(),
                  ),
                ),
                Container(
                  height: 4,
                ),
                Text(
                  'profile.following',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
