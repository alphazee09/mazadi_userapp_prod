import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_lib;

import '../controllers/image_picker.dart';
import '../models/account.dart';
import '../services/image_compress.dart';
import 'base.dart';

class AccountsRepository {
  final dio = Get.find<Api>();
  final imageCompressService = Get.find<ImageCompressService>();

  Future<Account?> loadLoggedIn() async {
    try {
      var response = await dio.api.get('/account');
      return Account.fromJSON(response.data);
    } catch (error, stacktrace) {
      print('error loading logged in user: $error, $stacktrace');
      return null;
    }
  }

  Future<bool> delete(Account account) async {
    try {
      await dio.api.delete('/account');
      return true;
    } catch (error, stacktrace) {
      print('error deleting account: $error, $stacktrace');
      return false;
    }
  }

  Future<Account?> loadAccountDetails(String accountId) async {
    try {
      var response = await dio.api.get('/account/details/$accountId');
      return Account.fromJSON(response.data);
    } catch (error) {
      print('error loading account details: $error');
      return null;
    }
  }

  Future<Account?> update(
    Account account, [
    AssetEntityPath? galleryAsset,
    XFile? cameraAsset,
  ]) async {
    List<dio_lib.MultipartFile> files = [];

    if (galleryAsset != null) {
      var compressed = await imageCompressService.compressFileByPath(
          galleryAsset.path, 250, 250);

      files.add(dio_lib.MultipartFile.fromFileSync(
        compressed.path,
        filename: galleryAsset.name,
      ));
    }

    if (cameraAsset != null) {
      var compressed = await imageCompressService.compressFile(cameraAsset);

      files.add(dio_lib.MultipartFile.fromFileSync(
        compressed.path,
        filename: cameraAsset.name,
      ));
    }

    try {
      var data = dio_lib.FormData.fromMap({
        'name': account.name,
        'deviceFCMToken': account.deviceFCMToken,
        'meta': account.meta?.asObject(),
        'allowedNotifications': account.allowedNotifications?.asObject(),
        'acceptedTermsAndCondition': account.acceptedTermsAndCondition,
        'introDone': account.introDone,
        'introSkipped': account.introSkipped,
        'categoriesSetupDone': account.categoriesSetupDone,
        'preferredCategoriesIds': account.preferredCategoriesIds,
        'files': files,
        'locationLatLng': jsonEncode(account.locationLatLng),
        'locationPretty': account.locationPretty,
      });

      var response = await dio.api.post('/account', data: data);
      return Account.fromJSON(response.data);
    } catch (error) {
      print('could not update account: $error');
      return null;
    }
  }

  Future<List<Account>> search(String keyword, [int page = 0]) async {
    try {
      var response = await dio.api.post('/account/search', data: {
        'keyword': keyword,
        'page': page,
      });

      return List<Account>.from(
        response.data.map(
          (el) => Account.fromJSON(el),
        ),
      );
    } catch (error) {
      print('Error searching accounts: $error');
      return [];
    }
  }

  Future<dynamic> loadStats() async {
    try {
      var response = await dio.api.get('/account/stats');
      return response.data;
    } catch (error) {
      print('Error loading account stats: $error');
      return null;
    }
  }

  Future<void> blockAccount(String accountId) {
    return dio.api.put('/account/update/blocked/block/$accountId');
  }

  Future<void> unblockAccount(String accountId) {
    return dio.api.put('/account/update/blocked/unblock/$accountId');
  }
}
