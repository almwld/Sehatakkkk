import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NextcloudSecureService {
  NextcloudSecureService({FlutterSecureStorage? storage, Dio? dio})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ?? Dio();

  final FlutterSecureStorage _storage;
  final Dio _dio;

  Future<void> configure({
    required String serverUrl,
    required String username,
    required String appPassword,
  }) async {
    await _storage.write(
      key: 'sehatak.nextcloud.base_url',
      value: serverUrl.trim().replaceFirst(RegExp(r'/$'), ''),
    );
    await _storage.write(key: 'sehatak.nextcloud.username', value: username.trim());
    await _storage.write(key: 'sehatak.nextcloud.app_password', value: appPassword);
  }

  Future<bool> isConfigured() async {
    final values = await Future.wait([
      _storage.read(key: 'sehatak.nextcloud.base_url'),
      _storage.read(key: 'sehatak.nextcloud.username'),
      _storage.read(key: 'sehatak.nextcloud.app_password'),
    ]);
    return values.every((value) => value != null && value.isNotEmpty);
  }

  Future<String> upload({
    required File file,
    required String remotePath,
    ProgressCallback? onProgress,
  }) async {
    final baseUrl = (await _storage.read(key: 'sehatak.nextcloud.base_url') ?? '')
        .replaceFirst(RegExp(r'/$'), '');
    final username = await _storage.read(key: 'sehatak.nextcloud.username');
    final appPassword = await _storage.read(key: 'sehatak.nextcloud.app_password');
    if (baseUrl.isEmpty || username == null || username.isEmpty || appPassword == null || appPassword.isEmpty) {
      throw StateError('Nextcloud غير مهيأ');
    }

    final cleanPath = remotePath
        .split('/')
        .where((part) => part.isNotEmpty && part != '.' && part != '..')
        .map(Uri.encodeComponent)
        .join('/');
    final endpoint = '$baseUrl/remote.php/dav/files/${Uri.encodeComponent(username)}/$cleanPath';
    final token = base64Encode(utf8.encode('$username:$appPassword'));

    final response = await _dio.put<void>(
      endpoint,
      data: file.openRead(),
      options: Options(
        headers: {
          'Authorization': 'Basic $token',
          'Content-Type': 'application/octet-stream',
        },
        contentType: 'application/octet-stream',
        validateStatus: (status) => status != null && status >= 200 && status < 400,
      ),
      onSendProgress: onProgress,
    );

    if (response.statusCode == null || response.statusCode! >= 400) {
      throw StateError('فشل رفع الملف إلى Nextcloud (${response.statusCode})');
    }
    return endpoint;
  }

  Future<void> clearCredentials() async {
    await Future.wait([
      _storage.delete(key: 'sehatak.nextcloud.base_url'),
      _storage.delete(key: 'sehatak.nextcloud.username'),
      _storage.delete(key: 'sehatak.nextcloud.app_password'),
    ]);
  }
}
