import 'package:flutter/material.dart';

import 'tour_models.dart';
import 'tour_themes.dart';

abstract final class MoreTour {
  static List<TourStep> steps({
    required GlobalKey userCard,
    required GlobalKey vitals,
    required GlobalKey categories,
    required GlobalKey services,
    required GlobalKey logout,
  }) => [
        TourStep(
          key: userCard,
          emoji: '👤',
          title: 'مساحتك الشخصية',
          description: 'من هنا تصل إلى ملفك الشخصي وتراجع معلومات حسابك الأساسية بسرعة.',
          accentColor: TourThemes.more,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: vitals,
          emoji: '📊',
          title: 'المؤشرات الحيوية',
          description: 'اختصارات مباشرة لأدوات تتبع المؤشرات الصحية مثل الضغط والسكر والوزن والنوم.',
          accentColor: TourThemes.more,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: categories,
          emoji: '🧭',
          title: 'تصنيف الخدمات',
          description: 'بدلاً من البحث في قائمة طويلة، اختر فئة لتظهر الخدمات المرتبطة بها فقط.',
          accentColor: TourThemes.more,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: services,
          emoji: '🧰',
          title: 'كل خدمات صحتك',
          description: 'هنا تجد الأدوات والخدمات الإضافية، من الخرائط والتأمين إلى الدعم والإعدادات.',
          accentColor: TourThemes.more,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: logout,
          emoji: '🔐',
          title: 'الخروج بأمان',
          description: 'زر تسجيل الخروج موجود في نهاية الصفحة عندما تحتاج إلى إنهاء الجلسة على الجهاز.',
          accentColor: TourThemes.more,
          position: TooltipPosition.top,
          actionHint: 'انتهت جولة المزيد — استكشف ما تحتاجه وقتما تشاء.',
        ),
      ];
}
