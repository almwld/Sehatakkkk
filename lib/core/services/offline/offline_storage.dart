// ============================================================
// 📁 lib/core/services/offline/offline_storage.dart
// 💾 تخزين البيانات محلياً للاستخدام دون اتصال
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineStorage {
  static final OfflineStorage _instance = OfflineStorage._internal();
  factory OfflineStorage() => _instance;
  OfflineStorage._internal();

  static const String _keyDoctors = 'offline_doctors';
  static const String _keyHospitals = 'offline_hospitals';
  static const String _keyPharmacies = 'offline_pharmacies';
  static const String _keyLabs = 'offline_labs';
  static const String _keyArticles = 'offline_articles';
  static const String _keyTips = 'offline_tips';
  static const String _keyCommunityPosts = 'offline_community_posts';
  static const String _keyLastUpdate = 'offline_last_update';

  // ============================================================
  // 💾 حفظ البيانات
  // ============================================================
  Future<void> saveDoctors(List<Map<String, dynamic>> doctors) async {
    await _saveData(_keyDoctors, doctors);
  }

  Future<void> saveHospitals(List<Map<String, dynamic>> hospitals) async {
    await _saveData(_keyHospitals, hospitals);
  }

  Future<void> savePharmacies(List<Map<String, dynamic>> pharmacies) async {
    await _saveData(_keyPharmacies, pharmacies);
  }

  Future<void> saveLabs(List<Map<String, dynamic>> labs) async {
    await _saveData(_keyLabs, labs);
  }

  Future<void> saveArticles(List<Map<String, dynamic>> articles) async {
    await _saveData(_keyArticles, articles);
  }

  Future<void> saveTips(List<Map<String, dynamic>> tips) async {
    await _saveData(_keyTips, tips);
  }

  Future<void> saveCommunityPosts(List<Map<String, dynamic>> posts) async {
    await _saveData(_keyCommunityPosts, posts);
  }

  Future<void> _saveData(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(data);
    await prefs.setString(key, json);
    await prefs.setString(_keyLastUpdate, DateTime.now().toIso8601String());
  }

  // ============================================================
  // 📥 تحميل البيانات
  // ============================================================
  Future<List<Map<String, dynamic>>> getDoctors() async {
    return await _getData(_keyDoctors);
  }

  Future<List<Map<String, dynamic>>> getHospitals() async {
    return await _getData(_keyHospitals);
  }

  Future<List<Map<String, dynamic>>> getPharmacies() async {
    return await _getData(_keyPharmacies);
  }

  Future<List<Map<String, dynamic>>> getLabs() async {
    return await _getData(_keyLabs);
  }

  Future<List<Map<String, dynamic>>> getArticles() async {
    return await _getData(_keyArticles);
  }

  Future<List<Map<String, dynamic>>> getTips() async {
    return await _getData(_keyTips);
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts() async {
    return await _getData(_keyCommunityPosts);
  }

  Future<List<Map<String, dynamic>>> _getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // 🔍 التحقق من وجود بيانات
  // ============================================================
  Future<bool> hasData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyDoctors) ||
           prefs.containsKey(_keyHospitals) ||
           prefs.containsKey(_keyPharmacies) ||
           prefs.containsKey(_keyLabs);
  }

  Future<DateTime?> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final date = prefs.getString(_keyLastUpdate);
    if (date == null) return null;
    return DateTime.tryParse(date);
  }

  // ============================================================
  // 🗑️ مسح البيانات
  // ============================================================
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDoctors);
    await prefs.remove(_keyHospitals);
    await prefs.remove(_keyPharmacies);
    await prefs.remove(_keyLabs);
    await prefs.remove(_keyArticles);
    await prefs.remove(_keyTips);
    await prefs.remove(_keyCommunityPosts);
    await prefs.remove(_keyLastUpdate);
  }
}
