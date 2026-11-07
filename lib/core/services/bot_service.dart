import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/core/services/local_ai/medical_knowledge_catalog.dart';
import 'package:sehatak/core/services/local_ai/medical_safety_engine.dart';
import 'package:sehatak/core/services/local_ai/symptom_interpreter.dart';
import 'package:sehatak/core/services/local_storage_service.dart';

class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  final ChatBot _chatBot = ChatBot();
  final LocalStorageService _storage = LocalStorageService();
  String _sessionId = '';

  Future<void> initialize({String? sessionId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _sessionId = sessionId ?? (uid == null ? 'bot_guest_v1' : 'bot_user_$uid');
    await _storage.initialize();
  }

  Future<Map<String, dynamic>> processMessage(
    String message, {
    String languageCode = 'ar',
  }) async {
    await _storage.saveMessage(
      sessionId: _sessionId,
      message: message,
      isUser: true,
      type: 'user',
    );

    final response = _chatBot.respond(message, languageCode: languageCode);
    var reply = response['response']?.toString() ?? '';
    final type = response['type']?.toString() ?? 'assistant';
    if (response['source'] != null) {
      reply += '\n\n${languageCode == 'fr' ? 'Source' : (languageCode == 'en' ? 'Source' : 'المصدر')}: ${response['source']}';
      if (response['source_url'] != null) reply += '\n${response['source_url']}';
      reply += '\n${languageCode == 'fr' ? 'Validation clinique locale en attente.' : (languageCode == 'en' ? 'Local clinician review is pending.' : 'المراجعة السريرية المحلية ما زالت مطلوبة.')}';
    }

    await _storage.saveMessage(
      sessionId: _sessionId,
      message: reply,
      isUser: false,
      type: type,
    );

    return {
      ...response,
      'response': reply,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> analyzeSymptoms(
    String symptoms, {
    String languageCode = 'ar',
  }) {
    final safety = MedicalSafetyEngine.assess(
      symptoms,
      languageCode: languageCode,
    );
    if (safety.emergency) {
      return {'response': safety.response, 'type': 'emergency'};
    }
    return SymptomInterpreter.analyze(
          symptoms,
          languageCode: languageCode,
        ) ??
        {
          'response': languageCode == 'fr'
              ? 'Décrivez les symptômes, leur durée et leur intensité.'
              : (languageCode == 'en'
                  ? 'Describe the symptoms, how long they have lasted, and their severity.'
                  : 'اذكر الأعراض ومدتها وشدتها.'),
          'type': 'clarification',
        };
  }

  Future<List<Map<String, dynamic>>> getConversation() =>
      _storage.getConversation(_sessionId);

  Future<void> clearConversation() => _storage.clearConversation(_sessionId);

  String? getDrugInfo(String drugName) => _chatBot.getMedicineInfo(drugName);

  String? getDiseaseInfo(String diseaseName) => _chatBot.getDiseaseInfo(diseaseName);

  String getRandomTip() {
    final answer = MedicalKnowledgeCatalog.answer('النشاط البدني', 'ar');
    if (answer == null) return 'ابدأ بنشاط بدني خفيف يناسب قدرتك، وزد المدة تدريجياً.';
    return '${answer['response']}\n\nالمصدر: ${answer['source']}\n${answer['source_url']}\nالمراجعة السريرية المحلية ما زالت مطلوبة.';
  }

  Map<String, dynamic> getStatistics() => {
        'catalog_topics': MedicalKnowledgeCatalog.entries.length,
        'languages': const ['ar', 'en', 'fr'],
        'clinical_review_pending': true,
      };

  // LocalStorageService is shared across the app; do not close its database
  // when a provider is disposed while another screen may still be using it.
  void dispose() {}
}
