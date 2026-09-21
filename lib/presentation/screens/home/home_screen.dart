import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';
import 'package:sehatak/presentation/widgets/community/doctor_community_fab.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_navigation_bar.dart';

class ScreenKeys {
  static const home = ValueKey('home_tab');
  static const doctors = ValueKey('doctors_tab');
  static const pharmacy = ValueKey('pharmacy_tab');
  static const chat = ValueKey('chat_tab');
  static const labs = ValueKey('labs_tab');
  static const patient = ValueKey('patient_tab');
  static const more = ValueKey('more_tab');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final _scrollController = ScrollController();
  late final GlobalScrollManager _scrollManager;
  bool _isLoggedIn = false, _backPressedOnce = false;
  Timer? _backExitTimer;
  Timer? _healthRefreshTimer;
  late final Map<int, Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollManager = GlobalScrollManager();
    _screens = {
      0: HomeTab(key: ScreenKeys.home, scrollController: _scrollController),
      1: const DoctorsListScreen(key: ScreenKeys.doctors),
      2: const PharmacyScreen(key: ScreenKeys.pharmacy),
      3: const ChatScreen(key: ScreenKeys.chat),
      4: const LabsListScreen(key: ScreenKeys.labs),
      5: const PatientDashboard(key: ScreenKeys.patient),
      6: const MoreScreen(key: ScreenKeys.more),
    };
    _checkAuth();
    _systemNav();
    _healthRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) context.read<HomeBloc>().add(HomeHealthStatsRefreshed());
    });
  }

  void _systemNav() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _checkAuth() {
    final v = FirebaseAuth.instance.currentUser != null;
    if (mounted && v != _isLoggedIn) setState(() => _isLoggedIn = v);
  }

  @override
  void dispose() {
    _backExitTimer?.cancel();
    _healthRefreshTimer?.cancel();
    _scrollController.dispose();
    _scrollManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _checkAuth();
      _systemNav();
    }
  }

  bool _scroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.reverse) {
        _scrollManager.handleScrollDelta(6);
      } else if (n.direction == ScrollDirection.forward) {
        _scrollManager.handleScrollDelta(-6);
      }
    } else if (n is ScrollEndNotification &&
        n.metrics.pixels <= n.metrics.minScrollExtent + 2) {
      _scrollManager.show();
    }
    return false;
  }

  void _back() {
    // زر الرجوع داخل HomeScreen له مستويان:
    // 1) إذا كان المستخدم داخل إحدى واجهات شريط التنقل، فالرجوع مرة واحدة
    //    يعيده إلى الرئيسية فقط، ولا يُخرج من التطبيق.
    // 2) الخروج من التطبيق متاح فقط عندما تكون الرئيسية هي الواجهة الحالية،
    //    وعندها يتطلب ضغطتين متتاليتين.
    if (_currentIndex != 0) {
      _backPressedOnce = false;
      _backExitTimer?.cancel();
      if (mounted) {
        setState(() => _currentIndex = 0);
      }
      _scrollManager.show();
      HapticFeedback.lightImpact();
      return;
    }

    if (_backPressedOnce) {
      _backPressedOnce = false;
      _backExitTimer?.cancel();
      SystemNavigator.pop();
      return;
    }

    _backPressedOnce = true;
    ToastService.showToast(
      message: 'اضغط مرة أخرى للخروج من التطبيق',
      type: ToastType.info,
      duration: const Duration(seconds: 2),
    );
    _backExitTimer?.cancel();
    _backExitTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _backPressedOnce = false);
    });
  }

  void _tab(int i) {
    if (!_isLoggedIn && FirebaseAuth.instance.currentUser != null) {
      _checkAuth();
    }
    final logged = FirebaseAuth.instance.currentUser != null;
    if ((i == 3 || i == 4 || i == 5) && !logged) {
      _auth();
      return;
    }
    _scrollManager.show();

    // التنقل اليدوي يلغي حالة "اضغط مرة أخرى للخروج" حتى لا تنتقل
    // حالة الخروج من الرئيسية إلى تبويب آخر.
    _backPressedOnce = false;
    _backExitTimer?.cancel();

    if (_currentIndex != i) {
      setState(() => _currentIndex = i);
    }
    HapticFeedback.lightImpact();
  }

  void _auth() {
    if (FirebaseAuth.instance.currentUser != null) {
      _checkAuth();
      return;
    }
    // AppRouter is the single owner of authentication navigation.
    AppRouter.router.go(AppRouter.auth);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _back();
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor:
            dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _scroll,
              child: IndexedStack(
                index: _currentIndex,
                children: _screens.values.toList(growable: false),
              ),
            ),
            if (_currentIndex == 0)
              PositionedDirectional(
                end: 18,
                bottom: 92,
                child: DoctorCommunityFab(
                  scrollController: _scrollController,
                  dark: dark,
                  onPostPublished: () => context.read<HomeBloc>().add(HomeDataRefreshed()),
                ),
              ),
          ],
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _scrollManager,
          builder: (_, __) => _AnimatedBottomNavigationBar(
            visible: _scrollManager.isVisible,
            child: CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _tab,
              scrollController: _scrollController,
              scrollManager: _scrollManager,
              isLoggedIn: _isLoggedIn,
              onAuthRequired: _auth,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBottomNavigationBar extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedBottomNavigationBar({
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Animate the complete navigation widget as one unit. Do not animate its
    // height: the chat button intentionally overflows above the bar, and an
    // AnimatedSize/Align height animation can clip that overflow for a frame.
    // A slide keeps the button, icon, label, shadow and bar together and
    // preserves their original geometry throughout the animation.
    return ClipRect(
      clipBehavior: Clip.none,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 1.05),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          opacity: visible ? 1 : 0,
          child: child,
        ),
      ),
    );
  }
}
