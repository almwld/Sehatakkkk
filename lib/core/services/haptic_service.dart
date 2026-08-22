import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  // ✅ اهتزاز خفيف - عند النقر
  Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ اهتزاز متوسط - عند الضغط
  Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ اهتزاز قوي - عند الضغط الطويل
  Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ اهتزاز عند التحديد
  Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ اهتزاز عند استقبال رسالة
  Future<void> messageReceived() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ اهتزاز عند إرسال رسالة
  Future<void> messageSent() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ اهتزاز عند المكالمة
  Future<void> callRinging() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ اهتزاز عند الخطأ
  Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }
}
