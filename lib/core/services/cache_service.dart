import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static SharedPreferences? _prefs;
  static Future<void>? _initialization;

  /// يبدأ تحميل SharedPreferences في الخلفية حتى لا يمنع عرض واجهة التطبيق.
  /// جميع عمليات الكتابة تنتظر اكتمال التهيئة، بينما القراءات المبكرة تعيد
  /// القيمة المتاحة إن كانت التهيئة قد اكتملت بعد.
  static Future<void> init() {
    final existing = _initialization;
    if (existing != null) return Future<void>.value();
    if (_prefs != null) return Future<void>.value();
    final future = SharedPreferences.getInstance().then((value) {
      _prefs = value;
    }).catchError((error) {
      _initialization = null;
      throw error;
    });
    _initialization = future;
    unawaited(future.catchError((_) {}));
    return Future<void>.value();
  }

  static Future<void> _ensureReady() async {
    init();
    final future = _initialization;
    if (future != null) await future;
  }

  static Future<void> setString(String key, String value) async {
    await _ensureReady();
    await _prefs!.setString(key, value);
  }

  static String? getString(String key) => _prefs?.getString(key);

  static Future<void> setBool(String key, bool value) async {
    await _ensureReady();
    await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) => _prefs?.getBool(key);

  static Future<void> setInt(String key, int value) async {
    await _ensureReady();
    await _prefs!.setInt(key, value);
  }

  static int? getInt(String key) => _prefs?.getInt(key);

  static Future<void> saveList(String key, List<Map<String, dynamic>> value) async {
    await _ensureReady();
    await _prefs!.setString(key, jsonEncode(value));
  }

  static Future<List<Map<String, dynamic>>?> getList(String key) async {
    await _ensureReady();
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      await _prefs!.remove(key);
      return null;
    }
  }

  static Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await _ensureReady();
    await _prefs!.setString(key, jsonEncode(value));
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    await _ensureReady();
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      await _prefs!.remove(key);
      return null;
    }
  }

  static Future<void> remove(String key) async {
    await _ensureReady();
    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    await _ensureReady();
    await _prefs!.clear();
  }
}
