import 'package:translator/translator.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();

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

  Future<String> translate({required String text, required String toLanguage, String fromLanguage = 'ar'}) async {
    if (text.isEmpty || toLanguage == fromLanguage) return text;
    try {
      final result = await _translator.translate(text, from: fromLanguage, to: toLanguage);
      return result.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  Future<List<String>> translateBatch({required List<String> texts, required String toLanguage, String fromLanguage = 'ar'}) async {
    final results = <String>[];
    for (final text in texts) {
      results.add(await translate(text: text, toLanguage: toLanguage, fromLanguage: fromLanguage));
    }
    return results;
  }

  Future<String> detectLanguage(String text) async {
    if (text.trim().isEmpty) return 'ar';
    final arabic = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
    final latin = RegExp(r'[A-Za-z]').allMatches(text).length;
    return arabic >= latin ? 'ar' : 'en';
  }
}
