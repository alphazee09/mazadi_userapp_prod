import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mazadi/theme/colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/controllers/image_picker.dart';
import '../../core/controllers/flash.dart';
import '../common/action_button.dart';
import '../simple_app_bar.dart';
import 'assets_picker_item.dart';
import 'camera_asset_item.dart';

// ignore: must_be_immutable
class AssetsPicker extends StatefulWidget {
  int existingAssetsCount;
  bool allowMultiSelect;
  Function? onDone;
  int? maxAllowedSelected;

  AssetsPicker({
    super.key,
    this.existingAssetsCount = 0,
    this.allowMultiSelect = true,
    this.onDone,
    this.maxAllowedSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AssetsPicker createState() => _AssetsPicker();
}

class _AssetsPicker extends State<AssetsPicker> {
  final imagePickerController = Get.find<ImagePickerController>();
  final flashController = Get.find<FlashController>();

  int _currentPage = 0;
  int _lastPage = -1;

  // ignore: constant_identifier_names, non_constant_identifier_names
  var ALL_IMAGES_FOLDER_NAME = tr('assets.all_images_folder');

  final List<Widget> _cameraAssetWidgets = [];
  final List<Widget> _assetWidgets = [];
  final List<AssetPathEntity> _folders = [];
  String? _currentFolder;

  StreamSubscription<List<XFile>>? _cameraAssetsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
    _loadCameraAssets();

    _cameraAssetsSubscription =
        imagePickerController.cameraAssets.listen((cameraAssets) {
      _loadCameraAssets(cameraAssets);
    });
  }

  @override
  void dispose() {
    _cameraAssetsSubscription?.cancel();
    super.dispose();
  }

  void goBack() {
    Navigator.of(context).pop();
    if (widget.onDone != null) {
      widget.onDone!();
    }
  }

  void _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (_currentPage != _lastPage) {
        _fetchNewMedia();
      }
    }
  }

  void _loadCameraAssets([List<XFile>? cameraAssets]) {
    if (!mounted) {
      return;
    }
    List<Widget> newCameraAssets = [];

    var assets = cameraAssets ?? imagePickerController.cameraAssets;
    for (var element in assets) {
      var image = Image.file(
        File(element.path),
        fit: BoxFit.cover,
      );

      newCameraAssets.add(
        CameraAssetsPickerItem(
          image: image,
          asset: element,
          select: () {},
        ),
      );
    }

    setState(() {
      _cameraAssetWidgets.clear();
      _cameraAssetWidgets.addAll(newCameraAssets);
    });
  }

  Future<void> _fetchNewMedia() async {
    if (_folders.isEmpty) {
      var folders = await imagePickerController.getGalleryFolders();

      var seen = <String>{};
      var uniqueFolders =
          folders.where((element) => seen.add(element.name)).toList();
      if (mounted) {
        setState(() {
          _folders.clear();
          _folders.addAll(uniqueFolders);
        });
      }
    }

    _lastPage = _currentPage;
    var media = await imagePickerController.getAssetsForPage(
      _currentPage,
      _currentFolder,
    );

    List<Widget> temp = [];

    for (var asset in media) {
      if (asset.type != AssetType.image) {
        continue;
      }

      var assetWidget = FutureBuilder(
          future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
          builder: (BuildContext innerContext, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container();
            }

            var image = Image.memory(
              snapshot.data as Uint8List,
              fit: BoxFit.cover,
            ).image;

            return AssetsPickerItem(
                image: image,
                asset: asset,
                select: () {
                  if (widget.allowMultiSelect == false) {
                    imagePickerController.unselectOtherAssets(asset.id);
                  }

                  var isSelected = imagePickerController.assetIsSelected(asset);

                  if (isSelected) {
                    imagePickerController.toggleAssetSelection(asset);
                    return true;
                  }

                  if (widget.maxAllowedSelected != null &&
                      widget.maxAllowedSelected! <=
                          imagePickerController.getSelectedAssetsCount()) {
                    flashController.showMessageFlash(tr('assets.max_allowed',
                        namedArgs: {
                          'no': widget.maxAllowedSelected.toString()
                        }));
                    return true;
                  }

                  imagePickerController.toggleAssetSelection(asset);
                  return true;
                });
          });

      temp.add(assetWidget);
    }

    if (mounted) {
      setState(() {
        _assetWidgets.addAll(temp);
        _currentPage++;
      });
    }
  }

  void _handleChangeFolder(String newFolder) {
    if (mounted) {
      setState(() {
        _currentFolder = newFolder == ALL_IMAGES_FOLDER_NAME ? null : newFolder;
        _assetWidgets.clear();
        _currentPage = 0;
        _lastPage = -1;
      });
    }

    _fetchNewMedia();
  }

  Widget _renderFoldersDropdown() {
    var allImagesItem = DropdownMenuItem(
      value: ALL_IMAGES_FOLDER_NAME,
      child: Text(
        ALL_IMAGES_FOLDER_NAME,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).extension<CustomThemeFields>()!.title,
      ),
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        customButton: SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Text(
                    _currentFolder ?? ALL_IMAGES_FOLDER_NAME,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SvgPicture.asset(
                    'assets/icons/svg/down.svg',
                    height: 18,
                    width: 18,
                    semanticsLabel: 'Down',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        value: _currentFolder ?? ALL_IMAGES_FOLDER_NAME,
        style: Theme.of(context).extension<CustomThemeFields>()!.title,
        onChanged: (value) {
          _handleChangeFolder(value as String);
        },
        items: _folders.isEmpty
            ? [allImagesItem]
            : [
                allImagesItem,
                ..._folders.map(
                  (e) {
                    return DropdownMenuItem(
                      value: e.name,
                      child: Text(
                        e.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .title,
                      ),
                    );
                  },
                )
              ],
      ),
    );
  }

  Widget _renderBottomNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Flexible(
              child: ActionButton(
                onPressed: () {
                  goBack();
                },
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'assets.select',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title
                          .copyWith(
                            color: DarkColors.font_1,
                          ),
                    ).tr(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var allAssets = [..._cameraAssetWidgets, ..._assetWidgets];
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        appBar: SimpleAppBar(
            onBack: goBack,
            withSearch: false,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: IntrinsicWidth(
                  child: _renderFoldersDropdown(),
                )),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        imagePickerController.openCamera();
                      },
                      splashRadius: 24,
                      icon: SvgPicture.asset(
                        'assets/icons/svg/camera.svg',
                        height: 24,
                        width: 24,
                        semanticsLabel: 'Camera',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Container(
                      width: 16,
                    )
                  ],
                ),
              ],
            )),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scroll) {
            _handleScrollEvent(scroll);
            return true;
          },
          child: _cameraAssetWidgets.isEmpty && _assetWidgets.isEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'assets.no_images_in_folder',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title
                          .copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 22,
                          ),
                    ).tr(),
                  ),
                )
              : GridView.builder(
                  itemCount: allAssets.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return allAssets[index];
                  },
                ),
        ),
        bottomNavigationBar: _renderBottomNavbar(),
      ),
    );
  }
}
