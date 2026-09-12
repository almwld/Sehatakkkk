import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:sehatak/core/config/livekit_config.dart';

/// Authenticated client for the standalone Railway notification service.
/// This service never contains Firebase Admin credentials.
class NotificationSender {
  NotificationSender._();
  static final NotificationSender instance = NotificationSender._();

  String get baseUrl => const String.fromEnvironment(
        'NOTIFICATION_SERVER_URL',
        defaultValue: LiveKitConfig.tokenServerUrl,
      ).replaceFirst(RegExp(r'/$'), '');

  Future<Map<String, dynamic>> send({
    required String receiverId,
    required String type,
    required String title,
    required String body,
    String? subType,
    Map<String, dynamic>? data,
    bool skipPreferences = false,
    bool skipDnd = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول لإرسال الإشعار');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) throw StateError('تعذر الحصول على رمز Firebase');

    final payload = <String, dynamic>{
      'receiverId': receiverId,
      'type': type,
      'title': title,
      'body': body,
      if (subType != null && subType.isNotEmpty) 'subType': subType,
      'data': data ?? <String, dynamic>{},
      if (skipPreferences) 'skipPreferences': true,
      if (skipDnd) 'skipDnd': true,
    };

    final response = await http
        .post(
          Uri.parse('$baseUrl/notification'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationSenderException(
        decoded['error']?.toString() ?? 'تعذر إرسال الإشعار',
        response.statusCode,
        decoded['code']?.toString(),
      );
    }
    return decoded;
  }

  Future<Map<String, dynamic>> sendBatch(
    List<Map<String, dynamic>> notifications,
  ) async {
    if (notifications.isEmpty) return <String, dynamic>{'success': true, 'total': 0};
    if (notifications.length > 100) throw ArgumentError('الحد الأقصى 100 إشعار');
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) throw StateError('يجب تسجيل الدخول');
    final response = await http
        .post(
          Uri.parse('$baseUrl/notification/batch'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({'notifications': notifications}),
        )
        .timeout(const Duration(seconds: 30));
    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationSenderException(decoded['error']?.toString() ?? 'تعذر إرسال الإشعارات', response.statusCode, decoded['code']?.toString());
    }
    return decoded;
  }

  Future<bool> isHealthy() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notification/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final value = jsonDecode(body);
      return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

class NotificationSenderException implements Exception {
  const NotificationSenderException(this.message, this.statusCode, this.code);
  final String message;
  final int statusCode;
  final String? code;

  @override
  String toString() => 'NotificationSenderException($statusCode, $code): $message';
}
