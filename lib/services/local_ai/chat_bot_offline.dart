import 'package:sehatak/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/services/local_ai/medical_knowledge_local.dart';
import 'package:sehatak/core/services/local_ai/medical_knowledge_catalog.dart';

/// Offline chatbot adapter used by legacy assistant entry points.
class ChatBotOffline {
  ChatBotOffline({this.sessionId = 'offline'});

  final String sessionId;
  final ChatBot _bot = ChatBot();
  final MedicalKnowledgeLocal knowledge = MedicalKnowledgeLocal();

  static const List<String> _medicineTerms = [
    'دواء', 'ادويه', 'دواء', 'جرعه', 'جرعة', 'كم حبه', 'حبوب', 'مضاد حيوي',
    'باراسيتامول', 'بنادول', 'paracetamol', 'acetaminophen', 'ibuprofen',
    'ايبوبروفين', 'اسبرين', 'aspirin', 'amoxicillin', 'اموكسيسيلين',
    'ميتفورمين', 'metformin', 'insulin', 'انسولين', 'diclofenac', 'ديكلوفيناك',
    'omeprazole', 'اوميبرازول', 'azithromycin', 'ازيثرومايسين',
  ];

  Future<void> initialize() async => knowledge.initializeOfflineData();

  Future<List<Map<String, dynamic>>> getConversation() => knowledge.getConversation(sessionId);

  Map<String, dynamic> respond(String message, {String languageCode = 'ar'}) {
    final curated = MedicalKnowledgeCatalog.answer(message, languageCode);
    final normalized = MedicalKnowledgeCatalog.normalize(message);
    final medicationQuestion = _medicineTerms.any(
      (term) => normalized.contains(MedicalKnowledgeCatalog.normalize(term)),
    );
    final result = curated != null
        ? Map<String, dynamic>.from(curated)
        : medicationQuestion
            ? <String, dynamic>{
                'response': languageCode == 'fr'
                    ? 'Je ne peux pas confirmer la sécurité ni la dose de ce médicament à partir des données locales actuelles. Vérifiez la notice officielle et demandez conseil à un médecin ou à un pharmacien. Ne commencez pas, n’arrêtez pas et ne modifiez pas un traitement sur la base de cette conversation.'
                    : languageCode == 'en'
                        ? 'The current local data cannot verify this medicine’s safety or dose. Check its approved leaflet and ask a doctor or pharmacist. Do not start, stop, or change treatment based on this chat.'
                        : 'لا تستطيع البيانات المحلية الحالية توثيق أمان هذا الدواء أو جرعته. راجع النشرة المعتمدة واسأل الطبيب أو الصيدلي. لا تبدأ العلاج أو توقفه أو تغيّر جرعته اعتماداً على هذه المحادثة.',
                'type': 'medication_safety',
              }
            : Map<String, dynamic>.from(_bot.respond(message));
    _persist(message, result);
    return result;
  }

  Future<void> _persist(String message, Map<String, dynamic> response) async {
    try {
      await knowledge.saveMessage(sessionId: sessionId, message: message, isUser: true, type: 'user');
      await knowledge.saveMessage(
        sessionId: sessionId,
        message: response['response']?.toString() ?? '',
        isUser: false,
        type: response['type']?.toString() ?? 'general',
      );
    } catch (_) {}
  }

  Future<void> clearHistory() => knowledge.clearConversation(sessionId);
  String? getDrugInfoByName(String drugName) => _bot.getDrugInfoByName(drugName);
  String? getDiseaseInfoByName(String diseaseName) => _bot.getDiseaseInfoByName(diseaseName);
  String getRandomTip() => _bot.getRandomTip();
  Map<String, dynamic> getStatistics() => _bot.getStatistics();
}
