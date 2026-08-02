import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/gradient_button.dart';
import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:sehatak/presentation/screens/home/widgets/quick_services.dart';
import 'package:sehatak/presentation/screens/home/widgets/doctor_card.dart';
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

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  // ✅ البيانات
  final List<String> _bannerImages = BannerImages.list;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1, 'gender': 'male', 'price': 150, 'available': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2, 'gender': 'male', 'price': 180, 'available': true},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3, 'gender': 'female', 'price': 120, 'available': false},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4, 'gender': 'male', 'price': 140, 'available': true},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5, 'gender': 'female', 'price': 160, 'available': true},
    {'id': '6', 'name': 'د. سعيد العمري', 'specialty': 'جلدية', 'rating': 4.5, 'reviews': 145, 'image': ImageKit.doctor1, 'gender': 'male', 'price': 130, 'available': true},
  ];

  final List<QuickServiceItem> _quickServices = [
    QuickServiceItem(icon: ImageKit.pharmacyIcon, label: 'صيدلية', color: AppColors.success, screen: const MedicinesScreen()),
    QuickServiceItem(icon: ImageKit.emergencyIcon, label: 'طوارئ', color: AppColors.error, screen: const EmergencyNumbers()),
    QuickServiceItem(icon: ImageKit.homeMedical, label: 'خدمات منزلية', color: Colors.brown, screen: const ServicesScreen()),
    QuickServiceItem(icon: ImageKit.donateBlood, label: 'تبرع بالدم', color: Colors.red, screen: const BloodDonationScreen()),
    QuickServiceItem(icon: ImageKit.maleDoctorIcon, label: 'أطباء', color: AppColors.primary, screen: const DoctorsListScreen()),
    QuickServiceItem(icon: ImageKit.lab1, label: 'مختبرات', color: AppColors.purple, screen: const LabsListScreen()),
    QuickServiceItem(icon: ImageKit.medicine1, label: 'صحة', color: AppColors.pink, screen: const HealthDashboard()),
    QuickServiceItem(icon: ImageKit.cartIcon, label: 'محفظة', color: AppColors.amber, screen: const WalletScreen()),
    QuickServiceItem(icon: ImageKit.medicalIcon, label: 'استشارة', color: AppColors.teal, screen: const ConsultationScreen()),
    QuickServiceItem(icon: ImageKit.notificationsIcon, label: 'بالقرب منك', color: Colors.orange, screen: const InteractiveMapScreen()),
    QuickServiceItem(icon: ImageKit.placeholder, label: 'تأمين', color: Colors.blue, screen: const InsuranceCompanies()),
  ];

  final List<Map<String, dynamic>> _featuredHospitals = [
    {'id': '1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء', 'image': ImageKit.hospital1, 'rating': 4.9, 'phone': '01-234571', 'specialty': 'عام', 'open': true},
    {'id': '2', 'name': 'مستشفى الجمهورية', 'location': 'صنعاء', 'image': ImageKit.hospital2, 'rating': 4.8, 'phone': '01-234572', 'specialty': 'عام', 'open': true},
    {'id': '3', 'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageKit.hospital3, 'rating': 4.7, 'phone': '01-234573', 'specialty': 'أطفال وولادة', 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredLabs = [
    {'id': '1', 'name': 'مختبرات الذبحاني', 'location': 'صنعاء - شارع الأصبحي', 'image': ImageKit.lab1, 'rating': 4.9, 'phone': '01-234567', 'open': true},
    {'id': '2', 'name': 'مختبرات العولقي', 'location': 'صنعاء - شارع الستين', 'image': ImageKit.lab2, 'rating': 4.8, 'phone': '01-234568', 'open': true},
    {'id': '3', 'name': 'مختبرات المأمون', 'location': 'صنعاء - حدة', 'image': ImageKit.lab3, 'rating': 4.7, 'phone': '01-234569', 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredPharmacies = [
    {'id': '1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء - شارع حدة', 'image': ImageKit.pharmacy1, 'rating': 4.9, 'phone': '01-234580', 'open': true},
    {'id': '2', 'name': 'صيدلية عالم الصيدلة', 'location': 'صنعاء - شارع الستين', 'image': ImageKit.pharmacy2, 'rating': 4.8, 'phone': '01-234581', 'open': true},
    {'id': '3', 'name': 'صيدلية النهضة', 'location': 'صنعاء - باب اليمن', 'image': ImageKit.pharmacy3, 'rating': 4.7, 'phone': '01-234582', 'open': true},
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 🎯 البانر
                BannerCarousel(images: _bannerImages),
                SizedBox(height: 20.h),

                // 🚀 الخدمات السريعة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'خدمات سريعة',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServicesScreen()),
                      ),
                      child: Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                QuickServices(services: _quickServices),
                SizedBox(height: 24.h),

                // 👨‍⚕️ أفضل الأطباء
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أفضل الأطباء',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DoctorsListScreen()),
                      ),
                      child: Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _topDoctors.length > 6 ? 6 : _topDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _topDoctors[index];
                    return DoctorCard(
                      doctor: doctor,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailsScreen(doctorId: doctor['id'] as String),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24.h),

                // 🏥 مستشفيات مميزة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مستشفيات مميزة',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HospitalScreen()),
                      ),
                      child: Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _featuredHospitals.length > 6 ? 6 : _featuredHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = _featuredHospitals[index];
                    return _buildHospitalCard(hospital, isDark);
                  },
                ),
                SizedBox(height: 24.h),

                // 🧪 مختبرات مميزة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مختبرات مميزة',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LabsListScreen()),
                      ),
                      child: Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _featuredLabs.length > 6 ? 6 : _featuredLabs.length,
                  itemBuilder: (context, index) {
                    final lab = _featuredLabs[index];
                    return _buildLabCard(lab, isDark);
                  },
                ),
                SizedBox(height: 24.h),

                // 💊 صيدليات مميزة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'صيدليات مميزة',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                      ),
                      child: Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _featuredPharmacies.length > 6 ? 6 : _featuredPharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacy = _featuredPharmacies[index];
                    return _buildPharmacyCard(pharmacy, isDark);
                  },
                ),
                SizedBox(height: 50.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HospitalScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Image.network(
                    hospital['image'] as String,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120.h,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.r,
                  right: 8.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        Text(
                          hospital['rating'].toString(),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.r,
                  left: 8.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: hospital['open'] == true 
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      hospital['open'] == true ? 'مفتوح' : 'مغلق',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital['name'] as String,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hospital['location'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GradientButton(
                    text: 'حجز',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HospitalScreen()),
                    ),
                    height: 32.h,
                    fontSize: 11.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabCard(Map<String, dynamic> lab, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LabsListScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Image.network(
                lab['image'] as String,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120.h,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab['name'] as String,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lab['location'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GradientButton(
                    text: 'حجز',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LabsListScreen()),
                    ),
                    height: 32.h,
                    fontSize: 11.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(Map<String, dynamic> pharmacy, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PharmacyScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Image.network(
                pharmacy['image'] as String,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120.h,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy['name'] as String,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    pharmacy['location'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GradientButton(
                    text: 'طلب',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                    ),
                    height: 32.h,
                    fontSize: 11.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
