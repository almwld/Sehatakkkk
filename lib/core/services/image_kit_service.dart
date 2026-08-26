// ============================================================
// 📁 lib/core/services/image_kit_service.dart
// 🖼️ خدمة ImageKit لإدارة الصور
// ============================================================

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sehatak/core/config/imagekit_config.dart';

class ImageKitService {
  static final ImageKitService _instance = ImageKitService._internal();
  factory ImageKitService() => _instance;
  ImageKitService._internal();

  // ✅ عنوان URL الأساسي
  static const String _baseUrl = ImageKitConfig.baseUrl;

  // ✅ مفتاح API (يجب وضعه في ملف .env أو secure storage)
  static const String _apiKey = 'YOUR_IMAGEKIT_API_KEY';
  static const String _privateKey = 'YOUR_IMAGEKIT_PRIVATE_KEY';

  // ============================================================
  // 📤 تحميل صورة إلى ImageKit
  // ============================================================

  Future<String> uploadImage({
    required File file,
    required String folder,
    String? fileName,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = '$_baseUrl/v1/files/upload';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // ✅ إضافة التوثيق
      request.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}';

      // ✅ إضافة الملف
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName ?? file.path.split('/').last,
        ),
      );

      // ✅ إضافة المجلد
      request.fields['folder'] = folder;

      // ✅ إضافة البيانات الوصفية
      if (customMetadata != null) {
        request.fields['customMetadata'] = jsonEncode(customMetadata);
      }

      // ✅ إرسال الطلب
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return result['url'] as String;
      } else {
        throw Exception('❌ Upload failed: ${result['message']}');
      }
    } catch (e) {
      print('❌ Image upload error: $e');
      rethrow;
    }
  }

  // ============================================================
  // 📤 تحميل صورة من URL إلى ImageKit
  // ============================================================

  Future<String> uploadImageFromUrl({
    required String imageUrl,
    required String folder,
    String? fileName,
  }) async {
    try {
      // ✅ تحميل الصورة من URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('❌ Failed to download image from URL');
      }

      // ✅ حفظ مؤقت
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${fileName ?? DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(response.bodyBytes);

      // ✅ رفع إلى ImageKit
      return await uploadImage(
        file: tempFile,
        folder: folder,
        fileName: fileName,
      );
    } catch (e) {
      print('❌ Upload from URL error: $e');
      rethrow;
    }
  }

  // ============================================================
  # 🗑️ حذف صورة من ImageKit
  // ============================================================

  Future<void> deleteImage(String fileId) async {
    try {
      final url = '$_baseUrl/v1/files/$fileId';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('❌ Delete failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Image delete error: $e');
      rethrow;
    }
  }

  // ============================================================
  # 📋 الحصول على قائمة الصور
  // ============================================================

  Future<List<Map<String, dynamic>>> listImages({
    String? folder,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/files')
          .replace(queryParameters: {
        if (folder != null) 'folder': folder,
        'limit': limit.toString(),
        'page': page.toString(),
      });

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('❌ List failed: ${response.body}');
      }
    } catch (e) {
      print('❌ List images error: $e');
      rethrow;
    }
  }

  // ============================================================
  # 🔍 البحث عن صورة
  // ============================================================

  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/files/search')
          .replace(queryParameters: {'q': query});

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('❌ Search failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Search images error: $e');
      rethrow;
    }
  }

  // ============================================================
  # 🖼️ الحصول على URL مع تحويلات
  // ============================================================

  static String getImageUrl({
    required String path,
    int? width,
    int? height,
    bool crop = false,
    int quality = 80,
    String format = 'auto',
  }) {
    String url = '$_baseUrl$path';

    // ✅ إضافة معلمات التحويل
    final params = <String>[];
    if (width != null) params.add('w-$width');
    if (height != null) params.add('h-$height');
    if (crop) params.add('c-main');
    params.add('q-$quality');
    params.add('f-$format');

    if (params.isNotEmpty) {
      url += '?tr=${params.join(',')}';
    }

    return url;
  }

  // ============================================================
  # 📦 تحويل الصورة إلى Base64
  // ============================================================

  static Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('❌ Image to base64 error: $e');
      return '';
    }
  }

  // ============================================================
  # 📥 تحميل صورة من ImageKit
  // ============================================================

  static Future<File?> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('❌ Download failed');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      print('❌ Download image error: $e');
      return null;
    }
  }

  // ============================================================
  # 📊 إحصائيات الصور
  // ============================================================

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final url = Uri.parse('$_baseUrl/v1/files/statistics');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_privateKey'))}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('❌ Statistics failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Statistics error: $e');
      return {};
    }
  }
}
