import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageCompressor {
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const int quality = 75;

  static Future<File> compressImage(File file) async {
    try {
      // ✅ قراءة الصورة
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return file;

      // ✅ تغيير الحجم
      img.Image resized = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : image.width,
        height: image.height > maxHeight ? maxHeight : image.height,
        interpolation: img.Interpolation.average,
      );

      // ✅ ضغط الجودة
      final compressedBytes = img.encodeJpg(resized, quality: quality);

      // ✅ حفظ الملف المضغوط
      final fileName = path.basenameWithoutExtension(file.path);
      final dir = path.dirname(file.path);
      final compressedFile = File('$dir/${fileName}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      print('✅ تم ضغط الصورة: ${file.lengthSync()} → ${compressedFile.lengthSync()} bytes');
      return compressedFile;
    } catch (e) {
      print('❌ فشل ضغط الصورة: $e');
      return file;
    }
  }

  static Future<File?> compressImageIfNeeded(File file) async {
    final size = await file.length();
    if (size > 1024 * 1024) {
      return await compressImage(file);
    }
    return file;
  }
}
