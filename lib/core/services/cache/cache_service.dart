// ============================================================
// 📁 lib/core/services/cache/cache_service.dart
// ⚡ خدمة التخزين المؤقت
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const Duration _cacheDuration = Duration(minutes: 30);
  static const String _keyPrefix = 'cache_';
  static const String _keyTimestamp = 'cache_timestamp_';

  // ============================================================
  // 💾 حفظ في الـ Cache
  // ============================================================
  Future<void> set(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(value);
    await prefs.setString('$_keyPrefix$key', json);
    await prefs.setString('$_keyTimestamp$key', DateTime.now().toIso8601String());
  }

  // ============================================================
  // 📥 قراءة من الـ Cache
  // ============================================================
  Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_keyPrefix$key');
    if (json == null) return null;
    return jsonDecode(json);
  }

  // ============================================================
  // 🔍 التحقق من صحة الـ Cache
  // ============================================================
  Future<bool> isValid(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString('$_keyTimestamp$key');
    if (timestamp == null) return false;
    
    final date = DateTime.tryParse(timestamp);
    if (date == null) return false;
    
    final diff = DateTime.now().difference(date);
    return diff < _cacheDuration;
  }

  // ============================================================
  // 🗑️ مسح الـ Cache
  // ============================================================
  Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$key');
    await prefs.remove('$_keyTimestamp$key');
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
