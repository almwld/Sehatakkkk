import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sehatak/core/config/livekit_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

String _mediaMimeType(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  const types = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'heif': 'image/heif',
    'mp4': 'video/mp4',
    'm4v': 'video/x-m4v',
    'mov': 'video/quicktime',
    'webm': 'video/webm',
    '3gp': 'video/3gpp',
    'mp3': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'wav': 'audio/wav',
    'ogg': 'audio/ogg',
    'pdf': 'application/pdf',
  };
  return types[extension] ?? 'application/octet-stream';
}

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

  /// Read credentials as one snapshot. Every feature uses this singleton and
  /// the same secure-storage keys, so no feature owns a separate config copy.
  Future<void> loadConfig() async {
    final values = await Future.wait<String?>([
      _storage.read(key: 'sehatak.nextcloud.base_url'),
      _storage.read(key: 'sehatak.nextcloud.username'),
      _storage.read(key: 'sehatak.nextcloud.app_password'),
    ]);
    baseUrl = (values[0] ?? '').trim().replaceFirst(RegExp(r'/$'), '');
    username = (values[1] ?? '').trim();
    password = values[2] ?? '';
    debugPrint('Nextcloud configuration loaded: ${isConfigured ? 'ready' : 'incomplete'}');
  }

  bool get isConfigured =>
      baseUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;

  Future<void> updateConfig({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final normalizedUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw ArgumentError('أدخل عنوان Nextcloud صالحاً يبدأ بـ https:// أو http://');
    }
    if (username.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('اسم المستخدم وكلمة مرور تطبيق Nextcloud مطلوبان');
    }
    await _storage.write(key: 'sehatak.nextcloud.base_url', value: normalizedUrl);
    await _storage.write(key: 'sehatak.nextcloud.username', value: username.trim());
    await _storage.write(key: 'sehatak.nextcloud.app_password', value: password);
    this.baseUrl = normalizedUrl;
    this.username = username.trim();
    this.password = password;
  }

  Future<void> clearConfig() async {
    await Future.wait([
      _storage.delete(key: 'sehatak.nextcloud.base_url'),
      _storage.delete(key: 'sehatak.nextcloud.username'),
      _storage.delete(key: 'sehatak.nextcloud.app_password'),
    ]);
    baseUrl = '';
    username = '';
    password = '';
  }

  void _ensureConfigured() {
    if (baseUrl.isEmpty || username.isEmpty || password.isEmpty) {
      throw StateError(
        'إعدادات خادم Nextcloud غير مكتملة. تحقق من عنوان الخادم واسم المستخدم وكلمة مرور التطبيق في إعدادات Nextcloud.',
      );
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

  /// Builds the per-user Nextcloud namespace used by legacy direct WebDAV
  /// uploads. The authenticated media gateway applies this same owner prefix
  /// server-side, so callers must pass only a logical path (never a UID).
  String _platformPath(String path) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('يجب تسجيل الدخول قبل رفع الملفات إلى مساحة المستخدم');
    }

    final segments = _cleanLogicalPath(path).split('/')
      ..removeWhere((part) => part.isEmpty);
    if (segments.isNotEmpty && segments.first.toLowerCase() == 'sehatak') {
      segments.removeAt(0);
    }

    // Accept the canonical owner prefix for compatibility, but never allow
    // a caller to address another user's namespace.
    if (segments.isNotEmpty && segments.first == 'users') {
      if (segments.length < 2 || segments[1] != uid) {
        throw ArgumentError('مسار Nextcloud لا يطابق مالك الملف الحالي');
      }
      segments.removeRange(0, 2);
    } else if (segments.length > 1 && segments[1] == uid) {
      // Older callers embedded their UID in paths such as profiles/<uid>.
      // Ownership is now represented once, at the namespace root.
      segments.removeAt(1);
    }

    return <String>['Sehatak', 'users', uid, ...segments].join('/');
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

  Future<void> _ensureDirectories(String directory) async {
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
    String? chatId,
  }) async {
    try {
      if (!await file.exists()) {
        return const NextcloudUploadResult(success: false, error: 'الملف المحلي غير موجود');
      }
      final name = _cleanPart(fileName ?? file.path.split(Platform.pathSeparator).last);
      if (name.isEmpty) return const NextcloudUploadResult(success: false, error: 'اسم الملف غير صالح');

      // Production media credentials belong to the server, not the installed
      // APK. Use the authenticated media gateway first so reinstalling the app
      // or switching devices never requires users to re-enter Nextcloud secrets.
      final serverResult = await _uploadViaBackend(
        file: file,
        path: path,
        fileName: name,
        chatId: chatId,
        createShare: createShare,
        onProgress: onProgress,
      );
      if (serverResult != null) return serverResult;

      // Backward-compatible fallback for installations that intentionally
      // configured a private Nextcloud endpoint on-device.
      if (!isConfigured) await loadConfig();
      if (!isConfigured) {
        return const NextcloudUploadResult(
          success: false,
          error: 'تعذر الوصول إلى خادم الوسائط. تحقق من اتصال الإنترنت ثم أعد المحاولة.',
        );
      }
      _ensureConfigured();
      final logicalDirectory = _platformPath(path);
      final remotePath = '$logicalDirectory/$name';
      final davUrl = _davUrl(remotePath);
      final fileLength = await file.length();
      debugPrint('Nextcloud upload started ($fileLength bytes).');

      await _ensureDirectories(logicalDirectory);

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
        debugPrint('Nextcloud public-share creation failed.');
        shareError = 'تم رفع الملف بنجاح، وتعذر تجهيز رابط الوصول: $e';
      }
      return NextcloudUploadResult(success: true, url: publicUrl, path: remotePath, fileName: name, error: shareError, shareReady: publicUrl != null && publicUrl.isNotEmpty);
    } catch (e, st) {
      debugPrint('Nextcloud upload failed: ${e.runtimeType}.');
      return NextcloudUploadResult(success: false, error: e.toString());
    }
  }

  Future<NextcloudUploadResult?> _uploadViaBackend({
    required File file,
    required String path,
    required String fileName,
    String? chatId,
    required bool createShare,
    void Function(int, int)? onProgress,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        return const NextcloudUploadResult(
          success: false,
          error: 'تعذر التحقق من جلسة الدخول لرفع الوسائط.',
        );
      }
      final configuredBase = LiveKitConfig.tokenServerUrl;
      final base = configuredBase.endsWith('/')
          ? configuredBase.substring(0, configuredBase.length - 1)
          : configuredBase;
      final length = await file.length();
      final response = await _dio.post<dynamic>(
        '$base/media/upload',
        data: file.openRead(),
        queryParameters: {
          'path': path,
          if (chatId != null && chatId.isNotEmpty) 'chatId': chatId,
          'fileName': fileName,
          'mimeType': _mediaMimeType(fileName),
          'createShare': createShare ? 'true' : 'false',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/octet-stream',
            'Content-Length': length.toString(),
          },
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
        onSendProgress: onProgress,
      );

      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (body['success'] != true) {
        throw StateError(body['message']?.toString() ?? 'فشل خادم الوسائط في رفع الملف');
      }
      final fileData = body['file'] is Map
          ? Map<String, dynamic>.from(body['file'] as Map)
          : <String, dynamic>{};
      final remotePath = fileData['remotePath']?.toString();
      var publicUrl = fileData['url']?.toString();
      if (publicUrl != null && publicUrl.isEmpty) publicUrl = null;

      // Retry link creation separately. Never upload the same media twice
      // because Nextcloud's initial public-share request was unavailable.
      if (createShare && (publicUrl == null || publicUrl.isEmpty) &&
          remotePath != null && remotePath.isNotEmpty) {
        for (var attempt = 0; attempt < 3; attempt++) {
          try {
            final share = await _dio.post<dynamic>(
              '$base/media/share',
              data: {'remotePath': remotePath},
              options: Options(
                headers: {'Authorization': 'Bearer $token'},
                responseType: ResponseType.json,
                validateStatus: (status) => status != null && status >= 200 && status < 300,
              ),
            );
            final shareBody = share.data is Map
                ? Map<String, dynamic>.from(share.data as Map)
                : <String, dynamic>{};
            final candidate = shareBody['url']?.toString();
            if (candidate != null && candidate.isNotEmpty) {
              publicUrl = candidate;
              break;
            }
          } catch (_) {
            if (attempt < 2) {
              await Future<void>.delayed(Duration(seconds: attempt + 1));
            }
          }
        }
      }

      return NextcloudUploadResult(
        success: true,
        url: publicUrl,
        path: remotePath,
        fileName: fileName,
        shareReady: publicUrl != null && publicUrl.isNotEmpty,
        error: createShare && (publicUrl == null || publicUrl.isEmpty)
            ? 'تم رفع الملف بنجاح، لكن تعذر إنشاء رابط المشاركة. أعد المحاولة بعد قليل.'
            : null,
      );
    } catch (error) {
      // Once an authenticated upload request has been attempted, never fall
      // back to a second upload: a timeout may happen after Nextcloud stored
      // the bytes but before the client received the response.
      debugPrint('Server media upload failed: ' + error.runtimeType.toString());
      return NextcloudUploadResult(
        success: false,
        error: 'تعذر تأكيد نتيجة رفع الملف إلى خادم الوسائط. تحقق من الاتصال قبل إعادة المحاولة.',
      );
    }
  }

  /// Creates a public share through the authenticated server gateway for
  /// server-owned media. Legacy device-owned paths keep the old direct OCS
  /// route so existing installations and older messages remain readable.
  Future<String?> createShareForMedia(String remotePath) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    final ownerPrefix = 'Sehatak/users/' + uid + '/';
    if (uid.isNotEmpty && remotePath.startsWith(ownerPrefix)) {
      try {
        final token = await user!.getIdToken();
        if (token == null || token.isEmpty) return null;
        final configuredBase = LiveKitConfig.tokenServerUrl;
        final base = configuredBase.endsWith('/')
            ? configuredBase.substring(0, configuredBase.length - 1)
            : configuredBase;
        final response = await _dio.post<dynamic>(
          base + '/media/share',
          data: {'remotePath': remotePath},
          options: Options(
            headers: {'Authorization': 'Bearer ' + token},
            responseType: ResponseType.json,
            validateStatus: (status) => status != null && status >= 200 && status < 300,
          ),
        );
        final body = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        final url = body['url']?.toString();
        return url == null || url.isEmpty ? null : url;
      } catch (_) {
        return null;
      }
    }
    return createPublicShare(remotePath);
  }

  Future<String?> createPublicShare(String remotePath) async {
    if (!isConfigured) await loadConfig();
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
      debugPrint('Nextcloud share request failed: ${e.runtimeType}.');
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
          'Nextcloud URL verification hop=$hop status=$status '
          'contentType=${contentType ?? '(none)'}',
        );

        if (status == 200 || status == 206) {
          await response.stream.listen(null).cancel();
          return contentLength == null || contentLength > 0;
        }

        if (status >= 300 && status < 400 && location != null && location.isNotEmpty) {
          await response.stream.listen(null).cancel();
          final next = current.resolve(location);
          if (next.host != current.host) {
            debugPrint('Nextcloud URL verification rejected a cross-host redirect.');
            return false;
          }
          current = next;
          continue;
        }

        await response.stream.listen(null).cancel();
        return false;
      }

      debugPrint('Nextcloud URL verification exceeded the redirect limit.');
      return false;
    } catch (e, st) {
      debugPrint('Nextcloud URL verification failed: ${e.runtimeType}.');
      return false;
    } finally {
      client.close();
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
