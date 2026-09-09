import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/core/routes/payment_routes.dart';
import 'package:sehatak/presentation/screens/splash_screen.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_dashboard.dart';
import 'package:sehatak/presentation/screens/platform/marketplace_admin_dashboard.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/search/unified_search_screen.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/community/community_screen.dart';

/// Single navigation source of truth.
/// The GoRouter definition is retained for deep-link capable callers, while
/// MaterialApp also uses [onGenerateRoute] because the current application
/// shell is a MaterialApp and Home must not call GoRouter APIs without a
/// GoRouter host.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static const String splash = '/splash';
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
  static const String appointments = '/appointments';
  static const String notifications = '/notifications';
  static const String cart = '/cart';
  static const String wallet = '/wallet';
  static const String map = '/map';
  static const String consultation = '/consultation';
  static const String services = '/services';
  static const String emergency = '/emergency';
  static const String bloodDonation = '/blood-donation';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String articles = '/articles';
  static const String community = '/community';
  static const String pharmacyDashboard = '/pharmacy-dashboard';
  static const String marketplaceAdmin = '/marketplace-admin';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (c, s) => const SplashScreen()),
      GoRoute(path: home, builder: (c, s) => const HomeScreen()),
      GoRoute(path: auth, builder: (c, s) => const AuthScreen()),
      GoRoute(path: doctors, builder: (c, s) => const DoctorsListScreen()),
      GoRoute(path: doctorDetails, builder: (c, s) => DoctorDetailsScreen(doctorId: s.pathParameters['id'] ?? '')),
      GoRoute(path: pharmacy, builder: (c, s) => const PharmacyScreen()),
      GoRoute(path: pharmacyDashboard, builder: (c, s) => const PharmacyDashboard()),
      GoRoute(path: marketplaceAdmin, builder: (c, s) => const MarketplaceAdminDashboard()),
      GoRoute(path: labs, builder: (c, s) => const LabsListScreen()),
      GoRoute(path: chat, builder: (c, s) => const ChatScreen()),
      GoRoute(path: more, builder: (c, s) => const MoreScreen()),
      GoRoute(path: dashboard, builder: (c, s) => const RoleBasedDashboardScreen()),
      GoRoute(path: profile, builder: (c, s) => const PatientProfile()),
      GoRoute(path: appointments, builder: (c, s) => const PatientAppointments()),
      GoRoute(path: notifications, builder: (c, s) => const NotificationsScreen()),
      GoRoute(path: cart, builder: (c, s) => const CartScreen()),
      GoRoute(path: wallet, builder: (c, s) => const WalletScreen()),
      GoRoute(path: map, builder: (c, s) => const InteractiveMapScreen()),
      GoRoute(path: consultation, builder: (c, s) => const ConsultationScreen()),
      GoRoute(path: services, builder: (c, s) => const ServicesScreen()),
      GoRoute(path: emergency, builder: (c, s) => const EmergencyNumbers()),
      GoRoute(path: bloodDonation, builder: (c, s) => const BloodDonationScreen()),
      GoRoute(path: settings, builder: (c, s) => const SettingsScreen()),
      GoRoute(path: search, builder: (c, s) => AdvancedSearchScreen(initialQuery: s.uri.queryParameters['q'])),
      GoRoute(path: articles, builder: (c, s) => const ArticlesScreen()),
      GoRoute(path: community, builder: (c, s) => const CommunityScreen()),
    ],
  );

  /// Route registry used by the current MaterialApp shell.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? home;
    switch (name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen(), settings: settings);
      case doctors:
        return MaterialPageRoute(builder: (_) => const DoctorsListScreen(), settings: settings);
      case pharmacy:
        return MaterialPageRoute(builder: (_) => const PharmacyScreen(), settings: settings);
      case labs:
        return MaterialPageRoute(builder: (_) => const LabsListScreen(), settings: settings);
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen(), settings: settings);
      case more:
        return MaterialPageRoute(builder: (_) => const MoreScreen(), settings: settings);
      case dashboard:
        return MaterialPageRoute(builder: (_) => const RoleBasedDashboardScreen(), settings: settings);
      case profile:
        return MaterialPageRoute(builder: (_) => const PatientProfile(), settings: settings);
      case appointments:
        return MaterialPageRoute(builder: (_) => const PatientAppointments(), settings: settings);
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen(), settings: settings);
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen(), settings: settings);
      case map:
        return MaterialPageRoute(builder: (_) => const InteractiveMapScreen(), settings: settings);
      case consultation:
        return MaterialPageRoute(builder: (_) => const ConsultationScreen(), settings: settings);
      case services:
        return MaterialPageRoute(builder: (_) => const ServicesScreen(), settings: settings);
      case emergency:
        return MaterialPageRoute(builder: (_) => const EmergencyNumbers(), settings: settings);
      case bloodDonation:
        return MaterialPageRoute(builder: (_) => const BloodDonationScreen(), settings: settings);
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen(), settings: settings);
      case search:
        final args = settings.arguments;
        final query = args is String ? args : null;
        return MaterialPageRoute(builder: (_) => AdvancedSearchScreen(initialQuery: query), settings: settings);
      case articles:
        return MaterialPageRoute(builder: (_) => const ArticlesScreen(), settings: settings);
      case community:
        return MaterialPageRoute(builder: (_) => const CommunityScreen(), settings: settings);
      case pharmacyDashboard:
        return MaterialPageRoute(builder: (_) => const PharmacyDashboard(), settings: settings);
      case marketplaceAdmin:
        return MaterialPageRoute(builder: (_) => const MarketplaceAdminDashboard(), settings: settings);
      default:
        if (name.startsWith('/doctor/')) {
          final id = name.substring('/doctor/'.length);
          return MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: id), settings: settings);
        }
        return PaymentRoutes.onGenerateRoute(settings);
    }
  }
}
