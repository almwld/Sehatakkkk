import 'package:sehatak/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/services/local_ai/medical_knowledge_local.dart';

/// Offline chatbot adapter used by the AI screens.
class ChatBotOffline {
  ChatBotOffline({this.sessionId = 'offline'});

  final String sessionId;
  final ChatBot _bot = ChatBot();
  final MedicalKnowledgeLocal knowledge = MedicalKnowledgeLocal();

  Future<void> initialize() async => knowledge.initializeOfflineData();

  Future<List<Map<String, dynamic>>> getConversation() => knowledge.getConversation(sessionId);

  Map<String, dynamic> respond(String message) {
    final result = Map<String, dynamic>.from(_bot.respond(message));
    _persist(message, result);
    return result;
  }

  Future<void> _persist(String message, Map<String, dynamic> response) async {
    try {
      await knowledge.saveMessage(sessionId: sessionId, message: message, isUser: true, type: 'user');
      await knowledge.saveMessage(sessionId: sessionId, message: response['response']?.toString() ?? '', isUser: false, type: response['type']?.toString() ?? 'general');
    } catch (_) {}
  }

  Future<void> clearHistory() => knowledge.clearConversation(sessionId);
  String? getDrugInfoByName(String drugName) => _bot.getDrugInfoByName(drugName);
  String? getDiseaseInfoByName(String diseaseName) => _bot.getDiseaseInfoByName(diseaseName);
  String getRandomTip() => _bot.getRandomTip();
  Map<String, dynamic> getStatistics() => _bot.getStatistics();
}
