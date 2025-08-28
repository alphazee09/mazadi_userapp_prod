import 'dart:async';

import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../core/controllers/account.dart';
import '../../core/controllers/chat.dart';
import '../../core/controllers/flash.dart';
import '../../core/controllers/image_picker.dart';
import '../../core/models/chat_group.dart';
import '../../core/models/chat_message.dart';
import '../../core/navigator.dart';
import '../../utils/generic.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/common/loader.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/simple_app_bar.dart';
import '../profile/details/index.dart';
import 'dialogs/delete_messages.dart';
import 'widgets/message.dart';

class ChatChannel extends StatefulWidget {
  final ChatGroup chatGroup;

  const ChatChannel({super.key, required this.chatGroup});

  @override
  // ignore: library_private_types_in_public_api
  _ChatChannelState createState() => _ChatChannelState();
}

class _ChatChannelState extends State<ChatChannel> {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();
  final chatController = Get.find<ChatController>();
  final flashController = Get.find<FlashController>();
  final imagePickerController = Get.find<ImagePickerController>();

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _fetchingInitialMessages = false;
  bool _loadingOlderMessagesInProgress = false;
  RxList _selectedMessagesIds = [].obs;
  int _currentPage = 1;

  final Rx<bool> _messageIsEmpty = true.obs;
  final Rx<bool> _showEmojiPicker = false.obs;

  late StreamSubscription<bool> keyboardSubscription;
  late StreamSubscription<List<Rx<ChatMessage>>>? _chatMessagesSubscription;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      _messageIsEmpty.value = _controller.text.isEmpty;
    });

    _scrollToNewMessage();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) async {
      if (visible) {
        // THIS IS FOR THE MESSAGES TO NOT BE UNDER THE KEYBOARD
        await Future.delayed(const Duration(milliseconds: 500));
        _scrollToNewMessage();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.markMessagesAsSeen(widget.chatGroup.id);
    });

    fetchInitialMessagesAndListenForChanges();
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _chatMessagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchInitialMessagesAndListenForChanges() async {
    if (_fetchingInitialMessages) {
      return;
    }

    setState(() {
      _fetchingInitialMessages = true;
    });

    await chatController.fetchMessagesForGroup(widget.chatGroup.id);

    var chatMessagesGroup = chatController.chatMessages[widget.chatGroup.id];
    if (chatMessagesGroup != null) {
      _chatMessagesSubscription = chatMessagesGroup.listen((_) {
        if (_loadingOlderMessagesInProgress) {
          return;
        }
        _scrollToNewMessage();
      });
    }

    setState(() {
      _fetchingInitialMessages = false;
    });

    _scrollToNewMessage();
  }

  void _scrollToNewMessage() {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  void _handleSelectMessage(String id) {
    if (_selectedMessagesIds.contains(id)) {
      _selectedMessagesIds.remove(id);
    } else {
      _selectedMessagesIds.add(id);
    }

    _selectedMessagesIds.refresh();
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) {
      return;
    }

    chatController.sendMessage(widget.chatGroup.id, _controller.text);
    _controller.clear();

    _scrollToNewMessage();
  }

  Future<void> _loadOlderMessages() async {
    var groupMessages = chatController.chatMessages[widget.chatGroup.id]!;
    if (groupMessages.isEmpty) {
      return;
    }

    setState(() {
      _loadingOlderMessagesInProgress = true;
    });

    try {
      await chatController.fetchMessagesForGroup(
        widget.chatGroup.id,
        _currentPage,
        50,
        true,
      );
    } catch (error) {
      print('Error while loading older messages: $error');
    } finally {
      setState(() {
        _loadingOlderMessagesInProgress = false;
        _currentPage++;
      });
    }
  }

  void handleAssetsSelected() {
    chatController.sendAssetMessage(
      widget.chatGroup.id,
      imagePickerController.galleryAssets.toList(),
      imagePickerController.cameraAssets.toList(),
    );

    imagePickerController.clear();
  }

  Widget _renderAppBarActionsSection() {
    if (_selectedMessagesIds.isEmpty) {
      return Container();
    }

    var containsMessagesThatAreNotMine = chatController
        .chatMessages[widget.chatGroup.id]!
        .where((el) => _selectedMessagesIds.contains(el.value.id))
        .any((el) =>
            el.value.fromAccountId != accountController.account.value.id);

    return Row(
      children: [
        IconButton(
          splashRadius: 24,
          icon: SvgPicture.asset(
            'assets/icons/svg/copy.svg',
            semanticsLabel: 'Copy',
            height: 20,
            width: 20,
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () async {
            var messages = chatController.chatMessages[widget.chatGroup.id]!
                .where((el) => _selectedMessagesIds.contains(el.value.id))
                .map((el) => el.value)
                .toList();

            if (messages.isEmpty) {
              return;
            }

            if (messages.length == 1) {
              await Clipboard.setData(
                  ClipboardData(text: messages[0].message!));
            } else {
              var text = messages
                  .map((el) => el.message != null && el.message!.isNotEmpty
                      ? el.message
                      : '')
                  .join('\n');
              await Clipboard.setData(ClipboardData(text: text));
            }

            flashController.showMessageFlash(
              _selectedMessagesIds.length == 1
                  ? tr('chat.single_message_copied')
                  : tr('chat.messages_copied', namedArgs: {
                      'no': _selectedMessagesIds.length.toString()
                    }),
              FlashMessageType.success,
            );
          },
        ),
        containsMessagesThatAreNotMine
            ? Container()
            : IconButton(
                splashRadius: 24,
                icon: SvgPicture.asset(
                  'assets/icons/svg/trash.svg',
                  semanticsLabel: 'Delete',
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RemoveChatMessagesDialogContent(
                        onConfirm: () async {
                          var toRemove = _selectedMessagesIds
                              .map((el) => el.toString())
                              .toList();

                          await chatController.removeMessages(
                            widget.chatGroup.id,
                            toRemove,
                          );

                          _selectedMessagesIds.clear();
                          _selectedMessagesIds.refresh();
                        },
                      );
                    },
                  );
                },
              )
      ],
    );
  }

  Widget _renderBottomNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: TextField(
                    maxLines: 20,
                    minLines: 1,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    controller: _controller,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                    scrollPadding: const EdgeInsets.only(
                      bottom: 130,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: IntrinsicWidth(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                splashRadius: 24,
                                icon: SvgPicture.asset(
                                  'assets/icons/svg/attach.svg',
                                  semanticsLabel: 'Attachment',
                                  height: 20,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .fontColor_1,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onPressed: () {
                                  imagePickerController.openImageGalleryPicker(
                                    true,
                                    handleAssetsSelected,
                                    5,
                                  );
                                },
                              ),
                            ),
                            Flexible(
                              child: Obx(
                                () => IconButton(
                                  padding: EdgeInsets.zero,
                                  splashRadius: 24,
                                  icon: Icon(
                                    _showEmojiPicker.value
                                        ? Icons.abc_sharp
                                        : Icons.emoji_emotions_outlined,
                                    color: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .fontColor_1,
                                  ),
                                  onPressed: () {
                                    _showEmojiPicker.value =
                                        !_showEmojiPicker.value;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      hintText: tr('chat.send_message'),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      counterText: '',
                      fillColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_2,
                      hintStyle: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .background_2,
                            width: 0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 8,
              ),
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  child: ActionButton(
                    filled: false,
                    radius: 8,
                    width: 44,
                    height: 44,
                    background: _messageIsEmpty.value
                        ? Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .separator
                        : Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action,
                    onPressed: () {
                      _sendMessage();
                    },
                    border: Border.all(
                      color: _messageIsEmpty.value
                          ? Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .separator
                          : Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .action,
                    ),
                    child: Icon(
                      Icons.send,
                      size: 20,
                      color: _messageIsEmpty.value
                          ? Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1
                          : DarkColors.font_1,
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Obx(
            () => Offstage(
              offstage: !_showEmojiPicker.value,
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: EmojiPicker(
                  textEditingController: _controller,
                  config: Config(
                    categoryViewConfig: CategoryViewConfig(
                      initCategory: Category.RECENT,
                      backgroundColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_1,
                      indicatorColor: Colors.blue,
                      iconColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      iconColorSelected: Colors.blue,
                      backspaceColor: Colors.blue,
                      categoryIcons: const CategoryIcons(),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                    ),
                    skinToneConfig: SkinToneConfig(
                      dialogBackgroundColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      indicatorColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .separator,
                      enabled: true,
                    ),
                    searchViewConfig: SearchViewConfig(
                      backgroundColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_1,
                    ),
                    emojiViewConfig: EmojiViewConfig(
                      buttonMode: ButtonMode.MATERIAL,
                      columns: 8,
                      emojiSizeMax: 26 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.30
                              : 1.0),
                      backgroundColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_1,
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      gridPadding: EdgeInsets.zero,
                      recentsLimit: 28,
                      replaceEmojiOnLimitExceed: false,
                      noRecents: Text(
                        'chat.no_recent_emojis',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                        textAlign: TextAlign.center,
                      ).tr(),
                      loadingIndicator: const SizedBox.shrink(),
                    ),
                    checkPlatformCompatibility: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var otherUser =
        widget.chatGroup.firstAccountId == accountController.account.value.id
            ? widget.chatGroup.secondAccount
            : widget.chatGroup.firstAccount;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        body: Container(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: _fetchingInitialMessages
                        ? const Loader()
                        : Obx(
                            () => RefreshIndicator(
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                              backgroundColor: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .separator,
                              edgeOffset: 50,
                              onRefresh: () async {
                                await _loadOlderMessages();
                              },
                              child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: chatController
                                          .chatMessages[widget.chatGroup.id]
                                          ?.length ??
                                      0,
                                  shrinkWrap: true,
                                  itemBuilder: (_, index) {
                                    var accountId = chatController
                                        .chatMessages[widget.chatGroup.id]![
                                            index]
                                        .value
                                        .fromAccountId;

                                    var sender =
                                        widget.chatGroup.firstAccountId ==
                                                accountId
                                            ? widget.chatGroup.firstAccount
                                            : widget.chatGroup.secondAccount;

                                    var message = chatController.chatMessages[
                                        widget.chatGroup.id]![index];

                                    return Obx(
                                      () => ChatMessageWidget(
                                        handleSelect: () {
                                          _handleSelectMessage(
                                              message.value.id);
                                        },
                                        selectedMessages:
                                            _selectedMessagesIds.toList(),
                                        message: message,
                                        sender: sender!,
                                        loggedAccount:
                                            accountController.account.value,
                                      ),
                                    );
                                  }),
                            ),
                          ),
                  ),
                ),
                _renderBottomNavbar()
              ],
            ),
          ),
        ),
        appBar: SimpleAppBar(
          withBack: true,
          onBack: goBack,
          withSearch: false,
          elevation: 0,
          title: Container(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      navigatorService.push(
                        ProfileDetailsScreen(
                          accountId: otherUser!.id,
                        ),
                        NavigationStyle.SharedAxis,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        UserAvatar(
                          account: otherUser,
                          size: 40,
                        ),
                        Container(
                          width: 8,
                        ),
                        Flexible(
                          child: Text(
                            GenericUtils.generateNameForAccount(otherUser),
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .title,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(end: 16),
                  child: Obx(
                    () => _renderAppBarActionsSection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
