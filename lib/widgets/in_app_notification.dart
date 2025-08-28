import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../core/controllers/notifications.dart';
import '../core/models/notification.dart';

// ignore: must_be_immutable
class InAppNotification extends StatelessWidget {
  mazadiNotification notification;
  Function close;

  InAppNotification({
    super.key,
    required this.notification,
    required this.close,
  });

  final notificationController = Get.find<NotificationsController>();

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).extension<CustomThemeFields>()!.background_3,
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            offset: const Offset(0.5, 3), //(x,y)
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsetsDirectional.only(end: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icons/notifications/${notificationController.generateIconForNotification(notification)}.svg',
                    height: 40,
                    semanticsLabel: 'Notification',
                  ),
                  Container(
                    width: 16,
                  ),
                  Expanded(
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title[currentLanguage]!,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          Container(
                            height: 4,
                          ),
                          Text(
                            notification.description[currentLanguage]!,
                            maxLines: 3,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                child: IconButton(
                  splashRadius: 24,
                  iconSize: 14,
                  onPressed: () {
                    close();
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/svg/close.svg',
                    semanticsLabel: 'Close',
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
