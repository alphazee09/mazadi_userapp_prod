import 'dart:async';

import 'package:mazadi/core/controllers/account.dart';
import 'package:mazadi/core/models/notification.dart';
import 'package:mazadi/core/navigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flash/flash_helper.dart';

import '../../screens/auction-details/index.dart';
import '../../screens/chat/channel.dart';
import '../../screens/profile/details/index.dart';
import '../../widgets/in_app_notification.dart';
import '../repositories/notification.dart';
import 'chat.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class NotificationsController extends GetxController {
  final accountController = Get.find<AccountController>();
  final chatController = Get.find<ChatController>();
  final navigationService = Get.find<NavigatorService>();
  final notificationRepository = Get.find<NotificationRepository>();

  final unreadNotificationsCount = 0.obs;
  final notifications = RxList<mazadiNotification>();
  Rx<bool> hasNotificationsPermission = false.obs;

  StreamSubscription<String>? _fcmTokenSubscription;
  StreamSubscription<RemoteMessage>? _firebaseMessageSub;
  StreamSubscription<RemoteMessage>? _firebaseMessageOpenedAppSub;

  @override
  void onClose() {
    _fcmTokenSubscription?.cancel();
    _firebaseMessageSub?.cancel();
    _firebaseMessageOpenedAppSub?.cancel();
    notifications.clear();
    super.onClose();
  }

  Future<int> getUnreadNotificationsCount() async {
    return await notificationRepository.getUnreadNotificationsCount();
  }

  Future<List<mazadiNotification>> loadForAccountPaginated([
    int page = 0,
    int perPage = 20,
  ]) async {
    return await notificationRepository.loadForAccount(page, perPage);
  }

  Future<List<mazadiNotification>> loadForAccount() async {
    var notificationsLoadPromise = notificationRepository.loadForAccount();
    var unreadNotificationsCountPromise =
        notificationRepository.getUnreadNotificationsCount();

    var userNotifications = await notificationsLoadPromise;
    unreadNotificationsCount.value = await unreadNotificationsCountPromise;

    notifications.clear();
    notifications.addAll(userNotifications);
    return userNotifications;
  }

  bool hasUnreadNotifications() {
    return notifications.any((element) => !element.read) ||
        unreadNotificationsCount.value > 0;
  }

  void setUnreadNotificationsCount(int value) {
    unreadNotificationsCount.value = value;
    unreadNotificationsCount.refresh();
  }

  Future<bool> markAllAsSeen() async {
    var marked = await notificationRepository.markAllAsRead();
    if (marked) {
      for (var element in notifications) {
        element.read = true;
      }

      unreadNotificationsCount.value = 0;
      unreadNotificationsCount.refresh();
      notifications.refresh();
    }
    return marked;
  }

  Future askNotificationsPermission() async {
    var messaging = FirebaseMessaging.instance;

    try {
      var settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        hasNotificationsPermission.value = false;
        return false;
      }

      hasNotificationsPermission.value = true;
      _fcmTokenSubscription = messaging.onTokenRefresh.listen((fcmToken) {
        accountController.saveFCMToken(fcmToken);
      });

      await messaging.deleteToken();
      var fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        accountController.saveFCMToken(fcmToken);
      }
      return true;
    } catch (error) {
      hasNotificationsPermission.value = false;
      print('Could not ask for notifications permission: $error');
      return false;
    }
  }

  Future initializeFirebase() async {
    try {
      await askNotificationsPermission();

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      _firebaseMessageSub =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var accountId = message.data['accountId'];
        if (accountId == null ||
            accountId != accountController.account.value.id) {
          return;
        }

        var notificationType = NotificationType.values.firstWhere(
          // ignore: prefer_interpolation_to_compose_strings
          (e) => e.toString() == 'NotificationType.' + message.data['type'],
        );

        var notificationId = message.data['notificationId'];
        var alreadyExists = notifications.any(
          (element) => element.id == notificationId,
        );

        if (alreadyExists) {
          return;
        }

        var currentLanguage =
            accountController.account.value.meta?.appLanguage ?? 'en';
        // Parse the message received
        var notification = mazadiNotification(
          id: notificationId,
          type: notificationType,
          entityId: getEntityIdFromNotificationData(message.data),
          read: false,
          title: {currentLanguage: message.notification!.title!},
          description: {currentLanguage: message.notification!.body!},
        );

        notifications.insert(0, notification);
        unreadNotificationsCount.value++;

        unreadNotificationsCount.refresh();
        notifications.refresh();

        // ignore: use_build_context_synchronously
        navigator!.context.showFlash(
          duration: const Duration(seconds: 5),
          builder: (context, controller) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                controller.dismiss();
                handleRemoteMessageTap(message);
              },
              child: FlashBar(
                controller: controller,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.top,
                backgroundColor: Colors.transparent,
                content: InAppNotification(
                  notification: notification,
                  close: () {
                    controller.dismiss();
                  },
                ),
              ),
            );
          },
        );
      });

      _firebaseMessageOpenedAppSub =
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        var notificationType = NotificationType.values.firstWhere(
          // ignore: prefer_interpolation_to_compose_strings
          (e) => e.toString() == 'NotificationType.' + message.data['type'],
        );

        var currentLanguage =
            accountController.account.value.meta?.appLanguage ?? 'en';

        var notification = mazadiNotification(
          id: uuid.v4(),
          type: notificationType,
          entityId: getEntityIdFromNotificationData(message.data),
          title: {currentLanguage: message.notification!.title!},
          read: true,
          description: {currentLanguage: message.notification!.body!},
        );

        notifications.insert(0, notification);
        notifications.refresh();

        handleRemoteMessageTap(message);
      });
    } catch (error) {
      print('Error initializing firebase: $error');
    }
  }

  void navigateToAuction(String auctionId) {
    navigationService.push(
      AuctionDetailsScreen(
        auctionId: auctionId,
        assetsLen: 0,
      ),
    );
  }

  void navigateToAccount(String accountId) {
    navigationService.push(
      ProfileDetailsScreen(
        accountId: accountId,
      ),
    );
  }

  void navigateToChatGroup(String chatGroupId) async {
    var chatGroup = chatController.chatGroups
        .firstWhereOrNull((element) => element.id == chatGroupId);
    if (chatGroup == null) {
      await chatController.loadChatGroups();
      chatGroup = chatController.chatGroups
          .firstWhereOrNull((element) => element.id == chatGroupId);

      if (chatGroup == null) {
        return;
      }
    }

    navigationService.push(
      ChatChannel(
        chatGroup: chatGroup,
      ),
      NavigationStyle.SharedAxis,
    );
  }

  void navigateToChatGroupFromMsg(Map<String, dynamic> data) {
    var chatGroupId = data['chatGroupId'];
    if (chatGroupId == null) {
      return;
    }

    navigateToChatGroup(chatGroupId);
  }

  void navigateToAuctionFromMsg(Map<String, dynamic> data) {
    var auctionId = data['auctionId'];
    if (auctionId == null) {
      return;
    }
    navigateToAuction(auctionId);
  }

  String getEntityIdFromNotificationData(dynamic data) {
    if (data['type'] == 'NEW_MESSAGE') {
      return data['chatGroupId'];
    }

    if (data['type'] == 'NEW_FOLLOWER') {
      return data['accountId'];
    }

    return data['auctionId'];
  }

  void handleRemoteMessageTap(RemoteMessage message) {
    try {
      if (message.data['type'] == null) {
        return;
      }

      if (message.data['notificationId'] != null) {
        notificationRepository.markAsRead(message.data['notificationId']);

        var notification = notifications.firstWhereOrNull(
          (element) => element.id == message.data['notificationId'],
        );

        if (notification != null) {
          notification.read = true;
          unreadNotificationsCount.value -= 1;
          unreadNotificationsCount.refresh();
          notifications.refresh();
        }
      }

      switch (message.data['type']) {
        case 'BID_WAS_SEEN':
        case 'MY_AUCTION_STARTED':
        case 'AUCTION_FROM_FAVOURITES_STARTED':
        case 'SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION':
        case 'AUCTION_FROM_FAVOURITES_HAS_BID':
        case 'AUCTION_ADDED_TO_FAVOURITES':
        case 'FAVOURITE_AUCTION_PRICE_CHANGE':
        case 'NEW_BID_ON_AUCTION':
        case 'BID_REMOVED_ON_AUCTION':
        case 'NEW_AUCTION_FROM_FOLLOWING':
        case 'BID_ACCEPTED_ON_AUCTION':
        case 'BID_REJECTED_ON_AUCTION':
        case 'AUCTION_UPDATED':
          navigateToAuctionFromMsg(message.data);

        case 'NEW_FOLLOWER':
          navigateToAccount(message.data['accountId']);

        case 'NEW_MESSAGE':
          navigateToChatGroupFromMsg(message.data);

        case 'FEEDBACK_RECEIVED':
          navigationService.push(
            ProfileDetailsScreen(
              accountId: accountController.account.value.id,
            ),
          );
        case 'SYSTEM':
          break;
        default:
          print('default');
      }
    } catch (err) {
      print('There was an error in opening the message: $err');
    }
  }

  void handleNotificationTap(mazadiNotification notification) {
    try {
      if (!notification.read) {
        notificationRepository.markAsRead(notification.id);
        notification.read = true;
        unreadNotificationsCount.value -= 1;

        unreadNotificationsCount.refresh();
        notifications.refresh();
      }

      switch (notification.type) {
        case NotificationType.MY_AUCTION_STARTED:
        case NotificationType.AUCTION_FROM_FAVOURITES_STARTED:
        case NotificationType.BID_WAS_SEEN:
        case NotificationType.SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION:
        case NotificationType.AUCTION_ADDED_TO_FAVOURITES:
        case NotificationType.FAVOURITE_AUCTION_PRICE_CHANGE:
        case NotificationType.NEW_BID_ON_AUCTION:
        case NotificationType.BID_REMOVED_ON_AUCTION:
        case NotificationType.BID_ACCEPTED_ON_AUCTION:
        case NotificationType.BID_REJECTED_ON_AUCTION:
        case NotificationType.NEW_AUCTION_FROM_FOLLOWING:
        case NotificationType.AUCTION_FROM_FAVOURITES_HAS_BID:
          navigateToAuction(notification.entityId);

        case NotificationType.NEW_MESSAGE:
          navigateToChatGroup(notification.entityId);

        case NotificationType.NEW_FOLLOWER:
          navigateToAccount(notification.entityId);

        case NotificationType.SYSTEM:
          break;

        case NotificationType.REVIEW_RECEIVED:
          navigationService.push(
            ProfileDetailsScreen(
              accountId: accountController.account.value.id,
            ),
          );

        default:
          print('default notification tap');
      }
    } catch (error) {
      print('There was an error in opening the message$error');
    }
  }

  String generateIconForNotification(mazadiNotification notification) {
    switch (notification.type) {
      case NotificationType.AUCTION_ADDED_TO_FAVOURITES:
        return 'favourite';
      case NotificationType.BID_WAS_SEEN:
        return 'binoculars';
      case NotificationType.AUCTION_FROM_FAVOURITES_STARTED:
      case NotificationType.MY_AUCTION_STARTED:
      case NotificationType.NEW_BID_ON_AUCTION:
      case NotificationType.AUCTION_FROM_FAVOURITES_HAS_BID:
        return 'shuttle';
      case NotificationType.SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION:
        return 'pie-chart';
      case NotificationType.FAVOURITE_AUCTION_PRICE_CHANGE:
        return 'price-change';
      case NotificationType.BID_REMOVED_ON_AUCTION:
      case NotificationType.BID_REJECTED_ON_AUCTION:
        return 'lose-bid';
      case NotificationType.AUCTION_UPDATED:
      case NotificationType.NEW_AUCTION_FROM_FOLLOWING:
        return 'auction';
      case NotificationType.BID_ACCEPTED_ON_AUCTION:
        return 'win-bid';
      case NotificationType.NEW_MESSAGE:
        return 'message';
      case NotificationType.REVIEW_RECEIVED:
        return 'feedback';
      case NotificationType.SYSTEM:
      case NotificationType.NEW_FOLLOWER:
        return 'follower';
    }
  }

  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId ?? ''}");
  }
}
