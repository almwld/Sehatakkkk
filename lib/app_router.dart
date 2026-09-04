import 'package:sehatak/core/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String auth = '/auth';
  static const String doctors = '/doctors';
  static const String doctorDetails = '/doctor/:id';
  static const String pharmacy = '/pharmacy';
  static const String labs = '/labs';
  static const String chat = '/chat';
  static const String more = '/more';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String cart = '/cart';
  static const String wallet = '/wallet';
  static const String map = '/map';
  static const String consultation = '/consultation';
  static const String services = '/services';
  static const String emergency = '/emergency';
  static const String settings = '/settings';
  static const String search = '/search';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: doctors,
        builder: (context, state) => const DoctorsListScreen(),
      ),
      GoRoute(
        path: doctorDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DoctorDetailsScreen(
              doctor: DoctorModel(
                id: id,
                name: 'طبيب',
                specialty: 'طبيب عام',
              ),
            );
        },
      ),
      GoRoute(
        path: pharmacy,
        builder: (context, state) => const PharmacyScreen(),
      ),
      GoRoute(
        path: labs,
        builder: (context, state) => const LabsListScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: more,
        builder: (context, state) => const MoreScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const PatientDashboard(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const PatientProfile(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: map,
        builder: (context, state) => const InteractiveMapScreen(),
      ),
      GoRoute(
        path: consultation,
        builder: (context, state) => const ConsultationScreen(),
      ),
      GoRoute(
        path: services,
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: emergency,
        builder: (context, state) => const EmergencyNumbers(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
