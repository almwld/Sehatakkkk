import 'package:flutter/material.dart';

import 'tour_models.dart';
import 'tour_themes.dart';

abstract final class PharmacyTour {
  static List<TourStep> steps({
    required GlobalKey title,
    required GlobalKey cart,
    required GlobalKey search,
    required GlobalKey categories,
    required GlobalKey products,
    required GlobalKey firstProduct,
    required GlobalKey addToCart,
  }) => [
        TourStep(
          key: title,
          emoji: '💊',
          title: 'صيدلية صحتك',
          description: 'هنا تبدأ رحلة شراء الأدوية من المنتجات المنشورة والمعتمدة داخل متجر صحتك.',
          accentColor: TourThemes.pharmacy,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: cart,
          emoji: '🛒',
          title: 'سلة مشترياتك',
          description: 'تابع عدد العناصر التي أضفتها وافتح السلة لمراجعة اختياراتك.',
          accentColor: TourThemes.pharmacy,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: search,
          emoji: '🔍',
          title: 'ابحث عن الدواء',
          description: 'ابحث بالاسم أو المادة الفعالة أو الفئة للوصول إلى المنتج بسرعة.',
          accentColor: TourThemes.pharmacy,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: categories,
          emoji: '🏷️',
          title: 'صفِّ النتائج',
          description: 'استخدم فئات المنتجات لتقليل النتائج والتركيز على النوع الذي تحتاجه.',
          accentColor: TourThemes.pharmacy,
          position: TooltipPosition.bottom,
        ),
        TourStep(
          key: products,
          emoji: '📦',
          title: 'المنتجات المنشورة',
          description: 'تصفح المنتجات الفعلية مع السعر، حالة المخزون، البائع ومعلومات الدواء المتاحة.',
          accentColor: TourThemes.pharmacy,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: firstProduct,
          emoji: '🔎',
          title: 'تفاصيل المنتج',
          description: 'راجع اسم الدواء ومعلوماته ومصدره وتوفره قبل إضافته إلى السلة.',
          accentColor: TourThemes.pharmacy,
          position: TooltipPosition.top,
        ),
        TourStep(
          key: addToCart,
          emoji: '➕',
          title: 'أضف إلى السلة',
          description: 'إذا كان المنتج متوفراً، استخدم زر الإضافة لبناء طلبك خطوة بخطوة.',
          accentColor: TourThemes.pharmacy,
          position: TooltipPosition.left,
          actionHint: 'انتهت الجولة — التسوق جاهز عندما تحتاجه.',
        ),
      ];
}
