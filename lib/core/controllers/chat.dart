import 'package:mazadi/core/services/socket.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/chat_group.dart';
import '../models/chat_message.dart';
import '../repositories/chat.dart';
import 'account.dart';
import 'image_picker.dart';
import 'socket.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class ChatController extends GetxController {
  final chatRepository = Get.find<ChatRepository>();
  final accountController = Get.find<AccountController>();
  final socketController = Get.find<SocketController>();

  RxList<ChatGroup> chatGroups = RxList<ChatGroup>();
  RxMap<String, RxList<Rx<ChatMessage>>> chatMessages = RxMap();

  bool isInitialized = false;

  Future<void> init() async {
    if (isInitialized) {
      return;
    }

    await loadChatGroups();
    isInitialized = true;

    socketController.setHandler(
      CustomMessages.newMessage,
      handleNewMessageReceived,
    );

    socketController.setHandler(
      CustomMessages.messagesRemoved,
      handleMessagesRemoved,
    );
  }

  void clear() {
    isInitialized = false;
    chatGroups.clear();
    chatMessages.clear();
    chatGroups.refresh();
    chatMessages.refresh();
  }

  Future<ChatGroup?> getChatGroupWithAccount(String accountId) async {
    var currentAccountId = accountController.account.value.id;
    if (currentAccountId == '' || currentAccountId == accountId) {
      return null;
    }

    var existingGroup = chatGroups.firstWhereOrNull(
      (element) =>
          (element.firstAccount?.id == accountId &&
              element.secondAccount?.id == currentAccountId) ||
          (element.secondAccount?.id == accountId &&
              element.firstAccount?.id == currentAccountId),
    );

    if (existingGroup != null) {
      return existingGroup;
    }

    var chatGroup = await chatRepository.createOrLoadWithAccount(accountId);
    if (chatGroup == null) {
      return null;
    }

    chatGroups.add(chatGroup);
    return chatGroup;
  }

  bool unreadMessagesExist() {
    for (var chatGroup in chatGroups) {
      if (chatGroup.unreadMessages != null && chatGroup.unreadMessages! > 0) {
        return true;
      }
    }

    return false;
  }

  Future<void> removeMessages(
    String chatGroupId,
    List<String> messageIds,
  ) async {
    var messagesList = chatMessages[chatGroupId];
    if (messagesList == null) {
      return;
    }

    for (var messageId in messageIds) {
      var message = messagesList.firstWhereOrNull(
        (element) => element.value.id == messageId,
      );

      if (message != null) {
        messagesList.remove(message);
      }
    }

    // We need to check the lastMessageDate from the chat group and update it
    // with the latest message remaining
    updateChatGroupLastMessageWithLatestMessage(chatGroupId);

    await chatRepository.removeMessages(chatGroupId, messageIds);
  }

  void handleNewMessageReceived(dynamic data) {
    var newCreatedMessage = ChatMessage.fromJson(data);
    var groupId = newCreatedMessage.chatGroupId;

    var messagesList = chatMessages[groupId];
    if (messagesList == null) {
      messagesList = [].obs as RxList<Rx<ChatMessage>>?;
      chatMessages[groupId] = messagesList.obs as RxList<Rx<ChatMessage>>;
    }

    messagesList!.add(Rx<ChatMessage>(newCreatedMessage));

    // increment the unread messages count
    var chatGroup = chatGroups.firstWhereOrNull(
      (element) => element.id == groupId,
    );

    if (chatGroup != null) {
      chatGroup.unreadMessages = (chatGroup.unreadMessages ?? 0) + 1;
      chatGroups.refresh();
    }
  }

  Future<String?> translate(String id, String lang) async {
    return await chatRepository.translate(id, lang);
  }

  void handleMessagesRemoved(dynamic data) {
    var groupId = data['groupId'];
    var messagesIds = List<String>.from(data['messagesIds']);

    var chatGroup = chatGroups.firstWhereOrNull(
      (element) => element.id == groupId,
    );
    if (chatGroup == null) {
      return;
    }

    var groupMessages = chatMessages[groupId];
    if (groupMessages == null) {
      return;
    }

    for (var messageId in messagesIds) {
      var message = groupMessages.firstWhereOrNull(
        (element) => element.value.id == messageId,
      );

      // if the message is unread, we need to decrement the unread messages count
      if (message != null && message.value.seenAt == null) {
        chatGroup.unreadMessages = (chatGroup.unreadMessages ?? 1) - 1;
        chatGroups.refresh();
      }

      if (message != null) {
        groupMessages.remove(message);
      }
    }

    updateChatGroupLastMessageWithLatestMessage(groupId);
  }

  Future<void> sendAssetMessage(
    String groupId,
    List<AssetEntity>? galleryAssets,
    List<XFile>? cameraAssets,
  ) async {
    var currentAccountId = accountController.account.value.id;
    var chatMessage = ChatMessage(
      id: uuid.v4(),
      chatGroupId: groupId,
      galleryAssets: galleryAssets,
      cameraAssets: cameraAssets,
      type: 'assets',
      status: ChatMessageStatus.pending,
      fromAccountId: currentAccountId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    var messagesList = chatMessages[groupId];
    if (messagesList == null) {
      messagesList = [].obs as RxList<Rx<ChatMessage>>?;
      chatMessages[groupId] = messagesList.obs as RxList<Rx<ChatMessage>>;
    }
    messagesList!.add(Rx<ChatMessage>(chatMessage));

    var chatGroupToUpdate = chatGroups.firstWhereOrNull(
      (element) => element.id == groupId,
    );

    if (chatGroupToUpdate != null) {
      chatGroupToUpdate.lastMessageAt = chatMessage.createdAt;
      chatGroups.refresh();
    }

    var galleryAssetsList = (galleryAssets ?? []).map((asset) async {
      var originalFile = await asset.originFile;
      var absolutePath = originalFile?.absolute.path ?? '';
      var name = absolutePath.split('/').last;

      return AssetEntityPath(path: absolutePath, name: name);
    });

    var galleryFuture = Future.wait(galleryAssetsList);
    var galleryAssetsPath = await galleryFuture;

    var sent = await chatRepository.sendAssetsMessage(
      SendAssetsMessageParams(
        id: chatMessage.id,
        cameraAssets: cameraAssets,
        galleryAssets: galleryAssetsPath,
        groupId: groupId,
      ),
    );

    var listMessageToUpdate = chatMessages[groupId]!.firstWhereOrNull(
      (element) => element.value.id == chatMessage.id,
    );

    if (listMessageToUpdate != null) {
      if (sent) {
        listMessageToUpdate.value.status = ChatMessageStatus.sent;
      } else {
        listMessageToUpdate.value.status = ChatMessageStatus.error;
      }
      listMessageToUpdate.refresh();
    }
  }

  Future<void> sendMessage(String groupId, String message) async {
    var currentAccountId = accountController.account.value.id;
    var chatMessage = ChatMessage(
      id: uuid.v4(),
      chatGroupId: groupId,
      fromAccountId: currentAccountId,
      message: message,
      status: ChatMessageStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    var messagesList = chatMessages[groupId];
    if (messagesList == null) {
      messagesList = [].obs as RxList<Rx<ChatMessage>>?;
      chatMessages[groupId] = messagesList.obs as RxList<Rx<ChatMessage>>;
    }
    messagesList!.add(Rx<ChatMessage>(chatMessage));

    var chatGroupToUpdate = chatGroups.firstWhereOrNull(
      (element) => element.id == groupId,
    );

    if (chatGroupToUpdate != null) {
      chatGroupToUpdate.lastMessageAt = chatMessage.createdAt;
      chatGroups.refresh();
    }

    var sent = await chatRepository.sendMessage(chatMessage);

    var listMessageToUpdate = chatMessages[groupId]!.firstWhereOrNull(
      (element) => element.value.id == chatMessage.id,
    );

    if (listMessageToUpdate != null) {
      if (sent) {
        listMessageToUpdate.value.status = ChatMessageStatus.sent;
      } else {
        listMessageToUpdate.value.status = ChatMessageStatus.error;
      }
      listMessageToUpdate.refresh();
    }
  }

  Future<void> markMessagesAsSeen(String chatGroupId) async {
    var unseenMessagesExisted = false;
    var chatGroup = chatGroups.firstWhereOrNull(
      (element) => element.id == chatGroupId,
    );
    if (chatGroup == null) {
      return;
    }

    chatGroup.unreadMessages = 0;
    chatGroups.refresh();

    var messagesList = chatMessages[chatGroupId];
    if (messagesList == null) {
      return;
    }

    for (var element in chatMessages[chatGroupId]!) {
      if (element.value.seenAt == null) {
        unseenMessagesExisted = true;
        element.value.seenAt = DateTime.now();
      }
    }

    if (unseenMessagesExisted) {
      await chatRepository.markMessagesAsSeen(chatGroupId);
    }
  }

  Future<void> fetchMessagesForGroup(
    String chatGroupId, [
    int page = 0,
    int perPage = 50,
    bool olderMessages = false,
  ]) async {
    var messages = await chatRepository.loadMessagesForGroup(
      chatGroupId,
      page,
      perPage,
    );
    messages.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    var messagesList = chatMessages[chatGroupId];
    if (messagesList == null) {
      RxList<Rx<ChatMessage>> emptyList = RxList<Rx<ChatMessage>>();
      messagesList = emptyList;
      chatMessages[chatGroupId] = messagesList;
    }

    if (page == 0) {
      messagesList.clear();
    }

    var messagesToParse = olderMessages ? messages : messages.reversed;

    for (var message in messagesToParse) {
      var messageAlreadyAdded = chatMessages[chatGroupId]!.any(
        (element) => element.value.id == message.id,
      );

      if (messageAlreadyAdded) {
        continue;
      }

      if (olderMessages) {
        chatMessages[chatGroupId]!.insert(0, Rx<ChatMessage>(message));
      } else {
        chatMessages[chatGroupId]!.add(Rx<ChatMessage>(message));
      }
    }

    chatMessages[chatGroupId]!.refresh();
  }

  Future<void> loadChatGroups() async {
    var chatGroupsData = await chatRepository.loadGroupsForAccount();
    chatGroups.clear();
    chatGroups.addAll(chatGroupsData);
    chatGroups.refresh();

    for (var element in chatGroups) {
      chatMessages[element.id] = RxList<Rx<ChatMessage>>();

      // We only need one message (the last one), to display it in the preview
      // chats screen
      var messages = await chatRepository.loadMessagesForGroup(
        element.id,
        0,
        1,
      );

      chatMessages[element.id]!.addAll(
        messages.map((e) => Rx<ChatMessage>(e)).toList(),
      );
    }
  }

  updateChatGroupLastMessageWithLatestMessage(String groupId) {
    var chatGroupToUpdate = chatGroups.firstWhereOrNull(
      (element) => element.id == groupId,
    );

    if (chatGroupToUpdate != null) {
      var messagesList = chatMessages[groupId];
      if (messagesList == null) {
        return;
      }

      var lastMessage =
          messagesList.isNotEmpty ? messagesList.last.value : null;
      if (lastMessage != null) {
        chatGroupToUpdate.lastMessageAt = lastMessage.createdAt;
        chatGroups.refresh();
      }
    }
  }
}
