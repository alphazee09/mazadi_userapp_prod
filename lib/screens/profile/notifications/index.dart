import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/controllers/notifications.dart';
import '../../../theme/colors.dart';
import '../../../widgets/common/section_heading.dart';
import '../../../widgets/common/simple_button.dart';
import '../../../widgets/simple_app_bar.dart';
import 'item.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationsSettingsScreen createState() => _NotificationsSettingsScreen();
}

class _NotificationsSettingsScreen extends State<NotificationsSettingsScreen> {
  final accountController = Get.find<AccountController>();
  final notificationController = Get.find<NotificationsController>();
  final flashController = Get.find<FlashController>();

  bool _authorizationGranted = false;
  bool _askingPermission = false;

  @override
  void initState() {
    super.initState();

    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    var messaging = FirebaseMessaging.instance;
    var settings = await messaging.getNotificationSettings();

    var authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    setState(() {
      _authorizationGranted = authorized;
    });
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _askForPermission() async {
    if (_askingPermission) {
      return;
    }

    setState(() {
      _askingPermission = true;
    });

    var given = await notificationController.askNotificationsPermission();
    if (given) {
      flashController.showMessageFlash(
        tr('profile.notifications.permission_granted'),
        FlashMessageType.success,
      );
    } else {
      flashController.showMessageFlash(
        tr('profile.notifications.permission_rejected'),
      );
    }

    setState(() {
      _authorizationGranted = given;
      _askingPermission = false;
    });
  }

  Widget _renderGivePermissionWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: Get.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[500],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'profile.notifications.permission_not_granted',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ).tr(),
              ),
              Container(
                width: 8,
              ),
              SvgPicture.asset(
                'assets/icons/svg/profile/notification-colored.svg',
                height: 60,
                semanticsLabel: 'Notifications',
              ),
            ],
          ),
          Container(
            height: 8,
          ),
          Text(
            'profile.notifications.permission_not_granted_msg',
            style: Theme.of(context)
                .extension<CustomThemeFields>()!
                .smaller
                .copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ).tr(),
          Container(
            height: 16,
          ),
          IntrinsicWidth(
            child: SimpleButton(
              width: Get.width,
              onPressed: () {
                _askForPermission();
              },
              isLoading: _askingPermission,
              background:
                  Theme.of(context).extension<CustomThemeFields>()!.action,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'profile.notifications.give_permission',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(
                            color: DarkColors.font_1,
                            fontWeight: FontWeight.w500,
                          ),
                    ).tr(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget renderNotificationItems() {
    return Column(
      children: [
        SectionHeading(
          title: tr('profile.notifications.auctions'),
          withMore: false,
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.auction_updated_title'),
          description: tr('profile.notifications.auction_updated_descr'),
          value: accountController
              .account.value.allowedNotifications!.AUCTION_UPDATED,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.AUCTION_UPDATED = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.new_auction_from_followed'),
          description:
              tr('profile.notifications.new_auction_from_followed_descr'),
          value: accountController
              .account.value.allowedNotifications!.NEW_AUCTION_FROM_FOLLOWING,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.NEW_AUCTION_FROM_FOLLOWING = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.my_auction_started'),
          description: tr('profile.notifications.my_auction_started_descr'),
          value: accountController
              .account.value.allowedNotifications!.MY_AUCTION_STARTED,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.MY_AUCTION_STARTED = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.fav_auction_started'),
          description: tr('profile.notifications.fav_auction_started_descr'),
          value: accountController.account.value.allowedNotifications!
              .AUCTION_FROM_FAVOURITES_STARTED,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.AUCTION_FROM_FAVOURITES_STARTED = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        SectionHeading(
          title: tr('profile.notifications.bids'),
          withMore: false,
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.bid_added_title'),
          description: tr('profile.notifications.bid_added_descr'),
          value: accountController
              .account.value.allowedNotifications!.NEW_BID_ON_AUCTION,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.NEW_BID_ON_AUCTION = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.bid_removed_title'),
          description: tr('profile.notifications.bid_removed_descr'),
          value: accountController
              .account.value.allowedNotifications!.BID_REMOVED_ON_AUCTION,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.BID_REMOVED_ON_AUCTION = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.bid_accepted_title'),
          description: tr('profile.notifications.bid_accepted_descr'),
          value: accountController
              .account.value.allowedNotifications!.BID_ACCEPTED_ON_AUCTION,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.BID_ACCEPTED_ON_AUCTION = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.bid_rejected_title'),
          description: tr('profile.notifications.bid_rejected_descr'),
          value: accountController
              .account.value.allowedNotifications!.BID_REJECTED_ON_AUCTION,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.BID_REJECTED_ON_AUCTION = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.bid_seen'),
          description: tr('profile.notifications.bid_seen_descr'),
          value: accountController
              .account.value.allowedNotifications!.BID_WAS_SEEN,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.BID_WAS_SEEN = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.same_auction_bid'),
          description: tr('profile.notifications.same_auction_bid_descr'),
          value: accountController.account.value.allowedNotifications!
              .SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        SectionHeading(
          title: tr('profile.notifications.favourites'),
          withMore: false,
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.auction_added_to_favourites'),
          description:
              tr('profile.notifications.auction_added_to_favourites_descr'),
          value: accountController
              .account.value.allowedNotifications!.AUCTION_ADDED_TO_FAVOURITES,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.AUCTION_ADDED_TO_FAVOURITES = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.bid_on_favourites_auction'),
          description:
              tr('profile.notifications.bid_on_favourites_auction_descr'),
          value: accountController.account.value.allowedNotifications!
              .AUCTION_FROM_FAVOURITES_HAS_BID,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.AUCTION_FROM_FAVOURITES_HAS_BID = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.favourite_price_change'),
          description: tr('profile.notifications.favourite_price_change_descr'),
          value: accountController.account.value.allowedNotifications!
              .FAVOURITE_AUCTION_PRICE_CHANGE,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.FAVOURITE_AUCTION_PRICE_CHANGE = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        SectionHeading(
          title: tr('profile.notifications.generic'),
          withMore: false,
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.review_title'),
          description: tr('profile.notifications.review_descr'),
          value: accountController
              .account.value.allowedNotifications!.REVIEW_RECEIVED,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.REVIEW_RECEIVED = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.new_message_title'),
          description: tr('profile.notifications.new_message_descr'),
          value:
              accountController.account.value.allowedNotifications!.NEW_MESSAGE,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.NEW_MESSAGE = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
        AccountAlloweNotificationItem(
          title: tr('profile.notifications.new_follower'),
          description: tr('profile.notifications.new_follower_descr'),
          value: accountController
              .account.value.allowedNotifications!.NEW_FOLLOWER,
          onChange: (value) {
            var allowedNotif =
                accountController.account.value.allowedNotifications!;
            allowedNotif.NEW_FOLLOWER = value;

            EasyDebounce.debounce(
              'account-allowed-notifications',
              const Duration(milliseconds: 300),
              () => accountController
                  .updateAccountAllowedNotifications(allowedNotif),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: SafeArea(
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          resizeToAvoidBottomInset: true,
          appBar: SimpleAppBar(
              onBack: goBack,
              withSearch: false,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      'profile.notifications.notifications',
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title,
                    ).tr(),
                  ),
                ],
              )),
          body: SingleChildScrollView(
            child: Obx(
              () => Column(
                children: [
                  Container(
                    height: 30,
                  ),
                  _authorizationGranted
                      ? Container()
                      : _renderGivePermissionWidget(),
                  renderNotificationItems(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
