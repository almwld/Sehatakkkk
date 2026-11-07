import 'package:sehatak/core/services/local_ai/local_intent_engine.dart';

class MedicalSafetyResult {
  final bool emergency;
  final String response;

  const MedicalSafetyResult({required this.emergency, required this.response});
}

/// Conservative, deterministic local triage layer.
/// It does not diagnose and does not replace emergency services or a clinician.
class MedicalSafetyEngine {
  static MedicalSafetyResult assess(String input, {String languageCode = 'ar'}) {
    final emergency = MedicalSafetyIntent.isEmergencyText(input);
    if (!emergency) {
      return const MedicalSafetyResult(
        emergency: false,
        response: '',
      );
    }

    final response = languageCode == 'fr'
        ? 'Ce message contient un signe potentiellement urgent. Si les symptômes sont graves ou s’aggravent, rendez-vous immédiatement aux urgences ou appelez les services d’urgence locaux. Ne comptez pas sur cet assistant pour évaluer une urgence.'
        : languageCode == 'en'
            ? 'This message includes a possible warning sign. If symptoms are severe or worsening, go to the nearest emergency department or call local emergency services now. Do not rely on this assistant to assess an emergency.'
            : 'هذه الرسالة تتضمن علامة قد تستدعي تقييماً عاجلاً. إذا كانت الأعراض شديدة أو تتفاقم، توجّه إلى أقرب قسم طوارئ أو اتصل بخدمات الطوارئ المحلية فوراً. لا تعتمد على المساعد لتقييم حالة خطرة.';
    return MedicalSafetyResult(emergency: true, response: response);
  }
}
