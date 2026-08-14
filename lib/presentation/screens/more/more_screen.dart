import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/appointments/appointments_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  // ✅ بيانات المؤشرات الحيوية
  final List<Map<String, dynamic>> _vitals = [
    {'icon': 'assets/images/tracking/blood_pressure.png', 'label': 'ضغط الدم', 'value': '120/80', 'unit': 'مم زئبق', 'color': Colors.blue},
    {'icon': 'assets/images/tracking/blood_sugar.png', 'label': 'سكر الدم', 'value': '98', 'unit': 'مجم/دل', 'color': Colors.orange},
    {'icon': 'assets/images/tracking/fitness.png', 'label': 'اللياقة', 'value': '85', 'unit': '%', 'color': Colors.green},
    {'icon': 'assets/images/tracking/weight_tracking.png', 'label': 'الوزن', 'value': '72', 'unit': 'كجم', 'color': Colors.purple},
  ];

  // ✅ بيانات الخدمات - كل الخدمات مرتبطة بشاشاتها
  final List<Map<String, dynamic>> _services = [
    {'icon': 'assets/images/services/medical_records.png', 'label': 'الملف الشخصي', 'screen': const PatientProfile()},
    {'icon': 'assets/images/services/health_tips.png', 'label': 'صفحتي الصحية', 'screen': const HealthDashboard()},
    {'icon': 'assets/images/services/notifications.png', 'label': 'الإشعارات', 'screen': const NotificationsScreen()},
    {'icon': 'assets/images/services/wallet.png', 'label': 'المحفظة', 'screen': const WalletScreen()},
    {'icon': 'assets/images/services/calendar_booking.png', 'label': 'مواعيدي', 'screen': const AppointmentsScreen()},
    {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ', 'screen': const EmergencyNumbers()},
    {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم', 'screen': const BloodDonationScreen()},
    {'icon': 'assets/images/services/laboratory.png', 'label': 'المختبرات', 'screen': const LabsListScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'الأطباء', 'screen': const DoctorsListScreen()},
    {'icon': 'assets/images/services/pharmacy.png', 'label': 'الصيدلية', 'screen': const PharmacyScreen()},
    {'icon': 'assets/images/services/medical_community.png', 'label': 'خدمات صحية', 'screen': const ServicesScreen()},
    {'icon': 'assets/images/services/video_consultation.png', 'label': 'استشارة فيديو', 'screen': const ConsultationScreen()},
    {'icon': 'assets/images/services/medical_community.png', 'label': 'عن التطبيق', 'screen': const AboutScreen()},
    {'icon': 'settings_material', 'label': 'الإعدادات', 'screen': const SettingsScreen()},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.position.pixels > 20;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المزيد'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: _isScrolled ? 1 : 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ بطاقة المستخدم
            _buildUserCard(user, isDark),
            const SizedBox(height: 16),

            // ✅ المؤشرات الحيوية
            Text(
              'المؤشرات الحيوية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildVitalsGrid(isDark),
            const SizedBox(height: 16),

            // ✅ الخدمات
            Text(
              'الخدمات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildServicesGrid(isDark),
            const SizedBox(height: 16),

            // ✅ زر تسجيل الخروج
            _buildLogoutButton(isDark),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🧑 بطاقة المستخدم
  // ============================================================
  Widget _buildUserCard(User? user, bool isDark) {
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
            radius: 32,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              user?.displayName?.substring(0, 1) ?? 'م',
              style: TextStyle(
                fontSize: 24,
                color: AppColors.primary,
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
                  user?.displayName ?? 'مستخدم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'user@email.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientProfile()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 المؤشرات الحيوية
  // ============================================================
  Widget _buildVitalsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        return Container(
          padding: const EdgeInsets.all(12),
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
              Image.asset(
                vital['icon'] as String,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.circle,
                    color: vital['color'] as Color,
                    size: 40,
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                vital['value'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                vital['unit'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                vital['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 🛠️ الخدمات
  // ============================================================
  Widget _buildServicesGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => service['screen'] as Widget),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
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
                _buildServiceIcon(service['icon'] as String, AppColors.primary, size: 48),
                const SizedBox(height: 6),
                Text(
                  service['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🎨 دالة عرض أيقونة الخدمات
  // ============================================================
  Widget _buildServiceIcon(String iconPath, Color fallbackColor, {double size = 32}) {
    if (iconPath == 'settings_material') {
      return Icon(Icons.settings, color: AppColors.primary, size: size);
    }
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: fallbackColor, size: size);
      },
    );
  }

  // ============================================================
  // 🚪 زر تسجيل الخروج
  // ============================================================
  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 📦 دوال مساعدة
  // ============================================================
  void _showLogoutDialog() {
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
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }
}
