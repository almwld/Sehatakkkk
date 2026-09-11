import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/services/local_storage_service.dart';

class RemoteUpdateService {
  static final RemoteUpdateService _instance = RemoteUpdateService._internal();
  factory RemoteUpdateService() => _instance;
  RemoteUpdateService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _storage = LocalStorageService();

  Future<void> syncKnowledgeBase() async {
    try {
      if (!await _checkInternet()) return;
      final serverData = await _fetchRemoteData(await _getLastUpdateTime());
      if (serverData != null && serverData['version'] != null) await _updateLocalData(serverData);
    } catch (e) { print('❌ Sync error: $e'); }
  }

  Future<Map<String, dynamic>?> _fetchRemoteData(String lastUpdate) async {
    try { final doc = await _firestore.collection('ai_knowledge').doc('base').get(); return doc.exists ? doc.data() : null; } catch (e) { print('❌ Fetch error: $e'); return null; }
  }

  Future<void> _updateLocalData(Map<String, dynamic> data) async {
    if (data['drugs'] is List) await _storage.insertDrugs(List<Map<String, dynamic>>.from(data['drugs']));
    if (data['diseases'] is List) await _storage.insertDiseases(List<Map<String, dynamic>>.from(data['diseases']));
    if (data['first_aid'] is List) await _storage.insertFirstAid(List<Map<String, String>>.from(data['first_aid']));
    if (data['tips'] is List) await _storage.insertHealthTips(List<String>.from(data['tips']));
    if (data['yemeni_words'] is Map) await _updateYemeniWords(Map<String, String>.from(data['yemeni_words']));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_version', data['version'].toString());
    await prefs.setInt('ai_last_update', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _updateYemeniWords(Map<String, String> words) async {
    final prefs = await SharedPreferences.getInstance();
    final current = Map<String, String>.from((prefs.getStringList('yemeni_words') ?? const []).fold<Map<String, String>>({}, (m, item) { final p = item.split('=', 2); if (p.length == 2) m[p[0]] = p[1]; return m; }));
    current.addAll(words);
    await prefs.setStringList('yemeni_words', current.entries.map((e) => '${e.key}=${e.value}').toList());
  }

  Future<String> _getLastUpdateTime() async { final prefs = await SharedPreferences.getInstance(); return prefs.getString('ai_version') ?? '0.0.0'; }
  Future<bool> _checkInternet() async { try { final result = await InternetAddress.lookup('google.com'); return result.isNotEmpty && result.first.rawAddress.isNotEmpty; } catch (_) { return false; } }
  Future<void> autoUpdate() async { final prefs = await SharedPreferences.getInstance(); final last = prefs.getInt('ai_last_check') ?? 0; final now = DateTime.now().millisecondsSinceEpoch; if (now-last > 86400000) { await syncKnowledgeBase(); await prefs.setInt('ai_last_check', now); } }
}
