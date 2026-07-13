import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/ambulance/ambulance_request_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/nursing/nursing_care_screen.dart';
import 'package:sehatak/presentation/screens/doctor/home_visit_screen.dart';
import 'package:sehatak/presentation/screens/lab/home_lab_test_screen.dart';
import 'package:sehatak/presentation/screens/physiotherapy/physiotherapy_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';

class HomeServicesScreen extends StatelessWidget {
  const HomeServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final services = [
      {'icon': Icons.health_and_safety, 'title': 'تمريض منزلي', 'subtitle': 'رعاية تمريضية في منزلك', 'color': Colors.blue, 'screen': const NursingCareScreen()},
      {'icon': Icons.medical_services, 'title': 'زيارات طبية', 'subtitle': 'طبيب يزورك في منزلك', 'color': Colors.teal, 'screen': const HomeVisitScreen()},
      {'icon': Icons.physical_therapy, 'title': 'علاج طبيعي', 'subtitle': 'جلسات علاج طبيعي في المنزل', 'color': Colors.orange, 'screen': const PhysiotherapyScreen()},
      {'icon': Icons.ambulance, 'title': 'سيارة إسعاف', 'subtitle': 'طلب سيارة إسعاف فورية', 'color': Colors.red, 'screen': const AmbulanceRequestScreen()},
      {'icon': Icons.healing, 'title': 'إسعافات أولية', 'subtitle': 'دليل الإسعافات الأولية', 'color': Colors.deepOrange, 'screen': const FirstAidScreen()},
      {'icon': Icons.science, 'title': 'فحص عينة سريع', 'subtitle': 'فحص مخبري في منزلك', 'color': Colors.purple, 'screen': const HomeLabTestScreen()},
      {'icon': Icons.monitor_heart, 'title': 'قياس ضغط الدم', 'subtitle': 'مراقبة ضغط الدم في المنزل', 'color': Colors.pink, 'screen': const BloodPressureScreen()},
      {'icon': Icons.biotech, 'title': 'فحص السكر', 'subtitle': 'مراقبة مستوى السكر', 'color': Colors.amber, 'screen': const GlucoseTrackerScreen()},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الخدمات المنزلية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(service, isDark);
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark) {
    final color = service['color'] as Color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => service['screen'] as Widget),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
