import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://hi-g26z.onrender.com';
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 15)));
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) _dio.options.headers['Authorization'] = 'Bearer $_token';
  }

  static bool get isLoggedIn => _token != null;

  static Future<Map<String, dynamic>> sendOTP(String phone) async {
    final res = await _dio.post('/api/otp/send', data: {'phone': phone});
    return res.data;
  }

  static Future<Map<String, dynamic>> login(String phone, String otp) async {
    final res = await _dio.post('/api/auth/login', data: {'phone': phone, 'otp': otp});
    if (res.data['success'] == true) {
      _token = res.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    }
    return res.data;
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
