import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      print('✅ CacheService initialized');
    }
  }

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final data = _prefs.getString(key);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveList(String key, List<dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Future<List<dynamic>?> getList(String key) async {
    final data = _prefs.getString(key);
    if (data == null) return null;
    try {
      return jsonDecode(data) as List<dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  bool hasCachedData(String key) {
    return _prefs.containsKey(key);
  }
}
