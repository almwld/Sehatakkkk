import 'package:flutter/material.dart';

import 'tour_models.dart';
import 'tour_themes.dart';

abstract final class LabsTour {
  static List<TourStep> steps({
    required GlobalKey tabs,
    required GlobalKey search,
    required GlobalKey categories,
    required GlobalKey results,
    required GlobalKey firstLab,
    required GlobalKey homeService,
  }) => [
        TourStep(
          key: tabs,
          emoji: '🔬',
          title: 'مختبرات صحتك',
          description: 'استعرض المختبرات حسب القوائم المتاحة، واكتشف الخيارات الأفضل والخدمات المنزلية.',
          accentColor: TourThemes.labs,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: search,
          emoji: '🔍',
          title: 'ابحث عن فحصك',
          description: 'ابحث باسم المختبر أو التخصص أو الفحص للوصول إلى النتيجة التي تحتاجها.',
          accentColor: TourThemes.labs,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: categories,
          emoji: '🧪',
          title: 'فلترة ذكية',
          description: 'اختر فئة مثل الدم أو الهرمونات أو الفيتامينات لتضييق قائمة الفحوصات والمختبرات.',
          accentColor: TourThemes.labs,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: results,
          emoji: '🏥',
          title: 'نتائج المختبرات',
          description: 'هنا تظهر المختبرات الفعلية من النظام، مع البيانات المتاحة لكل منشأة.',
          accentColor: TourThemes.labs,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: firstLab,
          emoji: '⭐',
          title: 'بطاقة المختبر',
          description: 'افتح بطاقة المختبر للتعرف على خدماته وتفاصيله والانتقال إلى إجراءات الحجز المتاحة.',
          accentColor: TourThemes.labs,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: homeService,
          emoji: '🏠',
          title: 'خدمة منزلية',
          description: 'انتقل إلى تبويب الخدمة المنزلية عندما تريد استعراض المختبرات التي تدعم الوصول إلى المنزل.',
          accentColor: TourThemes.labs,
          position: TooltipPosition.top,
          actionHint: 'انتهت الجولة — اختر المختبر الأنسب لك.',
        ),
      ];
}
