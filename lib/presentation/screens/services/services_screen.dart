import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/exercise/exercise_plan_screen.dart';
import 'package:sehatak/presentation/screens/diet/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ الخدمات مع الأيقونات الجديدة
    final List<Map<String, dynamic>> services = [
      {
        'icon': 'assets/images/services/calendar_booking.png',
        'label': 'حجز موعد',
        'color': AppColors.primary,
        'screen': const DoctorsListScreen(),
      },
      {
        'icon': 'assets/images/services/pharmacy.png',
        'label': 'طلب دواء',
        'color': AppColors.success,
        'screen': const MedicinesScreen(),
      },
      {
        'icon': 'assets/images/services/laboratory.png',
        'label': 'فحص مخبري',
        'color': AppColors.purple,
        'screen': const LabsListScreen(),
      },
      {
        'icon': 'assets/images/services/consultation.png',
        'label': 'استشارة طبية',
        'color': AppColors.teal,
        'screen': const ConsultationScreen(),
      },
      {
        'icon': 'assets/images/services/emergency.png',
        'label': 'طوارئ',
        'color': AppColors.error,
        'screen': const EmergencyNumbers(),
      },
      {
        'icon': 'assets/images/services/medical_community.png',
        'label': 'رعاية منزلية',
        'color': Colors.brown,
        'screen': const ServicesScreen(),
      },
      {
        'icon': 'assets/images/services/blood_donation.png',
        'label': 'تبرع بالدم',
        'color': Colors.red,
        'screen': const BloodDonationScreen(),
      },
      {
        'icon': 'assets/images/tracking/mental_health.png',
        'label': 'صحة نفسية',
        'color': Colors.purple,
        'screen': const MentalHealthScreen(),
      },
      {
        'icon': 'assets/images/tracking/fitness.png',
        'label': 'تمارين',
        'color': Colors.orange,
        'screen': const ExercisePlanScreen(),
      },
      {
        'icon': 'assets/images/tracking/nutrition.png',
        'label': 'تغذية',
        'color': Colors.green,
        'screen': const DietPlanScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الخدمات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ شريط البحث
            _buildSearchBar(isDark),
            const SizedBox(height: 20),

            // ✅ شبكة الخدمات
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(
                  icon: service['icon'] as String,
                  label: service['label'] as String,
                  color: service['color'] as Color,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => service['screen'] as Widget,
                      ),
                    );
                  },
                  isDark: isDark,
                );
              },
            ),
            const SizedBox(height: 24),

            // ✅ خدمات إضافية
            _buildSectionTitle('خدمات مميزة', isDark),
            const SizedBox(height: 12),
            _buildFeaturedServices(isDark),
            const SizedBox(height: 24),

            // ✅ عروض خاصة
            _buildSectionTitle('عروض خاصة', isDark),
            const SizedBox(height: 12),
            _buildSpecialOffers(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ✅ شريط البحث
  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن خدمة...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            Icons.mic,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            size: 22,
          ),
        ],
      ),
    );
  }

  // ✅ بطاقة الخدمة
  Widget _buildServiceCard({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                icon,
                width: 32,
                height: 32,
                color: color,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.circle,
                    color: color,
                    size: 32,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ عنوان القسم
  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'عرض الكل',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ خدمات مميزة
  Widget _buildFeaturedServices(bool isDark) {
    final featuredServices = [
      {'icon': 'assets/images/services/video_consultation.png', 'label': 'استشارة فيديو', 'color': AppColors.teal},
      {'icon': 'assets/images/services/ai_assistant.png', 'label': 'مساعد ذكي', 'color': AppColors.purple},
      {'icon': 'assets/images/services/health_tips.png', 'label': 'نصائح صحية', 'color': AppColors.pink},
      {'icon': 'assets/images/services/medical_records.png', 'label': 'سجلات طبية', 'color': AppColors.primary},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredServices.length,
        itemBuilder: (context, index) {
          final service = featuredServices[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  service['icon'] as String,
                  width: 28,
                  height: 28,
                  color: service['color'] as Color,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.circle,
                      color: service['color'] as Color,
                      size: 28,
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  service['label'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ عروض خاصة
  Widget _buildSpecialOffers(bool isDark) {
    final offers = [
      {'title': 'خصم 20% على أول استشارة', 'color': Colors.red, 'icon': 'assets/images/services/consultation.png'},
      {'title': 'فحص مجاني مع أول حجز', 'color': AppColors.primary, 'icon': 'assets/images/services/laboratory.png'},
      {'title': 'توصيل مجاني للطلبات فوق 2000', 'color': Colors.green, 'icon': 'assets/images/services/pharmacy.png'},
    ];

    return Column(
      children: offers.map((offer) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (offer['color'] as Color).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (offer['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  offer['icon'] as String,
                  width: 24,
                  height: 24,
                  color: offer['color'] as Color,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_offer,
                      color: offer['color'] as Color,
                      size: 24,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  offer['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'استفد الآن',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
