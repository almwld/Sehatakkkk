import 'package:flutter/material.dart';

import 'tour_models.dart';
import 'tour_themes.dart';

abstract final class DoctorsTour {
  static List<TourStep> steps({
    required GlobalKey search,
    required GlobalKey specialties,
    required GlobalKey results,
    required GlobalKey firstDoctor,
    required GlobalKey doctorActions,
    required GlobalKey refresh,
  }) => [
        TourStep(
          key: search,
          emoji: '🔎',
          title: 'ابحث عن طبيبك',
          description: 'اكتب اسم الطبيب أو ما تبحث عنه للوصول إلى النتائج بسرعة، مع تحديث النتائج أثناء الكتابة.',
          accentColor: TourThemes.doctors,
          position: TooltipPosition.bottom,
          actionHint: 'جرّب اسم طبيب أو تخصصاً طبياً.',
        ),
        TourStep(
          key: specialties,
          emoji: '🩺',
          title: 'التخصصات بين يديك',
          description: 'صف التخصصات يساعدك على تضييق النتائج والعثور على الطبيب المناسب لاحتياجك.',
          accentColor: TourThemes.doctors,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: results,
          emoji: '👨‍⚕️',
          title: 'قائمة الأطباء',
          description: 'هنا تظهر النتائج الفعلية من النظام، مع معلومات التوفر والملف الطبي لكل طبيب.',
          accentColor: TourThemes.doctors,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: firstDoctor,
          emoji: '⭐',
          title: 'بطاقة الطبيب',
          description: 'افتح بطاقة الطبيب لاستعراض تفاصيله، تخصصه، حالته والخدمات المتاحة له.',
          accentColor: TourThemes.doctors,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: doctorActions,
          emoji: '💬',
          title: 'تواصل مباشرة',
          description: 'عندما تكون الأدوات متاحة في بطاقة الطبيب، يمكنك بدء محادثة أو اتصال بطريقة مباشرة.',
          accentColor: TourThemes.doctors,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: refresh,
          emoji: '🔄',
          title: 'حدّث النتائج',
          description: 'اسحب القائمة للتحديث والحصول على أحدث حالة للأطباء والبيانات المتاحة.',
          accentColor: TourThemes.doctors,
          position: TooltipPosition.bottom,
          actionHint: 'هذه الجولة ستظهر مرة واحدة فقط على هذا الجهاز.',
        ),
      ];
}
