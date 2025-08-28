import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class ImageCompressService extends GetxService {
  Future<File> compressFile(XFile file) async {
    return compressFileByPath(file.path);
  }

  Future<File> compressFileByPath(String path,
      [int? minHeight, int? minWidth]) async {
    var fileBytesData = File.fromUri(Uri.parse(path)).readAsBytesSync();

    var result = await FlutterImageCompress.compressWithList(
      fileBytesData.buffer.asUint8List(),
      minHeight: minHeight ?? 844,
      minWidth: minWidth ?? 1500,
      quality: 50,
    );

    var file = await createFileFromUint8List(result, uuid.v4());
    return file;
  }

  Future<File> createFileFromUint8List(Uint8List data, String sufix) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File tempFile = File('$tempPath/$sufix.bin');
    await tempFile.writeAsBytes(data);
    return tempFile;
  }
}
