import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية
  // ============================================================
  static const String _coreIcons = 'assets/icons/core';
  static const String _navigationIcons = 'assets/icons/navigation';
  static const String _specialties = 'assets/icons/specialties';
  static const String _miniSpecialties = 'assets/icons/mini_specialties';
  static const String _social = 'assets/icons/social';
  static const String _banners = 'assets/images/banners';
  static const String _images = 'assets/images';

  // ============================================================
  // 📌 البانرات (مؤقتاً نستخدم ألواناً بدلاً من الصور)
  // ============================================================
  static final List<Map<String, dynamic>> bannerData = [
    {
      'title': 'رعاية صحية متميزة',
      'sub': 'احجز موعدك الآن مع أفضل الأطباء',
      'color': Color(0xFF0D5257),
      'icon': Icons.health_and_safety,
    },
    {
      'title': 'صيدليتك في راحة يدك',
      'sub': 'اطلب أدويتك وتصلك في أسرع وقت',
      'color': Color(0xFF2E7D32),
      'icon': Icons.local_pharmacy,
    },
    {
      'title': 'مختبرات متطورة',
      'sub': 'نتائج دقيقة وسريعة',
      'color': Color(0xFF6A1B9A),
      'icon': Icons.science,
    },
    {
      'title': 'استشارات طبية فورية',
      'sub': 'تحدث مع طبيبك عبر الفيديو والصوت',
      'color': Color(0xFFC62828),
      'icon': Icons.video_call,
    },
  ];

  // ============================================================
  // 🎯 دالة واحدة موحدة لجميع الأيقونات (مثل مواعيدي)
  // ============================================================
  static Widget svgIcon(String path, {double width = 24, double height = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // ============================================================
  // 📌 أيقونات الشريط السفلي (Navigation) - نفس آلية مواعيدي
  // ============================================================
  static Widget navIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_navigationIcons/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات الأساسية (Core) - نفس آلية مواعيدي
  // ============================================================
  static Widget coreIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_coreIcons/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التخصصات - نفس آلية مواعيدي
  // ============================================================
  static Widget specialtyIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_specialties/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التخصصات المصغرة - نفس آلية مواعيدي
  // ============================================================
  static Widget miniSpecialtyIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_miniSpecialties/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التواصل الاجتماعي - نفس آلية مواعيدي
  // ============================================================
  static Widget socialIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_social/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 🎨 بناء بانر بديل (بدون صورة) - نفس شكل البانر ولكن بألوان
  // ============================================================
  static Widget buildBannerCard(Map<String, dynamic> banner, {double? height}) {
    return Container(
      height: height ?? 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (banner['color'] as Color).withOpacity(0.9),
            (banner['color'] as Color).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (banner['color'] as Color).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ✅ خلفية مزخرفة
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              banner['icon'] as IconData,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // ✅ المحتوى
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(banner['icon'] as IconData, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'صحتك',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  banner['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  banner['sub'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ دوال مساعدة للوصول إلى المسارات (للحالات النادرة)
  // ============================================================
  static String coreIconPath(String name) => '$_coreIcons/$name.svg';
  static String navIconPath(String name) => '$_navigationIcons/$name.svg';
  static String specialtyIconPath(String name) => '$_specialties/$name.svg';
  static String miniSpecialtyIconPath(String name) => '$_miniSpecialties/$name.svg';
  static String socialIconPath(String name) => '$_social/$name.svg';
  static String bannerPath(String name) => '$_banners/$name';
}
