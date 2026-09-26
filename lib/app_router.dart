import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/routes/payment_routes.dart';
import 'package:sehatak/core/navigation/duplicate_navigation_observer.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/chat/add_status_screen.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';
import 'package:sehatak/presentation/screens/community/community_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_screen.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_company_screen.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_tracking_screen.dart';
import 'package:sehatak/presentation/screens/dental/dental_clinics_screen.dart';
import 'package:sehatak/presentation/screens/dental/dental_clinic_detail_screen.dart';
import 'package:sehatak/presentation/screens/dental/dental_doctors_screen.dart';
import 'package:sehatak/presentation/screens/dental/dental_doctor_detail_screen.dart';
import 'package:sehatak/presentation/screens/dental/dental_consultation_screen.dart';
import 'package:sehatak/presentation/screens/dental/dental_hospitals_screen.dart';
import 'package:sehatak/presentation/screens/dental/dental_tips_screen.dart';
import 'package:sehatak/presentation/screens/sleep/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/step_tracker/step_tracker_screen.dart';
import 'package:sehatak/presentation/screens/heart_rate/heart_rate_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';
import 'package:sehatak/presentation/screens/diet_plan/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/nutrition/nutrition_health_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/family/family_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_dashboard.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/platform/marketplace_admin_dashboard.dart';
import 'package:sehatak/presentation/screens/search/unified_search_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/packages/packages_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/splash_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/widgets/home/guided_tour/screen_tours.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static const String splash = '/splash',
      home = '/',
      auth = '/auth',
      doctors = '/doctors',
      doctorDetails = '/doctor/:id',
      pharmacy = '/pharmacy',
      labs = '/labs',
      hospitals = '/hospitals',
      chat = '/chat',
      more = '/more',
      dashboard = '/dashboard',
      profile = '/profile',
      appointments = '/appointments',
      notifications = '/notifications',
      cart = '/cart',
      wallet = '/wallet',
      map = '/map',
      consultation = '/consultation',
      services = '/services',
      packages = '/packages',
      emergency = '/emergency',
      bloodDonation = '/blood-donation',
      settings = '/settings',
      search = '/search',
      articles = '/articles',
      community = '/community',
      pharmacyDashboard = '/pharmacy-dashboard',
      labDashboard = '/lab-dashboard',
      marketplaceAdmin = '/marketplace-admin',
      chatRoom = '/chat-room',
      addStatus = '/chat/add-status',
      storyViewer = '/chat/story',
      sleepTracker = '/sleep-tracker',
      stepTracker = '/step-tracker',
      heartRate = '/heart-rate',
      bloodPressure = '/blood-pressure',
      glucoseTracker = '/glucose-tracker',
      weightTracker = '/weight-tracker',
      mentalHealth = '/mental-health',
      dietPlan = '/diet-plan',
      nutrition = '/nutrition',
      health = '/health',
      delivery = '/delivery',
      deliveryCompanies = '/delivery/companies',
      deliveryTracking = '/delivery/tracking', family = '/family',
      dentalClinics = '/dental/clinics', dentalClinicDetail = '/dental/clinic/:id',
      dentalDoctors = '/dental/doctors', dentalDoctorDetail = '/dental/doctor/:id',
      dentalConsultation = '/dental/consultation', dentalHospitals = '/dental/hospitals', dentalTips = '/dental/tips';

  static bool _backPressedOnce = false;
  static Timer? _backExitTimer;

  static Future<void> handlePlatformBack(BuildContext context) async {
    await _handleBack(context);
  }

  static Future<bool> _handleBack(BuildContext context) async {
    final router = GoRouter.of(context);

    // Home is a page-backed GoRouter route, so its PopScope cannot be relied
    // upon as the sole Android back interceptor. Delegate root-back handling
    // to the actual HomeScreen state so tabs return to Home and only a second
    // press exits.
    if (router.routerDelegate.currentConfiguration.uri.toString() == home) {
      HomeScreen.navigatorKey.currentState?.handleSystemBack();
      return false;
    }

    // Any routed page is an internal destination: Android Back must return
    // directly to the Home root instead of walking through the GoRouter stack.
    // This also prevents nested route history from exposing a blank/previous
    // page before Home.
    if (router.routerDelegate.currentConfiguration.uri.toString() != home) {
      _backPressedOnce = false;
      _backExitTimer?.cancel();
      router.go(home);
      return false;
    }

    // Home is the only place where Android Back can exit the application.
    // It is handled by HomeScreen, which also handles returning from tabs.
    final nav = navigatorKey.currentState;
    if (nav?.canPop() == true) {
      nav!.pop();
      return true;
    }

    // We are at the Home root: require two consecutive presses to exit.
    if (_backPressedOnce) {
      _backPressedOnce = false;
      _backExitTimer?.cancel();
      await SystemNavigator.pop();
      return true;
    }

    _backPressedOnce = true;
    ToastService.showInfo('اضغط مرة أخرى للخروج من التطبيق');
    _backExitTimer?.cancel();
    _backExitTimer = Timer(const Duration(seconds: 2), () {
      _backPressedOnce = false;
    });
    return true;
  }

  /// Back from any routed internal screen always returns to the Home root.
  /// HomeScreen itself owns the two-press exit behavior via PopScope.
  static FutureOr<bool> _returnToHome(BuildContext context) {
    _backPressedOnce = false;
    _backExitTimer?.cancel();
    if (GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString() == home) return true;
    context.go(home);
    return false;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    observers: <NavigatorObserver>[DuplicateNavigationObserver()],
    initialLocation: splash,
    refreshListenable:
        GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (_, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      if (state.matchedLocation == auth && loggedIn) return home;
      return null;
    },
    routes: [
      GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: home,
          onExit: _handleBack,
          builder: (_, __) => HomeScreen(key: HomeScreen.navigatorKey)),
      GoRoute(
                    path: auth,
          redirect: (_, __) =>
              FirebaseAuth.instance.currentUser != null ? home : null,
          builder: (_, __) => const AuthScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: doctors,
          builder: (_, __) =>
              ScreenTours.wrapDoctors(const DoctorsListScreen())),
      GoRoute(
          onExit: _returnToHome,
          path: doctorDetails,
          builder: (_, s) =>
              DoctorDetailsScreen(doctorId: s.pathParameters['id'] ?? '')),
      GoRoute(
          onExit: _returnToHome,
          path: pharmacy,
          builder: (_, __) => ScreenTours.wrapPharmacy(const PharmacyScreen())),
      GoRoute(
          onExit: _returnToHome,
          path: pharmacyDashboard,
          builder: (_, __) => const PharmacyDashboard()),
      GoRoute(
          onExit: _returnToHome,
          path: labDashboard,
          builder: (_, __) => const LabDashboardScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: marketplaceAdmin,
          builder: (_, __) => const MarketplaceAdminDashboard()),
      GoRoute(
          onExit: _returnToHome,
          path: labs,
          builder: (_, __) => ScreenTours.wrapLabs(const LabsListScreen())),
      GoRoute(
          onExit: _returnToHome,path: hospitals, builder: (_, __) => const HospitalScreen()),
      GoRoute(
          onExit: _returnToHome,path: chat, builder: (_, __) => const ChatScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: chatRoom,
          builder: (_, s) {
            final e = (s.extra as Map?)?.cast<String, dynamic>() ??
                const <String, dynamic>{};
            return ChatRoomScreen(
                chatId: '${e['chatId'] ?? ''}',
                otherUserId: '${e['otherUserId'] ?? ''}',
                otherUserName: '${e['otherUserName'] ?? 'مستخدم'}',
                otherUserImage: e['otherUserImage'] as String?,
                groupImage: e['groupImage'] as String?,
                isGroup: e['isGroup'] == true);
          }),
      GoRoute(
          onExit: _returnToHome,path: addStatus, builder: (_, __) => const AddStatusScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: storyViewer,
          builder: (_, s) => StoryViewerScreen(status: s.extra as dynamic)),
      GoRoute(onExit: _returnToHome, path: family, builder: (_, __) => const FamilyDashboardScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: more,
          builder: (_, __) => ScreenTours.wrapMore(const MoreScreen())),
      GoRoute(
          onExit: _returnToHome,
          path: dashboard,
          builder: (_, __) => const RoleBasedDashboardScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: profile,
          builder: (_, __) => ScreenTours.wrapProfile(const PatientProfile())),
      GoRoute(
          onExit: _returnToHome,
          path: appointments, builder: (_, __) => const PatientAppointments()),
      GoRoute(
          onExit: _returnToHome,
          path: notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(
          onExit: _returnToHome,path: cart, builder: (_, __) => const CartScreen()),
      GoRoute(
          onExit: _returnToHome,path: wallet, builder: (_, __) => const WalletScreen()),
      GoRoute(
          onExit: _returnToHome,path: map, builder: (_, __) => const InteractiveMapScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: consultation, builder: (_, __) => const ConsultationScreen()),
      GoRoute(
          onExit: _returnToHome,path: services, builder: (_, __) => const ServicesScreen()),
      GoRoute(
          onExit: _returnToHome,path: packages, builder: (_, __) => const PackagesScreen()),
      GoRoute(
          onExit: _returnToHome,path: emergency, builder: (_, __) => const EmergencyNumbers()),
      GoRoute(
          onExit: _returnToHome,
          path: bloodDonation, builder: (_, __) => const BloodDonationScreen()),
      GoRoute(
          onExit: _returnToHome,path: settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: search,
          builder: (_, s) =>
              AdvancedSearchScreen(initialQuery: s.uri.queryParameters['q'])),
      GoRoute(
          onExit: _returnToHome,path: articles, builder: (_, __) => const ArticlesScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: community,
          pageBuilder: (_, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const CommunityScreen(),
            opaque: true,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
          ),
        ),
      GoRoute(
          onExit: _returnToHome,
          path: sleepTracker, builder: (_, __) => const SleepTrackerScreen()),
      GoRoute(
          onExit: _returnToHome,path: stepTracker, builder: (_, __) => const StepTrackerScreen()),
      GoRoute(
          onExit: _returnToHome,path: heartRate, builder: (_, __) => const HeartRateScreen()),
      GoRoute(
          onExit: _returnToHome,path: bloodPressure, builder: (_, __) => const BloodPressureScreen()),
      GoRoute(
          onExit: _returnToHome,path: glucoseTracker, builder: (_, __) => const GlucoseTrackerScreen()),
      GoRoute(
          onExit: _returnToHome,path: weightTracker, builder: (_, __) => const WeightTrackerScreen()),
      GoRoute(
          onExit: _returnToHome,path: mentalHealth, builder: (_, __) => const MentalHealthScreen()),
      GoRoute(
          onExit: _returnToHome,path: dietPlan, builder: (_, __) => const DietPlanScreen()),
      GoRoute(
          onExit: _returnToHome,path: nutrition, builder: (_, __) => const NutritionHealthScreen()),
      GoRoute(
          onExit: _returnToHome,path: health, builder: (_, __) => const HealthDashboard()),
      GoRoute(
          onExit: _returnToHome,path: delivery, builder: (_, __) => const DeliveryScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: deliveryCompanies,
          builder: (context, state) {
            final extra = (state.extra as Map?)?.cast<String, dynamic>() ??
                const <String, dynamic>{};
            return DeliveryCompanyScreen(
                selectedCompanyId: extra['selectedCompanyId'] as String?,
                distance: (extra['distance'] as num?)?.toDouble() ?? 5.0,
                area: '${extra['area'] ?? ''}',
                onSelect: (company) => context.pop(company));
          }),
      GoRoute(onExit: _returnToHome, path: dentalClinics, builder: (_, __) => const DentalClinicsScreen()),
      GoRoute(onExit: _returnToHome, path: dentalClinicDetail, builder: (_, s) => DentalClinicDetailScreen(clinicId: s.pathParameters['id'] ?? '')),
      GoRoute(onExit: _returnToHome, path: dentalDoctors, builder: (_, __) => const DentalDoctorsScreen()),
      GoRoute(onExit: _returnToHome, path: dentalDoctorDetail, builder: (_, s) => DentalDoctorDetailScreen(doctorId: s.pathParameters['id'] ?? '')),
      GoRoute(onExit: _returnToHome, path: dentalConsultation, builder: (_, __) => const DentalConsultationScreen()),
      GoRoute(onExit: _returnToHome, path: dentalHospitals, builder: (_, __) => const DentalHospitalsScreen()),
      GoRoute(onExit: _returnToHome, path: dentalTips, builder: (_, __) => const DentalTipsScreen()),
      GoRoute(
          onExit: _returnToHome,
          path: deliveryTracking,
          builder: (_, state) {
            final orderId = state.uri.queryParameters['orderId'] ??
                (state.extra is String ? state.extra as String : '');
            return DeliveryTrackingScreen(orderId: orderId);
          }),
    ],
  );

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    final name = routeSettings.name ?? home;
    if (name == auth && FirebaseAuth.instance.currentUser != null)
      return MaterialPageRoute(
          builder: (_) => const HomeScreen(), settings: routeSettings);
    switch (name) {
      case splash:
        return MaterialPageRoute(
            builder: (_) => const SplashScreen(), settings: routeSettings);
      case home:
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(), settings: routeSettings);
      case auth:
        return MaterialPageRoute(
            builder: (_) => const AuthScreen(), settings: routeSettings);
      case doctors:
        return MaterialPageRoute(
            builder: (_) => ScreenTours.wrapDoctors(const DoctorsListScreen()),
            settings: routeSettings);
      case pharmacy:
        return MaterialPageRoute(
            builder: (_) => ScreenTours.wrapPharmacy(const PharmacyScreen()),
            settings: routeSettings);
      case labs:
        return MaterialPageRoute(
            builder: (_) => ScreenTours.wrapLabs(const LabsListScreen()),
            settings: routeSettings);
      case hospitals:
        return MaterialPageRoute(
            builder: (_) => const HospitalScreen(), settings: routeSettings);
      case chat:
        return MaterialPageRoute(
            builder: (_) => const ChatScreen(), settings: routeSettings);
      case chatRoom:
        return MaterialPageRoute(
            builder: (_) => const ChatRoomScreen(
                chatId: '',
                otherUserId: '',
                otherUserName: 'مستخدم',
                isGroup: false),
            settings: routeSettings);
      case addStatus:
        return MaterialPageRoute(
            builder: (_) => const AddStatusScreen(), settings: routeSettings);
      case more:
        return MaterialPageRoute(
            builder: (_) => ScreenTours.wrapMore(const MoreScreen()),
            settings: routeSettings);
      case dashboard:
        return MaterialPageRoute(
            builder: (_) => const RoleBasedDashboardScreen(),
            settings: routeSettings);
      case profile:
        return MaterialPageRoute(
            builder: (_) => ScreenTours.wrapProfile(const PatientProfile()),
            settings: routeSettings);
      case appointments:
        return MaterialPageRoute(
            builder: (_) => const PatientAppointments(),
            settings: routeSettings);
      case notifications:
        return MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
            settings: routeSettings);
      case cart:
        return MaterialPageRoute(
            builder: (_) => const CartScreen(), settings: routeSettings);
      case wallet:
        return MaterialPageRoute(
            builder: (_) => const WalletScreen(), settings: routeSettings);
      case map:
        return MaterialPageRoute(
            builder: (_) => const InteractiveMapScreen(),
            settings: routeSettings);
      case consultation:
        return MaterialPageRoute(
            builder: (_) => const ConsultationScreen(),
            settings: routeSettings);
      case services:
        return MaterialPageRoute(
            builder: (_) => const ServicesScreen(), settings: routeSettings);
      case packages:
        return MaterialPageRoute(builder: (_) => const PackagesScreen(), settings: routeSettings);
      case emergency:
        return MaterialPageRoute(
            builder: (_) => const EmergencyNumbers(), settings: routeSettings);
      case bloodDonation:
        return MaterialPageRoute(
            builder: (_) => const BloodDonationScreen(),
            settings: routeSettings);
      case settings:
        return MaterialPageRoute(
            builder: (_) => const SettingsScreen(), settings: routeSettings);
      case search:
        return MaterialPageRoute(
            builder: (_) => AdvancedSearchScreen(
                initialQuery: routeSettings.arguments is String
                    ? routeSettings.arguments as String
                    : null),
            settings: routeSettings);
      case articles:
        return MaterialPageRoute(
            builder: (_) => const ArticlesScreen(), settings: routeSettings);
      case community:
        return MaterialPageRoute(
            builder: (_) => const CommunityScreen(), settings: routeSettings);
      case sleepTracker:
        return MaterialPageRoute(
            builder: (_) => const SleepTrackerScreen(),
            settings: routeSettings);
      case stepTracker:
        return MaterialPageRoute(
            builder: (_) => const StepTrackerScreen(), settings: routeSettings);
      case heartRate:
        return MaterialPageRoute(
            builder: (_) => const HeartRateScreen(), settings: routeSettings);
      case bloodPressure:
        return MaterialPageRoute(
            builder: (_) => const BloodPressureScreen(), settings: routeSettings);
      case glucoseTracker:
        return MaterialPageRoute(
            builder: (_) => const GlucoseTrackerScreen(), settings: routeSettings);
      case weightTracker:
        return MaterialPageRoute(
            builder: (_) => const WeightTrackerScreen(), settings: routeSettings);
      case mentalHealth:
        return MaterialPageRoute(
            builder: (_) => const MentalHealthScreen(), settings: routeSettings);
      case dietPlan:
        return MaterialPageRoute(
            builder: (_) => const DietPlanScreen(), settings: routeSettings);
      case nutrition:
        return MaterialPageRoute(
            builder: (_) => const NutritionHealthScreen(), settings: routeSettings);
      case health:
        return MaterialPageRoute(
            builder: (_) => const HealthDashboard(), settings: routeSettings);
      case delivery:
        return MaterialPageRoute(
            builder: (_) => const DeliveryScreen(), settings: routeSettings);
      case deliveryTracking:
        return MaterialPageRoute(
            builder: (_) => DeliveryTrackingScreen(
                orderId: routeSettings.arguments is String
                    ? routeSettings.arguments as String
                    : ''),
            settings: routeSettings);
      default:
        if (name.startsWith('/doctor/'))
          return MaterialPageRoute(
              builder: (_) => DoctorDetailsScreen(
                  doctorId: name.substring('/doctor/'.length)),
              settings: routeSettings);
        return PaymentRoutes.onGenerateRoute(routeSettings);
    }
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
