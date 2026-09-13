import 'package:flutter/material.dart';

import 'screen_guided_tour.dart';
import 'tour_themes.dart';
import 'tour_manager.dart';

abstract final class ScreenTours {
  static Widget wrapDoctors(Widget child) => ScreenGuidedTour(
        tourKey: TourManager.doctorsKey,
        steps: [
          _s('ابحث عن طبيب', 'ابحث عن طبيبك', 'اكتب اسم الطبيب أو كلمة مرتبطة بالتخصص للوصول للنتائج بسرعة.', TourThemes.doctors, '🔎'),
          _s('باطنية', 'التخصصات', 'استخدم شريط التخصصات لتضييق قائمة الأطباء حسب المجال الطبي.', TourThemes.doctors, '🩺'),
          _s('الأطباء', 'قائمة الأطباء', 'هذه المنطقة تعرض الأطباء والبيانات التي يوفرها النظام عن التوفر والتقييم.', TourThemes.doctors, '👨‍⚕️', ScreenTooltipPosition.top),
          _s('استشاري', 'بطاقة الطبيب', 'افتح بطاقة الطبيب للوصول إلى التفاصيل والملف والخدمات المتاحة.', TourThemes.doctors, '⭐', ScreenTooltipPosition.top),
          _s('دردشة', 'التواصل', 'من أدوات بطاقة الطبيب يمكنك بدء الدردشة أو الاتصال عندما تكون الخدمة متاحة.', TourThemes.doctors, '💬', ScreenTooltipPosition.top),
          _s('الأطباء', 'تحديث النتائج', 'اسحب القائمة للأسفل لتحديث أحدث بيانات الأطباء.', TourThemes.doctors, '🔄', ScreenTooltipPosition.bottom, 'انتهت جولة الأطباء.'),
        ],
        child: child,
      );

  static Widget wrapPharmacy(Widget child) => ScreenGuidedTour(
        tourKey: TourManager.pharmacyKey,
        steps: [
          _s('متجر أدوية صحتك', 'صيدلية صحتك', 'هنا تتصفح المنتجات المنشورة والمعتمدة داخل متجر صحتك.', TourThemes.pharmacy, '💊'),
          _s('السلة', 'سلة المشتريات', 'تابع العناصر المضافة وافتح السلة لمراجعة اختياراتك.', TourThemes.pharmacy, '🛒'),
          _s('ابحث باسم الدواء', 'البحث عن الدواء', 'ابحث باسم الدواء أو المادة الفعالة أو الفئة.', TourThemes.pharmacy, '🔍'),
          _s('الكل', 'فئات المنتجات', 'استخدم الفئات لتقليل النتائج والوصول للنوع الذي تحتاجه.', TourThemes.pharmacy, '🏷️'),
          _s('منتج', 'المنتجات', 'تصفح المنتجات الفعلية والسعر والتوفر ومصدر البيع.', TourThemes.pharmacy, '📦', ScreenTooltipPosition.top),
          _s('ر.ي', 'تفاصيل المنتج', 'راجع معلومات المنتج ومصدره وتوفره قبل اتخاذ قرار الإضافة.', TourThemes.pharmacy, '🔎', ScreenTooltipPosition.top),
          _s('إضافة', 'الإضافة للسلة', 'عندما يكون المنتج متوفراً استخدم زر الإضافة لبناء طلبك.', TourThemes.pharmacy, '➕', ScreenTooltipPosition.left, 'انتهت جولة الصيدلية.'),
        ],
        child: child,
      );

  static Widget wrapLabs(Widget child) => ScreenGuidedTour(
        tourKey: TourManager.labsKey,
        steps: [
          _s('المختبرات', 'مختبرات صحتك', 'استعرض قوائم المختبرات والخدمات المنزلية المتاحة.', TourThemes.labs, '🔬'),
          _s('ابحث عن مختبر', 'ابحث عن فحصك', 'ابحث باسم المختبر أو التخصص أو الفحص.', TourThemes.labs, '🔍'),
          _s('دم', 'الفئات', 'اختر فئة مثل الدم أو الهرمونات أو الفيتامينات لتصفية النتائج.', TourThemes.labs, '🧪'),
          _s('مختبر', 'نتائج المختبرات', 'هنا تظهر بيانات المختبرات المتاحة من النظام.', TourThemes.labs, '🏥', ScreenTooltipPosition.top),
          _s('مختبر', 'بطاقة المختبر', 'افتح البطاقة للتعرف على الخدمات والتفاصيل وإجراءات الحجز.', TourThemes.labs, '⭐', ScreenTooltipPosition.top),
          _s('خدمة منزلية', 'الخدمة المنزلية', 'انتقل إلى تبويب الخدمة المنزلية لاستعراض المختبرات التي تدعم الوصول للمنزل.', TourThemes.labs, '🏠', ScreenTooltipPosition.top, 'انتهت جولة المختبرات.'),
        ],
        child: child,
      );

  static Widget wrapProfile(Widget child) => ScreenGuidedTour(
        tourKey: TourManager.profileKey,
        steps: [
          _s('مريض', 'ملفك الصحي', 'ابدأ من بطاقة الحساب لمراجعة بياناتك الأساسية وملفك الصحي.', TourThemes.profile, '👤'),
          _s('اشتراك', 'اشتراكك الصحي', 'راجع نوع الباقة والخدمات المرتبطة بها عندما تكون معروضة في الملف.', TourThemes.profile, '💎'),
          _s('المؤشرات', 'المؤشرات الحيوية', 'راجع أهم القياسات الصحية وأدوات التتبع المرتبطة بها.', TourThemes.profile, '❤️', ScreenTooltipPosition.top),
          _s('المواعيد', 'وصول سريع', 'اختصارات مباشرة للأدوات الأكثر استخداماً مثل المواعيد والأدوية.', TourThemes.profile, '⚡', ScreenTooltipPosition.top),
          _s('الخدمات', 'الخدمات الطبية', 'استكشف الخدمات الصحية المرتبطة بحسابك من مكان واحد.', TourThemes.profile, '🩺', ScreenTooltipPosition.top),
          _s('المزمنة', 'الأمراض المزمنة', 'تابع المعلومات الصحية المزمنة المسجلة داخل ملفك.', TourThemes.profile, '📋', ScreenTooltipPosition.top),
          _s('التطعيمات', 'التطعيمات', 'راجع سجلات التطعيمات ومعلوماتها.', TourThemes.profile, '💉', ScreenTooltipPosition.top),
          _s('الحساسية', 'الحساسية', 'راجع معلومات الحساسية المسجلة لتبقى بيانات الرعاية واضحة.', TourThemes.profile, '⚠️', ScreenTooltipPosition.top, 'اكتملت جولة الملف الصحي.'),
        ],
        child: child,
      );

  static Widget wrapMore(Widget child) => ScreenGuidedTour(
        tourKey: TourManager.moreKey,
        steps: [
          _s('مستخدم', 'مساحتك الشخصية', 'من هنا تصل إلى ملفك الشخصي ومعلومات حسابك الأساسية.', TourThemes.more, '👤'),
          _s('المؤشرات الحيوية', 'المؤشرات الحيوية', 'اختصارات مباشرة لأدوات تتبع الضغط والسكر والوزن والنوم وغيرها.', TourThemes.more, '📊', ScreenTooltipPosition.top),
          _s('الكل', 'تصنيف الخدمات', 'اختر فئة لتظهر الخدمات المرتبطة بها فقط.', TourThemes.more, '🧭'),
          _s('الخدمات', 'كل خدمات صحتك', 'هنا تجد الأدوات والخدمات الإضافية من الخرائط والتأمين إلى الدعم والإعدادات.', TourThemes.more, '🧰', ScreenTooltipPosition.top),
          _s('تسجيل الخروج', 'الخروج بأمان', 'زر تسجيل الخروج موجود في نهاية الصفحة عندما تحتاج إلى إنهاء الجلسة.', TourThemes.more, '🔐', ScreenTooltipPosition.top, 'انتهت جولة المزيد.'),
        ],
        child: child,
      );

  static ScreenTourStep _s(
    String target,
    String title,
    String description,
    Color color,
    String emoji, [
    ScreenTooltipPosition position = ScreenTooltipPosition.bottom,
    String? hint,
  ]) => ScreenTourStep(
        targetText: target,
        title: title,
        description: description,
        accentColor: color,
        emoji: emoji,
        position: position,
        actionHint: hint,
      );
}
