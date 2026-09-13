import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/roles.dart';
import 'package:sehatak/presentation/screens/admin/dashboard/admin_dashboard.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/hospital/dashboard/hospital_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_dashboard.dart';
import 'package:sehatak/presentation/screens/platform/dashboard/platform_dashboard.dart';
import 'package:sehatak/presentation/screens/dashboard/role_dashboard_specs.dart';

/// Single account-dashboard dispatcher. PatientDashboard remains the patient experience.
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
      case 'doctor': return const DoctorDashboardScreen();
      case 'pharmacist': return const PharmacyDashboard();
      case 'hospital': return const HospitalDashboard();
      case 'admin': return const AdminDashboard();
      case 'superAdmin': return const PlatformDashboard();
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

class ProfessionalRoleDashboard extends StatefulWidget {
  const ProfessionalRoleDashboard({super.key, required this.role});
  final String role;

  @override
  State<ProfessionalRoleDashboard> createState() => _ProfessionalRoleDashboardState();
}

class _ProfessionalRoleDashboardState extends State<ProfessionalRoleDashboard> {
  bool _loading = true;
  int _appointments = 0;
  int _bookings = 0;
  int _payments = 0;
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final db = FirebaseFirestore.instance;
      final profileFuture = db.collection('users').doc(user.uid).get();
      final appointmentsFuture = db.collection('appointments').where('providerId', isEqualTo: user.uid).get();
      final bookingsFuture = db.collection('bookings').where('providerId', isEqualTo: user.uid).get();
      final paymentsFuture = db.collection('payments').where('providerId', isEqualTo: user.uid).get();
      final results = await Future.wait([profileFuture, appointmentsFuture, bookingsFuture, paymentsFuture]);
      if (!mounted) return;
      final profile = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      setState(() {
        _name = (profile.data()?['name'] ?? user.displayName ?? '').toString();
        _appointments = (results[1] as QuerySnapshot<Map<String, dynamic>>).docs.length;
        _bookings = (results[2] as QuerySnapshot<Map<String, dynamic>>).docs.length;
        _payments = (results[3] as QuerySnapshot<Map<String, dynamic>>).docs.length;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Professional dashboard load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = RoleDashboardSpecs.forRole(widget.role);
    final name = spec.title;
    final actions = spec.actions;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text('لوحة $name'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, actions: [IconButton(onPressed: _loadDashboard, icon: const Icon(Icons.refresh))]),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _header(name),
            const SizedBox(height: 14),
            if (_loading) const LinearProgressIndicator(minHeight: 3),
            if (!_loading) _stats(dark),
            const SizedBox(height: 18),
            Text('إدارة ${RoleDashboardSpecs.forRole(widget.role).title} وخدماتها', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...actions.map((item) => _actionCard(context, item, dark)),
          ],
        ),
      ),
    );
  }

  Widget _header(String roleName) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('مرحباً${_name.isEmpty ? '' : ' $_name'}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text(RoleDashboardSpecs.forRole(widget.role).subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]),
  );

  Widget _stats(bool dark) => Row(children: [
    Expanded(child: _statCard('المواعيد', _appointments, Icons.calendar_month, dark)),
    const SizedBox(width: 8),
    Expanded(child: _statCard('الحجوزات', _bookings, Icons.event_available, dark)),
    const SizedBox(width: 8),
    Expanded(child: _statCard('المعاملات', _payments, Icons.account_balance_wallet, dark)),
  ]);

  Widget _statCard(String title, int value, IconData icon, bool dark) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(15)),
    child: Column(children: [Icon(icon, color: AppColors.primary, size: 24), const SizedBox(height: 5), Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(fontSize: 9, color: Colors.grey))]),
  );

  Widget _actionCard(BuildContext context, _DashboardAction item, bool dark) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(13)), child: Icon(item.icon, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(item.subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey))])),
          const Icon(Icons.chevron_left),
        ]),
      ),
    ),
  );

  List<_DashboardAction> _actionsFor(String role) {
    return RoleDashboardSpecs.forRole(role).actions
        .map((item) => _DashboardAction(item.title, item.subtitle, item.route, item.icon))
        .toList(growable: false);
  }
}

class _DashboardAction {
  const _DashboardAction(this.title, this.subtitle, this.route, this.icon);
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}
