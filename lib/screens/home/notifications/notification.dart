import 'package:mazadi/core/models/notification.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/notifications.dart';

class NotificationItem extends StatelessWidget {
  final mazadiNotification notification;
  final Function onTap;

  NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final notificationController = Get.find<NotificationsController>();

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();

    return Container(
      color: notification.read
          ? Theme.of(context).extension<CustomThemeFields>()!.background_1
          : Theme.of(context).extension<CustomThemeFields>()!.background_2,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onTap();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/notifications/${notificationController.generateIconForNotification(notification)}.svg',
                      height: 40,
                      semanticsLabel: 'dsa',
                    ),
                    Container(
                      width: 16,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          notification.createdAt == null
                              ? Container()
                              : Text(
                                  DateFormat('d MMM, h:mm a', currentLanguage)
                                      .format(notification.createdAt!),
                                  style: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .smallest,
                                ),
                          Container(
                            height: 8,
                          ),
                          Text(
                            notification.title[currentLanguage] ??
                                notification.title['en']!,
                            maxLines: 3,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            height: 4,
                          ),
                          Text(
                            notification.description[currentLanguage] ??
                                notification.description['en']!,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
            height: 8,
            indent: 16,
            endIndent: 16,
            thickness: 1,
          )
        ],
      ),
    );
  }
}
