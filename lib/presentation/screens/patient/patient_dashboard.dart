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
  String _userRole = 'مريض';
  bool _isLoading = true;

  // ✅ الإحصائيات السريعة
  final List<Map<String, dynamic>> _stats = [
    {'label': 'المواعيد', 'value': '3', 'icon': Icons.calendar_month, 'color': AppColors.primary},
    {'label': 'الأدوية', 'value': '5', 'icon': Icons.medication, 'color': Colors.orange},
    {'label': 'التحاليل', 'value': '2', 'icon': Icons.science, 'color': Colors.purple},
    {'label': 'التقارير', 'value': '4', 'icon': Icons.description, 'color': Colors.teal},
  ];

  // ✅ المؤشرات الحيوية
  final List<Map<String, dynamic>> _vitals = [
    {
      'icon': Icons.favorite,
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.red,
      'status': 'طبيعي',
      'screen': const BloodPressureScreen(),
    },
    {
      'icon': Icons.biotech,
      'label': 'سكر الدم',
      'value': '98',
      'unit': 'مجم/دل',
      'color': Colors.orange,
      'screen': const GlucoseTrackerScreen(),
    },
    {
      'icon': Icons.directions_walk,
      'label': 'اللياقة',
      'value': '85',
      'unit': '%',
      'color': Colors.green,
      'screen': const SleepTrackerScreen(),
    },
    {
      'icon': Icons.monitor_weight,
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.purple,
      'screen': const WeightTrackerScreen(),
    },
  ];

  // ✅ الخدمات الطبية (مع أسماء توضيحية)
  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.calendar_month, 'label': 'المواعيد', 'color': Colors.green, 'screen': const AppointmentsScreen()},
    {'icon': Icons.medication, 'label': 'الأدوية', 'color': Colors.orange, 'screen': const MedicinesScreen()},
    {'icon': Icons.science, 'label': 'المختبرات', 'color': Colors.purple, 'screen': const LabsListScreen()},
    {'icon': Icons.medical_services, 'label': 'الأطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': Icons.local_pharmacy, 'label': 'الصيدلية', 'color': Colors.red, 'screen': const PharmacyScreen()},
    {'icon': Icons.health_and_safety, 'label': 'صحتي', 'color': Colors.teal, 'screen': const HealthDashboard()},
    {'icon': Icons.description, 'label': 'التقارير', 'color': Colors.blueGrey, 'screen': const MedicalReportsScreen()},
    {'icon': Icons.notifications, 'label': 'الإشعارات', 'color': Colors.cyan, 'screen': const NotificationsScreen()},
    {'icon': Icons.wallet, 'label': 'المحفظة', 'color': Colors.brown, 'screen': const WalletScreen()},
    {'icon': Icons.emergency, 'label': 'طوارئ', 'color': Colors.red, 'screen': const EmergencyNumbers()},
    {'icon': Icons.bloodtype, 'label': 'تبرع بالدم', 'color': Colors.deepOrange, 'screen': const BloodDonationScreen()},
    {'icon': Icons.video_call, 'label': 'استشارة فيديو', 'color': Colors.indigo, 'screen': const ConsultationScreen()},
    {'icon': Icons.smart_toy, 'label': 'المساعد الذكي', 'color': Colors.cyan, 'screen': const AiChatbotScreen()},
    {'icon': Icons.card_membership, 'label': 'الباقات', 'color': Colors.amber, 'screen': const SubscriptionsScreen()},
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
      appBar: AppBar(
        title: Text(dashboardTitle),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: roleColor.withOpacity(0.3)),
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
                  // ✅ بطاقة الترحيب
                  _buildWelcomeCard(isDark),
                  const SizedBox(height: 16),

                  // ✅ الإحصائيات السريعة
                  _buildStatsRow(),
                  const SizedBox(height: 20),

                  // ✅ المؤشرات الحيوية مع عناوين واضحة
                  const Text(
                    'المؤشرات الحيوية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildVitalsGrid(isDark),
                  const SizedBox(height: 24),

                  // ✅ الخدمات الطبية مع أسماء توضيحية
                  const Text(
                    'الخدمات الطبية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildServicesGrid(isDark),

                  // ✅ مساحة للشريط السفلي
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  // ✅ بطاقة الترحيب
  Widget _buildWelcomeCard(bool isDark) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً 👋',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getRoleIcon(), color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _userRole,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        final color = vital['color'] as Color;
        return GestureDetector(
          onTap: () {
            final screen = vital['screen'] as Widget;
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    vital['icon'] as IconData,
                    color: color,
                    size: 28,
                  ),
                ),
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
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vital['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
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

  // ✅ الخدمات الطبية مع أسماء توضيحية
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
        final color = service['color'] as Color;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => service['screen'] as Widget),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: color,
                    size: 28,
                  ),
                ),
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
}
