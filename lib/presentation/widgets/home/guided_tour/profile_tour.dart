import 'package:flutter/material.dart';

import 'tour_models.dart';
import 'tour_themes.dart';

abstract final class ProfileTour {
  static List<TourStep> steps({
    required GlobalKey patientCard,
    required GlobalKey subscription,
    required GlobalKey vitals,
    required GlobalKey quickAccess,
    required GlobalKey services,
    required GlobalKey chronic,
    required GlobalKey vaccinations,
    required GlobalKey allergies,
  }) => [
        TourStep(
          key: patientCard,
          emoji: '👤',
          title: 'ملفك الصحي',
          description: 'هذا هو مركز معلوماتك الأساسية. افتح ملفك لمراجعة بياناتك وتحديث ما تحتاجه.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: subscription,
          emoji: '💎',
          title: 'اشتراكك الصحي',
          description: 'تعرف على نوع الباقة الحالية والخدمات المرتبطة بها من لوحة المستخدم.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: vitals,
          emoji: '❤️',
          title: 'المؤشرات الحيوية',
          description: 'راجع أهم مؤشراتك الصحية بسرعة، وافتح أي مؤشر للوصول إلى أدوات التتبع المرتبطة به.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: quickAccess,
          emoji: '⚡',
          title: 'وصول سريع',
          description: 'اختصارات عملية لأكثر الأدوات استخداماً مثل المواعيد والأدوية والمختبرات.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: services,
          emoji: '🩺',
          title: 'الخدمات الطبية',
          description: 'مجموعة الخدمات التي تساعدك على إدارة الرعاية الصحية من مكان واحد.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: chronic,
          emoji: '📋',
          title: 'الأمراض المزمنة',
          description: 'قسم مخصص لمتابعة المعلومات المتعلقة بالحالات المزمنة داخل ملفك الصحي.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: vaccinations,
          emoji: '💉',
          title: 'التطعيمات',
          description: 'تابع معلومات التطعيمات والسجلات المرتبطة بها ضمن ملفك.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: allergies,
          emoji: '⚠️',
          title: 'الحساسية',
          description: 'راجع معلومات الحساسية المسجلة لديك لتبقى بياناتك الصحية واضحة ومنظمة.',
          accentColor: TourThemes.profile,
          position: TooltipPosition.top,
          actionHint: 'اكتملت الجولة — ملفك الصحي أصبح أسهل في الاستكشاف.',
        ),
      ];
}
