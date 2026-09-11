import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressService {
  static Future<Uint8List> compressImage(File file, {int quality = 70}) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: quality,
        rotate: 0,
      );
      return result ?? await file.readAsBytes();
    } catch (e) {
      print('❌ Error compressing image: $e');
      return file.readAsBytes();
    }
  }

  static Future<File?> compressAndSave(File file, {int quality = 70}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        rotate: 0,
        minWidth: 800,
        minHeight: 600,
      );
      return result == null ? null : File(result.path);
    } catch (e) {
      print('❌ Error compressing and saving: $e');
      return null;
    }
  }

  static Future<Uint8List> compressBytes(Uint8List bytes, {int quality = 70}) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 600,
        quality: quality,
        rotate: 0,
      );
      return result;
    } catch (e) {
      print('❌ Error compressing bytes: $e');
      return bytes;
    }
  }

  static Future<File?> compressProfileImage(File file) => compressAndSave(file, quality: 60);

  static Future<List<File?>> compressMultiple(List<File> files, {int quality = 70}) async {
    return Future.wait(files.map((file) => compressAndSave(file, quality: quality)));
  }

  static Future<File?> compressWithSize(
    File file, {
    int width = 800,
    int height = 600,
    int quality = 70,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: width,
        minHeight: height,
        quality: quality,
        rotate: 0,
      );
      return result == null ? null : File(result.path);
    } catch (e) {
      print('❌ Error compressing with size: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getCompressionStats(File original, File compressed) async {
    final originalSize = await original.length();
    final compressedSize = await compressed.length();
    final reduction = originalSize == 0
        ? 0.0
        : ((originalSize - compressedSize) / originalSize * 100);

    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'reduction': double.parse(reduction.toStringAsFixed(2)),
      'originalSizeKB': (originalSize / 1024).toStringAsFixed(2),
      'compressedSizeKB': (compressedSize / 1024).toStringAsFixed(2),
    };
  }
}
