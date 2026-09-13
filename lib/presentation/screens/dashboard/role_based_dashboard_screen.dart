import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/roles.dart';
import 'package:sehatak/presentation/screens/admin/dashboard/admin_dashboard.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/hospital/dashboard/hospital_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_dashboard.dart';
import 'package:sehatak/presentation/screens/platform/dashboard/platform_dashboard.dart';

/// The single dashboard dispatcher used after router authentication.
/// PatientDashboard is preserved as the default patient experience.
class RoleBasedDashboardScreen extends StatelessWidget {
  const RoleBasedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const PatientDashboard();
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final role = (snapshot.data?.data()?['role'] ?? 'user').toString().trim();
        return _dashboardForRole(role);
      },
    );
  }

  Widget _dashboardForRole(String role) {
    switch (role) {
      case 'doctor':
        return const DoctorDashboardScreen();
      case 'pharmacist':
        return const PharmacyDashboard();
      case 'hospital':
        return const HospitalDashboard();
      case 'admin':
        return const AdminDashboard();
      case 'superAdmin':
        return const PlatformDashboard();
      case 'user':
      case 'patient':
      case '':
        return const PatientDashboard();
      case 'nurse':
      case 'midwife':
      case 'physiotherapist':
      case 'lab':
      case 'paramedic':
      case 'delivery':
      case 'service':
      case 'veterinarian':
        return ProfessionalRoleDashboard(role: role);
      default:
        return const PatientDashboard();
    }
  }
}

class ProfessionalRoleDashboard extends StatelessWidget {
  const ProfessionalRoleDashboard({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final name = AppRoles.getRoleName(role);
    final services = _services[role] ?? const <String>[];
    return Scaffold(
      appBar: AppBar(title: Text('لوحة $name'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
            child: Text('مرحباً بك في لوحة $name', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 18),
          const Text('خدمات الدور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...services.map((service) => Card(child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0x1A0A8F83), child: Icon(Icons.medical_services_outlined, color: AppColors.primary)),
                title: Text(service, style: const TextStyle(fontWeight: FontWeight.w800)),
                trailing: const Icon(Icons.chevron_left),
              ))),
        ],
      ),
    );
  }

  static const Map<String, List<String>> _services = {
    'nurse': ['إدارة خدمات التمريض', 'المواعيد', 'متابعة المرضى', 'التواصل الصحي'],
    'midwife': ['إدارة خدمات القبالة', 'متابعة الحالات', 'المواعيد', 'التواصل الصحي'],
    'physiotherapist': ['إدارة جلسات العلاج الطبيعي', 'المواعيد', 'متابعة الحالات', 'التواصل الصحي'],
    'lab': ['إدارة خدمات المختبر', 'طلبات الفحوصات', 'النتائج', 'المواعيد'],
    'paramedic': ['إدارة خدمات الإسعاف', 'الطلبات الطارئة', 'التواصل الصحي'],
    'delivery': ['إدارة التوصيل', 'الطلبات', 'المهام الحالية', 'المحفظة'],
    'service': ['إدارة الخدمات', 'الطلبات', 'المواعيد', 'المحفظة'],
    'veterinarian': ['إدارة خدمات الطب البيطري', 'المواعيد', 'السجلات', 'التواصل الصحي'],
  };
}
