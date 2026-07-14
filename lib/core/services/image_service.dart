import 'package:flutter/material.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية
  // ============================================================
  static const String _baseImages = 'assets/images';
  static const String _baseIcons = 'assets/icons';
  
  // ============================================================
  // 🖼️ البانرات (Banners) - 4 صور
  // ============================================================
  static const String banner1 = '$_baseImages/banners/banner_1.png';
  static const String banner2 = '$_baseImages/banners/banner_2.png';
  static const String banner3 = '$_baseImages/banners/banner_3.png';
  static const String banner4 = '$_baseImages/banners/banner_4.png';
  
  // ✅ قائمة البانرات
  static final List<String> bannerList = [
    banner1,
    banner2,
    banner3,
    banner4,
  ];
  
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
  static const String iconNotifications = '$_baseIcons/core/notifications_active.svg';
  static const String iconCart = '$_baseIcons/core/pharmacy.svg';
  static const String iconSearch = '$_baseIcons/core/search.svg';
  static const String iconBroadcast = '$_baseIcons/core/broadcast.svg';
}

// ============================================================
// 🏥 صور المستشفيات (Hospitals)
// ============================================================

// ============================================================
// 📦 أيقونات الخدمات السريعة (Quick Services)
// ============================================================
static const String serviceDoctors = '$_baseIcons/services/أطباء.png';
static const String servicePharmacy = '$_baseIcons/services/ادويه.png';
static const String serviceLabs = '$_baseIcons/services/مخابر.png';
static const String serviceEmergency = '$_baseIcons/services/بالقرب مني .png';
static const String serviceHealth = '$_baseIcons/services/صحةالقلب.png';
static const String serviceWallet = '$_baseIcons/services/محفظ.png';
static const String serviceConsultation = '$_baseIcons/services/محادثات للمعارف.png';
static const String serviceAppointments = '$_baseIcons/services/مواعيد.png';
static const String serviceNearby = '$_baseIcons/services/بالقرب مني .png';
static const String serviceInsurance = '$_baseIcons/services/تامين.png';
static const String serviceBloodDonation = '$_baseIcons/services/تقييم.png';
static const String serviceHomeServices = '$_baseIcons/services/مراسلات.png';
