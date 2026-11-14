import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';

/// The "My Health" tab entry point.
///
/// Keeps the existing role-specific dashboards and their layouts intact while
/// resolving the signed-in account role from the users/{uid} Firestore record.
class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleBasedDashboardScreen();
  }
}
