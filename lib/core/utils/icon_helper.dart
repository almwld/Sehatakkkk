import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class IconHelper {
  // ✅ عرض أيقونة SVG محلية
  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // ✅ في حالة الخطأ، استخدم أيقونة Material كـ Fallback
        return Icon(Icons.circle, size: size, color: color ?? AppColors.primary);
      },
    );
  }

  // ✅ عرض أيقونة PNG محلية
  static Widget pngIcon(String path, {double size = 24, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, size: size, color: color ?? AppColors.primary);
      },
    );
  }

  // ✅ عرض أيقونة حسب النوع
  static Widget buildIcon(String path, {double size = 24, Color? color}) {
    if (path.endsWith('.svg')) {
      return svgIcon(path, size: size, color: color);
    } else if (path.endsWith('.png')) {
      return pngIcon(path, size: size, color: color);
    } else {
      return Icon(Icons.circle, size: size, color: color ?? AppColors.primary);
    }
  }

  // ✅ أيقونة افتراضية للخطأ
  static Widget fallbackIcon({double size = 24, Color? color}) {
    return Icon(Icons.circle, size: size, color: color ?? AppColors.primary);
  }

  // ✅ أيقونة الصورة
  static Widget imageIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/doctor.svg', size: size, color: color);
  }

  // ✅ أيقونة المستخدم
  static Widget userIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/doctor.svg', size: size, color: color);
  }

  // ✅ أيقونة المزيد
  static Widget moreIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/more_menu.svg', size: size, color: color);
  }

  // ✅ أيقونة الإشعارات
  static Widget notificationIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/notifications_active.svg', size: size, color: color);
  }

  // ✅ أيقونة الصيدلية
  static Widget pharmacyIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/pharmacy.svg', size: size, color: color);
  }

  // ✅ أيقونة المختبر
  static Widget labIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/blood_test.svg', size: size, color: color);
  }

  // ✅ أيقونة الطوارئ
  static Widget emergencyIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/emergency.svg', size: size, color: color);
  }

  // ✅ أيقونة الدردشة
  static Widget chatIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/text_chat.svg', size: size, color: color);
  }

  // ✅ أيقونة مكالمة فيديو
  static Widget videoCallIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/video_call.svg', size: size, color: color);
  }

  // ✅ أيقونة المواعيد
  static Widget appointmentIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/navigation/calendar.svg', size: size, color: color);
  }

  // ✅ أيقونة السجل الصحي
  static Widget healthRecordIcon({double size = 24, Color? color}) {
    return svgIcon('assets/icons/core/health_record.svg', size: size, color: color);
  }
}
