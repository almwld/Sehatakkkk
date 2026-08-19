import 'dart:convert';
import 'package:sehatak/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/core/services/local_storage_service.dart';

class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  final ChatBot _chatBot = ChatBot();
  final LocalStorageService _storage = LocalStorageService();
  String _sessionId = '';

  Future<void> initialize({String? sessionId}) async {
    _sessionId = sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.initialize();
  }

  // ============================================================
  // 💬 معالجة الرسائل
  // ============================================================

  Future<Map<String, dynamic>> processMessage(String message) async {
    // ✅ حفظ رسالة المستخدم
    await _storage.saveMessage(
      sessionId: _sessionId,
      message: message,
      isUser: true,
      type: 'user',
    );

    // ✅ معالجة الرسالة
    final response = _chatBot.respond(message);
    final reply = response['response'] as String;
    final type = response['type'] as String;

    // ✅ حفظ رد البوت
    await _storage.saveMessage(
      sessionId: _sessionId,
      message: reply,
      isUser: false,
      type: type,
    );

    return {
      'response': reply,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================
  // 📊 تحليل الأعراض
  // ============================================================

  Map<String, dynamic> analyzeSymptoms(String symptoms) {
    final triageEngine = TriageEngine();
    return triageEngine.predict(symptoms);
  }

  // ============================================================
  // 📋 الحصول على المحادثة
  // ============================================================

  Future<List<Map<String, dynamic>>> getConversation() async {
    return await _storage.getConversation(_sessionId);
  }

  // ============================================================
  // 🗑️ مسح المحادثة
  // ============================================================

  Future<void> clearConversation() async {
    await _storage.clearConversation(_sessionId);
  }

  // ============================================================
  // 💊 معلومات الدواء
  // ============================================================

  String? getDrugInfo(String drugName) {
    return _chatBot.getDrugInfoByName(drugName);
  }

  // ============================================================
  // 🩺 معلومات المرض
  // ============================================================

  String? getDiseaseInfo(String diseaseName) {
    return _chatBot.getDiseaseInfoByName(diseaseName);
  }

  // ============================================================
  // 💡 نصيحة عشوائية
  // ============================================================

  String getRandomTip() {
    return _chatBot.getRandomTip();
  }

  // ============================================================
  // 📊 إحصائيات
  // ============================================================

  Map<String, dynamic> getStatistics() {
    return _chatBot.getStatistics();
  }

  // ============================================================
  // 🗑️ تنظيف
  // ============================================================

  void dispose() {
    _storage.dispose();
  }
}
