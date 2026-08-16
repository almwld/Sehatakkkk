import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/appointments/appointments_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/sleep_tracker/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  String _userName = 'مريض';
  String _userEmail = '';
  String _userRole = 'مريض'; // ✅ دور المستخدم
  bool _isLoading = true;

  // ✅ الإحصائيات السريعة
  final List<Map<String, dynamic>> _stats = [
    {'label': 'المواعيد', 'value': '3', 'icon': Icons.calendar_month, 'color': AppColors.primary},
    {'label': 'الأدوية', 'value': '5', 'icon': Icons.medication, 'color': Colors.orange},
    {'label': 'التحاليل', 'value': '2', 'icon': Icons.science, 'color': Colors.purple},
    {'label': 'التقارير', 'value': '4', 'icon': Icons.description, 'color': Colors.teal},
  ];

  // ✅ بيانات المؤشرات الحيوية مع الربط بالشاشات
  final List<Map<String, dynamic>> _vitals = [
    {
      'icon': 'assets/images/tracking/blood_pressure.png',
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.blue,
      'screen': const BloodPressureScreen(),
    },
    {
      'icon': 'assets/images/tracking/blood_sugar.png',
      'label': 'سكر الدم',
      'value': '98',
      'unit': 'مجم/دل',
      'color': Colors.orange,
      'screen': const GlucoseTrackerScreen(),
    },
    {
      'icon': 'assets/images/tracking/fitness.png',
      'label': 'اللياقة',
      'value': '85',
      'unit': '%',
      'color': Colors.green,
      'screen': const SleepTrackerScreen(),
    },
    {
      'icon': 'assets/images/tracking/weight_tracking.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.purple,
      'screen': const WeightTrackerScreen(),
    },
  ];

  // ✅ بيانات الخدمات مع مسارات الأيقونات
  final List<Map<String, dynamic>> _services = [
    {
      'icon': 'assets/images/services/calendar_booking.png',
      'label': 'المواعيد',
      'screen': const AppointmentsScreen(),
      'color': Colors.green,
    },
    {
      'icon': 'assets/images/services/medications.png',
      'label': 'الأدوية',
      'screen': const MedicinesScreen(),
      'color': Colors.orange,
    },
    {
      'icon': 'assets/images/services/laboratory.png',
      'label': 'المختبرات',
      'screen': const LabsListScreen(),
      'color': Colors.purple,
    },
    {
      'icon': 'assets/images/services/consultation.png',
      'label': 'الأطباء',
      'screen': const DoctorsListScreen(),
      'color': AppColors.primary,
    },
    {
      'icon': 'assets/images/services/pharmacy.png',
      'label': 'الصيدلية',
      'screen': const PharmacyScreen(),
      'color': Colors.red,
    },
    {
      'icon': 'assets/images/services/health_tips.png',
      'label': 'صفحتي الصحية',
      'screen': const HealthDashboard(),
      'color': Colors.teal,
    },
    {
      'icon': 'assets/images/services/medical_records.png',
      'label': 'التقارير',
      'screen': const MedicalReportsScreen(),
      'color': Colors.blueGrey,
    },
    {
      'icon': 'assets/images/services/notifications.png',
      'label': 'الإشعارات',
      'screen': const NotificationsScreen(),
      'color': Colors.cyan,
    },
    {
      'icon': 'assets/images/services/wallet.png',
      'label': 'المحفظة',
      'screen': const WalletScreen(),
      'color': Colors.brown,
    },
    {
      'icon': 'assets/images/services/emergency.png',
      'label': 'طوارئ',
      'screen': const EmergencyNumbers(),
      'color': Colors.red,
    },
    {
      'icon': 'assets/images/services/blood_donation.png',
      'label': 'تبرع بالدم',
      'screen': const BloodDonationScreen(),
      'color': Colors.deepOrange,
    },
    {
      'icon': 'assets/images/services/video_consultation.png',
      'label': 'استشارة فيديو',
      'screen': const ConsultationScreen(),
      'color': Colors.indigo,
    },
    {
      'icon': 'assets/images/services/ai_assistant.png',
      'label': 'المساعد الذكي',
      'screen': const AiChatbotScreen(),
      'color': Colors.cyan,
    },
    {
      'icon': 'assets/images/services/subscriptions.png',
      'label': 'الباقات',
      'screen': const SubscriptionsScreen(),
      'color': Colors.amber,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _userName = data?['name'] ?? user.displayName ?? 'مريض';
            _userEmail = user.email ?? '';
            // ✅ تحديد الدور من قاعدة البيانات
            _userRole = data?['role'] ?? data?['type'] ?? 'مريض';
          });
        } else {
          setState(() {
            _userName = user.displayName ?? 'مريض';
            _userEmail = user.email ?? '';
            _userRole = 'مريض';
          });
        }
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
    setState(() => _isLoading = false);
  }

  // ✅ الحصول على عنوان مناسب حسب الدور
  String _getDashboardTitle() {
    switch (_userRole.toLowerCase()) {
      case 'طبيب':
      case 'doctor':
        return 'لوحة الطبيب';
      case 'ممرض':
      case 'nurse':
        return 'لوحة الممرض';
      case 'مشرف':
      case 'supervisor':
      case 'admin':
        return 'لوحة المشرف';
      case 'صيدلي':
      case 'pharmacist':
        return 'لوحة الصيدلي';
      case 'فني':
      case 'technician':
        return 'لوحة الفني';
      default:
        return 'لوحة المريض';
    }
  }

  // ✅ الحصول على أيقونة مناسبة حسب الدور
  IconData _getRoleIcon() {
    switch (_userRole.toLowerCase()) {
      case 'طبيب':
      case 'doctor':
        return Icons.medical_services;
      case 'ممرض':
      case 'nurse':
        return Icons.health_and_safety;
      case 'مشرف':
      case 'supervisor':
      case 'admin':
        return Icons.admin_panel_settings;
      case 'صيدلي':
      case 'pharmacist':
        return Icons.local_pharmacy;
      case 'فني':
      case 'technician':
        return Icons.science;
      default:
        return Icons.person;
    }
  }

  // ✅ الحصول على لون مناسب حسب الدور
  Color _getRoleColor() {
    switch (_userRole.toLowerCase()) {
      case 'طبيب':
      case 'doctor':
        return Colors.blue;
      case 'ممرض':
      case 'nurse':
        return Colors.green;
      case 'مشرف':
      case 'supervisor':
      case 'admin':
        return Colors.orange;
      case 'صيدلي':
      case 'pharmacist':
        return Colors.purple;
      case 'فني':
      case 'technician':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardTitle = _getDashboardTitle();
    final roleIcon = _getRoleIcon();
    final roleColor = _getRoleColor();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: dashboardTitle,
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          // ✅ عرض دور المستخدم في الشريط العلوي
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: roleColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(roleIcon, color: roleColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  _userRole,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: roleColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.person, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientProfile()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ الإحصائيات السريعة
                  _buildStatsRow(),
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
                  
                  // ✅ الخدمات الطبية
                  Text(
                    'الخدمات الطبية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildServicesGrid(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ✅ بطاقة الترحيب مع عرض الدور
  Widget _buildWelcomeCard(bool isDark) {
    final roleColor = _getRoleColor();
    final roleIcon = _getRoleIcon();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'مرحباً 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // ✅ عرض الدور في البطاقة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(roleIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _userRole,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userEmail,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ الإحصائيات السريعة
  Widget _buildStatsRow() {
    return Row(
      children: _stats.map((stat) {
        final color = stat['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ✅ المؤشرات الحيوية
  Widget _buildVitalsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        return GestureDetector(
          onTap: () {
            final screen = vital['screen'] as Widget;
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
          child: Container(
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
                _buildIcon(vital['icon'] as String, vital['color'] as Color, size: 32, scale: 5.0),
                const SizedBox(height: 8),
                Text(
                  vital['value'] as String,
                  style: TextStyle(
                    fontSize: 20,
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
          ),
        );
      },
    );
  }

  // ✅ الخدمات الطبية
  Widget _buildServicesGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
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
                _buildIcon(service['icon'] as String, service['color'] as Color, size: 36, scale: 5.0),
                const SizedBox(height: 8),
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

  Widget _buildIcon(String iconPath, Color fallbackColor, {double size = 32, double scale = 5.0}) {
    final actualSize = size * scale;
    if (iconPath.startsWith('http') || iconPath.startsWith('https')) {
      return Image.network(
        iconPath,
        width: actualSize,
        height: actualSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image,
          color: fallbackColor,
          size: actualSize,
        ),
      );
    }
    return Image.asset(
      iconPath,
      width: actualSize,
      height: actualSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.image,
        color: fallbackColor,
        size: actualSize,
      ),
    );
  }
}
