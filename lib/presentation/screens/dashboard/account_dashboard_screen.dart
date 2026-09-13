import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';

/// Router-facing account dashboard entry point.
/// RoleBasedDashboardScreen owns all role selection while preserving the patient dashboard.
class AccountDashboardScreen extends StatelessWidget {
  const AccountDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleBasedDashboardScreen();
  }
}
