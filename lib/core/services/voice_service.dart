import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sehatak/core/constants/yemeni_dialect.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastTranscription = '';

  // ============================================================
  // 🎤 إدخال صوتي
  // ============================================================

  Future<String?> listenToSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          print('🎤 Speech status: $status');
        },
        onError: (error) {
          print('❌ Speech error: $error');
        },
      );

      if (!available) {
        print('❌ Speech recognition not available');
        return null;
      }

      _isListening = true;
      
      final result = await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _lastTranscription = result.recognizedWords;
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        localeId: 'ar_YE', // ✅ لهجة يمنية
      );

      // ✅ انتظار النتيجة
      await Future.delayed(const Duration(seconds: 3));
      
      if (_lastTranscription.isNotEmpty) {
        return _lastTranscription;
      }
      
      return null;
    } catch (e) {
      print('❌ Listen error: $e');
      return null;
    }
  }

  // ============================================================
  // 🔊 قراءة الردود
  // ============================================================

  Future<void> speak(String text) async {
    try {
      _isSpeaking = true;
      
      // ✅ تحويل النص إلى لهجة يمنية قبل القراءة
      final yemeniText = YemeniDialect.toSanaaniDialect(text);
      
      await _tts.setLanguage('ar-YE');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      
      await _tts.speak(yemeniText);
      
      _isSpeaking = false;
    } catch (e) {
      print('❌ TTS error: $e');
      _isSpeaking = false;
    }
  }

  // ============================================================
  // ⏹️ إيقاف القراءة
  // ============================================================

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  // ============================================================
  // 📊 الحالة
  // ============================================================

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastTranscription => _lastTranscription;

  // ============================================================
  // 🗑️ تنظيف
  // ============================================================

  void dispose() {
    _tts.stop();
    _speech.stop();
  }
}
