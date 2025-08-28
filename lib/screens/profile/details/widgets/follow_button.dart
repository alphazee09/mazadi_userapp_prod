import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/controllers/flash.dart';
import '../../../../core/controllers/followers.dart';
import '../../../../core/models/account.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/common/simple_button.dart';
import 'following_info_dialog.dart';

class FollowAccountButton extends StatefulWidget {
  final Rx<Account> account;

  const FollowAccountButton({
    super.key,
    required this.account,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FollowAccountButton createState() => _FollowAccountButton();
}

class _FollowAccountButton extends State<FollowAccountButton> {
  final accountController = Get.find<AccountController>();
  final followersController = Get.find<FollowersController>();
  final flashController = Get.find<FlashController>();

  bool _followInProgress = false;

  void showSuccessFollowDialog() {
    var alert = FollowingAccountInfoDialog(
      account: widget.account.value,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> handleFollow() async {
    if (_followInProgress) {
      return;
    }

    if (mounted) {
      setState(() {
        _followInProgress = true;
      });
    }

    try {
      if (accountController.isFollowingAccount(widget.account.value.id)) {
        var unfollowSuccess =
            await followersController.unfollow(widget.account.value.id);

        if (unfollowSuccess) {
          widget.account.value.followersCount =
              widget.account.value.followersCount! - 1;

          flashController.showMessageFlash(
            tr('profile.unfollow_success', namedArgs: {
              'name': GenericUtils.generateNameForAccount(
                widget.account.value,
              ),
            }),
            FlashMessageType.success,
          );
        } else {
          flashController.showMessageFlash(
            tr('profile.could_not_unfollow', namedArgs: {
              'name': GenericUtils.generateNameForAccount(
                widget.account.value,
              ),
            }),
          );
        }
      } else {
        var followSuccess =
            await followersController.follow(widget.account.value.id);
        if (followSuccess) {
          widget.account.value.followersCount =
              widget.account.value.followersCount! + 1;

          showSuccessFollowDialog();
        } else {
          flashController.showMessageFlash(
            tr('profile.could_not_follow', namedArgs: {
              'name': GenericUtils.generateNameForAccount(
                widget.account.value,
              ),
            }),
          );
        }
      }

      widget.account.refresh();

      if (mounted) {
        setState(() {
          _followInProgress = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _followInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleButton(
      onPressed: () {
        handleFollow();
      },
      height: 42,
      isLoading: _followInProgress,
      borderColor:
          Theme.of(context).extension<CustomThemeFields>()!.fontColor_3,
      background:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svg/notification.svg',
            height: 24,
            semanticsLabel: 'Notification',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
          Container(
            width: 8,
          ),
          Obx(
            () => Text(
                    accountController
                            .isFollowingAccount(widget.account.value.id)
                        ? 'profile.unfollow'
                        : 'profile.follow',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller)
                .tr(),
          )
        ],
      ),
    );
  }
}
