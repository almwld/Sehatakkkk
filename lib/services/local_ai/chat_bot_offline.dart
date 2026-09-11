import 'package:sehatak/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/services/local_ai/medical_knowledge_local.dart';

/// Offline chatbot adapter used by the AI screens.
/// It keeps the existing synchronous ChatBot API while adding session
/// persistence through the local medical knowledge store.
class ChatBotOffline {
  ChatBotOffline({this.sessionId = 'offline'});

  final String sessionId;
  final ChatBot _bot = ChatBot();
  final MedicalKnowledgeLocal knowledge = MedicalKnowledgeLocal();

  Future<void> initialize() async {
    await knowledge.initializeOfflineData();
  }

  Map<String, dynamic> respond(String message) {
    final response = _bot.respond(message);
    final result = Map<String, dynamic>.from(response);

    // Persist asynchronously without making the legacy synchronous API
    // awaitable. Failures must never break offline responses.
    _persist(message, result);
    return result;
  }

  Future<void> _persist(String message, Map<String, dynamic> response) async {
    try {
      await knowledge.saveMessage(
        sessionId: sessionId,
        message: message,
        isUser: true,
        type: 'user',
      );
      await knowledge.saveMessage(
        sessionId: sessionId,
        message: response['response']?.toString() ?? '',
        isUser: false,
        type: response['type']?.toString() ?? 'general',
      );
    } catch (_) {
      // Local persistence is best-effort; the chatbot remains usable offline.
    }
  }

  Future<void> clearHistory() => knowledge.clearConversation(sessionId);

  String? getDrugInfoByName(String drugName) => _bot.getDrugInfoByName(drugName);

  String? getDiseaseInfoByName(String diseaseName) => _bot.getDiseaseInfoByName(diseaseName);

  String getRandomTip() => _bot.getRandomTip();

  Map<String, dynamic> getStatistics() => _bot.getStatistics();
}
