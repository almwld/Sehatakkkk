/// Legacy offline assistant compatibility facade.
///
/// This class intentionally avoids unsupported diagnoses, triage scores,
/// medication doses, and unsourced health tips. New clinical answers must use
/// the source-attributed local medical assistant.
class LocalMedicalAI {
  static final LocalMedicalAI _instance = LocalMedicalAI._internal();
  factory LocalMedicalAI() => _instance;
  LocalMedicalAI._internal();

  final Map<String, String> _appHelp = {
    'حجز موعد': 'اذهب للأطباء > اختر التخصص > اختر الطبيب > التاريخ > أكد',
    'طلب دواء': 'اذهب للصيدلية > ابحث > أضف للسلة > أكمل الطلب',
    'استشارة': 'اذهب للدردشة > اختر طبيب > ابدأ المحادثة',
    'تذكير أدوية': 'اذهب للتذكير > أضف التذكير واتبع تعليمات الوصفة المعتمدة',
    'طوارئ': 'توجّه إلى أقرب قسم طوارئ أو اتصل بخدمات الطوارئ المحلية.',
  };

  /// No validated triage model is connected to this legacy API.
  Map<String, dynamic> triage(String symptoms, {String? bodyPart}) => {
        'specialization': 'غير محدد',
        'urgency': 'unassessed',
        'action': 'لا يمكن تقييم درجة الخطورة من هذا المسار القديم. تواصل مع مختص صحي، واطلب الطوارئ عند وجود علامات خطر.',
        'timeframe': '',
        'confidence': 0.0,
        'matched_symptoms': const <String>[],
      };

  /// Never returns speculative conditions, probabilities, or treatments.
  Map<String, dynamic> symptomChecker(String symptoms, {String? bodyPart}) => {
        'triage': triage(symptoms, bodyPart: bodyPart),
        'possible_conditions': const <Map<String, String>>[],
        'notes': 'لا تتوفر نتائج تشخيصية موثقة في هذا المسار. استشر مختصاً صحياً.',
      };

  /// Legacy bundled medicine details are withheld pending clinical review.
  Map<String, dynamic>? drugInfo(String drugName) => null;

  /// Legacy disease details are withheld pending source and clinical review.
  Map<String, dynamic>? diseaseInfo(String diseaseName) => null;

  String? appHelp(String query) {
    for (final entry in _appHelp.entries) {
      if (query.contains(entry.key)) return entry.value;
    }
    return null;
  }

  String randomTip() =>
      'لا تتوفر نصيحة صحية موثقة في هذا المسار القديم.';

  String chatbotRespond(String message) {
    if (RegExp(r'سلام|هلا|مرحب|اهلا|hi|hello', caseSensitive: false)
        .hasMatch(message)) {
      return 'مرحباً. أنا مساعد صحتك، ويمكنني إرشادك إلى خدمات المنصة.';
    }
    if (RegExp(r'طوارئ|emergency|نزيف|اختناق|لا استطيع التنفس')
        .hasMatch(message)) {
      return 'قد تكون الحالة طارئة. توجّه إلى أقرب قسم طوارئ أو اتصل بخدمات الطوارئ المحلية الآن.';
    }
    if (RegExp(r'دواء|علاج|جرعة|باراسيتامول|ايبوبروفين|medicine|dose',
            caseSensitive: false)
        .hasMatch(message)) {
      return 'لا أعرض جرعات أو تعليمات استعمال دواء من قاعدة غير مراجعة. تحقق من النشرة الرسمية واستشر الطبيب أو الصيدلي.';
    }
    if (RegExp(r'عندي|اعاني|احس|اشعر|الم|وجع').hasMatch(message)) {
      return 'صف الأعراض ومدتها وشدتها. لا يمكن لهذا المسار تشخيص الحالة أو تحديد درجة خطورتها.';
    }
    if (RegExp(r'باقة|اشتراك|سعر|تكلفة').hasMatch(message)) {
      return 'يمكنك الاطلاع على الباقات والأسعار الحالية من قسم الاشتراكات داخل التطبيق.';
    }
    if (RegExp(r'كيف|طريقة').hasMatch(message)) {
      for (final entry in _appHelp.entries) {
        if (message.contains(entry.key)) {
          return '${entry.key}:\n${entry.value}';
        }
      }
    }
    return 'لم أجد مادة موثقة لهذا السؤال في المسار القديم. استخدم المساعد الصحي الأساسي أو تواصل مع مختص صحي.';
  }
}
