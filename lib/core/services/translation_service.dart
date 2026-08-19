import 'package:translator/translator.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();

  // ✅ اللغات المدعومة
  final List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'الإنجليزية'},
    {'code': 'fr', 'name': 'الفرنسية'},
    {'code': 'es', 'name': 'الإسبانية'},
    {'code': 'de', 'name': 'الألمانية'},
    {'code': 'it', 'name': 'الإيطالية'},
    {'code': 'tr', 'name': 'التركية'},
    {'code': 'ur', 'name': 'الأردية'},
  ];

  Future<String> translate({
    required String text,
    required String toLanguage,
    String fromLanguage = 'ar',
  }) async {
    try {
      if (text.isEmpty) return text;
      if (toLanguage == fromLanguage) return text;

      final translation = await _translator.translate(
        text,
        from: fromLanguage,
        to: toLanguage,
      );

      return translation.text;
    } catch (e) {
      print('❌ Translation error: $e');
      return text;
    }
  }

  // ✅ ترجمة متعددة
  Future<List<String>> translateBatch({
    required List<String> texts,
    required String toLanguage,
    String fromLanguage = 'ar',
  }) async {
    try {
      final results = <String>[];
      for (final text in texts) {
        final translated = await translate(
          text: text,
          toLanguage: toLanguage,
          fromLanguage: fromLanguage,
        );
        results.add(translated);
      }
      return results;
    } catch (e) {
      print('❌ Batch translation error: $e');
      return texts;
    }
  }

  // ✅ كشف اللغة
  Future<String> detectLanguage(String text) async {
    try {
      final detection = await _translator.detect(text);
      return detection.language ?? 'ar';
    } catch (e) {
      print('❌ Language detection error: $e');
      return 'ar';
    }
  }
}
