import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/heart_rate/heart_rate_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/blood_oxygen/blood_oxygen_screen.dart';
import 'package:sehatak/presentation/screens/temperature/temperature_screen.dart';

class VitalsDashboardScreen extends StatefulWidget {
  const VitalsDashboardScreen({super.key});

  @override
  State<VitalsDashboardScreen> createState() => _VitalsDashboardScreenState();
}

class _VitalsDashboardScreenState extends State<VitalsDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _vitals = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _vitalCards = [
    {'icon': Icons.monitor_heart_rounded, 'label': 'ضغط الدم', 'key': 'bloodPressure', 'color': AppColors.error, 'screen': const BloodPressureScreen()},
    {'icon': Icons.biotech_rounded, 'label': 'السكر', 'key': 'glucose', 'color': AppColors.warning, 'screen': const GlucoseTrackerScreen()},
    {'icon': Icons.favorite_rounded, 'label': 'معدل القلب', 'key': 'heartRate', 'color': AppColors.pink, 'screen': const HeartRateScreen()},
    {'icon': Icons.monitor_weight_rounded, 'label': 'الوزن', 'key': 'weight', 'color': AppColors.info, 'screen': const WeightTrackerScreen()},
    {'icon': Icons.bloodtype_rounded, 'label': 'الأكسجين', 'key': 'bloodOxygen', 'color': AppColors.purple, 'screen': const BloodOxygenScreen()},
    {'icon': Icons.thermostat_rounded, 'label': 'درجة الحرارة', 'key': 'temperature', 'color': AppColors.orange, 'screen': const TemperatureScreen()},
  ];

  @override
  void initState() {
    super.initState();
    _loadVitals();
  }

  Future<void> _loadVitals() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _vitals = data['vitals'] ?? {};
          });
        }
      } catch (e) {
        print('❌ Error loading vitals: $e');
      }
    }

    setState(() => _isLoading = false);
  }

  String _getVitalValue(String key) {
    final value = _vitals[key];
    if (value == null) return '--';
    if (value is int) return value.toString();
    if (value is double) return value.toStringAsFixed(1);
    return value.toString();
  }

  String _getVitalUnit(String key) {
    switch (key) {
      case 'bloodPressure': return 'mmHg';
      case 'glucose': return 'mg/dL';
      case 'heartRate': return 'bpm';
      case 'weight': return 'kg';
      case 'bloodOxygen': return '%';
      case 'temperature': return '°C';
      default: return '';
    }
  }

  String _getVitalStatus(String key, dynamic value) {
    if (value == null) return '';

    switch (key) {
      case 'bloodPressure':
        if (value is String && value.contains('/')) {
          final parts = value.split('/');
          if (parts.length == 2) {
            final systolic = int.tryParse(parts[0]) ?? 0;
            final diastolic = int.tryParse(parts[1]) ?? 0;
            if (systolic < 120 && diastolic < 80) return 'طبيعي';
            if (systolic < 130 || diastolic < 85) return 'مرتفع قليلاً';
            if (systolic < 140 || diastolic < 90) return 'مرتفع';
            return 'مرتفع جداً';
          }
        }
        return '';
      case 'glucose':
        if (value is int) {
          if (value < 100) return 'طبيعي';
          if (value < 126) return 'مرتفع';
          return 'عالي';
        }
        return '';
      case 'heartRate':
        if (value is int) {
          if (value >= 60 && value <= 100) return 'طبيعي';
          if (value < 60) return 'منخفض';
          return 'مرتفع';
        }
        return '';
      case 'weight':
        return '';
      case 'bloodOxygen':
        if (value is int) {
          if (value >= 95) return 'طبيعي';
          if (value >= 90) return 'منخفض قليلاً';
          return 'منخفض';
        }
        return '';
      case 'temperature':
        if (value is double) {
          if (value >= 36.5 && value <= 37.5) return 'طبيعي';
          if (value < 36.5) return 'منخفض';
          return 'مرتفع';
        }
        return '';
      default:
        return '';
    }
  }

  Color _getVitalColor(String key, dynamic value) {
    final status = _getVitalStatus(key, value);
    switch (status) {
      case 'طبيعي': return AppColors.success;
      case 'مرتفع':
      case 'مرتفع جداً':
      case 'عالي':
      case 'مرتفع قليلاً':
        return AppColors.error;
      case 'منخفض':
      case 'منخفض قليلاً':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: const Text('المؤشرات الحيوية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // الانتقال إلى إضافة قراءة
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ ملخص سريع
                  _buildSummary(),
                  const SizedBox(height: 20),
                  // ✅ بطاقات المؤشرات
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _vitalCards.length,
                    itemBuilder: (context, index) {
                      final card = _vitalCards[index];
                      final key = card['key'] as String;
                      final value = _vitals[key];
                      final status = _getVitalStatus(key, value);
                      final color = _getVitalColor(key, value);
                      final displayValue = _getVitalValue(key);
                      final unit = _getVitalUnit(key);

                      return _buildVitalCard(
                        icon: card['icon'] as IconData,
                        label: card['label'] as String,
                        value: displayValue,
                        unit: unit,
                        status: status,
                        color: color,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => card['screen'] as Widget,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // ✅ آخر القراءات
                  _buildRecentReadings(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary() {
    final normalCount = _vitalCards.where((card) {
      final key = card['key'] as String;
      final value = _vitals[key];
      return _getVitalStatus(key, value) == 'طبيعي';
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('${_vitalCards.length}', 'المؤشرات'),
          _summaryItem('$normalCount', 'طبيعي'),
          _summaryItem('${_vitalCards.length - normalCount}', 'يحتاج متابعة'),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required String status,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: status.isNotEmpty ? color.withOpacity(0.3) : (isDark ? const Color(0xFF2D3A54) : Colors.transparent),
            width: status.isNotEmpty ? 1.5 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (status.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReadings() {
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
            'آخر القراءات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_vitals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'لا توجد قراءات بعد',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ..._vitals.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;
              final unit = _getVitalUnit(key);
              final label = _vitalCards.firstWhere(
                (card) => card['key'] == key,
                orElse: () => {'label': key},
              )['label'] as String;

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
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '$value $unit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getVitalColor(key, value),
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
