import 'package:flutter/material.dart';

import 'tour_models.dart';
import 'tour_themes.dart';

abstract final class HomeTour {
  static List<TourStep> steps({
    required GlobalKey notifications,
    required GlobalKey cart,
    required GlobalKey search,
    required GlobalKey vitals,
    required GlobalKey quickServices,
    required GlobalKey doctors,
    required GlobalKey community,
  }) => [
        TourStep(
          key: notifications,
          emoji: '🔔',
          title: 'ابقَ على اطلاع',
          description: 'كل تنبيه مهم من صحتك يصل إلى هنا: مواعيد، رسائل، تحديثات ونتائج تحتاج انتباهك.',
          accentColor: TourThemes.home,
          position: TooltipPosition.bottom,
          actionHint: 'اضغط التالي لنكتشف بقية واجهة صحتك.',
        ),
        TourStep(
          key: cart,
          emoji: '🛒',
          title: 'كل طلباتك في مكان واحد',
          description: 'راجع الأدوية والمنتجات التي اخترتها، وتابع سلتك قبل إكمال طلبك.',
          accentColor: TourThemes.home,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: search,
          emoji: '🔍',
          title: 'ابحث بذكاء',
          description: 'ابحث عن طبيب أو دواء أو خدمة بسرعة من البحث الموحد في أعلى الرئيسية.',
          accentColor: TourThemes.home,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: vitals,
          emoji: '📊',
          title: 'مؤشراتك الحيوية',
          description: 'نظرة سريعة على صحتك ونشاطك اليومي تساعدك على متابعة عاداتك ومؤشراتك باستمرار.',
          accentColor: TourThemes.home,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: quickServices,
          emoji: '⚡',
          title: 'الخدمات السريعة',
          description: 'أقصر طريق إلى الخدمات الأكثر استخداماً، من الأطباء والطوارئ إلى المختبرات والصحة.',
          accentColor: TourThemes.home,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: doctors,
          emoji: '👨‍⚕️',
          title: 'أفضل الأطباء',
          description: 'اكتشف الأطباء المتاحين، تخصصاتهم وملفاتهم، ثم اختر الخدمة المناسبة لك.',
          accentColor: TourThemes.home,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: community,
          emoji: '👥',
          title: 'مجتمع صحتك',
          description: 'مساحة صحية للتفاعل والمشاركة واكتشاف محتوى مفيد داخل مجتمع صحتك.',
          accentColor: TourThemes.home,
          position: TooltipPosition.top,
          actionHint: 'انتهت الجولة — يمكنك العودة لأي قسم في أي وقت.',
        ),
      ];
}
