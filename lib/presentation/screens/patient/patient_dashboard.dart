import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ بيانات المريض من Firestore
  Map<String, dynamic> _patientData = {};
  bool _isLoading = true;
  String _patientName = 'مستخدم';
  String _patientEmail = 'غير متوفر';
  String _patientPhone = 'غير متوفر';

  // ✅ إحصائيات المريض (افتراضية)
  Map<String, dynamic> _stats = {
    'bloodPressure': '--/--',
    'glucose': '--',
    'weight': '--',
    'medications': '0',
  };

  // ✅ آخر المواعيد
  List<Map<String, dynamic>> _appointments = [];

  // ✅ آخر النتائج الطبية
  List<Map<String, dynamic>> _recentResults = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // ✅ جلب بيانات المريض من Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _patientData = data;
          _patientName = data['name'] ?? user.displayName ?? 'مستخدم';
          _patientEmail = data['email'] ?? user.email ?? 'غير متوفر';
          _patientPhone = data['phone'] ?? user.phoneNumber ?? 'غير متوفر';
          
          // ✅ جلب الإحصائيات
          _stats = {
            'bloodPressure': data['bloodPressure'] ?? '--/--',
            'glucose': data['glucose']?.toString() ?? '--',
            'weight': data['weight']?.toString() ?? '--',
            'medications': data['medications']?.toString() ?? '0',
          };

          // ✅ جلب المواعيد
          _appointments = List<Map<String, dynamic>>.from(data['appointments'] ?? []);

          // ✅ جلب النتائج
          _recentResults = List<Map<String, dynamic>>.from(data['recentResults'] ?? []);
        });
      } else {
        // ✅ إذا لم يكن هناك مستند، أنشئ واحداً
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'مستخدم',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'bloodPressure': '--/--',
          'glucose': '--',
          'weight': '--',
          'medications': '0',
          'appointments': [],
          'recentResults': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _patientName = user.displayName ?? 'مستخدم';
          _patientEmail = user.email ?? 'غير متوفر';
          _patientPhone = user.phoneNumber ?? 'غير متوفر';
        });
      }
    } catch (e) {
      print('❌ Error loading patient data: $e');
      // ✅ استخدام بيانات Firebase Auth كنسخة احتياطية
      setState(() {
        _patientName = user.displayName ?? 'مستخدم';
        _patientEmail = user.email ?? 'غير متوفر';
        _patientPhone = user.phoneNumber ?? 'غير متوفر';
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
        appBar: AppBar(
          title: const Text('صحتي', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('صحتي', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPatientData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ بطاقة الترحيب (بيانات من Firestore)
            _buildWelcomeCard(_patientName, isDark),
            const SizedBox(height: 16),
            // ✅ الإحصائيات السريعة
            _buildQuickStats(),
            const SizedBox(height: 16),
            // ✅ الخدمات الصحية
            _buildHealthServices(),
            const SizedBox(height: 16),
            // ✅ آخر المواعيد
            _buildAppointments(),
            const SizedBox(height: 16),
            // ✅ آخر النتائج
            _buildRecentResults(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String userName, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'حالتك الصحية جيدة',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {'label': 'ضغط الدم', 'value': _stats['bloodPressure'], 'icon': Icons.monitor_heart_rounded, 'color': AppColors.error},
      {'label': 'السكر', 'value': '${_stats['glucose']} mg/dL', 'icon': Icons.biotech_rounded, 'color': AppColors.warning},
      {'label': 'الوزن', 'value': '${_stats['weight']} كجم', 'icon': Icons.monitor_weight_rounded, 'color': AppColors.info},
      {'label': 'الأدوية', 'value': '${_stats['medications']}', 'icon': Icons.medication_rounded, 'color': AppColors.success},
    ];

    return Row(
      children: stats.map((stat) {
        final color = stat['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  stat['label'] as String,
                  style: const TextStyle(fontSize: 9, color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthServices() {
    final services = [
      {'icon': Icons.monitor_heart_rounded, 'label': 'ضغط الدم', 'color': AppColors.error, 'screen': const BloodPressureScreen()},
      {'icon': Icons.biotech_rounded, 'label': 'تتبع السكر', 'color': AppColors.warning, 'screen': const GlucoseTrackerScreen()},
      {'icon': Icons.monitor_weight_rounded, 'label': 'الوزن', 'color': AppColors.info, 'screen': const WeightTrackerScreen()},
      {'icon': Icons.medication_rounded, 'label': 'الأدوية', 'color': AppColors.success, 'screen': const MedicationReminderScreen()},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خدمات صحية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: services.map((service) {
              final color = service['color'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => service['screen'] as Widget,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          service['icon'] as IconData,
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service['label'] as String,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر المواعيد',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'لا توجد مواعيد',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ..._appointments.map((appointment) {
              final isPast = appointment['status'] == 'منتهي';
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade100,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['doctor'] ?? 'طبيب',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${appointment['date'] ?? ''} • ${appointment['time'] ?? ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPast
                            ? AppColors.grey.withOpacity(0.2)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment['status'] ?? 'قادم',
                        style: TextStyle(
                          fontSize: 9,
                          color: isPast ? AppColors.grey : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر النتائج',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicalReportsScreen(),
                    ),
                  );
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_recentResults.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'لا توجد نتائج',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ..._recentResults.map((result) {
              final color = result['color'] as Color? ?? AppColors.primary;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade100,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        result['icon'] as IconData? ?? Icons.science_rounded,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result['title'] ?? 'تقرير',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            result['date'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result['status'] ?? 'طبيعي',
                        style: TextStyle(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
