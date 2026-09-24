import 'package:flutter/material.dart';

/// Unified knowledge catalogue used by the smart health assistant.
/// Keeps service navigation and app guidance in one source of truth.
class SmartHealthKnowledge {
  static const List<Map<String, dynamic>> services = [
    {'title': 'الأطباء', 'keywords': ['طبيب','دكتور','دكتورة','تخصص','اكشف','ابغى دكتور','ابغى طبيب','احجز دكتور','موعد طبيب'], 'route': '/doctors', 'icon': Icons.medical_services_outlined, 'help': 'البحث عن طبيب واختيار التخصص والموعد المناسب.'},
    {'title': 'الصيدلية', 'keywords': ['دواء','صيدلية','دواءاتي','علاج','حبوب','روشتة','وصفة','دوائي'], 'route': '/pharmacy', 'icon': Icons.local_pharmacy_outlined, 'help': 'البحث عن الأدوية والمنتجات الصحية داخل الصيدلية.'},
    {'title': 'المختبرات', 'keywords': ['مختبر','معمل','تحليل','تحاليل','فحص','نتيجة','فحوصات','اشعة','أشعة'], 'route': '/labs', 'icon': Icons.biotech_outlined, 'help': 'الوصول إلى المختبرات والفحوصات والنتائج.'},
    {'title': 'صحتي', 'keywords': ['صحتي','مؤشرات','ضغط','سكر','وزن','نبض','نوم','خطوات','صحة'], 'route': '/health', 'icon': Icons.favorite_outline, 'help': 'متابعة المؤشرات الصحية والسجل الصحي.'},
    {'title': 'الاستشارة الطبية', 'keywords': ['استشارة','استشاره','طبيب عن بعد','استشارة طبية','اكلم طبيب','اتكلم مع دكتور','ابغى استشارة','كشف عن بعد'], 'route': '/consultation', 'icon': Icons.video_call_outlined, 'help': 'بدء أو متابعة استشارة طبية عن بُعد.'},
    {'title': 'الطوارئ', 'keywords': ['طوارئ','اسعاف','إسعاف','طارئ','نجدة','انقذوني','حالة طارئة','اختناق','نزيف شديد'], 'route': '/emergency', 'icon': Icons.emergency_outlined, 'help': 'الوصول السريع إلى معلومات وخدمات الطوارئ.'},
    {'title': 'الخدمات', 'keywords': ['خدمات','جميع الخدمات','الخدمات الصحية','ايش عندكم','ماذا يقدم التطبيق','كيف استخدم التطبيق','وين الخدمة'], 'route': '/services', 'icon': Icons.grid_view_outlined, 'help': 'استعراض الخدمات الصحية المتاحة في صحتك.'},
    {'title': 'التبرع بالدم', 'keywords': ['تبرع بالدم','متبرع بالدم','فصيلة دم','تبرع دم'], 'route': '/blood-donation', 'icon': Icons.bloodtype_outlined, 'help': 'الوصول إلى خدمة التبرع بالدم.'},
    {'title': 'المحفظة', 'keywords': ['محفظة','دفع','رصيد','فاتورة','مدفوعات'], 'route': '/wallet', 'icon': Icons.account_balance_wallet_outlined, 'help': 'متابعة المحفظة والمدفوعات داخل التطبيق.'},
    {'title': 'الخريطة', 'keywords': ['خريطة','موقع','وين اقرب','أين أقرب','اقرب مستشفى','مستشفى قريب','صيدلية قريبة','مختبر قريب','مركز صحي قريب'], 'route': '/map', 'icon': Icons.map_outlined, 'help': 'العثور على المنشآت والخدمات الصحية القريبة.'},
    {'title': 'التغذية', 'keywords': ['تغذية','غذاء','حمية','رجيم','سعرات','غذائي','وجبات'], 'route': '/nutrition', 'icon': Icons.restaurant_outlined, 'help': 'الوصول إلى أدوات ومعلومات التغذية الصحية.'},
    {'title': 'النوم', 'keywords': ['نوم','أرق','نومي','ساعات النوم'], 'route': '/sleep-tracker', 'icon': Icons.bedtime_outlined, 'help': 'متابعة النوم وتحسين عادات النوم.'},
    {'title': 'الملف الصحي', 'keywords': ['ملفي الصحي','الملف الصحي','بياناتي الصحية','سجلي الصحي'], 'route': '/profile', 'icon': Icons.person_outline, 'help': 'الوصول إلى الملف الشخصي والبيانات الصحية.'},
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

  static List<Map<String, dynamic>> findServices(String text) {
    final normalized = _normalize(text);
    return services.where((service) {
      final keywords = (service['keywords'] as List).cast<String>();
      return keywords.any((keyword) => normalized.contains(_normalize(keyword)));
    }).toList();
  }

  static Map<String, dynamic>? findService(String text) {
    final matches = findServices(text);
    return matches.isEmpty ? null : matches.first;
  }

  static String? serviceGuidance(String text) {
    final service = findService(text);
    if (service == null) return null;
    return 'يمكنني توجيهك مباشرة إلى «${service['title']}».\\n${service['help']}';
  }

  static String _normalize(String value) {
    return value.toLowerCase().trim()
        .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه').replaceAll('ى', 'ي');
  }
}
