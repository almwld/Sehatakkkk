import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/core/widgets/scroll_detector.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_nav_bar.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  final ScrollController _scrollController =
      ScrollController();

  late final GlobalScrollManager _scrollManager;
  late final Map<int, Widget> _screens;

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _scrollManager = GlobalScrollManager();

    _initializeScreens();

    // مهم:
    // لا ننتظر Firebase هنا.
    // الواجهة تظهر أولاً، ثم نتحقق من Firebase
    // عندما تكون التهيئة جاهزة.
    _checkLoginStatusSafely();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _scrollController.dispose();
    _scrollManager.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatusSafely();
    }
  }

  /// التحقق من حالة تسجيل الدخول بدون التسبب
  /// في توقف الواجهة إذا لم تكن Firebase جاهزة.
  void _checkLoginStatusSafely() {
    try {
      // Firebase لم تتم تهيئتها بعد.
      // لا نحاول الوصول إلى FirebaseAuth.
      if (Firebase.apps.isEmpty) {
        if (!mounted) return;

        if (_isLoggedIn) {
          setState(() {
            _isLoggedIn = false;
          });
        }

        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      final newStatus = user != null;

      if (!mounted) return;

      if (_isLoggedIn != newStatus) {
        setState(() {
          _isLoggedIn = newStatus;
        });
      }
    } catch (e) {
      debugPrint(
        '⚠️ HomeScreen Firebase status unavailable: $e',
      );

      // لا نسمح لخطأ Firebase بكسر الواجهة.
    }
  }

  void _initializeScreens() {
    _screens = {
      0: HomeTab(
        key: ScreenKeys.home,
        scrollController: _scrollController,
      ),

      1: const DoctorsListScreen(
        key: ScreenKeys.doctors,
      ),

      2: const PharmacyScreen(
        key: ScreenKeys.pharmacy,
      ),

      3: const ChatScreen(
        key: ScreenKeys.chat,
      ),

      4: const LabsListScreen(
        key: ScreenKeys.labs,
      ),

      5: const PatientDashboard(
        key: ScreenKeys.patient,
      ),

      6: const MoreScreen(
        key: ScreenKeys.more,
      ),
    };
  }

  void _onTabTap(int index) {
    final protectedTabs = <int>[3, 4, 5];

    if (protectedTabs.contains(index) && !_isLoggedIn) {
      _openAuth();
      return;
    }

    if (_currentIndex == index) {
      // إذا ضغط المستخدم على الرئيسية مرة أخرى،
      // نعيد الصفحة إلى الأعلى.
      if (index == 0 &&
          _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration:
              const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }

      return;
    }

    setState(() {
      _currentIndex = index;
    });

    // عند تغيير التبويب نعيد إظهار الشريط.
    _scrollManager.show();
    _scrollManager.reset();

    HapticFeedback.lightImpact();
  }

  void _openAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(),
      ),
    ).then((_) {
      if (mounted) {
        _checkLoginStatusSafely();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF8FAFC),

      body: ScrollDetector(
        scrollManager: _scrollManager,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens.values.toList(),
        ),
      ),

      bottomNavigationBar: AnimatedBuilder(
        animation: _scrollManager,
        builder: (context, child) {
          final visible =
              _scrollManager.isVisible;

          return SizedBox(
            height: 76,
            child: ClipRect(
              child: AnimatedAlign(
                duration:
                    const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment:
                    Alignment.bottomCenter,
                heightFactor:
                    visible ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !visible,
                  child:
                      CustomBottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: _onTabTap,
                    scrollManager: _scrollManager,
                    isLoggedIn: _isLoggedIn,
                    onAuthRequired: _openAuth,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
