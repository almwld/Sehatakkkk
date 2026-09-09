import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';

class RoleBasedDashboardScreen extends StatelessWidget {
  const RoleBasedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const PatientDashboard();
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        final role = snapshot.data?.data()?['role']?.toString();
        return role == 'doctor' ? const _DoctorDashboard() : const PatientDashboard();
      },
    );
  }
}

class _DoctorDashboard extends StatelessWidget {
  const _DoctorDashboard();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('لوحة الطبيب'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('لوحة الطبيب', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('إدارة المرضى والمواعيد والمحتوى من مكان واحد', style: TextStyle(color: Colors.white70, fontSize: 12))])),
        const SizedBox(height: 14),
        _statGrid(uid, dark),
        const SizedBox(height: 14),
        _action(context, 'assets/images/services/calendar_booking.png', 'المواعيد', 'متابعة المواعيد والحجوزات', AppRouter.consultation),
        _action(context, 'assets/images/services/medical_community.png', 'مجتمع صحتك', 'عرض المنشورات والتعليقات والمشاركات', AppRouter.community),
        _action(context, 'assets/images/services/medical_records.png', 'السجلات الطبية', 'الوصول المصرح إلى بيانات المرضى', AppRouter.dashboard),
        _action(context, 'assets/images/services/wallet.png', 'المحفظة', 'المعاملات والأرصدة', AppRouter.wallet),
      ]),
    );
  }

  Widget _statGrid(String? uid, bool dark) => FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
    future: uid == null ? null : FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: uid).limit(50).get(),
    builder: (_, snap) {
      final count = snap.data?.docs.length ?? 0;
      return Row(children: [
        Expanded(child: _stat('المواعيد', '$count', 'assets/images/services/calendar_booking.png', dark)),
        const SizedBox(width: 10),
        Expanded(child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: uid == null ? null : FirebaseFirestore.instance.collection('community_posts').where('userId', isEqualTo: uid).limit(50).get(),
          builder: (_, posts) => _stat('المنشورات', '${posts.data?.docs.length ?? 0}', 'assets/images/services/medical_community.png', dark),
        )),
      ]);
    },
  );

  Widget _stat(String title, String value, String asset, bool dark) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [LocalAssetIcon(asset, size: 36), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : Colors.grey[600])), Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF173131)))]))]));

  Widget _action(BuildContext context, String asset, String title, String subtitle, String route) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [LocalAssetIcon(asset, size: 42), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[600]))]))]),
      ),
    ),
  );
}
