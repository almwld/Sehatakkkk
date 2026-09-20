import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/dashboard/advanced_role_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';

class RoleBasedDashboardScreen extends StatelessWidget {
  const RoleBasedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const PatientDashboard();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final role = snapshot.data?.data()?['role']?.toString() ?? 'user';
        if (role == 'user' || role == 'patient') return const PatientDashboard();
        return AdvancedRoleDashboardScreen(role: role);
      },
    );
  }
}
