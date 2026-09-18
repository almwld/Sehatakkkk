import 'package:flutter/material.dart';

/// Unified knowledge catalogue used by the smart health assistant.
/// Keeps service navigation and app guidance in one source of truth.
class SmartHealthKnowledge {
  static const List<Map<String, dynamic>> services = [
    {'title': 'الأطباء', 'keywords': ['طبيب', 'دكتور', 'دكتورة', 'تخصص', 'دكتوراه', 'اكشف', 'ابغى دكتور', 'ابغى طبيب', 'ابا دكتور'], 'route': '/doctors', 'icon': Icons.medical_services_outlined, 'help': 'البحث عن طبيب واختيار التخصص المناسب.'},
    {'title': 'الصيدلية', 'keywords': ['دواء', 'صيدلية', 'دواءاتي', 'علاج', 'حبوب', 'روشتة', 'وصفة'], 'route': '/pharmacy', 'icon': Icons.local_pharmacy_outlined, 'help': 'البحث عن الأدوية والمنتجات الصحية.'},
    {'title': 'المختبرات', 'keywords': ['مختبر', 'معمل', 'تحليل', 'تحاليل', 'فحص', 'نتيجة', 'فحوصات', 'اشعة'], 'route': '/labs', 'icon': Icons.biotech_outlined, 'help': 'الوصول إلى خدمات المختبرات ونتائج الفحوصات.'},
    {'title': 'صحتي', 'keywords': ['صحتي', 'صحة', 'مؤشرات', 'ضغط', 'سكر', 'وزن'], 'route': '/health', 'icon': Icons.favorite_outline, 'help': 'متابعة المؤشرات الصحية والسجل الصحي.'},
    {'title': 'الاستشارة الطبية', 'keywords': ['استشارة', 'استشاره', 'طبيب عن بعد', 'استشارة طبية', 'اكلم طبيب', 'اتكلم مع دكتور', 'ابغى استشارة'], 'route': '/consultation', 'icon': Icons.video_call_outlined, 'help': 'بدء أو متابعة استشارة طبية.'},
    {'title': 'الطوارئ', 'keywords': ['طوارئ', 'اسعاف', 'إسعاف', 'طارئ', 'نجدة', 'انقذوني', 'حالة طارئة'], 'route': '/emergency', 'icon': Icons.emergency_outlined, 'help': 'الوصول السريع لخدمات الطوارئ والأرقام المهمة.'},
    {'title': 'الخدمات', 'keywords': ['خدمات', 'جميع الخدمات', 'الخدمات الصحية', 'ايش عندكم', 'ماذا يقدم التطبيق', 'كيف استخدم التطبيق', 'وين الخدمة'], 'route': '/services', 'icon': Icons.grid_view_outlined, 'help': 'استعراض جميع خدمات صحتك.'},
    {'title': 'التبرع بالدم', 'keywords': ['دم', 'تبرع بالدم', 'متبرع'], 'route': '/blood-donation', 'icon': Icons.bloodtype_outlined, 'help': 'الوصول إلى خدمة التبرع بالدم.'},
    {'title': 'المحفظة', 'keywords': ['محفظة', 'دفع', 'رصيد', 'فاتورة'], 'route': '/wallet', 'icon': Icons.account_balance_wallet_outlined, 'help': 'متابعة المحفظة والمدفوعات المتاحة داخل التطبيق.'},
    {'title': 'الخريطة', 'keywords': ['خريطة', 'موقع', 'وين اقرب', 'اقرب مستشفى', 'مستشفى قريب', 'صيدلية قريبة', 'مختبر قريب', 'مركز صحي قريب'], 'route': '/map', 'icon': Icons.map_outlined, 'help': 'العثور على المنشآت والخدمات الصحية على الخريطة.'},
  ];

  static const List<Map<String, String>> topics = [
    {'title': 'الأدوية', 'prompt': 'أريد معرفة معلومات عن دواء'},
    {'title': 'الأعراض', 'prompt': 'أريد المساعدة في فهم أعراضي'},
    {'title': 'الإسعافات الأولية', 'prompt': 'ماذا أفعل في حالة طارئة؟'},
    {'title': 'التغذية', 'prompt': 'أريد نصائح عن التغذية الصحية'},
    {'title': 'النوم', 'prompt': 'أريد نصائح لتحسين النوم'},
    {'title': 'الوقاية', 'prompt': 'كيف أقي نفسي من الأمراض؟'},
    {'title': 'صحة المرأة', 'prompt': 'أريد معلومات عن صحة المرأة'},
    {'title': 'صحة الطفل', 'prompt': 'أريد معلومات عن صحة الطفل'},
  ];

  static Map<String, dynamic>? findService(String text) {
    final normalized = _normalize(text);
    for (final service in services) {
      final keywords = (service['keywords'] as List).cast<String>();
      if (keywords.any((keyword) => normalized.contains(_normalize(keyword)))) {
        return service;
      }
    }
    return null;
  }

  static String? serviceGuidance(String text) {
    final service = findService(text);
    if (service == null) return null;
    return 'يمكنني توجيهك مباشرة إلى «${service['title']}».\n${service['help']}';
  }

  static String _normalize(String value) {
    return value.toLowerCase().trim()
        .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه').replaceAll('ى', 'ي');
  }
}
