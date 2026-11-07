import 'package:sehatak/core/services/local_ai/local_intent_engine.dart';

/// Conservative natural-language symptom interpreter. It identifies symptoms
/// and urgency; it does not diagnose or recommend medication.
class SymptomInterpreter {
  static const Map<String, List<String>> _lexicon = {
    'حمى / حرارة': [
      'حمى', 'حراره', 'حرارة', 'سخونه', 'سخونة', 'حار جسمي', 'جسمي حار',
      'في حرارة', 'عندي حرارة', 'حرارتي مرتفعه', 'حرارتي مرتفعة',
      'جسمي مولع', 'بدني حار', 'حرارتي طالعه', 'حرارتي عالية',
      'عندي سخونية', 'جسمي سخن',
    ],
    'غثيان': [
      'غثيان', 'غثيانه', 'احس بغثيان', 'احس بالغثيان', 'قلبي يموج',
      'نفسي تقلب', 'نفسي مقلوبه', 'نفسي مقلوبة', 'اشعر بالغثيان',
      'نفسي تعبانة', 'نفسي تعبان', 'اشتي استفرغ', 'عايز ارجع',
      'نفسي ارجع', 'حاسس اني هرجع',
    ],
    'قيء': [
      'استفراغ', 'استفرغ', 'ترجيع', 'ارجع', 'تقيؤ', 'قيء', 'اقياء',
      'برجع', 'برجع كل شيء',
    ],
    'صداع': [
      'صداع', 'راسي يوجعني', 'راسي يوجع', 'راسي يؤلمني', 'وجع راس',
      'الم راس', 'ألم رأس', 'راسي يفجر', 'راسي بينشق', 'دماغي يوجعني',
      'راسي مصدع',
    ],
    'سعال / كحة': [
      'سعال', 'كحه', 'كحة', 'اكح', 'اكح كثير', 'كحة تاعبني',
      'اكح طول الوقت', 'كحتي ما توقف', 'عندي كحه', 'بسعل',
    ],
    'التهاب الحلق': [
      'حلقي يوجع', 'حلقي يؤلمني', 'الم حلق', 'ألم حلق', 'حلق ناشف',
      'حلقي ملتهب', 'بلعومي يوجعني', 'وجع في الزور',
    ],
    'ضيق التنفس': [
      'ضيق نفس', 'ضيق تنفس', 'نفسي ضيق', 'ما اقدر اتنفس',
      'ما اقدر أتنفس', 'مش قادر اتنفس', 'مش قادر اتنفس كويس',
      'اختناق', 'مخنوق', 'كتمة نفس', 'نهجان شديد',
    ],
    'ألم الصدر': [
      'الم صدر', 'ألم صدر', 'صدري يوجعني', 'صدري يوجع',
      'وجع صدر', 'ضغط في صدري', 'قلبي يوجعني', 'وجع بالقفص الصدري',
    ],
    'دوخة': [
      'دوخه', 'دوخة', 'دايخ', 'دايخه', 'احس بدوخه',
      'احس اني بدوخ', 'الدنيا تلف بي', 'راسي يدور',
      'الدنيا بتلف', 'احس بدوار',
    ],
    'تعب / إرهاق': [
      'تعبان', 'تعبانه', 'تعب', 'مرهق', 'مرهقه', 'ارهاق',
      'إرهاق', 'مالي خلق', 'ضعف', 'جسمي مكسر', 'مهدود',
    ],
    'ألم البطن': [
      'بطني يوجعني', 'بطني يوجع', 'الم بطن', 'ألم بطن', 'وجع بطن',
      'معدتي توجعني', 'معدتي يوجعني', 'بطني يعورني', 'مغص',
      'بطني يعصرني', 'بطني يقطعني', 'معدتي بتوجعني',
    ],
    'إسهال': ['اسهال', 'إسهال', 'بطني يلعب', 'بطن يلعب معاي', 'براز مائي', 'عندي اسهال'],
    'إمساك': ['امساك', 'إمساك', 'ما اقدر ادخل الحمام', 'ما اخرج', 'صعوبة التبرز'],
    'ألم عضلي / مفاصل': [
      'عضلاتي توجعني', 'عضلاتي تؤلمني', 'مفاصلي توجعني',
      'مفاصلي تؤلمني', 'الم مفاصل', 'ألم مفاصل', 'وجع جسم',
      'جسمي كله يوجعني', 'عظامي توجعني',
    ],
    'ألم الظهر': ['ظهري يوجعني', 'ظهري يؤلمني', 'الم ظهر', 'ألم ظهر', 'وجع ظهر', 'اسفل ظهري يوجعني'],
    'طفح / حكة': ['طفح', 'حكه', 'حكة', 'جلدي يحكني', 'جلدي يحك', 'احمرار في الجلد', 'طلع لي طفح'],
    'خفقان': ['خفقان', 'قلبي يدق بسرعة', 'قلبي سريع', 'دقات قلبي سريعه', 'دقات قلبي سريعة', 'قلبي يخفق'],
    'رشح / احتقان': [
      'رشح', 'زكام', 'انفي مسدود', 'أنفي مسدود', 'احتقان',
      'سيلان الانف', 'سيلان الأنف', 'اعطس', 'عطس', 'مناخيري مسدودة',
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

  static Map<String, dynamic>? analyze(String input) {
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
      'urgency': emergency ? 'عاجل' : (found.length >= 3 ? 'يحتاج متابعة' : 'غير طارئ غالباً'),
      'emergency': emergency,
      'specialties': specialties,
      'duration': duration,
      'response': _buildResponse(found, emergency, specialties, duration),
    };
  }

  static String _buildResponse(
    List<String> symptoms,
    bool emergency,
    List<String> specialties,
    String? duration,
  ) {
    if (emergency) {
      return 'الأعراض التي ذكرتها قد تكون طارئة. توجّه إلى أقرب طوارئ الآن أو اتصل بخدمات الطوارئ المحلية.';
    }
    final summary = symptoms.join('، ');
    final specialty = specialties.isEmpty
        ? ''
        : ' التخصص المناسب مبدئياً: ${specialties.first}.';
    final since = duration == null ? '' : ' منذ $duration.';
    return 'الأعراض التي فهمتها: $summary.$since$specialty متى بدأت؟';
  }

  static String? _extractDuration(String text) {
    final patterns = [
      RegExp(r'(منذ|لي|صار لي|لي حوالي)\s*(\d+)\s*(يوم|ايام|اسبوع|اسابيع|شهر|اشهر)'),
      RegExp(r'(من يومين|من يوم|من اسبوع|من شهر)'),
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
