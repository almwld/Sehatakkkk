import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  static Future<CacheService> init() async {
    final instance = CacheService();
    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    print('✅ Cache service initialized');
  }

  // ============================================================
  // 💾 حفظ البيانات
  // ============================================================

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

  // ============================================================
  // 💾 حفظ البيانات كـ JSON
  // ============================================================

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

  // ============================================================
  // 💾 حفظ بيانات المحادثات
  // ============================================================

  Future<void> saveChats(List<Map<String, dynamic>> chats) async {
    await saveList('cached_chats', chats);
  }

  Future<List<Map<String, dynamic>>> getCachedChats() async {
    final data = await getList('cached_chats');
    if (data == null) return [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  // ============================================================
  // 🗑️ حذف البيانات
  // ============================================================

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // ============================================================
  // ✅ التحقق من وجود بيانات
  // ============================================================

  bool hasCachedData(String key) {
    return _prefs.containsKey(key);
  }

  bool get hasCachedChats => _prefs.containsKey('cached_chats');
}
