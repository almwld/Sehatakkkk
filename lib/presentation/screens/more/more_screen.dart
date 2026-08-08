import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/contact_us/contact_us_screen.dart';
import 'package:sehatak/presentation/screens/help_center/help_center_screen.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';
import 'package:sehatak/presentation/screens/settings/about_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المزيد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserCard(isDark, isLoggedIn, userName, context),
            const SizedBox(height: 20),
            _buildMenuItem(Icons.person_outline, 'الملف الشخصي', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientProfile()));
            }, isDark),
            _buildMenuItem(Icons.calendar_month, 'مواعيدي', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientAppointments()));
            }, isDark),
            _buildMenuItem(Icons.description, 'التقارير الطبية', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalReportsScreen()));
            }, isDark),
            _buildMenuItem(Icons.favorite, 'لوحة الصحة', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthDashboard()));
            }, isDark),
            _buildMenuItem(Icons.medication, 'تذكير الأدوية', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationReminderScreen()));
            }, isDark),
            const Divider(),
            _buildMenuItem(Icons.support_agent, 'اتصل بنا', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()));
            }, isDark),
            _buildMenuItem(Icons.help, 'مركز المساعدة', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
            }, isDark),
            _buildMenuItem(Icons.description, 'الشروط والأحكام', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
            }, isDark),
            _buildMenuItem(Icons.info, 'عن التطبيق', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
            }, isDark),
            _buildMenuItem(Icons.settings, 'الإعدادات', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }, isDark),
            if (isLoggedIn) ...[
              const Divider(),
              _buildMenuItem(Icons.logout, 'تسجيل الخروج', () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }, isDark, isLogout: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(bool isDark, bool isLoggedIn, String userName, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              userName.isNotEmpty ? userName[0] : 'م',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? userName : 'زائر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  isLoggedIn ? 'انقر لعرض الملف الشخصي' : 'قم بتسجيل الدخول',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            onPressed: () {
              if (isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientProfile()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : (isDark ? Colors.white : Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : (isDark ? Colors.white : Colors.black87),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
