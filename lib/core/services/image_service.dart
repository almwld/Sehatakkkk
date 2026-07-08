import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageService {
  // ============================================================
  // 📸 BASE PATH (من مجلد assets)
  // ============================================================
  static const String _assets = 'assets';
  static const String _images = '$_assets/images';
  static const String _banners = '$_images/banners';
  static const String _icons = '$_assets/icons';

  // ============================================================
  // 🖼️ البانرات (Banners) - من مجلد assets/images/banners/
  // ============================================================
  static const String banner1 = '$_banners/banner_1.png';
  static const String banner2 = '$_banners/banner_2.png';
  static const String banner3 = '$_banners/banner_3.png';
  static const String banner4 = '$_banners/banner_1.png';
  static const String banner5 = '$_banners/banner_2.png';

  // ============================================================
  // 👨‍⚕️ صور الأطباء (ستضاف لاحقاً)
  // ============================================================
  static const String doctor1 = '$_images/placeholder.png';
  static const String doctor2 = '$_images/placeholder.png';
  static const String doctor3 = '$_images/placeholder.png';
  static const String doctor4 = '$_images/placeholder.png';
  static const String doctor5 = '$_images/placeholder.png';
  static const String doctor6 = '$_images/placeholder.png';
  static const String doctor7 = '$_images/placeholder.png';
  static const String doctor8 = '$_images/placeholder.png';

  // ============================================================
  // 💊 صور المنتجات (Products)
  // ============================================================
  static const String medicine1 = '$_images/placeholder.png';
  static const String medicine2 = '$_images/placeholder.png';
  static const String medicine3 = '$_images/placeholder.png';
  static const String medicine4 = '$_images/placeholder.png';
  static const String medicine5 = '$_images/placeholder.png';
  static const String medicine6 = '$_images/placeholder.png';
  static const String medicine7 = '$_images/placeholder.png'; // ✅ تمت الإضافة
  static const String medicine8 = '$_images/placeholder.png'; // ✅ تمت الإضافة
  static const String medicine9 = '$_images/placeholder.png'; // ✅ تمت الإضافة
  static const String medicine10 = '$_images/placeholder.png'; // ✅ تمت الإضافة

  // ============================================================
  // 🏥 صور الصيدليات والمختبرات
  // ============================================================
  static const String pharmacy1 = '$_images/placeholder.png'; // ✅ تمت الإضافة
  static const String pharmacy2 = '$_images/placeholder.png'; // ✅ تمت الإضافة
  static const String lab1 = '$_images/placeholder.png'; // ✅ تمت الإضافة

  // ============================================================
  // 🖼️ صور وهمية (Placeholders)
  // ============================================================
  static const String placeholder = '$_images/placeholder.png';
  static const String avatarPlaceholder = '$_images/placeholder.png';
  static const String productPlaceholder = '$_images/placeholder.png';

  // ============================================================
  // ✅ دوال مساعدة
  // ============================================================
  static String getDoctorImage(int index) {
    final images = [doctor1, doctor2, doctor3, doctor4, doctor5, doctor6, doctor7, doctor8];
    return images[index % images.length];
  }

  static String getBannerImage(int index) {
    final images = [banner1, banner2, banner3, banner4, banner5];
    return images[index % images.length];
  }

  static String getMedicineImage(int index) {
    final medicines = [medicine1, medicine2, medicine3, medicine4, medicine5, medicine6, medicine7, medicine8, medicine9, medicine10];
    return medicines[index % medicines.length];
  }

  // ✅ أيقونات SVG من مجلد assets/icons/
  static String svgIcon(String name) => '$_icons/$name.svg';
  static String specialtyIcon(String name) => '$_icons/specialties/$name.svg';
  static String navigationIcon(String name) => '$_icons/navigation/$name.svg';
  static String socialIcon(String name) => '$_icons/social/$name.svg';
  static String coreIcon(String name) => '$_icons/core/$name.svg';

  // ✅ تحميل الصورة مع Caching (اختياري)
  static Widget cachedImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _shimmerPlaceholder(width, height),
      errorWidget: (context, url, error) => _errorPlaceholder(width, height),
    );
  }

  static Widget _shimmerPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 30)),
    );
  }

  static Widget _errorPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 30)),
    );
  }
}
