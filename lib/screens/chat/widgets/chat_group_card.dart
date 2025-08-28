import 'package:mazadi/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/chat.dart';
import '../../../core/models/account.dart';
import '../../../core/models/chat_group.dart';
import '../../../core/navigator.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/user_avatar.dart';
import '../channel.dart';

class ChatGroupCard extends StatelessWidget {
  final ChatGroup group;

  ChatGroupCard({
    super.key,
    required this.group,
  });

  final accountController = Get.find<AccountController>();
  final chatController = Get.find<ChatController>();
  final navigationService = Get.find<NavigatorService>();

  void _goToChat(ChatGroup chatGroup) {
    navigationService.push(
      ChatChannel(
        chatGroup: chatGroup,
      ),
      NavigationStyle.SharedAxis,
    );
  }

  Widget renderLastMessageInfo(BuildContext context, Account accountToDisplay) {
    var currentLanguage = context.locale.toString();

    return Obx(() {
      var messages = chatController.chatMessages[group.id] ?? [];
      var lastMessage = messages.isNotEmpty ? messages.last : null;

      return Row(
        children: [
          UserAvatar(
            account: accountToDisplay,
            size: 40,
          ),
          Container(
            width: 16,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        GenericUtils.generateNameForAccount(accountToDisplay),
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller
                            .copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 4,
                ),
                lastMessage == null
                    ? Container()
                    : Row(
                        children: [
                          Flexible(
                            child: Text(
                              lastMessage.value.type == 'text'
                                  ? lastMessage.value.message ?? ''
                                  : tr('chat.chat_images'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smallest
                                  .copyWith(
                                    color: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .fontColor_3,
                                  ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                lastMessage == null
                    ? Container()
                    : Text(
                        GenericUtils.getFormattedDate(
                          lastMessage.value.createdAt,
                          currentLanguage,
                        ),
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smallest
                            .copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                group.unreadMessages != null && group.unreadMessages! > 0
                    ? Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .action,
                        ),
                        margin: const EdgeInsets.only(top: 4),
                        child: Center(
                          child: Text(
                            group.unreadMessages.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smallest
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: DarkColors.font_1,
                                ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var accountToDisplay =
        group.firstAccountId == accountController.account.value.id
            ? group.secondAccount
            : group.firstAccount;

    if (accountToDisplay == null) {
      return Container();
    }

    return Container(
      margin: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).extension<CustomThemeFields>()!.separator,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: ClipRRect(
              child: Container(
                height: 150,
                width: Get.width,
                decoration: accountToDisplay.picture.isNotEmpty
                    ? BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.05),
                            BlendMode.dstATop,
                          ),
                          image: CachedNetworkImageProvider(
                            accountToDisplay.picture,
                          ),
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
                child: null,
              ),
            ),
          ),
          IntrinsicHeight(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _goToChat(group);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      renderLastMessageInfo(context, accountToDisplay),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
