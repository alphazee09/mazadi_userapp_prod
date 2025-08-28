import 'account.dart';

class ChatGroup {
  String id;
  String firstAccountId;
  String secondAccountId;

  int? unreadMessages;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastMessageAt;

  Account? firstAccount;
  Account? secondAccount;

  ChatGroup({
    required this.id,
    required this.firstAccountId,
    required this.secondAccountId,
    required this.createdAt,
    required this.updatedAt,
    this.firstAccount,
    this.secondAccount,
    this.lastMessageAt,
    this.unreadMessages,
  });

  static ChatGroup fromJSON(dynamic data) {
    var firstAccount = data['firstAccount'] != null
        ? Account.fromJSON(data['firstAccount'])
        : null;

    var secondAccount = data['secondAccount'] != null
        ? Account.fromJSON(data['secondAccount'])
        : null;

    var lastMessageAt = data['lastMessageAt'] != null
        ? DateTime.parse(data['lastMessageAt'])
        : null;

    return ChatGroup(
      id: data['id'],
      firstAccountId: data['firstAccountId'],
      secondAccountId: data['secondAccountId'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      firstAccount: firstAccount,
      secondAccount: secondAccount,
      lastMessageAt: lastMessageAt,
      unreadMessages: data['unreadMessages'],
    );
  }
}
