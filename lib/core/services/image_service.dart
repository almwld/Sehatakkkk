import 'package:flutter/material.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية
  // ============================================================
  static const String _baseImages = 'assets/images';
  
  // ============================================================
  // 🖼️ البانرات (Banners) - 4 صور
  // ============================================================
  static const String banner1 = '$_baseImages/banners/banner_1.png';
  static const String banner2 = '$_baseImages/banners/banner_2.png';
  static const String banner3 = '$_baseImages/banners/banner_3.png';
  static const String banner4 = '$_baseImages/banners/banner_4.png';
  
  // ============================================================
  // 👨‍⚕️ صور الأطباء (Doctors)
  // ============================================================
  static const String doctor1 = '$_baseImages/doctors/doctor_1.png';
  static const String doctor2 = '$_baseImages/doctors/doctor_2.png';
  static const String doctor3 = '$_baseImages/doctors/doctor_3.png';
  static const String doctor4 = '$_baseImages/doctors/doctor_4.png';
  static const String doctor5 = '$_baseImages/doctors/doctor_5.png';
  
  // ============================================================
  // 💊 صور الأدوية (Medicines)
  // ============================================================
  static const String medicine1 = '$_baseImages/medicines/medicine_1.png';
  static const String medicine2 = '$_baseImages/medicines/medicine_2.png';
  static const String medicine3 = '$_baseImages/medicines/medicine_3.png';
  static const String medicine4 = '$_baseImages/medicines/medicine_4.png';
  
  // ============================================================
  // 🏪 صور الصيدليات (Pharmacies)
  // ============================================================
  static const String pharmacy1 = '$_baseImages/pharmacies/pharmacy_1.png';
  static const String pharmacy2 = '$_baseImages/pharmacies/pharmacy_2.png';
  static const String pharmacy3 = '$_baseImages/pharmacies/pharmacy_3.png';
  
  // ============================================================
  // 🔬 صور المختبرات (Labs)
  // ============================================================
  static const String lab1 = '$_baseImages/labs/lab_1.png';
  static const String lab2 = '$_baseImages/labs/lab_2.png';
  static const String lab3 = '$_baseImages/labs/lab_3.png';
  
  // ============================================================
  // 🏥 صور المستشفيات (Hospitals)
  // ============================================================
  static const String hospital1 = '$_baseImages/hospitals/hospital_1.png';
  static const String hospital2 = '$_baseImages/hospitals/hospital_2.png';
  static const String hospital3 = '$_baseImages/hospitals/hospital_3.png';
  static const String hospital4 = '$_baseImages/hospitals/hospital_4.png';
  static const String hospital5 = '$_baseImages/hospitals/hospital_5.png';
  static const String hospital6 = '$_baseImages/hospitals/hospital_6.png';
  static const String hospital7 = '$_baseImages/hospitals/hospital_7.png';
  static const String hospital8 = '$_baseImages/hospitals/hospital_8.png';
  static const String hospital9 = '$_baseImages/hospitals/hospital_9.png';
  
  // ============================================================
  // 📦 أيقونات SVG (للـ HomeScreen)
  // ============================================================
  static const String iconNotifications = 'assets/icons/core/notifications_active.svg';
  static const String iconCart = 'assets/icons/core/pharmacy.svg';
  static const String iconSearch = 'assets/icons/core/search.svg';
  static const String iconBroadcast = 'assets/icons/core/broadcast.svg';
  
  // ============================================================
  // 📊 دوال مساعدة
  // ============================================================
  static String getDoctorImage(String doctorId) {
    switch (doctorId) {
      case '1': return doctor1;
      case '2': return doctor2;
      case '3': return doctor3;
      case '4': return doctor4;
      case '5': return doctor5;
      default: return doctor1;
    }
  }
  
  static String getMedicineImage(String medicineId) {
    final int id = int.tryParse(medicineId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final index = ((id - 1) % 4) + 1;
    return '$_baseImages/medicines/medicine_$index.png';
  }
}
