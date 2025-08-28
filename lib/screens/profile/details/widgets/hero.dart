import 'package:mazadi/core/controllers/flash.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/controllers/chat.dart';
import '../../../../core/models/account.dart';
import '../../../../core/navigator.dart';
import '../../../../widgets/common/account_status_circle.dart';
import '../../../../widgets/common/image_error.dart';
import '../../../../widgets/common/simple_button.dart';
import '../../../chat/channel.dart';
import '../../update/index.dart';
import 'follow_button.dart';
import 'follow_stats.dart';

class ProfileDetailsHero extends StatefulWidget {
  final Rx<Account> account;
  final Function reloadAccount;

  ProfileDetailsHero({
    super.key,
    required this.account,
    required this.reloadAccount,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileDetailsHero createState() => _ProfileDetailsHero();
}

class _ProfileDetailsHero extends State<ProfileDetailsHero> {
  final chatController = Get.find<ChatController>();
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();
  final flashController = Get.find<FlashController>();

  var _loadingDirectChat = false;

  Future<void> openDirectChatWithAccount() async {
    if (_loadingDirectChat) {
      return;
    }

    setState(() {
      _loadingDirectChat = true;
    });

    try {
      var chatGroup =
          await chatController.getChatGroupWithAccount(widget.account.value.id);
      if (chatGroup == null) {
        flashController.showMessageFlash(tr('profile.cannot_load_chat_group'));
        return;
      }

      navigatorService.push(
        ChatChannel(chatGroup: chatGroup),
        NavigationStyle.SharedAxis,
      );
    } catch (error) {
      flashController.showMessageFlash(tr('profile.cannot_load_chat_group'));
    } finally {
      if (mounted) {
        setState(() {
          _loadingDirectChat = false;
        });
      }
    }
  }

  Widget _renderAccountActionButton(BuildContext context) {
    if (accountController.account.value.id != widget.account.value.id) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: SimpleButton(
                filled: true,
                height: 42,
                borderColor: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .fontColor_3,
                background: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2,
                isLoading: _loadingDirectChat,
                onPressed: () {
                  openDirectChatWithAccount();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svg/chat.svg',
                      height: 18,
                      semanticsLabel: 'Send message',
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
                    Flexible(
                      child: Text('profile.send_message',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller)
                          .tr(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: SimpleButton(
              filled: true,
              height: 42,
              borderColor:
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_3,
              background: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_2,
              onPressed: () async {
                var updated = await navigatorService.push(
                  const UpdateProfileScreen(),
                  NavigationStyle.SharedAxis,
                );

                if (updated == true) {
                  widget.reloadAccount();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/svg/edit.svg',
                    height: 18,
                    semanticsLabel: 'Edit',
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
                  Flexible(
                    child: Text(
                      'profile.update_account',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderHeroForAccount(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 77),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: ClipOval(
                            child: widget.account.value.picture == ''
                                ? SvgPicture.asset(
                                    'assets/icons/svg/user.svg',
                                    semanticsLabel: 'User picture',
                                  )
                                : CachedNetworkImage(
                                    imageUrl: widget.account.value.picture,
                                    alignment: Alignment.center,
                                    fit: BoxFit.cover,
                                    maxWidthDiskCache: Get.width.toInt(),
                                    maxHeightDiskCache: Get.height.toInt(),
                                    errorWidget: (context, url, error) =>
                                        const ImageErrorWidget(),
                                  ),
                          ),
                        ),
                        AccountStatusCircle(accountId: widget.account.value.id)
                      ],
                    ),
                    AccountFollowStats(
                      account: widget.account,
                    )
                  ],
                ),
                Container(
                  height: 16,
                ),
                Row(
                  children: [
                    accountController.account.value.id !=
                            widget.account.value.id
                        ? Expanded(
                            child: FollowAccountButton(
                              account: widget.account,
                            ),
                          )
                        : Container(),
                    Container(
                      width: 8,
                    ),
                    Expanded(
                      child: _renderAccountActionButton(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _renderHeroForAccount(context),
        ),
      ),
    );
  }
}
