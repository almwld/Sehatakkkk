import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static late SharedPreferences _prefs;

  static Future<void> init() async { _prefs = await SharedPreferences.getInstance(); }
  static Future<void> setString(String key, String value) async => _prefs.setString(key, value);
  static String? getString(String key) => _prefs.getString(key);
  static Future<void> setBool(String key, bool value) async => _prefs.setBool(key, value);
  static bool? getBool(String key) => _prefs.getBool(key);
  static Future<void> setInt(String key, int value) async => _prefs.setInt(key, value);
  static int? getInt(String key) => _prefs.getInt(key);

  static Future<void> saveList(String key, List<Map<String, dynamic>> value) async => _prefs.setString(key, jsonEncode(value));
  static Future<List<Map<String, dynamic>>?> getList(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) { await _prefs.remove(key); return null; }
  }

  static Future<void> saveJson(String key, Map<String, dynamic> value) async => _prefs.setString(key, jsonEncode(value));
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) { await _prefs.remove(key); return null; }
  }

  static Future<void> remove(String key) async => _prefs.remove(key);
  static Future<void> clear() async => _prefs.clear();
}
