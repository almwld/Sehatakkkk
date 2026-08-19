import 'package:flutter/material.dart';
import 'package:sehatak/core/services/bot_service.dart';

class BotProvider extends ChangeNotifier {
  final BotService _botService = BotService();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _error;

  // ============================================================
  // 📋 الحالة
  // ============================================================

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================
  // 🚀 التهيئة
  // ============================================================

  Future<void> initialize() async {
    await _botService.initialize();
    _messages = await _botService.getConversation();
    notifyListeners();
  }

  // ============================================================
  // 💬 إرسال رسالة
  // ============================================================

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _botService.processMessage(message);
      _messages = await _botService.getConversation();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // 🗑️ مسح المحادثة
  // ============================================================

  Future<void> clearConversation() async {
    await _botService.clearConversation();
    _messages = await _botService.getConversation();
    notifyListeners();
  }

  // ============================================================
  // 💊 معلومات الدواء
  // ============================================================

  String? getDrugInfo(String drugName) {
    return _botService.getDrugInfo(drugName);
  }

  // ============================================================
  // 🩺 معلومات المرض
  // ============================================================

  String? getDiseaseInfo(String diseaseName) {
    return _botService.getDiseaseInfo(diseaseName);
  }

  // ============================================================
  // 💡 نصيحة عشوائية
  // ============================================================

  String getRandomTip() {
    return _botService.getRandomTip();
  }

  // ============================================================
  // 🗑️ تنظيف
  // ============================================================

  @override
  void dispose() {
    _botService.dispose();
    super.dispose();
  }
}
