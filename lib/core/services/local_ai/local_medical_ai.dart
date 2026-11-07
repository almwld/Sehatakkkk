import 'package:sehatak/core/services/local_ai/medical_knowledge_catalog.dart';
import 'package:sehatak/core/services/local_ai/medical_safety_engine.dart';
import 'package:sehatak/core/services/local_ai/symptom_interpreter.dart';

/// Deterministic offline assistant. Clinical answers come only from the
/// source-attributed multilingual catalogue; this class does not diagnose
/// or prescribe.
class ChatBot {
  static const List<String> _medicationTerms = [
    'دواء', 'الدواء', 'ادوية', 'أدوية', 'جرعة', 'جرعات',
    'medicine', 'medication', 'dose', 'dosage', 'médicament', 'dose',
    'باراسيتامول', 'paracetamol', 'ايبوبروفين', 'ibuprofen',
    'اموكسيسيلين', 'amoxicillin', 'ميتفورمين', 'metformin',
    'اسبرين', 'aspirin', 'اوميبرازول', 'omeprazole',
  ];

  Map<String, dynamic> respond(
    String message, {
    String languageCode = 'ar',
  }) {
    final input = message.trim();
    final lang = _language(languageCode);
    if (input.isEmpty) {
      return {
        'response': _text(
          lang,
          'اكتب سؤالك أو الأعراض التي تريد فهمها.',
          'Type your question or describe the symptoms you want to understand.',
          'Écrivez votre question ou décrivez les symptômes que vous souhaitez comprendre.',
        ),
        'type': 'clarification',
      };
    }

    final sourced = MedicalKnowledgeCatalog.answer(input, lang);
    if (sourced != null) return sourced;

    final safety = MedicalSafetyEngine.assess(input, languageCode: lang);
    if (safety.emergency) {
      return {'response': safety.response, 'type': 'emergency'};
    }

    final symptom = SymptomInterpreter.analyze(input, languageCode: lang);
    if (symptom != null) {
      return {
        'response': symptom['response']?.toString() ?? '',
        'type': 'symptom',
        'urgency': symptom['urgency'],
      };
    }

    final normalized = MedicalKnowledgeCatalog.normalize(input);
    if (_medicationTerms.any(
      (term) => normalized.contains(MedicalKnowledgeCatalog.normalize(term)),
    )) {
      return {
        'response': _medicationSafetyReply(lang),
        'type': 'medicine_safety',
      };
    }

    return {
      'response': _text(
        lang,
        'لم أجد مادة موثقة لهذا السؤال بعد. اذكر الأعراض ومدتها، أو اطلب الوصول إلى طبيب. لا أقدّم تشخيصاً أو جرعات دوائية.',
        'I do not yet have a sourced entry for this question. Describe the symptoms and their duration, or ask to find a clinician. I do not provide diagnoses or medication doses.',
        'Je ne dispose pas encore d’une fiche sourcée pour cette question. Décrivez les symptômes et leur durée, ou demandez à trouver un professionnel de santé. Je ne fournis ni diagnostic ni posologie.',
      ),
      'type': 'clarification',
    };
  }

  String getMedicineInfo(String medicineName, {String languageCode = 'ar'}) => _medicineSafetyReply(_language(languageCode));

  String getDiseaseInfo(String diseaseName, {String languageCode = 'ar'}) {
    final lang = _language(languageCode);
    final result = MedicalKnowledgeCatalog.answer(diseaseName, lang);
    return result?['response'] ?? _text(
      lang,
      'لا توجد حالياً مادة موثقة لهذا الموضوع. لا تعتمد على التخمين أو التشخيص الذاتي؛ استشر مختصاً صحياً.',
      'There is no sourced entry for this topic yet. Do not guess or self-diagnose; consult a qualified health professional.',
      'Aucune fiche sourcée n’est disponible pour ce sujet. Ne faites pas de suppositions ni d’autodiagnostic ; consultez un professionnel de santé qualifié.',
    );
  }

  String analyzeSymptoms(String symptoms, {String languageCode = 'ar'}) {
    final lang = _language(languageCode);
    final safety = MedicalSafetyEngine.assess(symptoms, languageCode: lang);
    if (safety.emergency) return safety.response;
    final result = SymptomInterpreter.analyze(symptoms, languageCode: lang);
    return result?['response']?.toString() ??
        _text(lang, 'اذكر الأعراض ومدتها وشدتها وأي أعراض مصاحبة. لا يمكن تشخيص الحالة من رسالة واحدة.', 'Describe the symptoms, duration and severity, including any associated symptoms. One message cannot establish a diagnosis.', 'Décrivez les symptômes, leur durée et leur intensité, ainsi que les symptômes associés. Un seul message ne permet pas d’établir un diagnostic.');
  }

  List<String> searchKnowledge(String query) {
    final normalized = MedicalKnowledgeCatalog.normalize(query);
    if (normalized.isEmpty) return const [];
    final matches = <String>[];
    for (final entry in MedicalKnowledgeCatalog.entries) {
      final aliases = (entry['aliases'] as List).cast<String>();
      if (aliases.any((alias) =>
          MedicalKnowledgeCatalog.normalize(alias).contains(normalized) ||
          normalized.contains(MedicalKnowledgeCatalog.normalize(alias)))) {
        matches.add(entry['id'] as String);
      }
    }
    return matches;
  }

  Map<String, dynamic> getStats() => {
        'total_entries': MedicalKnowledgeCatalog.entries.length,
        'languages': const ['ar', 'en', 'fr'],
        'source_attributed': true,
        'clinical_review_pending': true,
      };

  String _medicineSafetyReply(String languageCode) => _text(
        languageCode,
        'لا أعرض جرعات أو تعليمات استعمال دواء من قاعدة غير مراجعة. تحقق من النشرة الرسمية واستشر الطبيب أو الصيدلي، ولا تبدأ الدواء أو توقفه أو تغيّر جرعته اعتماداً على هذه المحادثة.',
        'I cannot provide dosing or use instructions from an unreviewed database. Check the official leaflet and ask a doctor or pharmacist; do not start, stop, or change a medicine based on this chat.',
        'Je ne peux pas fournir de posologie ni de consignes d’utilisation à partir d’une base non validée. Consultez la notice officielle et un médecin ou pharmacien ; ne commencez, n’arrêtez ni ne modifiez un traitement sur la base de cette conversation.',
      );

  String _language(String code) => code == 'en' || code == 'fr' ? code : 'ar';

  String _text(String language, String ar, String en, String fr) =>
      language == 'en' ? en : (language == 'fr' ? fr : ar);
}
