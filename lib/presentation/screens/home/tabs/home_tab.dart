import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/health_score_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userName = 'مستخدم';
  int _currentBanner = 0;
  bool _hasError = false;
  String _errorMessage = '';
  double _healthScore = 0.0;
  
  final List<String> _bannerImages = ImageKit.bannerList;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1, 'gender': 'male'},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2, 'gender': 'male'},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3, 'gender': 'female'},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4, 'gender': 'male'},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5, 'gender': 'female'},
  ];

  // ✅ الخدمات السريعة - استخدام أيقونات PNG محلية
  final List<Map<String, dynamic>> _quickServices = [
    {'icon': 'assets/images/icons/fast_services/Pharmacy.png', 'label': 'صيدلية', 'color': AppColors.success, 'screen': const MedicinesScreen()},
    {'icon': 'assets/images/icons/fast_services/Emergency.png', 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
    {'icon': 'assets/images/icons/fast_services/Home medical services.png', 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
    {'icon': 'assets/images/icons/fast_services/Donate blood.png', 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const BloodDonationScreen()},
    {'icon': 'assets/images/icons/doctors/Male doctor.png', 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': ImageKit.lab1, 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': ImageKit.medicine1, 'label': 'صحة', 'color': AppColors.pink, 'screen': const HealthDashboard()},
    {'icon': 'assets/images/icons/top_bar/Shopping cart.png', 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'استشارة', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
    {'icon': 'assets/images/services/map_location.png', 'label': 'بالقرب منك', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
    {'icon': 'assets/images/services/health_insurance.png', 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
  ];

  final List<Map<String, dynamic>> _stats = [
    {'icon': Icons.local_fire_department, 'value': '2,450', 'label': 'سعرة حرارية', 'color': Colors.orange, 'subtitle': 'اليوم'},
    {'icon': Icons.directions_walk, 'value': '8,542', 'label': 'خطوة', 'color': Colors.green, 'subtitle': 'اليوم'},
    {'icon': Icons.bedtime, 'value': '7.5', 'label': 'ساعات النوم', 'color': Colors.purple, 'subtitle': 'الليلة الماضية'},
    {'icon': Icons.favorite, 'value': '72', 'label': 'نبضة/دقيقة', 'color': Colors.red, 'subtitle': 'الآن'},
  ];

  // ... باقي البيانات (الدوال والـ widgets كما هي)
  
  // ✅ دالة لعرض الأيقونات مع دعم PNG و SVG
  Widget _buildServiceIcon(String iconPath, Color color, {double size = 32}) {
    // ✅ إذا كان المسار يبدأ بـ assets/images/icons/fast_services/ أو assets/images/
    if (iconPath.endsWith('.png') || iconPath.endsWith('.jpg') || iconPath.endsWith('.jpeg')) {
      return Image.asset(
        iconPath,
        width: size,
        height: size,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.circle, color: color, size: size);
        },
      );
    }
    
    // ✅ إذا كان SVG
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    
    // ✅ استخدام AppImage للصور من ImageKit
    return AppImage(
      url: iconPath,
      width: size,
      height: size,
    );
  }

  // ... باقي الكود
}
