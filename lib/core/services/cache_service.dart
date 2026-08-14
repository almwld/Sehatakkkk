import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static SharedPreferences? _prefs;

  // ✅ تهيئة الكاش
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ✅ حفظ بيانات JSON
  static Future<void> saveData(String key, Map<String, dynamic> data) async {
    try {
      if (_prefs == null) await init();
      final jsonString = jsonEncode(data);
      await _prefs?.setString(key, jsonString);
    } catch (e) {
      print('❌ خطأ في حفظ الكاش: $e');
    }
  }

  // ✅ قراءة بيانات JSON
  static Map<String, dynamic>? getData(String key) {
    try {
      if (_prefs == null) return null;
      final jsonString = _prefs?.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('❌ خطأ في قراءة الكاش: $e');
      return null;
    }
  }

  // ✅ حفظ قائمة (List)
  static Future<void> saveList(String key, List<dynamic> data) async {
    try {
      if (_prefs == null) await init();
      final jsonString = jsonEncode(data);
      await _prefs?.setString(key, jsonString);
    } catch (e) {
      print('❌ خطأ في حفظ الكاش: $e');
    }
  }

  // ✅ قراءة قائمة (List)
  static List<dynamic>? getList(String key) {
    try {
      if (_prefs == null) return null;
      final jsonString = _prefs?.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      print('❌ خطأ في قراءة الكاش: $e');
      return null;
    }
  }

  // ✅ حفظ بسيط (String)
  static Future<void> saveString(String key, String value) async {
    try {
      if (_prefs == null) await init();
      await _prefs?.setString(key, value);
    } catch (e) {
      print('❌ خطأ في حفظ الكاش: $e');
    }
  }

  // ✅ قراءة بسيط (String)
  static String? getString(String key) {
    try {
      if (_prefs == null) return null;
      return _prefs?.getString(key);
    } catch (e) {
      print('❌ خطأ في قراءة الكاش: $e');
      return null;
    }
  }

  // ✅ حذف مفتاح
  static Future<void> remove(String key) async {
    try {
      if (_prefs == null) await init();
      await _prefs?.remove(key);
    } catch (e) {
      print('❌ خطأ في حذف الكاش: $e');
    }
  }

  // ✅ مسح كل الكاش
  static Future<void> clearAll() async {
    try {
      if (_prefs == null) await init();
      await _prefs?.clear();
    } catch (e) {
      print('❌ خطأ في مسح الكاش: $e');
    }
  }

  // ✅ التحقق من وجود مفتاح
  static bool hasKey(String key) {
    try {
      if (_prefs == null) return false;
      return _prefs?.containsKey(key) ?? false;
    } catch (e) {
      return false;
    }
  }
}
