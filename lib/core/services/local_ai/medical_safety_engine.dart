import 'package:sehatak/core/services/local_ai/local_intent_engine.dart';

class MedicalSafetyResult {
  final bool emergency;
  final String response;

  const MedicalSafetyResult({required this.emergency, required this.response});
}

/// Conservative, deterministic local triage layer.
/// It does not diagnose and does not replace emergency services or a clinician.
class MedicalSafetyEngine {
  static MedicalSafetyResult assess(String input) {
    final emergency = MedicalSafetyIntent.isEmergencyText(input);
    if (!emergency) {
      return const MedicalSafetyResult(
        emergency: false,
        response: '',
      );
    }

    return const MedicalSafetyResult(
      emergency: true,
      response:
          '🚨 هذه الرسالة تتضمن علامة قد تستدعي تقييماً عاجلاً. إذا كانت الأعراض شديدة أو تتفاقم، توجّه إلى أقرب قسم طوارئ أو اتصل بخدمات الطوارئ المحلية فوراً. لا تعتمد على المساعد لتقييم حالة خطرة.',
    );
  }
}
