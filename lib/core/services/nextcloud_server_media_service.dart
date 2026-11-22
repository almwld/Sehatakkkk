import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/livekit_config.dart';
import 'nextcloud_service.dart';

/// Authenticated client for the Suga media endpoints. Nextcloud credentials
/// remain on the server; the app sends only its Firebase ID token.
class NextcloudServerMediaService {
  NextcloudServerMediaService._();
  static final NextcloudServerMediaService instance = NextcloudServerMediaService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(minutes: 10),
  ));

  String get _base {
    final value = LiveKitConfig.tokenServerUrl.trim();
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  String privateDownloadUrl(String remotePath) {
    return Uri.parse(_base + '/media/download')
        .replace(queryParameters: {'remotePath': remotePath})
        .toString();
  }

  Future<String> _idToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول قبل نقل الوسائط');
    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) throw StateError('تعذر الحصول على رمز مصادقة Firebase');
    return token;
  }

  Future<NextcloudUploadResult> upload({
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
      if (!await file.exists()) {
        return const NextcloudUploadResult(success: false, error: 'الملف المحلي غير موجود');
      }
      final name = (fileName?.trim().isNotEmpty == true) ? fileName!.trim() : file.uri.pathSegments.last;
      final type = (mimeType?.trim().isNotEmpty == true) ? mimeType!.trim() : 'application/octet-stream';
      final length = await file.length();
      final response = await _dio.post<dynamic>(
        _base + '/media/upload',
        queryParameters: {
          'chatId': chatId,
          'messageId': messageId,
          'fileName': name,
          'mimeType': type,
          'createShare': createShare ? 'true' : 'false',
        },
        data: file.openRead(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ' + await _idToken(),
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
      final data = body['file'] is Map
          ? Map<String, dynamic>.from(body['file'] as Map)
          : <String, dynamic>{};
      final remotePath = data['remotePath']?.toString();
      if (remotePath == null || remotePath.isEmpty) {
        return const NextcloudUploadResult(success: false, error: 'الخادم لم يُرجع مسار الملف');
      }
      final url = data['url']?.toString();
      return NextcloudUploadResult(
        success: true,
        url: url?.isNotEmpty == true ? url : null,
        path: remotePath,
        fileName: data['fileName']?.toString() ?? name,
        shareReady: data['shareReady'] == true,
      );
    } catch (error) {
      if (error is DioException && CancelToken.isCancel(error)) rethrow;
      return NextcloudUploadResult(success: false, error: error.toString());
    }
  }

  Future<String?> createPublicShare(String remotePath) async {
    final response = await _dio.post<dynamic>(
      _base + '/media/share',
      data: {'remotePath': remotePath},
      options: Options(
        headers: {'Authorization': 'Bearer ' + await _idToken()},
        contentType: 'application/json',
        responseType: ResponseType.json,
        validateStatus: (status) => status != null,
      ),
    );
    if (response.statusCode != 200 || response.data is! Map) return null;
    final body = Map<String, dynamic>.from(response.data as Map);
    final url = body['url']?.toString();
    return body['success'] == true && url?.isNotEmpty == true ? url : null;
  }
}
