import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

enum ChatMessageStatus {
  pending,
  sent,
  error,
}

class ChatMessage {
  final String id;
  final String chatGroupId;
  final String fromAccountId;
  final String? message;
  final String type;
  final List<String> assetPaths;
  ChatMessageStatus? status;

  List<AssetEntity>? galleryAssets;
  List<XFile>? cameraAssets;

  DateTime? seenAt;
  DateTime createdAt;
  DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.chatGroupId,
    required this.fromAccountId,
    required this.createdAt,
    required this.updatedAt,
    this.galleryAssets,
    this.cameraAssets,
    this.message,
    this.status = ChatMessageStatus.sent,
    this.type = 'text',
    this.assetPaths = const [],
    this.seenAt,
  });

  factory ChatMessage.fromJson(Map json) => ChatMessage(
        id: json['id'],
        chatGroupId: json['chatGroupId'],
        fromAccountId: json['fromAccountId'],
        message: json['message'],
        seenAt: json['seenAt'] != null ? DateTime.parse(json['seenAt']) : null,
        type: json['type'],
        assetPaths: json['assetPaths'] != null
            ? List<String>.from(json['assetPaths'])
            : [],
        createdAt: DateTime.parse(json['createdAt']).toLocal(),
        updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      );
}
