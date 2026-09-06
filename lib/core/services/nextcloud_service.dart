import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NextcloudService {
  static final NextcloudService _instance = NextcloudService._internal();
  factory NextcloudService() => _instance;
  NextcloudService._internal();

  String baseUrl = const String.fromEnvironment('NEXTCLOUD_URL', defaultValue: '');
  String username = const String.fromEnvironment('NEXTCLOUD_USERNAME', defaultValue: '');
  String password = const String.fromEnvironment('NEXTCLOUD_PASSWORD', defaultValue: '');

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 60),
  ));

  String _basicAuth() => base64Encode(utf8.encode('$username:$password'));

  Map<String, String> _headers() => {
    'OCS-APIRequest': 'true',
    'Authorization': 'Basic ${_basicAuth()}',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  void _ensureConfigured() {
    if (baseUrl.isEmpty || username.isEmpty || password.isEmpty) {
      throw StateError('Nextcloud غير مهيأ؛ اضبط بياناته من إعدادات Nextcloud.');
    }
  }

  Future<NextcloudUploadResult> uploadFile({
    required File file,
    required String path,
    String? fileName,
    void Function(int, int)? onProgress,
  }) async {
    try {
      _ensureConfigured();
      final name = fileName ?? file.path.split('/').last;
      final normalizedBase = baseUrl.replaceFirst(RegExp(r'\/\$'), '');
      final fullPath = '/$path/$name';
      final response = await _dio.put(
        '$normalizedBase/remote.php/dav/files/$username$fullPath',
        data: await MultipartFile.fromFile(file.path, filename: name),
        options: Options(headers: {
          'Authorization': 'Basic ${_basicAuth()}',
          'Content-Type': 'application/octet-stream',
        }),
        onSendProgress: onProgress,
      );
      final success = response.statusCode == 201 || response.statusCode == 204;
      return NextcloudUploadResult(
        success: success,
        url: success ? '$normalizedBase/remote.php/dav/files/$username$fullPath' : null,
        path: fullPath,
        fileName: name,
        error: success ? null : 'فشل رفع الملف: ${response.statusCode}',
      );
    } catch (e) {
      return NextcloudUploadResult(success: false, error: e.toString());
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      if (baseUrl.isEmpty) return false;
      final response = await http.get(Uri.parse('${baseUrl.replaceFirst(RegExp(r'\/\$'), '')}/status.php'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      _ensureConfigured();
      final response = await http.get(
        Uri.parse('${baseUrl.replaceFirst(RegExp(r'\/\$'), '')}/ocs/v2.php/cloud/user'),
        headers: _headers(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateConfig({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    this.baseUrl = baseUrl.trim().replaceFirst(RegExp(r'\/\$'), '');
    this.username = username.trim();
    this.password = password;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nextcloud_base_url', this.baseUrl);
    await prefs.setString('nextcloud_username', this.username);
    await prefs.setString('nextcloud_password', this.password);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('nextcloud_base_url') ?? baseUrl;
    username = prefs.getString('nextcloud_username') ?? username;
    password = prefs.getString('nextcloud_password') ?? password;
  }
}

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
