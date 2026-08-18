import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/services/local_storage_service.dart';

class RemoteUpdateService {
  static final RemoteUpdateService _instance = RemoteUpdateService._internal();
  factory RemoteUpdateService() => _instance;
  RemoteUpdateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _storage = LocalStorageService();

  // ============================================================
  // 🔄 تحديث قاعدة المعرفة
  // ============================================================

  Future<void> syncKnowledgeBase() async {
    try {
      // ✅ التحقق من وجود اتصال بالإنترنت
      final hasInternet = await _checkInternet();
      if (!hasInternet) {
        print('⚠️ No internet connection, using local data');
        return;
      }

      // ✅ تحميل آخر تحديث من السيرفر
      final lastUpdate = await _getLastUpdateTime();
      final serverData = await _fetchRemoteData(lastUpdate);

      if (serverData != null && serverData['version'] != null) {
        // ✅ تحديث البيانات المحلية
        await _updateLocalData(serverData);
        print('✅ Knowledge base updated to version ${serverData['version']}');
      }
    } catch (e) {
      print('❌ Sync error: $e');
    }
  }

  // ============================================================
  // 📥 تحميل البيانات عن بُعد
  // ============================================================

  Future<Map<String, dynamic>?> _fetchRemoteData(String lastUpdate) async {
    try {
      final doc = await _firestore.collection('ai_knowledge').doc('base').get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Fetch error: $e');
      return null;
    }
  }

  // ============================================================
  // 💾 تحديث البيانات المحلية
  // ============================================================

  Future<void> _updateLocalData(Map<String, dynamic> data) async {
    // ✅ تحديث الأدوية
    if (data.containsKey('drugs')) {
      final drugs = List<Map<String, dynamic>>.from(data['drugs']);
      await _storage.insertDrugs(drugs);
    }

    // ✅ تحديث الأمراض
    if (data.containsKey('diseases')) {
      final diseases = List<Map<String, dynamic>>.from(data['diseases']);
      await _storage.insertDiseases(diseases);
    }

    // ✅ تحديث الإسعافات
    if (data.containsKey('first_aid')) {
      final firstAid = List<Map<String, String>>.from(data['first_aid']);
      await _storage.insertFirstAid(firstAid);
    }

    // ✅ تحديث النصائح
    if (data.containsKey('tips')) {
      final tips = List<String>.from(data['tips']);
      await _storage.insertHealthTips(tips);
    }

    // ✅ تحديث الكلمات اليمنية
    if (data.containsKey('yemeni_words')) {
      final yemeniWords = Map<String, String>.from(data['yemeni_words']);
      await _updateYemeniWords(yemeniWords);
    }

    // ✅ حفظ الإصدار
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_version', data['version'] as String);
    await prefs.setInt('ai_last_update', DateTime.now().millisecondsSinceEpoch);
  }

  // ============================================================
  // 🗣️ تحديث الكلمات اليمنية
  // ============================================================

  Future<void> _updateYemeniWords(Map<String, String> words) async {
    // ✅ حفظ الكلمات الجديدة في قاعدة البيانات
    for (var entry in words.entries) {
      await _storage.saveCustomWord(entry.key, entry.value);
    }
  }

  // ============================================================
  // 📊 التحقق من التحديثات
  // ============================================================

  Future<String> _getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ai_version') ?? '0.0.0';
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // 🚀 تحديث تلقائي
  // ============================================================

  Future<void> autoUpdate() async {
    // ✅ التحقق مرة واحدة يومياً
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('ai_last_check') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - lastCheck > 86400000) { // 24 ساعة
      await syncKnowledgeBase();
      await prefs.setInt('ai_last_check', now);
    }
  }
}
