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
    sendTimeout: const Duration(minutes: 10),
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String baseUrl = '';
  String username = '';
  String password = '';

  /// Loads the platform Nextcloud account configured for this installation.
  /// Credentials remain in secure storage and are never written to Firestore.
  Future<void> loadConfig() async {
    baseUrl = (await _storage.read(key: 'sehatak.nextcloud.base_url') ?? '')
        .trim()
        .replaceFirst(RegExp(r'/$'), '');
    username = (await _storage.read(key: 'sehatak.nextcloud.username') ?? '').trim();
    password = await _storage.read(key: 'sehatak.nextcloud.app_password') ?? '';
  }

  Future<void> updateConfig({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
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
      throw StateError('خادم الوسائط غير مهيأ في هذا الجهاز.');
    }
  }

  String _authToken() => base64Encode(utf8.encode('$username:$password'));
  String _normalizedBase() => baseUrl.replaceFirst(RegExp(r'/$'), '');

  Map<String, String> _headers() => {
        'OCS-APIRequest': 'true',
        'Authorization': 'Basic ${_authToken()}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  String _cleanPart(String value) => value
      .trim()
      .replaceAll('\\', '')
      .replaceAll('/', '')
      .replaceAll('..', '');

  String _cleanLogicalPath(String path) => path
      .split('/')
      .map(_cleanPart)
      .where((part) => part.isNotEmpty && part != '.')
      .join('/');

  /// The platform's canonical media root. It mirrors NEXTCLOUD_ROOT_PATH in
  /// the server implementation, whose production default is `Sehatak`.
  String _platformPath(String path) {
    final clean = _cleanLogicalPath(path);
    if (clean.isEmpty) return 'Sehatak';
    return clean == 'Sehatak' || clean.startsWith('Sehatak/')
        ? clean
        : 'Sehatak/$clean';
  }

  String _davUrl(String remotePath) {
    final cleanPath = remotePath
        .replaceFirst(RegExp(r'^/+'), '')
        .split('/')
        .where((part) => part.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');
    return '${_normalizedBase()}/remote.php/dav/files/${Uri.encodeComponent(username)}/$cleanPath';
  }

  /// Creates every directory in the path before PUT. WebDAV does not create
  /// missing parent folders automatically; this was the main difference from
  /// the tested server-side upload path.
  Future<void> _ensureDirectories(String directory) async {
    var current = '';
    for (final part in _cleanLogicalPath(directory).split('/')) {
      if (part.isEmpty) continue;
      current = current.isEmpty ? part : '$current/$part';
      final response = await _dio.request<void>(
        _davUrl(current),
        options: Options(
          method: 'MKCOL',
          headers: {
            'Authorization': 'Basic ${_authToken()}',
          },
          validateStatus: (status) => status != null,
        ),
      );
      final status = response.statusCode ?? 0;
      // 201 = created, 405 = already exists. Both are valid for our purpose.
      if (status != 201 && status != 405) {
        throw StateError('فشل إنشاء مجلد الوسائط في Nextcloud: HTTP $status');
      }
    }
  }

  Future<NextcloudUploadResult> uploadFile({
    required File file,
    required String path,
    String? fileName,
    void Function(int, int)? onProgress,
    bool createShare = true,
  }) async {
    try {
      _ensureConfigured();
      if (!await file.exists()) {
        return const NextcloudUploadResult(success: false, error: 'الملف المحلي غير موجود');
      }

      final name = _cleanPart(fileName ?? file.path.split(Platform.pathSeparator).last);
      if (name.isEmpty) {
        return const NextcloudUploadResult(success: false, error: 'اسم الملف غير صالح');
      }

      // Keep the exact production storage namespace used by the server path:
      // Sehatak/chats/{chatId}/{folder}/{fileName}
      final logicalDirectory = _platformPath(path);
      final remotePath = '$logicalDirectory/$name';
      final davUrl = _davUrl(remotePath);

      await _ensureDirectories(logicalDirectory);

      final response = await _dio.put<void>(
        davUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Authorization': 'Basic ${_authToken()}',
            'Content-Type': 'application/octet-stream',
          },
          contentType: 'application/octet-stream',
          validateStatus: (status) => status != null,
        ),
        onSendProgress: onProgress,
      );

      final status = response.statusCode ?? 0;
      // Nextcloud WebDAV PUT normally returns 201 for a new object and 204
      // when replacing an existing object.
      if (status != 201 && status != 204) {
        return NextcloudUploadResult(
          success: false,
          path: remotePath,
          fileName: name,
          error: 'فشل رفع الملف إلى Nextcloud: HTTP $status',
        );
      }

      if (!createShare) {
        return NextcloudUploadResult(success: true, path: remotePath, fileName: name);
      }

      String? publicUrl;
      String? shareError;
      try {
        publicUrl = await createPublicShare(remotePath);
        if (publicUrl == null || publicUrl.isEmpty) {
          shareError = 'تم رفع الملف بنجاح، لكن رابط الوصول لم يجهز بعد';
        }
      } catch (e) {
        shareError = 'تم رفع الملف بنجاح، وتعذر تجهيز رابط الوصول: $e';
      }

      return NextcloudUploadResult(
        success: true,
        url: publicUrl,
        path: remotePath,
        fileName: name,
        error: shareError,
        shareReady: publicUrl != null && publicUrl.isNotEmpty,
      );
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
        body: {'path': '/${_cleanLogicalPath(remotePath)}', 'shareType': '3'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final ocs = body['ocs'] as Map<String, dynamic>?;
      final data = ocs?['data'] as Map<String, dynamic>?;
      final shareUrl = data?['url']?.toString();
      if (shareUrl == null || shareUrl.isEmpty) return null;
      return '${shareUrl.replaceFirst(RegExp(r'/$'), '')}/download';
    } catch (_) {
      return null;
    }
  }

  /// Checks the actual public download endpoint without requiring a HEAD
  /// implementation and without downloading an entire large video/audio file.
  Future<bool> verifyPublicUrl(String url) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers['Range'] = 'bytes=0-0';
      final streamed = await http.Client().send(request).timeout(const Duration(seconds: 20));
      final status = streamed.statusCode;
      final contentLength = streamed.contentLength;
      await streamed.stream.drain<void>();
      return (status == 200 || status == 206) && (contentLength == null || contentLength > 0);
    } catch (_) {
      return false;
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
      final response = await http.get(
        Uri.parse('${_normalizedBase()}/ocs/v2.php/cloud/user'),
        headers: _headers(),
      );
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
  final bool shareReady;

  const NextcloudUploadResult({
    required this.success,
    this.url,
    this.path,
    this.fileName,
    this.error,
    this.shareReady = false,
  });
}
