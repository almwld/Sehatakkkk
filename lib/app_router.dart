import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/core/routes/payment_routes.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/community/community_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_dashboard.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/platform/marketplace_admin_dashboard.dart';
import 'package:sehatak/presentation/screens/search/unified_search_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/splash_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';

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
      GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: auth, builder: (_, __) => const AuthScreen()),
      GoRoute(path: doctors, builder: (_, __) => const DoctorsListScreen()),
      GoRoute(
        path: doctorDetails,
        builder: (_, state) => DoctorDetailsScreen(
          doctorId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(path: pharmacy, builder: (_, __) => const PharmacyScreen()),
      GoRoute(path: pharmacyDashboard, builder: (_, __) => const PharmacyDashboard()),
      GoRoute(path: marketplaceAdmin, builder: (_, __) => const MarketplaceAdminDashboard()),
      GoRoute(path: labs, builder: (_, __) => const LabsListScreen()),
      GoRoute(path: chat, builder: (_, __) => const ChatScreen()),
      GoRoute(path: more, builder: (_, __) => const MoreScreen()),
      GoRoute(path: dashboard, builder: (_, __) => const RoleBasedDashboardScreen()),
      GoRoute(path: profile, builder: (_, __) => const PatientProfile()),
      GoRoute(path: appointments, builder: (_, __) => const PatientAppointments()),
      GoRoute(path: notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: cart, builder: (_, __) => const CartScreen()),
      GoRoute(path: wallet, builder: (_, __) => const WalletScreen()),
      GoRoute(path: map, builder: (_, __) => const InteractiveMapScreen()),
      GoRoute(path: consultation, builder: (_, __) => const ConsultationScreen()),
      GoRoute(path: services, builder: (_, __) => const ServicesScreen()),
      GoRoute(path: emergency, builder: (_, __) => const EmergencyNumbers()),
      GoRoute(path: bloodDonation, builder: (_, __) => const BloodDonationScreen()),
      GoRoute(path: settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(
        path: search,
        builder: (_, state) => AdvancedSearchScreen(
          initialQuery: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(path: articles, builder: (_, __) => const ArticlesScreen()),
      GoRoute(path: community, builder: (_, __) => const CommunityScreen()),
    ],
  );

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    final name = routeSettings.name ?? home;
    switch (name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: routeSettings);
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: routeSettings);
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen(), settings: routeSettings);
      case doctors:
        return MaterialPageRoute(builder: (_) => const DoctorsListScreen(), settings: routeSettings);
      case pharmacy:
        return MaterialPageRoute(builder: (_) => const PharmacyScreen(), settings: routeSettings);
      case labs:
        return MaterialPageRoute(builder: (_) => const LabsListScreen(), settings: routeSettings);
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen(), settings: routeSettings);
      case more:
        return MaterialPageRoute(builder: (_) => const MoreScreen(), settings: routeSettings);
      case dashboard:
        return MaterialPageRoute(builder: (_) => const RoleBasedDashboardScreen(), settings: routeSettings);
      case profile:
        return MaterialPageRoute(builder: (_) => const PatientProfile(), settings: routeSettings);
      case appointments:
        return MaterialPageRoute(builder: (_) => const PatientAppointments(), settings: routeSettings);
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen(), settings: routeSettings);
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen(), settings: routeSettings);
      case map:
        return MaterialPageRoute(builder: (_) => const InteractiveMapScreen(), settings: routeSettings);
      case consultation:
        return MaterialPageRoute(builder: (_) => const ConsultationScreen(), settings: routeSettings);
      case services:
        return MaterialPageRoute(builder: (_) => const ServicesScreen(), settings: routeSettings);
      case emergency:
        return MaterialPageRoute(builder: (_) => const EmergencyNumbers(), settings: routeSettings);
      case bloodDonation:
        return MaterialPageRoute(builder: (_) => const BloodDonationScreen(), settings: routeSettings);
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen(), settings: routeSettings);
      case search:
        final args = routeSettings.arguments;
        final query = args is String ? args : null;
        return MaterialPageRoute(
          builder: (_) => AdvancedSearchScreen(initialQuery: query),
          settings: routeSettings,
        );
      case articles:
        return MaterialPageRoute(builder: (_) => const ArticlesScreen(), settings: routeSettings);
      case community:
        return MaterialPageRoute(builder: (_) => const CommunityScreen(), settings: routeSettings);
      case pharmacyDashboard:
        return MaterialPageRoute(builder: (_) => const PharmacyDashboard(), settings: routeSettings);
      case marketplaceAdmin:
        return MaterialPageRoute(builder: (_) => const MarketplaceAdminDashboard(), settings: routeSettings);
      default:
        if (name.startsWith('/doctor/')) {
          return MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(doctorId: name.substring('/doctor/'.length)),
            settings: routeSettings,
          );
        }
        return PaymentRoutes.onGenerateRoute(routeSettings);
    }
  }
}
