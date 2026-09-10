import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
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
  static const String splash='/splash', home='/', auth='/auth', doctors='/doctors', doctorDetails='/doctor/:id', pharmacy='/pharmacy', labs='/labs', hospitals='/hospitals', chat='/chat', more='/more', dashboard='/dashboard', profile='/profile', appointments='/appointments', notifications='/notifications', cart='/cart', wallet='/wallet', map='/map', consultation='/consultation', services='/services', emergency='/emergency', bloodDonation='/blood-donation', settings='/settings', search='/search', articles='/articles', community='/community', pharmacyDashboard='/pharmacy-dashboard', marketplaceAdmin='/marketplace-admin';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (_, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      if (state.matchedLocation == auth && loggedIn) return home;
      return null;
    },
    routes: [
      GoRoute(path:splash,builder:(_,__)=>const SplashScreen()),
      GoRoute(path:home,builder:(_,__)=>const HomeScreen()),
      GoRoute(path:auth,redirect:(_,__)=>FirebaseAuth.instance.currentUser!=null?home:null,builder:(_,__)=>const AuthScreen()),
      GoRoute(path:doctors,builder:(_,__)=>const DoctorsListScreen()),
      GoRoute(path:doctorDetails,builder:(_,s)=>DoctorDetailsScreen(doctorId:s.pathParameters['id']??'')),
      GoRoute(path:pharmacy,builder:(_,__)=>const PharmacyScreen()),
      GoRoute(path:pharmacyDashboard,builder:(_,__)=>const PharmacyDashboard()),
      GoRoute(path:marketplaceAdmin,builder:(_,__)=>const MarketplaceAdminDashboard()),
      GoRoute(path:labs,builder:(_,__)=>const LabsListScreen()),
      GoRoute(path:hospitals,builder:(_,__)=>const HospitalScreen()),
      GoRoute(path:chat,builder:(_,__)=>const ChatScreen()),
      GoRoute(path:more,builder:(_,__)=>const MoreScreen()),
      GoRoute(path:dashboard,builder:(_,__)=>const RoleBasedDashboardScreen()),
      GoRoute(path:profile,builder:(_,__)=>const PatientProfile()),
      GoRoute(path:appointments,builder:(_,__)=>const PatientAppointments()),
      GoRoute(path:notifications,builder:(_,__)=>const NotificationsScreen()),
      GoRoute(path:cart,builder:(_,__)=>const CartScreen()),
      GoRoute(path:wallet,builder:(_,__)=>const WalletScreen()),
      GoRoute(path:map,builder:(_,__)=>const InteractiveMapScreen()),
      GoRoute(path:consultation,builder:(_,__)=>const ConsultationScreen()),
      GoRoute(path:services,builder:(_,__)=>const ServicesScreen()),
      GoRoute(path:emergency,builder:(_,__)=>const EmergencyNumbers()),
      GoRoute(path:bloodDonation,builder:(_,__)=>const BloodDonationScreen()),
      GoRoute(path:settings,builder:(_,__)=>const SettingsScreen()),
      GoRoute(path:search,builder:(_,s)=>AdvancedSearchScreen(initialQuery:s.uri.queryParameters['q'])),
      GoRoute(path:articles,builder:(_,__)=>const ArticlesScreen()),
      GoRoute(path:community,builder:(_,__)=>const CommunityScreen()),
    ],
  );

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name=settings.name??home;
    if(name==auth && FirebaseAuth.instance.currentUser!=null) return MaterialPageRoute(builder:(_)=>const HomeScreen(),settings:settings);
    switch(name) {
      case splash:return MaterialPageRoute(builder:(_)=>const SplashScreen(),settings:settings);
      case home:return MaterialPageRoute(builder:(_)=>const HomeScreen(),settings:settings);
      case auth:return MaterialPageRoute(builder:(_)=>const AuthScreen(),settings:settings);
      case doctors:return MaterialPageRoute(builder:(_)=>const DoctorsListScreen(),settings:settings);
      case pharmacy:return MaterialPageRoute(builder:(_)=>const PharmacyScreen(),settings:settings);
      case labs:return MaterialPageRoute(builder:(_)=>const LabsListScreen(),settings:settings);
      case hospitals:return MaterialPageRoute(builder:(_)=>const HospitalScreen(),settings:settings);
      case chat:return MaterialPageRoute(builder:(_)=>const ChatScreen(),settings:settings);
      case more:return MaterialPageRoute(builder:(_)=>const MoreScreen(),settings:settings);
      case dashboard:return MaterialPageRoute(builder:(_)=>const RoleBasedDashboardScreen(),settings:settings);
      case profile:return MaterialPageRoute(builder:(_)=>const PatientProfile(),settings:settings);
      case appointments:return MaterialPageRoute(builder:(_)=>const PatientAppointments(),settings:settings);
      case notifications:return MaterialPageRoute(builder:(_)=>const NotificationsScreen(),settings:settings);
      case cart:return MaterialPageRoute(builder:(_)=>const CartScreen(),settings:settings);
      case map:return MaterialPageRoute(builder:(_)=>const InteractiveMapScreen(),settings:settings);
      case consultation:return MaterialPageRoute(builder:(_)=>const ConsultationScreen(),settings:settings);
      case services:return MaterialPageRoute(builder:(_)=>const ServicesScreen(),settings:settings);
      case emergency:return MaterialPageRoute(builder:(_)=>const EmergencyNumbers(),settings:settings);
      case bloodDonation:return MaterialPageRoute(builder:(_)=>const BloodDonationScreen(),settings:settings);
      case settings:return MaterialPageRoute(builder:(_)=>const SettingsScreen(),settings:settings);
      case search:return MaterialPageRoute(builder:(_)=>AdvancedSearchScreen(initialQuery:settings.arguments is String?settings.arguments as String:null),settings:settings);
      case articles:return MaterialPageRoute(builder:(_)=>const ArticlesScreen(),settings:settings);
      case community:return MaterialPageRoute(builder:(_)=>const CommunityScreen(),settings:settings);
      case pharmacyDashboard:return MaterialPageRoute(builder:(_)=>const PharmacyDashboard(),settings:settings);
      case marketplaceAdmin:return MaterialPageRoute(builder:(_)=>const MarketplaceAdminDashboard(),settings:settings);
      default:
        if(name.startsWith('/doctor/')) return MaterialPageRoute(builder:(_)=>DoctorDetailsScreen(doctorId:name.substring('/doctor/'.length)),settings:settings);
        return PaymentRoutes.onGenerateRoute(settings);
    }
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) { _subscription=stream.asBroadcastStream().listen((_)=>notifyListeners()); }
  late final StreamSubscription<dynamic> _subscription;
  @override void dispose(){_subscription.cancel();super.dispose();}
}
