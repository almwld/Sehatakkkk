import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/edit_profile/edit_profile_screen.dart';
import 'package:sehatak/presentation/screens/change_password/change_password_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_medical_history.dart';
import 'package:sehatak/presentation/screens/patient/patient_prescriptions.dart';

class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  bool _isLoading = false;

  // ✅ بيانات المريض
  final Map<String, dynamic> _patientData = {
    'name': 'أحمد محمد',
    'email': 'ahmed@email.com',
    'phone': '+967 777 888 999',
    'bloodType': 'A+',
    'age': 35,
    'weight': 75,
    'height': 175,
    'emergencyContact': 'خالد أحمد',
    'emergencyPhone': '777888999',
  };

  // ✅ قائمة الخيارات
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': 'assets/images/services/medical_records.png', 'title': 'تعديل الملف الشخصي', 'screen': const EditProfileScreen()},
    {'icon': 'assets/images/services/calendar_booking.png', 'title': 'مواعيدي', 'screen': const PatientAppointments()},
    {'icon': 'assets/images/tracking/medical_report.png', 'title': 'التقارير الطبية', 'screen': const MedicalReportsScreen()},
    {'icon': 'assets/images/services/medical_community.png', 'title': 'السجل الطبي', 'screen': const PatientMedicalHistory()},
    {'icon': 'assets/images/services/medications.png', 'title': 'الوصفات الطبية', 'screen': const PatientPrescriptions()},
    {'icon': 'assets/images/services/laboratory.png', 'title': 'نتائج التحاليل', 'screen': const MedicalReportsScreen()},
    {'icon': 'assets/images/services/consultation.png', 'title': 'تغيير كلمة المرور', 'screen': const ChangePasswordScreen()},
  ];

  // ✅ دالة لعرض الأيقونات المحلية
  Widget _buildLocalIcon(String iconPath, {double size = 24, Color? color}) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.image, size: size, color: color ?? Colors.grey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? _patientData['name'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ بطاقة الملف الشخصي
                  _buildProfileCard(isDark, name),
                  const SizedBox(height: 20),

                  // ✅ القائمة
                  ..._menuItems.map((item) {
                    return _buildMenuItem(
                      icon: item['icon'] as String,
                      title: item['title'] as String,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => item['screen'] as Widget,
                          ),
                        );
                      },
                      isDark: isDark,
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  // ✅ زر تسجيل الخروج
                  _buildLogoutButton(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(bool isDark, String name) {
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
      child: Column(
        children: [
          // ✅ الصورة الشخصية
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0] : 'م',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            _patientData['email'] as String,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem('فصيلة الدم', _patientData['bloodType'] as String, isDark),
              _buildInfoItem('العمر', '${_patientData['age']} سنة', isDark),
              _buildInfoItem('الوزن', '${_patientData['weight']} كجم', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildLocalIcon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        _showLogoutDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: تسجيل الخروج
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
