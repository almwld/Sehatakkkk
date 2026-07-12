import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressService {
  // ============================================================
  // 📦 ضغط الصورة من File
  // ============================================================
  static Future<Uint8List> compressImage(File file, {int quality = 70}) async {
    try {
      var result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: quality,
        rotate: 0,
      );
      return result ?? Uint8List(0);
    } catch (e) {
      print('❌ Error compressing image: $e');
      return file.readAsBytes();
    }
  }

  // ============================================================
  // 💾 ضغط وحفظ الصورة كملف
  // ============================================================
  static Future<File?> compressAndSave(File file, {int quality = 70}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        rotate: 0,
        minWidth: 800,
        minHeight: 600,
      );
      return result;
    } catch (e) {
      print('❌ Error compressing and saving: $e');
      return null;
    }
  }

  // ============================================================
  // 📦 ضغط من Uint8List
  // ============================================================
  static Future<Uint8List> compressBytes(Uint8List bytes, {int quality = 70}) async {
    try {
      var result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 600,
        quality: quality,
        rotate: 0,
      );
      return result ?? bytes;
    } catch (e) {
      print('❌ Error compressing bytes: $e');
      return bytes;
    }
  }

  // ============================================================
  // 📦 ضغط صورة الملف الشخصي (خاص)
  // ============================================================
  static Future<File?> compressProfileImage(File file) async {
    return compressAndSave(file, quality: 60);
  }

  // ============================================================
  // 📦 ضغط صور متعددة دفعة واحدة
  // ============================================================
  static Future<List<File?>> compressMultiple(List<File> files, {int quality = 70}) async {
    List<Future<File?>> futures = [];
    for (var file in files) {
      futures.add(compressAndSave(file, quality: quality));
    }
    return await Future.wait(futures);
  }

  // ============================================================
  // 📦 ضغط الصورة مع تحديد الأبعاد
  // ============================================================
  static Future<File?> compressWithSize(File file, {int width = 800, int height = 600, int quality = 70}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: width,
        minHeight: height,
        quality: quality,
        rotate: 0,
      );
      return result;
    } catch (e) {
      print('❌ Error compressing with size: $e');
      return null;
    }
  }

  // ============================================================
  // 📊 حساب حجم الملف قبل وبعد الضغط
  // ============================================================
  static Future<Map<String, dynamic>> getCompressionStats(File original, File compressed) async {
    final originalSize = await original.length();
    final compressedSize = await compressed.length();
    final reduction = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(2);
    
    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'reduction': double.parse(reduction),
      'originalSizeKB': (originalSize / 1024).toStringAsFixed(2),
      'compressedSizeKB': (compressedSize / 1024).toStringAsFixed(2),
    };
  }
}
