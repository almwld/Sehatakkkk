import 'package:sehatak/core/services/local_ai/smart_health_knowledge.dart';

enum LocalAiIntent {
  greeting,
  serviceNavigation,
  symptom,
  medicine,
  healthAdvice,
  emergency,
  help,
  unknown,
}

class LocalAiIntentResult {
  final LocalAiIntent intent;
  final List<Map<String, dynamic>> services;
  final List<String> keywords;
  final double confidence;

  const LocalAiIntentResult({
    required this.intent,
    this.services = const [],
    this.keywords = const [],
    this.confidence = 0,
  });
}

/// Offline Arabic intent engine. It uses normalization, synonyms and common
/// Yemeni/Arabic wording; it never calls a network service.
class LocalAiIntentEngine {
  static const Map<String, List<String>> _aliases = {
    'طبيب': ['دكتور', 'دكتوره', 'دكتورة', 'طبيبة', 'طبيب'],
    'صيدلية': ['صيدليه', 'دواء', 'ادويه', 'أدوية', 'صيدلي'],
    'مختبر': ['مختبرات', 'مختبر', 'تحليل', 'تحاليل', 'فحص', 'فحوصات'],
    'مستشفى': ['مستشفي', 'مشفى', 'مركز صحي'],
    'استشارة': ['استشاره', 'كشف', 'موعد طبي', 'حجز طبيب'],
    'طوارئ': ['اسعاف', 'إسعاف', 'طوارئ', 'طارئ', 'نجده'],
    'ملفي': ['حسابي', 'بروفايل', 'الملف الشخصي', 'الملف الصحي'],
    'نوم': ['منام', 'نومي', 'ساعات النوم', 'ارق', 'أرق'],
    'تغذية': ['غذاء', 'اكل', 'أكل', 'رجيم', 'حمية', 'سعرات', 'وجبات'],
    'خريطة': ['موقع', 'وين اقرب', 'اين اقرب', 'قريب مني', 'بالقرب مني'],
  };

  static LocalAiIntentResult classify(String input) {
    final text = normalize(input);
    if (text.isEmpty) {
      return const LocalAiIntentResult(intent: LocalAiIntent.unknown);
    }

    if (_matchesAny(text, ['سلام', 'اهلا', 'مرحبا', 'هلا', 'صباح الخير', 'مساء الخير'])) {
      return const LocalAiIntentResult(intent: LocalAiIntent.greeting, confidence: .99);
    }

    final services = SmartHealthKnowledge.findServices(text);
    final expandedServiceText = _expandAliases(text);
    final expandedServices = SmartHealthKnowledge.findServices(expandedServiceText);
    final merged = <Map<String, dynamic>>[];
    for (final service in [...services, ...expandedServices]) {
      if (!merged.any((x) => x['route'] == service['route'])) merged.add(service);
    }

    final emergency = MedicalSafetyIntent.isEmergencyText(text);
    if (emergency) {
      return LocalAiIntentResult(
        intent: LocalAiIntent.emergency,
        services: _serviceByRoute(merged, '/emergency'),
        keywords: ['علامات خطر'],
        confidence: 1,
      );
    }

    if (_matchesAny(text, ['مساعده', 'مساعدة', 'كيف استخدم', 'كيف استعمل', 'ما اقدر', 'لا استطيع']) &&
        merged.isEmpty) {
      return const LocalAiIntentResult(intent: LocalAiIntent.help, confidence: .9);
    }

    if (_matchesAny(text, ['دواء', 'دواءي', 'جرعه', 'جرعة', 'حبوب', 'علاج دوائي', 'مضاد حيوي'])) {
      return LocalAiIntentResult(intent: LocalAiIntent.medicine, services: merged, confidence: .92);
    }

    if (_matchesAny(text, ['اشعر', 'احس', 'الم', 'وجع', 'حراره', 'حمى', 'سعال', 'كحه', 'غثيان',
      'استفراغ', 'دوخه', 'تعب', 'ضيق نفس', 'خفقان', 'طفح', 'اسهال', 'امساك'])) {
      return LocalAiIntentResult(intent: LocalAiIntent.symptom, services: merged, confidence: .94);
    }

    if (merged.isNotEmpty) {
      return LocalAiIntentResult(
        intent: LocalAiIntent.serviceNavigation,
        services: merged,
        confidence: .96,
      );
    }

    if (_matchesAny(text, ['نصيحه', 'نصيحة', 'كيف احافظ', 'صحه', 'صحة', 'وقايه', 'وقاية', 'رياضه', 'رياضة'])) {
      return const LocalAiIntentResult(intent: LocalAiIntent.healthAdvice, confidence: .85);
    }

    return const LocalAiIntentResult(intent: LocalAiIntent.unknown, confidence: .1);
  }

  static List<Map<String, dynamic>> _serviceByRoute(
      List<Map<String, dynamic>> services, String route) {
    return services.where((x) => x['route'] == route).toList();
  }

  static bool _matchesAny(String text, List<String> words) =>
      words.any((word) => text.contains(normalize(word)));

  static String _expandAliases(String text) {
    var result = text;
    _aliases.forEach((canonical, aliases) {
      for (final alias in aliases) {
        result = result.replaceAll(normalize(alias), canonical);
      }
    });
    return result;
  }

  static String normalize(String value) {
    return value.toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '')
        .replaceAll(RegExp(r'\\s+'), ' ')
        .trim();
  }
}

/// Shared safety vocabulary for the entire local assistant.
class MedicalSafetyIntent {
  static const List<String> redFlags = [
    'اختناق',
    'ما اقدر اتنفس',
    'لا استطيع التنفس',
    'ضيق تنفس شديد',
    'الم صدر شديد',
    'ألم صدر شديد',
    'نزيف شديد',
    'نزيف لا يتوقف',
    'اغمى علي',
    'اغمي علي',
    'فقدت الوعي',
    'تشنج',
    'شلل مفاجئ',
    'ضعف مفاجئ في جهة',
    'صعوبة الكلام فجاة',
    'زرقة',
    'شفايف زرقاء',
    'تسمم شديد',
    'جرعه زائده',
    'جرعة زائدة',
  ];

  static bool isEmergencyText(String text) {
    final normalized = LocalAiIntentEngine.normalize(text);
    return redFlags.any((flag) => normalized.contains(
          LocalAiIntentEngine.normalize(flag),
        ));
  }
}
