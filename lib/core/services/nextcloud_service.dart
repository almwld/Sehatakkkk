// ============================================================
// 📁 lib/core/services/nextcloud_service.dart
// ☁️ خدمة Nextcloud المتكاملة
// ============================================================

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NextcloudService {
  static final NextcloudService _instance = NextcloudService._internal();
  factory NextcloudService() => _instance;
  NextcloudService._internal();

  // ✅ بيانات Tab Digital (شريك Nextcloud)
  String baseUrl = 'https://noa.it.tabdigital.cloud';
  String username = 'PlatformSehatak@gmail.com';
  String password = '10.10.10.1010.10.10.10';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // ============================================================
  // 🔐 المصادقة
  // ============================================================
  String _getBasicAuth() {
    final credentials = '$username:$password';
    return base64Encode(utf8.encode(credentials));
  }

  Map<String, String> _getHeaders() {
    return {
      'OCS-APIRequest': 'true',
      'Authorization': 'Basic ${_getBasicAuth()}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  Map<String, String> _getJsonHeaders() {
    return {
      'Authorization': 'Basic ${_getBasicAuth()}',
      'Content-Type': 'application/json',
    };
  }

  // ============================================================
  // 📤 رفع ملف
  // ============================================================
  Future<NextcloudUploadResult> uploadFile({
    required File file,
    required String path,
    String? fileName,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final name = fileName ?? file.path.split('/').last;
      final fullPath = '/$path/$name';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: name,
        ),
      });

      final response = await _dio.put(
        '$baseUrl/remote.php/dav/files/$username$fullPath',
        data: formData,
        options: Options(
          headers: _getJsonHeaders(),
          
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 204) {
        final url = '$baseUrl/remote.php/dav/files/$username$fullPath';
        return NextcloudUploadResult(
          success: true,
          url: url,
          path: fullPath,
          fileName: name,
        );
      }

      return NextcloudUploadResult(
        success: false,
        error: 'فشل رفع الملف: ${response.statusCode}',
      );
    } catch (e) {
      return NextcloudUploadResult(
        success: false,
        error: 'خطأ في رفع الملف: $e',
      );
    }
  }

  // ============================================================
  // 📥 تحميل ملف
  // ============================================================
  Future<String?> downloadFile(String path) async {
    try {
      final response = await _dio.get(
        '$baseUrl/remote.php/dav/files/$username/$path',
        options: Options(
          headers: _getJsonHeaders(),
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final fileName = path.split('/').last;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.data as List<int>);
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 🗑️ حذف ملف
  // ============================================================
  Future<bool> deleteFile(String path) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/remote.php/dav/files/$username/$path',
        options: Options(headers: _getJsonHeaders()),
      );
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 📁 إنشاء مجلد
  // ============================================================
  Future<bool> createFolder(String path) async {
    try {
      final response = await _dio.request(
        '$baseUrl/remote.php/dav/files/$username/$path',
        options: Options(
          method: 'MKCOL',
          headers: _getJsonHeaders(),
        ),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 💬 وظائف الدردشة (المحفوظة)
  // ============================================================
  Future<String> getChatUrl(String chatId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ocs/v2.php/apps/spreed/api/v4/room'),
        headers: _getHeaders(),
        body: {
          'roomType': '1',
          'invite': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ocs']['data']['url'];
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('فشل إنشاء غرفة الدردشة: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Nextcloud error: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String roomId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ocs/v2.php/apps/spreed/api/v4/room/$roomId/message'),
        headers: _getHeaders(),
        body: {'message': message},
      );

      if (response.statusCode != 201) {
        throw Exception('فشل إرسال الرسالة');
      }
    } catch (e) {
      print('❌ Send message error: $e');
    }
  }

  // ============================================================
  // 🔍 التحقق من الخادم
  // ============================================================
  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status.php'),
      );
      print('✅ Server status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server status error: $e');
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ocs/v2.php/cloud/user'),
        headers: _getHeaders(),
      );
      print('✅ Auth test: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Auth test error: $e');
      return false;
    }
  }

  // ============================================================
  // 💾 حفظ الإعدادات
  // ============================================================
  Future<void> updateConfig({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    this.baseUrl = baseUrl;
    this.username = username;
    this.password = password;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nextcloud_base_url', baseUrl);
    await prefs.setString('nextcloud_username', username);
    await prefs.setString('nextcloud_password', password);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('nextcloud_base_url') ?? baseUrl;
    username = prefs.getString('nextcloud_username') ?? username;
    password = prefs.getString('nextcloud_password') ?? password;
  }
}

// ============================================================
// 📦 نموذج نتيجة الرفع
// ============================================================
class NextcloudUploadResult {
  final bool success;
  final String? url;
  final String? path;
  final String? fileName;
  final String? error;

  const NextcloudUploadResult({
    required this.success,
    this.url,
    this.path,
    this.fileName,
    this.error,
  });
}
