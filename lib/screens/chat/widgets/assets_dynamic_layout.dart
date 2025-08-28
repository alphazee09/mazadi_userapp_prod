import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class DynamicImageLayout extends StatelessWidget {
  final List<String>? assetPaths; // Network images
  final List<XFile>? cameraAssets; // Camera-captured images
  final List<AssetEntity>? galleryAssets; // Gallery images

  DynamicImageLayout({
    this.assetPaths,
    this.cameraAssets,
    this.galleryAssets,
  });

  Widget _buildNetworkImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        path,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCameraImage(XFile asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(asset.path),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGalleryImage(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _wrapImageWithConstraints(Widget image, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: image,
    );
  }

  Widget _buildSingleImage(Widget image, double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
        height: 200,
        width: width,
        child: image,
      ),
    );
  }

  Widget _buildImageWithOverlay(
      BuildContext context, Widget image, double height, int remainingCount) {
    return Stack(
      children: [
        _wrapImageWithConstraints(image, double.infinity, height),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combine all assets into a single list
    final List<Widget> imageWidgets = [
      ...?assetPaths?.map((path) => _buildNetworkImage(path)),
      ...?cameraAssets?.map((asset) => _buildCameraImage(asset)),
      ...?galleryAssets?.map((asset) => _buildGalleryImage(asset)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double imageHeight = maxWidth / 2 - 4;

        if (imageWidgets.isEmpty) {
          return Center(
            child: Text('No images available'),
          );
        } else if (imageWidgets.length == 1) {
          return _buildSingleImage(imageWidgets[0], maxWidth);
        } else if (imageWidgets.length == 3) {
          return Column(
            children: [
              Row(
                children: [
                  _wrapImageWithConstraints(
                      imageWidgets[0], maxWidth / 2 - 4, imageHeight),
                  SizedBox(width: 8),
                  _wrapImageWithConstraints(
                      imageWidgets[1], maxWidth / 2 - 4, imageHeight),
                ],
              ),
              SizedBox(height: 8),
              _wrapImageWithConstraints(imageWidgets[2], maxWidth, imageHeight),
            ],
          );
        } else {
          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: (maxWidth / 2) / imageHeight,
            ),
            itemCount: (imageWidgets.length > 4) ? 4 : imageWidgets.length,
            itemBuilder: (context, index) {
              if (index == 3 && imageWidgets.length > 4) {
                return _buildImageWithOverlay(
                  context,
                  imageWidgets[index],
                  imageHeight,
                  imageWidgets.length - 4,
                );
              } else {
                return _wrapImageWithConstraints(
                  imageWidgets[index],
                  maxWidth / 2 - 4,
                  imageHeight,
                );
              }
            },
          );
        }
      },
    );
  }
}
