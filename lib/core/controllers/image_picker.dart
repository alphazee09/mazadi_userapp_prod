import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../widgets/assets/assets_picker.dart';
import '../../widgets/permissions/ask_camera_permissions.dart';
import '../../widgets/permissions/ask_storage_permissions.dart';
import '../models/asset.dart';
import '../navigator.dart';

class AssetListItem {
  final AssetEntity? galleryAsset;
  final XFile? cameraAsset;

  AssetListItem({
    this.cameraAsset,
    this.galleryAsset,
  });
}

class AssetEntityPath {
  String path;
  String name;

  AssetEntityPath({
    required this.path,
    required this.name,
  });
}

class ImagePickerController extends GetxController {
  RxList<AssetEntity> galleryAssets = RxList<AssetEntity>();
  RxList<XFile> cameraAssets = RxList<XFile>();
  RxList<Asset> networkAssets = RxList<Asset>();

  final ImagePicker _picker = ImagePicker();
  final navigatorService = Get.find<NavigatorService>();

  void clear() {
    galleryAssets.clear();
    cameraAssets.clear();
    networkAssets.clear();
  }

  void setNetworkAssets(List<Asset> assets) {
    clear();
    networkAssets.addAll(assets);
  }

  Future<List<AssetEntityPath>> getGalleryAssetPaths() async {
    var galleryAssetsList = galleryAssets.map((asset) async {
      var originalFile = await asset.originFile;
      var absolutePath = originalFile?.absolute.path ?? '';
      var name = absolutePath.split('/').last;

      return AssetEntityPath(path: absolutePath, name: name);
    });

    var galleryFuture = Future.wait(galleryAssetsList);
    return await galleryFuture;
  }

  void toggleAssetSelection(AssetEntity asset) {
    if (assetIsSelected(asset)) {
      galleryAssets.removeWhere((element) => element.id == asset.id);
      return;
    }

    galleryAssets.add(asset);
  }

  void unselectOtherAssets(String assetToKeepId) {
    galleryAssets.removeWhere((element) => element.id != assetToKeepId);
    cameraAssets.removeWhere((element) => element.path != assetToKeepId);
  }

  void removeCameraAsset(String path) {
    cameraAssets.removeWhere((element) => element.path == path);
  }

  void removeGalleryAsset(String id) {
    galleryAssets.removeWhere((element) => element.id == id);
  }

  void removeNetworkAsset(String id) {
    networkAssets.removeWhere((element) => element.id == id);
  }

  void removeAllSelectedAssets() {
    cameraAssets.clear();
    galleryAssets.clear();
  }

  List<AssetListItem> generateAssetsList() {
    // ignore: invalid_use_of_protected_member
    var cameraAssets = this.cameraAssets.value;
    // ignore: invalid_use_of_protected_member
    var galleryAssets = this.galleryAssets.value;

    List<AssetListItem> result = [];
    for (var cameraAsset in cameraAssets) {
      result.add(AssetListItem(cameraAsset: cameraAsset, galleryAsset: null));
    }
    for (var galleryAsset in galleryAssets) {
      result.add(AssetListItem(cameraAsset: null, galleryAsset: galleryAsset));
    }

    return result;
  }

  int getSelectedAssetsCount() {
    return networkAssets.length + galleryAssets.length + cameraAssets.length;
  }

  bool assetIsSelected(AssetEntity asset) {
    var isSelected = galleryAssets.indexWhere((auth) => auth.id == asset.id);
    return isSelected != -1;
  }

  bool cameraAssetIsSelected(String path) {
    var isSelected = cameraAssets.indexWhere((auth) => auth.path == path);
    return isSelected != -1;
  }

  bool assetsAreSelected() {
    return cameraAssets.length + galleryAssets.length != 0;
  }

  Future<void> openCamera() async {
    var permissionStatus = await Permission.camera.status;
    if (permissionStatus != PermissionStatus.granted) {
      PermissionStatus permissionStatus = await Permission.camera.request();

      if (permissionStatus.isPermanentlyDenied) {
        navigatorService.push(AskCameraPermissions(
          isPermanent: true,
          onPressed: () {
            checkPermissionAndOpenCamera();
          },
        ));
        return;
      }

      if (permissionStatus.isDenied) {
        navigatorService.push(AskCameraPermissions(
          isPermanent: false,
          onPressed: () {
            checkPermissionAndOpenCamera();
          },
        ));
        return;
      }
    }

    var pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (pickedFile == null) {
      return;
    }

    cameraAssets.add(pickedFile);
    cameraAssets.refresh();
  }

  Future<void> openImageGalleryPicker(
      [bool allowMultiSelect = true,
      Function? onDone,
      int? maxAllowedSelected]) async {
    DeviceInfoPlugin? plugin = Platform.isAndroid ? DeviceInfoPlugin() : null;
    AndroidDeviceInfo? android =
        Platform.isAndroid ? await plugin!.androidInfo : null;

    var permissionStatus = Platform.isAndroid && android!.version.sdkInt >= 33
        ? await Permission.photos.status
        : await Permission.storage.status;

    if (permissionStatus != PermissionStatus.granted) {
      PermissionStatus permissionStatus =
          Platform.isAndroid && android!.version.sdkInt >= 33
              ? await Permission.photos.request()
              : await Permission.storage.request();

      if (permissionStatus.isPermanentlyDenied) {
        navigatorService.push(
          AskStoragePermissions(
            isPermanent: true,
            onPressed: () {
              checkPermissionAndOpenGalleryPicker();
            },
          ),
          NavigationStyle.SharedAxis,
        );
        return;
      }

      if (permissionStatus.isDenied) {
        navigatorService.push(
          AskStoragePermissions(
            isPermanent: false,
            onPressed: () {
              checkPermissionAndOpenGalleryPicker();
            },
          ),
          NavigationStyle.SharedAxis,
        );
        return;
      }
    }

    await navigatorService.push(
      AssetsPicker(
        allowMultiSelect: allowMultiSelect,
        onDone: onDone,
        maxAllowedSelected: maxAllowedSelected,
      ),
      NavigationStyle.SharedAxis,
    );
  }

  Future<List<AssetPathEntity>> getGalleryFolders() async {
    return await PhotoManager.getAssetPathList();
  }

  Future<List<AssetEntity>> getAssetsForPage(int page, [String? album]) async {
    if (album != null) {
      var albums = await getGalleryFolders();
      var albumData = albums.firstWhere((element) => element.name == album);
      // ignore: unnecessary_null_comparison
      if (albumData == null) {
        return [];
      }

      return await albumData.getAssetListPaged(page: page, size: 50);
    }

    var albums = await PhotoManager.getAssetPathList(onlyAll: true);
    if (albums.isEmpty) {
      return [];
    }

    return await albums[0].getAssetListPaged(page: page, size: 50);
  }

  Future<void> checkPermissionAndOpenCamera() async {
    var permissionStatus = Platform.isAndroid
        ? await Permission.photos.status
        : await Permission.storage.status;

    if (permissionStatus.isGranted) {
      var pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (pickedFile == null) {
        return;
      }
      cameraAssets.add(pickedFile);
    }
  }

  Future<void> checkPermissionAndOpenGalleryPicker() async {
    DeviceInfoPlugin? plugin = Platform.isAndroid ? DeviceInfoPlugin() : null;
    AndroidDeviceInfo? android =
        Platform.isAndroid ? await plugin!.androidInfo : null;

    var permissionStatus = Platform.isAndroid && android!.version.sdkInt >= 33
        ? await Permission.photos.status
        : await Permission.storage.status;

    if (permissionStatus.isGranted) {
      navigatorService.push(AssetsPicker());
      return;
    }

    Platform.isAndroid && android!.version.sdkInt >= 33
        ? await Permission.photos.request()
        : await Permission.storage.request();

    permissionStatus = Platform.isAndroid && android!.version.sdkInt >= 33
        ? await Permission.photos.status
        : await Permission.storage.status;

    if (permissionStatus.isGranted) {
      navigatorService.push(AssetsPicker());
      return;
    }
  }
}
