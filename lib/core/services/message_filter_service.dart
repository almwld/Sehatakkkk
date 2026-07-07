import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageFilterService {
  // ✅ قائمة الكلمات الممنوعة (أرقام، حسابات، تواصل خارجي)
  static final List<RegExp> _blockedPatterns = [
    RegExp(r'[0-9]{7,15}'), // أرقام هواتف
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), // إيميلات
    RegExp(r'(واتساب|WhatsApp|تلغرام|Telegram|فيسبوك|Facebook)'),
    RegExp(r'(كاش|Cash|تحويل|حوالة)'),
    RegExp(r'(paypal|باي بال|stc|STC)'),
  ];

  // ✅ تحليل الرسالة
  static Future<Map<String, dynamic>> filterMessage(String text) async {
    final List<String> warnings = [];
    final String maskedText = _applyFilters(text, warnings);
    
    return {
      'original': text,
      'filtered': maskedText,
      'isBlocked': warnings.isNotEmpty,
      'warnings': warnings,
      'hasPhoneNumber': _hasPhoneNumber(text),
      'hasEmail': _hasEmail(text),
    };
  }

  static String _applyFilters(String text, List<String> warnings) {
    String filtered = text;
    
    for (final pattern in _blockedPatterns) {
      final matches = pattern.allMatches(text);
      if (matches.isNotEmpty) {
        filtered = filtered.replaceAll(pattern, '🔒 [محتوى محمي]');
        warnings.add('تم حظر معلومات اتصال');
      }
    }
    
    return filtered;
  }

  static bool _hasPhoneNumber(String text) {
    return RegExp(r'[0-9]{7,15}').hasMatch(text);
  }

  static bool _hasEmail(String text) {
    return RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').hasMatch(text);
  }

  // ✅ تحويل الشات إلى طلب مهيكل
  static Future<Map<String, dynamic>> parseToOrder(String text) async {
    // ✅ كشف نوع الطلب
    String type = 'general';
    final keywords = {
      'فحص|تحليل|مختبر': 'lab',
      'دواء|علاج|صيدلية|حبة|كبسولة': 'pharmacy',
      'عيادة|كشف|استشارة|طبيب': 'consultation',
      'منزلي|زيارة|بيت': 'home_service',
    };

    for (final entry in keywords.entries) {
      if (RegExp(entry.key, caseSensitive: false).hasMatch(text)) {
        type = entry.value;
        break;
      }
    }

    return {
      'type': type,
      'confidence': 0.85,
      'keywords': _extractKeywords(text),
    };
  }

  static List<String> _extractKeywords(String text) {
    final words = text.split(RegExp(r'\s+'));
    return words.where((w) => w.length > 3).toList();
  }
}
