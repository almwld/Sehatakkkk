import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final fontScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المزيد'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ زر العيادة الذكية
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _goTo(context, const AIChatbotScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.medical_services, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'العيادة الذكية - ابدأ الفحص الآن',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * fontScale,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ قسم الخدمات السريعة
            _sectionTitle('خدمات سريعة', isDark, fontScale),
            const SizedBox(height: 12),
            _buildServicesGrid(isDark, primaryColor, fontScale),

            const SizedBox(height: 24),

            // ✅ قسم المؤشرات الحيوية
            _sectionTitle('المؤشرات الحيوية', isDark, fontScale),
            const SizedBox(height: 12),
            _buildVitalsGrid(fontScale),

            const SizedBox(height: 24),

            // ✅ قسم الإعدادات
            _sectionTitle('الإعدادات', isDark, fontScale),
            const SizedBox(height: 12),
            _buildSettingsList(isDark, primaryColor, fontScale),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark, double fontScale) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildServicesGrid(bool isDark, Color primaryColor, double fontScale) {
    final services = [
      {'icon': Icons.person_search, 'label': 'أطباء', 'screen': DoctorsListScreen()},
      {'icon': Icons.local_pharmacy, 'label': 'صيدلية', 'screen': MedicinesScreen()},
      {'icon': Icons.science, 'label': 'مختبرات', 'screen': LabsListScreen()},
      {'icon': Icons.emergency, 'label': 'طوارئ', 'screen': EmergencyNumbers()},
      {'icon': Icons.favorite, 'label': 'صحة', 'screen': HealthDashboard()},
      {'icon': Icons.wallet, 'label': 'محفظة', 'screen': WalletScreen()},
      {'icon': Icons.chat, 'label': 'استشارة', 'screen': ConsultationScreen()},
      {'icon': Icons.calendar_today, 'label': 'مواعيد', 'screen': PatientAppointments()},
      {'icon': Icons.location_on, 'label': 'بالقرب منك', 'screen': InteractiveMapScreen()},
      {'icon': Icons.health_and_safety, 'label': 'تأمين', 'screen': InsuranceCompanies()},
      {'icon': Icons.bloodtype, 'label': 'تبرع بالدم', 'screen': BloodDonationScreen()},
      {'icon': Icons.medication, 'label': 'خدمات منزلية', 'screen': ServicesScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () => _goTo(context, service['screen'] as Widget),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  service['icon'] as IconData,
                  color: primaryColor,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  service['label'] as String,
                  style: TextStyle(
                    fontSize: 11 * fontScale,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVitalsGrid(double fontScale) {
    final vitals = [
      {'icon': Icons.favorite, 'label': 'ضغط الدم', 'color': Colors.red},
      {'icon': Icons.bloodtype, 'label': 'السكر', 'color': Colors.blue},
      {'icon': Icons.monitor_weight, 'label': 'الوزن', 'color': Colors.green},
      {'icon': Icons.favorite_border, 'label': 'النبض', 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: vitals.length,
      itemBuilder: (context, index) {
        final vital = vitals[index];
        final color = vital['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(vital['icon'] as IconData, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                vital['label'] as String,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsList(bool isDark, Color primaryColor, double fontScale) {
    final settings = [
      {'icon': Icons.notifications, 'label': 'الإشعارات', 'screen': NotificationsScreen()},
      {'icon': Icons.settings, 'label': 'الإعدادات', 'screen': SettingsScreen()},
      {'icon': Icons.logout, 'label': 'تسجيل الخروج', 'action': 'logout'},
    ];

    return Column(
      children: settings.map((setting) {
        return ListTile(
          leading: Icon(
            setting['icon'] as IconData,
            color: primaryColor,
          ),
          title: Text(
            setting['label'] as String,
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            if (setting['action'] == 'logout') {
              _showLogoutDialog(context);
            } else if (setting['screen'] != null) {
              _goTo(context, setting['screen'] as Widget);
            }
          },
        );
      }).toList(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
