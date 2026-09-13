import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/admin/dashboard/admin_dashboard.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/hospital/dashboard/hospital_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_dashboard.dart';

class AccountDashboardScreen extends StatelessWidget {
  const AccountDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const PatientDashboard();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        final role = snapshot.data?.data()?['role']?.toString() ?? 'user';
        switch (role) {
          case 'doctor':
            return const RoleBasedDashboardScreen();
          case 'pharmacist':
            return const PharmacyDashboard();
          case 'admin':
          case 'superAdmin':
            return const AdminDashboard();
          case 'hospital':
            return const HospitalDashboard();
          default:
            return Stack(
              children: [
                const PatientDashboard(),
                Positioned(
                  top: 10,
                  left: 10,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(AppRouter.accountSettings),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF172033)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(blurRadius: 10, offset: Offset(0, 3), color: Color(0x22000000)),
                            ],
                          ),
                          child: const Icon(Icons.settings_outlined, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}
