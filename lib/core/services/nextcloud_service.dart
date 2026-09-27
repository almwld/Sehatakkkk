import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Media gateway for Sehatak.
///
/// Nextcloud credentials never live in the Flutter application. The client
/// authenticates with Firebase and the server performs the Nextcloud operation.
class NextcloudService {
  static final NextcloudService _instance = NextcloudService._internal();
  factory NextcloudService() => _instance;
  NextcloudService._internal();

  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://miraculous-compassion-production-1d54.up.railway.app',
  );

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(minutes: 10),
  ));

  // Kept for compatibility with the existing settings surface. These values
  // are intentionally never used for authentication or persisted.
  String baseUrl = backendUrl;
  String username = '';
  String password = '';

  Future<void> loadConfig() async {
    baseUrl = backendUrl;
    username = '';
    password = '';
  }

  Future<void> updateConfig({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    // Global Nextcloud credentials are server-owned. Ignore client-supplied
    // credentials rather than storing them in the device.
    this.baseUrl = backendUrl;
    this.username = '';
    this.password = '';
  }

  Future<void> clearConfig() async {
    baseUrl = backendUrl;
    username = '';
    password = '';
  }

  Future<String> _idToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('يجب تسجيل الدخول لاستخدام خادم الوسائط');
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('تعذر الحصول على رمز المصادقة');
    }
    return token;
  }

  String _cleanPart(String value) => value
      .trim()
      .replaceAll('\\', '')
      .replaceAll('/', '')
      .replaceAll('..', '');

  String _cleanLogicalPath(String path) => path
      .split('/')
      .map(_cleanPart)
      .where((part) => part.isNotEmpty && part != '.')
      .take(8)
      .join('/');

  Future<NextcloudUploadResult> uploadFile({
    required File file,
    required String path,
    String? fileName,
    void Function(int, int)? onProgress,
    bool createShare = true,
    CancelToken? cancelToken,
  }) async {
    try {
      if (!await file.exists()) {
        return const NextcloudUploadResult(
          success: false,
          error: 'الملف المحلي غير موجود',
        );
      }

      final name = _cleanPart(
        fileName ?? file.path.split(Platform.pathSeparator).last,
      );
      if (name.isEmpty) {
        return const NextcloudUploadResult(
          success: false,
          error: 'اسم الملف غير صالح',
        );
      }

      final bytes = await file.readAsBytes();
      final token = await _idToken();
      final mimeType = 'application/octet-stream';

      final response = await _dio.post<Map<String, dynamic>>(
        '$backendUrl/media/upload',
        queryParameters: {
          'path': _cleanLogicalPath(path),
          'fileName': name,
          'mimeType': mimeType,
          'createShare': createShare.toString(),
        },
        data: bytes,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': mimeType,
            'Content-Length': bytes.length.toString(),
          },
          responseType: ResponseType.json,
          validateStatus: (status) => status != null,
        ),
        onSendProgress: onProgress,
      );

      final body = response.data ?? const <String, dynamic>{};
      final fileData = body['file'] is Map
          ? Map<String, dynamic>.from(body['file'])
          : const <String, dynamic>{};
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300 || body['success'] != true) {
        return NextcloudUploadResult(
          success: false,
          error: body['message']?.toString() ??
              'فشل رفع الوسائط: HTTP $status',
        );
      }

      return NextcloudUploadResult(
        success: true,
        url: fileData['url']?.toString(),
        path: fileData['remotePath']?.toString(),
        fileName: fileData['fileName']?.toString() ?? name,
        shareReady: fileData['shareReady'] == true,
      );
    } on DioException catch (e) {
      return NextcloudUploadResult(
        success: false,
        error: e.response?.data is Map
            ? (e.response?.data['message']?.toString() ?? e.message)
            : e.message,
      );
    } catch (e) {
      return NextcloudUploadResult(success: false, error: e.toString());
    }
  }

  Future<String?> createPublicShare(String remotePath) async {
    try {
      final token = await _idToken();
      final response = await _dio.post<Map<String, dynamic>>(
        '$backendUrl/media/share',
        data: {'remotePath': remotePath},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.json,
          validateStatus: (status) => status != null,
        ),
      );
      if (response.statusCode != 200 || response.data?['success'] != true) {
        return null;
      }
      return response.data?['url']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<bool> verifyPublicUrl(String url) async {
    final client = HttpClient();
    var current = Uri.tryParse(url);
    if (current == null) return false;
    try {
      for (var hop = 0; hop <= 5; hop++) {
        final request = await client.getUrl(current);
        request.followRedirects = false;
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
        final response = await request.close().timeout(
              const Duration(seconds: 20),
            );
        final status = response.statusCode;
        final location = response.headers.value(HttpHeaders.locationHeader);
        await response.drain<void>();

        if (status == 200 || status == 206) return true;
        if (status >= 300 &&
            status < 400 &&
            location != null &&
            location.isNotEmpty) {
          final next = current.resolve(location);
          if (next.host != current.host) return false;
          current = next;
          continue;
        }
        return false;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      final response = await _dio.get(
        '$backendUrl/health',
        options: Options(validateStatus: (status) => status != null),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      final token = await _idToken();
      final response = await _dio.get(
        '$backendUrl/health',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status != null,
        ),
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
