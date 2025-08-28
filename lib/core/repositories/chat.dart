import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_lib;

import '../controllers/flash.dart';
import '../controllers/image_picker.dart';
import '../models/chat_group.dart';
import '../models/chat_message.dart';
import '../services/image_compress.dart';
import 'base.dart';

class ChatRepository {
  final dio = Get.find<Api>();
  final imageCompressService = Get.find<ImageCompressService>();
  final flashController = Get.find<FlashController>();

  Future<bool> sendAssetsMessage(SendAssetsMessageParams params) async {
    try {
      var data = await generateFormDataForAssetsMessage(params);
      await dio.api.post(
        '/chat-group/message/new/assets',
        data: data,
      );
      return true;
    } catch (error) {
      if (error is DioException) {
        var response = error.response?.data.toString() ?? '';

        if (response.contains('TOO_MANY')) {
          flashController.showMessageFlash(
              tr('create_auction.repository.too_many_assets'));
          return false;
        }

        if (response.contains('ASSET_TOO_BIG')) {
          flashController
              .showMessageFlash(tr('create_auction.repository.asset_too_big'));
          return false;
        }

        if (response.contains('ASSET_NOT_SUPPORTED')) {
          flashController.showMessageFlash(
              tr('create_auction.repository.asset_not_supported'));
          return false;
        }
      }

      return false;
    }
  }

  Future<bool> sendMessage(ChatMessage message) async {
    try {
      await dio.api.post(
        '/chat-group/message/new',
        data: {
          'message': message.message,
          'id': message.id,
          'groupId': message.chatGroupId,
        },
      );
      return true;
    } catch (error, stackTrace) {
      print('error sending message: $error, $stackTrace');
      return false;
    }
  }

  Future<void> removeMessages(String groupId, List<String> messagesIds) async {
    try {
      await dio.api.post(
        '/chat-group/delete/messages/$groupId',
        data: {'messagesIds': messagesIds},
      );
    } catch (error) {
      print('error removing messages: $error');
    }
  }

  Future<ChatGroup?> loadById(String id) async {
    try {
      var response = await dio.api.get('/chat-group/$id');
      return ChatGroup.fromJSON(response.data);
    } catch (error) {
      print('error loading chat group: $error');
      return null;
    }
  }

  Future<String?> translate(String id, String lang) async {
    try {
      var response = await dio.api.get('/chat-group/translate/$id/$lang');
      return response.data;
    } catch (error) {
      print('error translating chat message: $error');
      return null;
    }
  }

  Future<List<ChatMessage>> loadMessagesForGroup(
      String groupId, int page, int perPage) async {
    try {
      var response = await dio.api.get(
        '/chat-group/messages/$groupId/$page/$perPage',
      );
      return List<ChatMessage>.from(
          response.data.map((el) => ChatMessage.fromJson(el)));
    } catch (error) {
      print('error loading chat messages: $error');
      return [];
    }
  }

  Future<void> markMessagesAsSeen(String chatGroupId) async {
    try {
      await dio.api.put('/chat-group/seen/$chatGroupId');
    } catch (error) {
      print('error marking messages as seen: $error');
    }
  }

  Future<List<ChatGroup>> loadGroupsForAccount() async {
    try {
      var response = await dio.api.get('/chat-group');
      return List<ChatGroup>.from(
          response.data.map((el) => ChatGroup.fromJSON(el)));
    } catch (error, stackTrace) {
      print('error loading chat groups: $error, $stackTrace');
      return [];
    }
  }

  Future<bool> sendMessageToAccount(String accountId) async {
    try {
      var response = await dio.api.post('/chat-group/sendMessage/$accountId');
      return response.data['sent'];
    } catch (error) {
      print('error sending message to account: $error');
      return false;
    }
  }

  Future<ChatGroup?> loadForTwoAccount(
    String firstAcc,
    String secondAcc,
  ) async {
    try {
      var response = await dio.api.get('/chat-group/$firstAcc/$secondAcc');
      return ChatGroup.fromJSON(response.data);
    } catch (error) {
      print('error loading chat groups for two accounts: $error');
      return null;
    }
  }

  Future<ChatGroup?> createOrLoadWithAccount(
    String accountId,
  ) async {
    try {
      var response = await dio.api.post('/chat-group/$accountId');
      return ChatGroup.fromJSON(response.data);
    } catch (error, stackTrace) {
      print('Error creating chat group: $error $stackTrace');
      return null;
    }
  }

  Future<dio_lib.FormData> generateFormDataForAssetsMessage(
    SendAssetsMessageParams params,
  ) async {
    var galleryAssets = params.galleryAssets ?? [];
    var cameraAssets = params.cameraAssets ?? [];

    var files = galleryAssets.map((asset) async {
      var compressed =
          await imageCompressService.compressFileByPath(asset.path);
      return dio_lib.MultipartFile.fromFileSync(
        compressed.path,
        filename: asset.name,
      );
    }).toList();

    var cameraFiles = cameraAssets.map((asset) async {
      var compressed = await imageCompressService.compressFile(asset);
      return dio_lib.MultipartFile.fromFileSync(
        compressed.path,
        filename: asset.name,
      );
    }).toList();

    files.addAll(cameraFiles);

    var compressedFiles = await Future.wait(files);
    var data = dio_lib.FormData.fromMap({
      'id': params.id,
      'groupId': params.groupId,
      'files': compressedFiles,
    });
    return data;
  }
}

class SendAssetsMessageParams {
  String? id;
  String? groupId;
  List<AssetEntityPath>? galleryAssets;
  List<XFile>? cameraAssets;

  SendAssetsMessageParams({
    this.id,
    this.groupId,
    this.galleryAssets,
    this.cameraAssets,
  });
}
