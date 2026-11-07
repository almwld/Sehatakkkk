import 'package:sehatak/core/services/local_ai/local_intent_engine.dart';

/// Conservative natural-language symptom interpreter. It identifies symptoms
/// and urgency; it does not diagnose or recommend medication.
class SymptomInterpreter {
  static const Map<String, List<String>> _lexicon = {
    'حمى / حرارة': [
      'حمى', 'حراره', 'حرارة', 'سخونه', 'سخونة', 'fever', 'high temperature', 'fièvre', 'fievre', 'حار جسمي', 'جسمي حار',
      'في حرارة', 'عندي حرارة', 'حرارتي مرتفعه', 'حرارتي مرتفعة',
      'جسمي مولع', 'بدني حار', 'حرارتي طالعه', 'حرارتي عالية',
      'عندي سخونية', 'جسمي سخن', 'حرارتي طالعة', 'جسمي مولع نار', 'جسمي حامي', 'سخونة في جسمي',
    ],
    'غثيان': [
      'غثيان', 'غثيانه', 'احس بغثيان', 'nausea', 'feeling sick', 'nausée', 'nausee', 'احس بالغثيان', 'قلبي يموج',
      'نفسي تقلب', 'نفسي مقلوبه', 'نفسي مقلوبة', 'اشعر بالغثيان',
      'نفسي تعبانة', 'نفسي تعبان', 'اشتي استفرغ', 'عايز ارجع',
      'نفسي ارجع', 'حاسس اني هرجع', 'نفسي اطرش', 'بدي ارجع', 'معدتي مقلوبة', 'عايز استفرغ',
    ],
    'قيء': [
      'استفراغ', 'استفرغ', 'ترجيع', 'ارجع', 'تقيؤ', 'قيء', 'اقياء', 'vomiting', 'vomit', 'vomissements',
      'برجع', 'برجع كل شيء',
    ],
    'صداع': [
      'صداع', 'راسي يوجعني', 'headache', 'migraine', 'mal de tête', 'mal de tete', 'راسي يوجع', 'راسي يؤلمني', 'وجع راس',
      'الم راس', 'ألم رأس', 'راسي يفجر', 'راسي بينشق', 'دماغي يوجعني',
      'راسي مصدع', 'راسي بيوجعني', 'دماغي بتوجعني', 'صداعي شديد',
    ],
    'سعال / كحة': [
      'سعال', 'كحه', 'كحة', 'اكح', 'cough', 'coughing', 'toux', 'اكح كثير', 'كحة تاعبني',
      'اكح طول الوقت', 'كحتي ما توقف', 'عندي كحه', 'بسعل', 'كحتي مستمرة', 'عندي كحة طول اليوم',
    ],
    'التهاب الحلق': [
      'حلقي يوجع', 'حلقي يؤلمني', 'sore throat', 'throat pain', 'mal de gorge', 'الم حلق', 'ألم حلق', 'حلق ناشف',
      'حلقي ملتهب', 'بلعومي يوجعني', 'وجع في الزور',
    ],
    'ضيق التنفس': [
      'ضيق نفس', 'ضيق تنفس', 'shortness of breath', 'difficulty breathing', 'essoufflement', 'difficulté à respirer', 'نفسي ضيق', 'ما اقدر اتنفس',
      'ما اقدر أتنفس', 'ما اقدر اخذ نفسي', 'مش قادر اتنفس', 'مش قادر اتنفس كويس', 'مش قادر آخد نفسي', 'نفسي مقطوع', 'مكتوم', 'حاسس بكتمة',
      'اختناق', 'مخنوق', 'كتمة نفس', 'نهجان شديد',
    ],
    'ألم الصدر': [
      'الم صدر', 'ألم صدر', 'chest pain', 'douleur thoracique', 'صدري يوجعني', 'صدري يوجع',
      'وجع صدر', 'وجع في الصدر', 'صدري بيوجعني', 'صدري واجعني', 'ضغط في صدري', 'قلبي يوجعني', 'وجع بالقفص الصدري',
    ],
    'دوخة': [
      'دوخه', 'دوخة', 'dizziness', 'dizzy', 'vertige', 'étourdissement', 'دايخ', 'دايخه', 'احس بدوخه',
      'احس اني بدوخ', 'دوخت', 'الدنيا تلف بي', 'راسي يدور', 'راسي خفيف',
      'الدنيا بتلف', 'احس بدوار',
    ],
    'تعب / إرهاق': [
      'تعبان', 'تعبانه', 'تعب', 'fatigue', 'tiredness', 'fatigue', 'مرهق', 'مرهقه', 'ارهاق',
      'إرهاق', 'مالي خلق', 'ضعف', 'جسمي مكسر', 'مهدود',
    ],
    'ألم البطن': [
      'بطني يوجعني', 'بطني يوجع', 'abdominal pain', 'stomach ache', 'douleur abdominale', 'mal au ventre', 'الم بطن', 'ألم بطن', 'وجع بطن',
      'معدتي توجعني', 'معدتي يوجعني', 'بطني يعورني', 'مغص',
      'بطني يعصرني', 'بطني يقطعني', 'بطني بتوجعني', 'بطني بتعورني', 'مغص بطني', 'معدتي بتوجعني',
    ],
    'إسهال': ['اسهال', 'إسهال', 'diarrhea', 'diarrhoea', 'diarrhée', 'بطني يلعب', 'بطن يلعب معاي', 'براز مائي', 'اسهال مائي', 'بطني خربانه', 'بطني سايبه', 'عندي اسهال'],
    'إمساك': ['امساك', 'إمساك', 'constipation', 'ما اقدر ادخل الحمام', 'ما اقدر اتبرز', 'ما اخرج', 'صعوبة التبرز'],
    'ألم عضلي / مفاصل': [
      'عضلاتي توجعني', 'عضلاتي تؤلمني', 'muscle pain', 'joint pain', 'douleur musculaire', 'douleur articulaire', 'مفاصلي توجعني',
      'مفاصلي تؤلمني', 'الم مفاصل', 'ألم مفاصل', 'وجع جسم',
      'جسمي كله يوجعني', 'عظامي توجعني',
    ],
    'ألم الظهر': ['ظهري يوجعني', 'ظهري يؤلمني', 'back pain', 'mal de dos', 'الم ظهر', 'ألم ظهر', 'وجع ظهر', 'اسفل ظهري يوجعني'],
    'طفح / حكة': ['طفح', 'حكه', 'حكة', 'rash', 'itchy skin', 'éruption cutanée', 'eruption cutanee', 'جلدي يحكني', 'جلدي بيهرش', 'جلدي يحك', 'حكة شديدة', 'حساسية جلد', 'احمرار في الجلد', 'طلع لي طفح'],
    'خفقان': ['خفقان', 'قلبي يدق بسرعة', 'palpitations', 'racing heart', 'palpitations cardiaques', 'قلبي سريع', 'دقات قلبي سريعه', 'دقات قلبي سريعة', 'قلبي يخفق', 'قلبي يدق بسرعة', 'قلبي بيدق بسرعة'],
    'رشح / احتقان': [
      'رشح', 'زكام', 'runny nose', 'stuffy nose', 'common cold', 'rhume', 'nez qui coule', 'انفي مسدود', 'أنفي مسدود', 'احتقان',
      'سيلان الانف', 'سيلان الأنف', 'اعطس', 'عطس', 'مناخيري مسدودة', 'منخاري مسدود', 'انفي بيجري',
    ],
  };

  static const Map<String, String> _specialties = {
    'ضيق التنفس': 'الطوارئ / طبيب صدرية',
    'ألم الصدر': 'الطوارئ / طبيب قلب',
    'خفقان': 'طبيب قلب',
    'ألم البطن': 'طبيب باطنية / جهاز هضمي',
    'غثيان': 'طبيب باطنية / جهاز هضمي',
    'قيء': 'طبيب باطنية / جهاز هضمي',
    'طفح / حكة': 'طبيب جلدية',
    'ألم عضلي / مفاصل': 'طبيب عظام ومفاصل',
    'ألم الظهر': 'طبيب عظام ومفاصل',
    'رشح / احتقان': 'طبيب عام / أنف وأذن وحنجرة',
    'صداع': 'طبيب عام / أعصاب',
    'حمى / حرارة': 'طبيب عام',
  };

  static Map<String, dynamic>? analyze(String input, {String languageCode = 'ar'}) {
    final text = _normalize(input);
    if (text.isEmpty) return null;

    final found = <String>[];
    for (final entry in _lexicon.entries) {
      if (entry.value.any((phrase) => text.contains(_normalize(phrase)))) {
        found.add(entry.key);
      }
    }
    if (found.isEmpty) return null;

    final emergency = MedicalSafetyIntent.isEmergencyText(text);
    final specialties = found
        .map((symptom) => _specialties[symptom])
        .whereType<String>()
        .toSet()
        .take(2)
        .toList();
    final duration = _extractDuration(text);

    return {
      'symptoms': found,
      'urgency': emergency ? (languageCode == 'fr' ? 'Urgent' : languageCode == 'en' ? 'Urgent' : 'عاجل') : (found.length >= 3 ? (languageCode == 'fr' ? 'À surveiller' : languageCode == 'en' ? 'Needs follow-up' : 'يحتاج متابعة') : (languageCode == 'fr' ? 'Probablement non urgent' : languageCode == 'en' ? 'Usually non-urgent' : 'غير طارئ غالباً')),
      'emergency': emergency,
      'specialties': specialties,
      'duration': duration,
      'response': _buildResponse(found, emergency, specialties, duration, languageCode),
    };
  }

  static const Map<String, Map<String, String>> _symptomLabels = {
    'حمى / حرارة': {'en': 'fever', 'fr': 'fièvre'},
    'غثيان': {'en': 'nausea', 'fr': 'nausée'},
    'قيء': {'en': 'vomiting', 'fr': 'vomissements'},
    'صداع': {'en': 'headache', 'fr': 'mal de tête'},
    'سعال / كحة': {'en': 'cough', 'fr': 'toux'},
    'التهاب الحلق': {'en': 'sore throat', 'fr': 'mal de gorge'},
    'ضيق التنفس': {'en': 'shortness of breath', 'fr': 'essoufflement'},
    'ألم الصدر': {'en': 'chest pain', 'fr': 'douleur thoracique'},
    'دوخة': {'en': 'dizziness', 'fr': 'vertiges'},
    'تعب / إرهاق': {'en': 'fatigue', 'fr': 'fatigue'},
    'ألم البطن': {'en': 'abdominal pain', 'fr': 'douleur abdominale'},
    'إسهال': {'en': 'diarrhea', 'fr': 'diarrhée'},
    'إمساك': {'en': 'constipation', 'fr': 'constipation'},
    'ألم عضلي / مفاصل': {'en': 'muscle or joint pain', 'fr': 'douleur musculaire ou articulaire'},
    'ألم الظهر': {'en': 'back pain', 'fr': 'mal de dos'},
    'طفح / حكة': {'en': 'rash or itching', 'fr': 'éruption ou démangeaisons'},
    'خفقان': {'en': 'palpitations', 'fr': 'palpitations'},
    'رشح / احتقان': {'en': 'runny or blocked nose', 'fr': 'nez qui coule ou bouché'},
  };

  static const Map<String, Map<String, String>> _specialtyLabels = {
    'الطوارئ / طبيب صدرية': {'en': 'emergency care / respiratory doctor', 'fr': 'urgences / pneumologue'},
    'الطوارئ / طبيب قلب': {'en': 'emergency care / cardiologist', 'fr': 'urgences / cardiologue'},
    'طبيب قلب': {'en': 'cardiologist', 'fr': 'cardiologue'},
    'طبيب باطنية / جهاز هضمي': {'en': 'internal medicine / gastroenterology', 'fr': 'médecine interne / gastro-entérologie'},
    'طبيب جلدية': {'en': 'dermatologist', 'fr': 'dermatologue'},
    'طبيب عظام ومفاصل': {'en': 'orthopedist', 'fr': 'orthopédiste'},
    'طبيب عام / أنف وأذن وحنجرة': {'en': 'general practitioner / ENT', 'fr': 'médecin généraliste / ORL'},
    'طبيب عام / أعصاب': {'en': 'general practitioner / neurologist', 'fr': 'médecin généraliste / neurologue'},
    'طبيب عام': {'en': 'general practitioner', 'fr': 'médecin généraliste'},
  };

  static String _buildResponse(
    List<String> symptoms,
    bool emergency,
    List<String> specialties,
    String? duration,
    String languageCode,
  ) {
    if (emergency) {
      if (languageCode == 'fr') {
        return 'Les symptômes décrits peuvent être urgents. Rendez-vous immédiatement aux urgences ou appelez les services d’urgence locaux.';
      }
      if (languageCode == 'en') {
        return 'These symptoms may be an emergency. Go to the nearest emergency department now or call local emergency services.';
      }
      return 'الأعراض التي ذكرتها قد تكون طارئة. توجّه إلى أقرب طوارئ الآن أو اتصل بخدمات الطوارئ المحلية.';
    }
    final language = languageCode == 'fr' ? 'fr' : (languageCode == 'en' ? 'en' : 'ar');
    final summary = symptoms.map((s) => language == 'ar' ? s : (_symptomLabels[s]?[language] ?? s)).join(language == 'ar' ? '، ' : ', ');
    final specialty = specialties.isEmpty
        ? ''
        : language == 'ar'
            ? ' التخصص المناسب مبدئياً: ${specialties.first}.'
            : language == 'fr'
                ? ' Spécialité à envisager : ${_specialtyLabels[specialties.first]?['fr'] ?? specialties.first}.'
                : ' Suggested specialty: ${_specialtyLabels[specialties.first]?['en'] ?? specialties.first}.';
    final since = duration == null ? '' : ' $duration.';
    if (language == 'fr') return 'Symptômes compris : $summary.$since$specialty Depuis quand ont-ils commencé ?';
    if (language == 'en') return 'Symptoms understood: $summary.$since$specialty When did they start?';
    return 'الأعراض التي فهمتها: $summary.$since$specialty متى بدأت؟';
  }

  static String? _extractDuration(String text) {
    final patterns = [
      RegExp(r'(منذ|لي|صار لي|لي حوالي)\s*(\d+)\s*(يوم|ايام|اسبوع|اسابيع|شهر|اشهر)'),
      RegExp(r'(من يومين|من يوم|من اسبوع|من شهر)'),
      RegExp(r'(for|since)\s*(\d+)\s*(days?|weeks?|months?)'),
      RegExp(r'(depuis)\s*(\d+)\s*(jours?|semaines?|mois)'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(0);
    }
    return null;
  }

  static String _normalize(String value) => LocalAiIntentEngine.normalize(value);

  static String friendlyExample() => 'اشعر ب حمى وعندي غثيان';
}
