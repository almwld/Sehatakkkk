import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/livekit_config.dart';
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
  Future<void>? _configLoadFuture;

  String baseUrl = '';
  String username = '';
  String password = '';

  Future<void> loadConfig() async {
    baseUrl = (await _storage.read(key: 'sehatak.nextcloud.base_url') ?? '')
        .trim()
        .replaceFirst(RegExp(r'/$'), '');
    username = (await _storage.read(key: 'sehatak.nextcloud.username') ?? '').trim();
    password = await _storage.read(key: 'sehatak.nextcloud.app_password') ?? '';
    debugPrint('Nextcloud credentials loaded: ${baseUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty}');
  }

  Future<void> ensureConfigured() async {
    if (baseUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty) return;
    final pending = _configLoadFuture ??= loadConfig();
    try {
      await pending;
    } finally {
      if (identical(_configLoadFuture, pending)) _configLoadFuture = null;
    }
    _ensureConfigured();
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
      throw StateError('خادم الوسائط غير مهيأ؛ تحقق من إعدادات Nextcloud المحفوظة');
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
      .replaceAll('\\\\', '')
      .replaceAll('/', '')
      .replaceAll('..', '');

  String _cleanLogicalPath(String path) => path
      .split('/')
      .map(_cleanPart)
      .where((part) => part.isNotEmpty && part != '.')
      .join('/');

  String _platformPath(String path) {
    final segments = _cleanLogicalPath(path)
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    // Canonicalize any legacy casing/repeated root prefix to one Sehatak root.
    while (segments.isNotEmpty && segments.first.toLowerCase() == 'sehatak') {
      segments.removeAt(0);
    }
    return segments.isEmpty ? 'Sehatak' : 'Sehatak/${segments.join('/')}';
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

  Future<void> _ensureDirectories(String directory, {CancelToken? cancelToken}) async {
    var current = '';
    for (final part in _cleanLogicalPath(directory).split('/')) {
      if (part.isEmpty) continue;
      current = current.isEmpty ? part : '$current/$part';
      debugPrint('📁 MKCOL: $current');
      final response = await _dio.request<void>(
        _davUrl(current),
        options: Options(
          method: 'MKCOL',
          headers: {'Authorization': 'Basic ${_authToken()}'},
          validateStatus: (status) => status != null,
        ),
        cancelToken: cancelToken,
      );
      final status = response.statusCode ?? 0;
      debugPrint('📁 MKCOL response: $status');
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
    CancelToken? cancelToken,
  }) async {
    try {
      await ensureConfigured();
      _ensureConfigured();
      if (!await file.exists()) {
        return const NextcloudUploadResult(success: false, error: 'الملف المحلي غير موجود');
      }
      final name = _cleanPart(fileName ?? file.path.split(Platform.pathSeparator).last);
      if (name.isEmpty) return const NextcloudUploadResult(success: false, error: 'اسم الملف غير صالح');
      final logicalDirectory = _platformPath(path);
      final remotePath = '$logicalDirectory/$name';
      final davUrl = _davUrl(remotePath);
      final fileLength = await file.length();
      debugPrint('📤 PUT: $davUrl');
      debugPrint('📤 file size: $fileLength');

      await _ensureDirectories(logicalDirectory, cancelToken: cancelToken);

      final response = await _dio.put<void>(
        davUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Authorization': 'Basic ${_authToken()}',
            'Content-Type': 'application/octet-stream',
            'Content-Length': fileLength.toString(),
          },
          contentType: 'application/octet-stream',
          validateStatus: (status) => status != null,
        ),
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      );
      final status = response.statusCode ?? 0;
      debugPrint('📤 PUT status: $status');
      if (status != 201 && status != 204) {
        return NextcloudUploadResult(success: false, path: remotePath, fileName: name, error: 'فشل رفع الملف إلى Nextcloud: HTTP $status');
      }
      if (!createShare) return NextcloudUploadResult(success: true, path: remotePath, fileName: name);

      String? publicUrl;
      String? shareError;
      try {
        publicUrl = await createPublicShare(remotePath);
        if (publicUrl == null || publicUrl.isEmpty) shareError = 'تم رفع الملف بنجاح، لكن رابط الوصول لم يجهز بعد';
      } catch (e, st) {
        debugPrint('❌ createPublicShare failed: $e');
        debugPrint('❌ stack: $st');
        shareError = 'تم رفع الملف بنجاح، وتعذر تجهيز رابط الوصول: $e';
      }
      return NextcloudUploadResult(success: true, url: publicUrl, path: remotePath, fileName: name, error: shareError, shareReady: publicUrl != null && publicUrl.isNotEmpty);
    } catch (e, st) {
      if (e is DioException && CancelToken.isCancel(e)) rethrow;
      debugPrint('❌ uploadFile failed: $e');
      debugPrint('❌ stack: $st');
      return NextcloudUploadResult(success: false, error: e.toString());
    }
  }

  String privateDownloadUrl(String remotePath) {
    final base = LiveKitConfig.tokenServerUrl.replaceFirst(RegExp(r'/
    await ensureConfigured();
    _ensureConfigured();
    try {
      final response = await http.post(
        Uri.parse('${_normalizedBase()}/ocs/v2.php/apps/files_sharing/api/v1/shares?format=json'),
        headers: _headers(),
        body: {'path': '/${_cleanLogicalPath(remotePath)}', 'shareType': '3'},
      );
      debugPrint('🔗 Share status: ${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final ocs = body['ocs'] as Map<String, dynamic>?;
      final data = ocs?['data'] as Map<String, dynamic>?;
      final shareUrl = data?['url']?.toString();
      if (shareUrl == null || shareUrl.isEmpty) return null;

      return '${shareUrl.replaceFirst(RegExp(r'/$'), '')}/download';
    } catch (e, st) {
      debugPrint('❌ createPublicShare failed: $e');
      debugPrint('❌ stack: $st');
      return null;
    }
  }

  /// Verifies the same redirect behavior used by media players.
  /// The server returns 303 -> public.php/dav -> 200 for a normal GET.
  /// A Range request returns 500 on this server, so verification must not
  /// force a Range header.
  Future<bool> verifyPublicUrl(String url) async {
    final client = http.Client();
    var current = Uri.parse(url);
    try {
      for (var hop = 0; hop <= 5; hop++) {
        final request = http.Request('GET', current)
          ..followRedirects = false
          ..maxRedirects = 0;
        final response = await client.send(request).timeout(const Duration(seconds: 20));
        final status = response.statusCode;
        final location = response.headers['location'];
        final contentLength = response.contentLength;
        final contentType = response.headers['content-type'];
        debugPrint(
          '🔗 verifyPublicUrl hop=$hop status=$status '
          'location=${location == null ? '(none)' : '(present)'} contentType=${contentType ?? '(none)'}',
        );

        if (status == 200 || status == 206) {
          await response.stream.listen(null).cancel();
          return contentLength == null || contentLength > 0;
        }

        if (status >= 300 && status < 400 && location != null && location.isNotEmpty) {
          await response.stream.listen(null).cancel();
          final next = current.resolve(location);
          if (next.host != current.host) {
            debugPrint('❌ verifyPublicUrl rejected cross-host redirect: ${next.host}');
            return false;
          }
          current = next;
          continue;
        }

        await response.stream.listen(null).cancel();
        return false;
      }

      debugPrint('❌ verifyPublicUrl exceeded redirect limit url=$url');
      return false;
    } catch (e, st) {
      debugPrint('❌ verifyPublicUrl failed for $url: $e');
      debugPrint('❌ stack: $st');
      return false;
    } finally {
      client.close();
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      await ensureConfigured();
      final response = await http.get(Uri.parse('${_normalizedBase()}/status.php'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      await ensureConfigured();
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
}), '');
    return Uri.parse('$base/media/download')
        .replace(queryParameters: {'remotePath': remotePath})
        .toString();
  }

  Future<NextcloudUploadResult> uploadViaServer({
    required File file,
    required String chatId,
    required String messageId,
    String? fileName,
    String? mimeType,
    bool createShare = false,
    void Function(int, int)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('يجب تسجيل الدخول قبل رفع الوسائط');
      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw StateError('تعذر الحصول على رمز مصادقة Firebase');
      }
      if (!await file.exists()) {
        return const NextcloudUploadResult(success: false, error: 'الملف المحلي غير موجود');
      }

      final name = _cleanPart(fileName ?? file.uri.pathSegments.last);
      if (name.isEmpty) {
        return const NextcloudUploadResult(success: false, error: 'اسم الملف غير صالح');
      }
      final contentType = mimeType?.trim().isNotEmpty == true
          ? mimeType!.trim()
          : 'application/octet-stream';
      final length = await file.length();
      final base = LiveKitConfig.tokenServerUrl.replaceFirst(RegExp(r'/
    await ensureConfigured();
    _ensureConfigured();
    try {
      final response = await http.post(
        Uri.parse('${_normalizedBase()}/ocs/v2.php/apps/files_sharing/api/v1/shares?format=json'),
        headers: _headers(),
        body: {'path': '/${_cleanLogicalPath(remotePath)}', 'shareType': '3'},
      );
      debugPrint('🔗 Share status: ${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final ocs = body['ocs'] as Map<String, dynamic>?;
      final data = ocs?['data'] as Map<String, dynamic>?;
      final shareUrl = data?['url']?.toString();
      if (shareUrl == null || shareUrl.isEmpty) return null;

      return '${shareUrl.replaceFirst(RegExp(r'/$'), '')}/download';
    } catch (e, st) {
      debugPrint('❌ createPublicShare failed: $e');
      debugPrint('❌ stack: $st');
      return null;
    }
  }

  /// Verifies the same redirect behavior used by media players.
  /// The server returns 303 -> public.php/dav -> 200 for a normal GET.
  /// A Range request returns 500 on this server, so verification must not
  /// force a Range header.
  Future<bool> verifyPublicUrl(String url) async {
    final client = http.Client();
    var current = Uri.parse(url);
    try {
      for (var hop = 0; hop <= 5; hop++) {
        final request = http.Request('GET', current)
          ..followRedirects = false
          ..maxRedirects = 0;
        final response = await client.send(request).timeout(const Duration(seconds: 20));
        final status = response.statusCode;
        final location = response.headers['location'];
        final contentLength = response.contentLength;
        final contentType = response.headers['content-type'];
        debugPrint(
          '🔗 verifyPublicUrl hop=$hop status=$status '
          'location=${location == null ? '(none)' : '(present)'} contentType=${contentType ?? '(none)'}',
        );

        if (status == 200 || status == 206) {
          await response.stream.listen(null).cancel();
          return contentLength == null || contentLength > 0;
        }

        if (status >= 300 && status < 400 && location != null && location.isNotEmpty) {
          await response.stream.listen(null).cancel();
          final next = current.resolve(location);
          if (next.host != current.host) {
            debugPrint('❌ verifyPublicUrl rejected cross-host redirect: ${next.host}');
            return false;
          }
          current = next;
          continue;
        }

        await response.stream.listen(null).cancel();
        return false;
      }

      debugPrint('❌ verifyPublicUrl exceeded redirect limit url=$url');
      return false;
    } catch (e, st) {
      debugPrint('❌ verifyPublicUrl failed for $url: $e');
      debugPrint('❌ stack: $st');
      return false;
    } finally {
      client.close();
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      await ensureConfigured();
      final response = await http.get(Uri.parse('${_normalizedBase()}/status.php'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      await ensureConfigured();
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
}), '');
      final uri = Uri.parse('$base/media/upload').replace(queryParameters: {
        'chatId': chatId,
        'messageId': messageId,
        'fileName': name,
        'mimeType': contentType,
        'createShare': createShare ? 'true' : 'false',
      });

      final response = await _dio.post<dynamic>(
        uri.toString(),
        data: file.openRead(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/octet-stream',
            'Content-Length': length.toString(),
          },
          contentType: 'application/octet-stream',
          responseType: ResponseType.json,
          validateStatus: (status) => status != null,
        ),
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      );

      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (response.statusCode != 201 || body['success'] != true) {
        return NextcloudUploadResult(
          success: false,
          error: body['message']?.toString() ?? 'فشل رفع الوسائط عبر الخادم',
        );
      }
      final fileData = body['file'] is Map
          ? Map<String, dynamic>.from(body['file'] as Map)
          : <String, dynamic>{};
      final remotePath = fileData['remotePath']?.toString();
      if (remotePath == null || remotePath.isEmpty) {
        return const NextcloudUploadResult(success: false, error: 'الخادم لم يُرجع مسار الملف');
      }
      final url = fileData['url']?.toString();
      return NextcloudUploadResult(
        success: true,
        url: url?.isNotEmpty == true ? url : null,
        path: remotePath,
        fileName: fileData['fileName']?.toString() ?? name,
        shareReady: fileData['shareReady'] == true,
      );
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) rethrow;
      return NextcloudUploadResult(success: false, error: e.toString());
    }
  }

  Future<String?> createPublicShareViaServer(String remotePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول قبل مشاركة الملف');
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw StateError('تعذر الحصول على رمز مصادقة Firebase');
    }
    final base = LiveKitConfig.tokenServerUrl.replaceFirst(RegExp(r'/
    await ensureConfigured();
    _ensureConfigured();
    try {
      final response = await http.post(
        Uri.parse('${_normalizedBase()}/ocs/v2.php/apps/files_sharing/api/v1/shares?format=json'),
        headers: _headers(),
        body: {'path': '/${_cleanLogicalPath(remotePath)}', 'shareType': '3'},
      );
      debugPrint('🔗 Share status: ${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final ocs = body['ocs'] as Map<String, dynamic>?;
      final data = ocs?['data'] as Map<String, dynamic>?;
      final shareUrl = data?['url']?.toString();
      if (shareUrl == null || shareUrl.isEmpty) return null;

      return '${shareUrl.replaceFirst(RegExp(r'/$'), '')}/download';
    } catch (e, st) {
      debugPrint('❌ createPublicShare failed: $e');
      debugPrint('❌ stack: $st');
      return null;
    }
  }

  /// Verifies the same redirect behavior used by media players.
  /// The server returns 303 -> public.php/dav -> 200 for a normal GET.
  /// A Range request returns 500 on this server, so verification must not
  /// force a Range header.
  Future<bool> verifyPublicUrl(String url) async {
    final client = http.Client();
    var current = Uri.parse(url);
    try {
      for (var hop = 0; hop <= 5; hop++) {
        final request = http.Request('GET', current)
          ..followRedirects = false
          ..maxRedirects = 0;
        final response = await client.send(request).timeout(const Duration(seconds: 20));
        final status = response.statusCode;
        final location = response.headers['location'];
        final contentLength = response.contentLength;
        final contentType = response.headers['content-type'];
        debugPrint(
          '🔗 verifyPublicUrl hop=$hop status=$status '
          'location=${location == null ? '(none)' : '(present)'} contentType=${contentType ?? '(none)'}',
        );

        if (status == 200 || status == 206) {
          await response.stream.listen(null).cancel();
          return contentLength == null || contentLength > 0;
        }

        if (status >= 300 && status < 400 && location != null && location.isNotEmpty) {
          await response.stream.listen(null).cancel();
          final next = current.resolve(location);
          if (next.host != current.host) {
            debugPrint('❌ verifyPublicUrl rejected cross-host redirect: ${next.host}');
            return false;
          }
          current = next;
          continue;
        }

        await response.stream.listen(null).cancel();
        return false;
      }

      debugPrint('❌ verifyPublicUrl exceeded redirect limit url=$url');
      return false;
    } catch (e, st) {
      debugPrint('❌ verifyPublicUrl failed for $url: $e');
      debugPrint('❌ stack: $st');
      return false;
    } finally {
      client.close();
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      await ensureConfigured();
      final response = await http.get(Uri.parse('${_normalizedBase()}/status.php'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      await ensureConfigured();
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
}), '');
    final response = await _dio.post<dynamic>(
      '$base/media/share',
      data: {'remotePath': remotePath},
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
        contentType: 'application/json',
        responseType: ResponseType.json,
        validateStatus: (status) => status != null,
      ),
    );
    if (response.statusCode != 200 || response.data is! Map) return null;
    final body = Map<String, dynamic>.from(response.data as Map);
    if (body['success'] != true) return null;
    final url = body['url']?.toString();
    return url?.isNotEmpty == true ? url : null;
  }

  Future<String?> createPublicShare(String remotePath) async {
    await ensureConfigured();
    _ensureConfigured();
    try {
      final response = await http.post(
        Uri.parse('${_normalizedBase()}/ocs/v2.php/apps/files_sharing/api/v1/shares?format=json'),
        headers: _headers(),
        body: {'path': '/${_cleanLogicalPath(remotePath)}', 'shareType': '3'},
      );
      debugPrint('🔗 Share status: ${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final ocs = body['ocs'] as Map<String, dynamic>?;
      final data = ocs?['data'] as Map<String, dynamic>?;
      final shareUrl = data?['url']?.toString();
      if (shareUrl == null || shareUrl.isEmpty) return null;

      return '${shareUrl.replaceFirst(RegExp(r'/$'), '')}/download';
    } catch (e, st) {
      debugPrint('❌ createPublicShare failed: $e');
      debugPrint('❌ stack: $st');
      return null;
    }
  }

  /// Verifies the same redirect behavior used by media players.
  /// The server returns 303 -> public.php/dav -> 200 for a normal GET.
  /// A Range request returns 500 on this server, so verification must not
  /// force a Range header.
  Future<bool> verifyPublicUrl(String url) async {
    final client = http.Client();
    var current = Uri.parse(url);
    try {
      for (var hop = 0; hop <= 5; hop++) {
        final request = http.Request('GET', current)
          ..followRedirects = false
          ..maxRedirects = 0;
        final response = await client.send(request).timeout(const Duration(seconds: 20));
        final status = response.statusCode;
        final location = response.headers['location'];
        final contentLength = response.contentLength;
        final contentType = response.headers['content-type'];
        debugPrint(
          '🔗 verifyPublicUrl hop=$hop status=$status '
          'location=${location == null ? '(none)' : '(present)'} contentType=${contentType ?? '(none)'}',
        );

        if (status == 200 || status == 206) {
          await response.stream.listen(null).cancel();
          return contentLength == null || contentLength > 0;
        }

        if (status >= 300 && status < 400 && location != null && location.isNotEmpty) {
          await response.stream.listen(null).cancel();
          final next = current.resolve(location);
          if (next.host != current.host) {
            debugPrint('❌ verifyPublicUrl rejected cross-host redirect: ${next.host}');
            return false;
          }
          current = next;
          continue;
        }

        await response.stream.listen(null).cancel();
        return false;
      }

      debugPrint('❌ verifyPublicUrl exceeded redirect limit url=$url');
      return false;
    } catch (e, st) {
      debugPrint('❌ verifyPublicUrl failed for $url: $e');
      debugPrint('❌ stack: $st');
      return false;
    } finally {
      client.close();
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      await ensureConfigured();
      final response = await http.get(Uri.parse('${_normalizedBase()}/status.php'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> testAuth() async {
    try {
      await ensureConfigured();
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