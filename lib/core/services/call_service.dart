// ============================================================
// 📞 خدمة المكالمات - نسخة مبسطة
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  bool _isInCall = false;
  String? _currentCallId;

  bool get isInCall => _isInCall;

  // ✅ معالجة المكالمة الواردة
  void handleIncomingCall(BuildContext context, RemoteMessage message) {
    print('📞 Incoming call from: ${message.data}');
    // TODO: تنفيذ معالجة المكالمة الواردة
  }

  // ✅ بدء مكالمة
  void startCall(String callId) {
    _isInCall = true;
    _currentCallId = callId;
    print('📞 Call started: $callId');
  }

  // ✅ إنهاء مكالمة
  void endCall() {
    _isInCall = false;
    _currentCallId = null;
    print('📞 Call ended');
  }

  // ✅ كتم الصوت
  void toggleMute() {
    print('🔇 Toggle mute');
  }

  // ✅ تفعيل مكبر الصوت
  void toggleSpeaker() {
    print('🔊 Toggle speaker');
  }

  // ✅ تبديل الكاميرا
  void toggleCamera() {
    print('📷 Toggle camera');
  }

  void dispose() {
    _isInCall = false;
    _currentCallId = null;
  }
}
