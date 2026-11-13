import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/dashboard/advanced_role_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';

class RoleBasedDashboardScreen extends StatefulWidget {
  const RoleBasedDashboardScreen({super.key});
  @override State<RoleBasedDashboardScreen> createState()=>_RoleBasedDashboardScreenState();
}

class _RoleBasedDashboardScreenState extends State<RoleBasedDashboardScreen> {
  String? _noticeFor;
  Future<void> _ensureNotice(String role) async {
    if (_noticeFor == role) return;
    _noticeFor = role;
    try { await FirebaseFunctions.instanceFor(region:'us-central1').httpsCallable('ensureVerificationNotice').call(); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user=FirebaseAuth.instance.currentUser;
    if(user==null)return const PatientDashboard();
    return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      stream:FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder:(context,snapshot){
        if(snapshot.hasError){
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('تعذر تحميل صلاحيات الحساب. تحقق من الاتصال ثم أعد المحاولة.'),
              ),
            ),
          );
        }
        if(!snapshot.hasData){
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final rawRole=snapshot.data?.data()?['role']?.toString().trim()??'user';
        final normalized=rawRole.toLowerCase();
        final role=normalized=='superadmin'?'superAdmin':normalized;
        if(role=='user'||role=='patient')return const PatientDashboard();
        if(role!='admin'&&role!='superAdmin')WidgetsBinding.instance.addPostFrameCallback((_)=>_ensureNotice(role));
        return AdvancedRoleDashboardScreen(role:role);
      },
    );
  }
}
