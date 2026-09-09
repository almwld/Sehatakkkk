import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NextcloudService {
  static final NextcloudService _instance = NextcloudService._internal();
  factory NextcloudService() => _instance;
  NextcloudService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(minutes: 5),
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String baseUrl = '';
  String username = '';
  String password = '';

  Future<void> loadConfig() async {
    baseUrl = (await _storage.read(key: 'sehatak.nextcloud.base_url') ?? '')
        .trim().replaceFirst(RegExp(r'/$'), '');
    username = (await _storage.read(key: 'sehatak.nextcloud.username') ?? '').trim();
    password = await _storage.read(key: 'sehatak.nextcloud.app_password') ?? '';
  }

  Future<void> updateConfig({required String baseUrl, required String username, required String password}) async {
    this.baseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    this.username = username.trim();
    this.password = password;
    await _storage.write(key: 'sehatak.nextcloud.base_url', value: this.baseUrl);
    await _storage.write(key: 'sehatak.nextcloud.username', value: this.username);
    await _storage.write(key: 'sehatak.nextcloud.app_password', value: this.password);
  }

  Future<void> clearConfig() async {
    baseUrl = '';
    username = '';
    password = '';
    await Future.wait([
      _storage.delete(key: 'sehatak.nextcloud.base_url'),
      _storage.delete(key: 'sehatak.nextcloud.username'),
      _storage.delete(key: 'sehatak.nextcloud.app_password'),
    ]);
  }

  void _ensureConfigured() {
    if (baseUrl.isEmpty || username.isEmpty || password.isEmpty) {
      throw StateError('Nextcloud غير مهيأ؛ اضبط بياناته من إعدادات Nextcloud.');
    }
  }

  String _authToken() => base64Encode(utf8.encode('$username:$password'));
  String _normalizedBase() => baseUrl.replaceFirst(RegExp(r'/$'), '');

  Map<String, String> _headers() => {
        'OCS-APIRequest': 'true',
        'Authorization': 'Basic ${_authToken()}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  Future<NextcloudUploadResult> uploadFile({
    required File file,
    required String path,
    String? fileName,
    void Function(int, int)? onProgress,
  }) async {
    try {
      _ensureConfigured();
      final name = fileName ?? file.path.split('/').last;
      final safePath = path.split('/').where((p) => p.isNotEmpty && p != '..').map(Uri.encodeComponent).join('/');
      final fullPath = '/$safePath/$name';
      final response = await _dio.put<void>(
        '${_normalizedBase()}/remote.php/dav/files/${Uri.encodeComponent(username)}$fullPath',
        data: file.openRead(),
        options: Options(
          headers: {'Authorization': 'Basic ${_authToken()}', 'Content-Type': 'application/octet-stream'},
          contentType: 'application/octet-stream',
          validateStatus: (status) => status != null && status >= 200 && status < 400,
        ),
        onSendProgress: onProgress,
      );
      final success = response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 400;
      if (!success) return NextcloudUploadResult(success: false, path: fullPath, fileName: name, error: 'فشل رفع الملف: ${response.statusCode}');
      final publicUrl = await createPublicShare(fullPath);
      return NextcloudUploadResult(success: true, url: publicUrl, path: fullPath, fileName: name);
    } catch (e) {
      return NextcloudUploadResult(success: false, error: e.toString());
    }
  }

  Future<String?> createPublicShare(String remotePath) async {
    _ensureConfigured();
    try {
      final response = await http.post(
        Uri.parse('${_normalizedBase()}/ocs/v2.php/apps/files_sharing/api/v1/shares?format=json'),
        headers: _headers(),
        body: {'path': remotePath, 'shareType': '3'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (body['ocs'] as Map<String, dynamic>?)?['data'] as Map<String, dynamic>?;
      return data?['url']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      if (baseUrl.isEmpty) return false;
      final response = await http.get(Uri.parse('${_normalizedBase()}/status.php'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      _ensureConfigured();
      final response = await http.get(Uri.parse('${_normalizedBase()}/ocs/v2.php/cloud/user'), headers: _headers());
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class NextcloudUploadResult {
  final bool success;
  final String? url;
  final String? path;
  final String? fileName;
  final String? error;

  const NextcloudUploadResult({required this.success, this.url, this.path, this.fileName, this.error});
}
