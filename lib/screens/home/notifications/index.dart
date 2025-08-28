import 'package:mazadi/core/models/notification.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/controllers/flash.dart';
import '../../../core/controllers/notifications.dart';
import '../../../theme/colors.dart';
import '../../../widgets/common/action_button.dart';
import '../../../widgets/common/simple_button.dart';
import '../../../widgets/simple_app_bar.dart';
import 'notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationsScreen createState() => _NotificationsScreen();
}

class _NotificationsScreen extends State<NotificationsScreen> {
  final notificationsController = Get.find<NotificationsController>();
  final flashController = Get.find<FlashController>();

  final List<Rx<mazadiNotification>> loadedNotifications = [];
  static const _pageSize = 20;

  final PagingController<int, Obx> _pagingController =
      PagingController(firstPageKey: 0);

  int _unreadNotificationsCount = 0;
  bool _markAllAsSeenInProgress = false;

  @override
  void initState() {
    _loadUnreadNotificationsCount();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchNotifications(pageKey);
    });

    super.initState();
  }

  Future<void> _loadUnreadNotificationsCount() async {
    var unreadNotifications =
        await notificationsController.getUnreadNotificationsCount();

    if (mounted) {
      setState(() {
        _unreadNotificationsCount = unreadNotifications;
      });
    }

    notificationsController
        .setUnreadNotificationsCount(_unreadNotificationsCount);
  }

  Future<void> _fetchNotifications(int page) async {
    try {
      final newItems = await notificationsController.loadForAccountPaginated(
        page,
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(_computeList(newItems));
      } else {
        final nextPageKey = page + 1;
        _pagingController.appendPage(_computeList(newItems), nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  List<Obx> _computeList(List<mazadiNotification> notifications) {
    var obsNotifications = notifications.map((e) => e.obs).toList();
    loadedNotifications.addAll(obsNotifications);

    return [
      for (var not in obsNotifications)
        Obx(
          () => NotificationItem(
            notification: not.value,
            onTap: () {
              if (mounted) {
                setState(() {
                  _unreadNotificationsCount--;
                });
              }

              notificationsController.handleNotificationTap(not.value);
              not.value.read = true;
              not.refresh();
            },
          ),
        )
    ];
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _markAllAsRead() async {
    if (_markAllAsSeenInProgress ||
        notificationsController.unreadNotificationsCount.value == 0) {
      return;
    }

    setState(() {
      _markAllAsSeenInProgress = true;
    });

    var marked = await notificationsController.markAllAsSeen();

    if (marked) {
      flashController.showMessageFlash(
        tr('home.notifications.mark_as_seen_success'),
        FlashMessageType.success,
      );

      for (var element in loadedNotifications) {
        element.value.read = true;
        element.refresh();
      }
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = 0;
        });
      }
    } else {
      flashController
          .showMessageFlash(tr('home.notifications.mark_as_seen_error'));
    }
    setState(() {
      _markAllAsSeenInProgress = false;
    });
  }

  Widget _renderYouNeedToGivePermissions() {
    if (notificationsController.hasNotificationsPermission.value == true) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(
        left: 32.0,
        top: 24.0,
        right: 32.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue[500],
      ),
      child: Column(children: [
        Text(
          'permissions.need_to_request_notifications',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .extension<CustomThemeFields>()!
              .smaller
              .copyWith(
                fontWeight: FontWeight.w500,
              ),
        ).tr(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: ActionButton(
            filled: false,
            background:
                Theme.of(context).extension<CustomThemeFields>()!.action,
            child: Text(
              'permissions.open_settings',
              style: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smaller
                  .copyWith(
                    fontWeight: FontWeight.w500,
                    color: DarkColors.font_1,
                  ),
            ).tr(),
            onPressed: () async {
              await openAppSettings();
              notificationsController.askNotificationsPermission();
            },
          ),
        ),
      ]),
    );
  }

  Widget _renderNoNotificationsMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svg/profile/notification-colored.svg',
            height: 120,
            semanticsLabel: 'Notifications',
          ),
          Container(
            height: 32,
          ),
          Text(
            "home.notifications.dont_have_notifications",
            style: Theme.of(context).extension<CustomThemeFields>()!.title,
            textAlign: TextAlign.center,
          ).tr(),
          Container(
            height: 102,
          ),
        ],
      ),
    );
  }

  Widget _renderNotifications() {
    return PagedListView(
      scrollDirection: Axis.vertical,
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          return item as Widget;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
          onBack: goBack,
          withSearch: false,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'home.notifications.notifications',
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ).tr(),
              ),
              Flexible(
                child: _unreadNotificationsCount == 0
                    ? const SizedBox(
                        width: 1,
                        height: 1,
                      )
                    : Container(
                        margin: const EdgeInsetsDirectional.only(end: 16),
                        child: IntrinsicWidth(
                          child: SimpleButton(
                            height: 32,
                            onPressed: () {
                              _markAllAsRead();
                            },
                            filled: true,
                            isLoading: _markAllAsSeenInProgress,
                            background: _unreadNotificationsCount != 0
                                ? Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .background_2
                                : Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .separator,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'home.notifications.mark_as_seen',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .smallest
                                    .copyWith(
                                      color: _unreadNotificationsCount != 0
                                          ? Theme.of(context)
                                              .extension<CustomThemeFields>()!
                                              .fontColor_1
                                          : DarkColors.font_1,
                                    ),
                              ).tr(),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          width: Get.width,
          constraints: BoxConstraints(
            minHeight: Get.height - AppBar().preferredSize.height,
          ),
          child: Column(
            children: [
              Obx(() => _renderYouNeedToGivePermissions()),
              Flexible(
                child: Obx(
                  () => notificationsController.notifications.isEmpty
                      ? _renderNoNotificationsMessage()
                      : _renderNotifications(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
