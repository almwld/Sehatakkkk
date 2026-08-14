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

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  String _userName = 'مريض';
  String _userEmail = '';
  bool _isLoading = true;

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
  ];

  // ✅ بيانات المؤشرات الحيوية
  final List<Map<String, dynamic>> _vitals = [
    {
      'icon': 'assets/images/tracking/blood_pressure.png',
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.blue,
    },
    {
      'icon': 'assets/images/tracking/blood_sugar.png',
      'label': 'سكر الدم',
      'value': '98',
      'unit': 'مجم/دل',
      'color': Colors.orange,
    },
    {
      'icon': 'assets/images/tracking/fitness.png',
      'label': 'اللياقة',
      'value': '85',
      'unit': '%',
      'color': Colors.green,
    },
    {
      'icon': 'assets/images/tracking/weight_tracking.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.purple,
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
          setState(() {
            _userName = doc.data()?['name'] ?? user.displayName ?? 'مريض';
            _userEmail = user.email ?? '';
          });
        } else {
          setState(() {
            _userName = user.displayName ?? 'مريض';
            _userEmail = user.email ?? '';
          });
        }
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('لوحة المريض'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
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
                ],
              ),
            ),
    );
  }

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
          const Text(
            'مرحباً 👋',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _userName,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            _userEmail,
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

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
              _buildIcon(vital['icon'] as String, vital['color'] as Color, size: 32, scale: 5.0),
              const SizedBox(height: 8),
              Text(
                vital['value'] as String,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              Text(
                vital['unit'] as String,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                vital['label'] as String,
                style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[500]),
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
