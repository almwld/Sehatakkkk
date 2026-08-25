import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NextcloudService {
  static final NextcloudService _instance = NextcloudService._internal();
  factory NextcloudService() => _instance;
  NextcloudService._internal();

  // ✅ بيانات Tab Digital (شريك Nextcloud) - المؤكدة
  String baseUrl = 'https://noa.it.tabdigital.cloud';
  String username = 'PlatformSehatak@gmail.com';
  String password = '10.10.10.1010.10.10.10';

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
        // ✅ محاولة تشخيص الخطأ
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

  // ✅ اختبار المصادقة
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

  Map<String, String> _getHeaders() {
    final auth = base64Encode(utf8.encode('$username:$password'));
    return {
      'OCS-APIRequest': 'true',
      'Authorization': 'Basic $auth',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

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
