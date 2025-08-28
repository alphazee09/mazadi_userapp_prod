import 'dart:async';

import 'package:mazadi/utils/generic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/chat.dart';
import '../../core/controllers/main.dart';
import '../../core/models/chat_group.dart';
import '../../widgets/simple_app_bar.dart';
import 'widgets/chat_group_card.dart';
import 'widgets/sort_popup.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final mainController = Get.find<MainController>();
  final chatController = Get.find<ChatController>();

  final Rx<bool> _pointerDownInner = false.obs;

  var _chatGroups = <ChatGroup>[];
  var _currentSort = ChatGroupsSortBy.newest;
  var _currentSearchKey = '';
  late StreamSubscription<List<ChatGroup>> _chatGroupsSubscription;

  @override
  void initState() {
    super.initState();

    searchAndSortChatGroups();

    _chatGroupsSubscription = chatController.chatGroups.listen((_) {
      if (mounted) {
        searchAndSortChatGroups();
      }
    });
  }

  @override
  void dispose() {
    _chatGroupsSubscription.cancel();
    super.dispose();
  }

  void searchAndSortChatGroups() {
    setState(() {
      var initialChatGroups = chatController.chatGroups.toList();
      if (_currentSearchKey.isNotEmpty) {
        initialChatGroups = initialChatGroups
            .where((chatGroup) =>
                GenericUtils.generateNameForAccount(chatGroup.firstAccount)
                    .toLowerCase()
                    .contains(_currentSearchKey.toLowerCase()) ||
                GenericUtils.generateNameForAccount(chatGroup.secondAccount)
                    .toLowerCase()
                    .contains(_currentSearchKey.toLowerCase()))
            .toList();
      }

      _chatGroups = initialChatGroups;
      _chatGroups.sort((a, b) {
        switch (_currentSort) {
          case ChatGroupsSortBy.newest:
            return b.lastMessageAt != null
                ? b.lastMessageAt!.compareTo(a.lastMessageAt ?? DateTime.now())
                : 1;
          case ChatGroupsSortBy.oldest:
            return a.lastMessageAt != null
                ? a.lastMessageAt!.compareTo(b.lastMessageAt ?? DateTime.now())
                : -1;
        }
      });
    });
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _reloadData() async {
    try {
      await chatController.loadChatGroups();
    } catch (error) {
      print('Error while reloading chat data: $error');
    }
  }

  void _handleChatGroupsSearch(String searchKey) {
    if (_currentSearchKey == searchKey) {
      return;
    }

    setState(() {
      _currentSearchKey = searchKey;
    });

    searchAndSortChatGroups();
  }

  Widget _renderNoChatsMessage() {
    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svg/chat-color.svg',
            height: 160,
            semanticsLabel: 'Chat',
          ),
          Container(
            height: 32,
          ),
          Text(
            'chat.no_conversations_available',
            style: Theme.of(context).extension<CustomThemeFields>()!.title,
            textAlign: TextAlign.center,
          ).tr(),
        ],
      ),
    );
  }

  Widget _renderChatGroups(List<ChatGroup> chatGroups) {
    if (chatGroups.isEmpty) {
      return _renderNoChatsMessage();
    }

    return Container(
      constraints: BoxConstraints(minHeight: Get.height - 300),
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          for (var chatGroup in chatGroups) ChatGroupCard(group: chatGroup),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          if (_pointerDownInner.value) {
            _pointerDownInner.value = false;
            return;
          }

          _pointerDownInner.value = false;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          resizeToAvoidBottomInset: true,
          appBar: SimpleAppBar(
              handleSearchInputTapDown: () {
                _pointerDownInner.value = true;
              },
              withClearSearchKey: true,
              withSearch: true,
              withBack: false,
              elevation: 0,
              handleSearch: _handleChatGroupsSearch,
              searchPlaceholder: tr('chat.search'),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                        ),
                        Text(
                          'chat.chat',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .title,
                        ).tr(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    child: ChatGroupsSortPopup(
                      onSort: (ChatGroupsSortBy sortBy) {
                        setState(() {
                          _currentSort = sortBy;
                        });

                        searchAndSortChatGroups();
                      },
                      currentSort: _currentSort,
                    ),
                  ),
                ],
              )),
          body: RefreshIndicator(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.separator,
            edgeOffset: 100,
            onRefresh: () async {
              await _reloadData();
            },
            child: SingleChildScrollView(
              child: Container(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_1,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _renderChatGroups(_chatGroups),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
