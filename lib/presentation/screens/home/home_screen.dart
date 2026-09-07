// ============================================================
// 🏠 HomeScreen - الشاشة الرئيسية
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_navigation_bar.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/core/widgets/scroll_detector.dart';

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
  final ScrollController _scrollController = ScrollController();
  late final GlobalScrollManager _scrollManager;
  bool _isLoggedIn = false;
  late final Map<int, Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollManager = GlobalScrollManager();
    _checkLoginStatus();
    _initializeScreens();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final newStatus = FirebaseAuth.instance.currentUser != null;
    if (_isLoggedIn != newStatus && mounted) {
      setState(() => _isLoggedIn = newStatus);
    }
  }

  void _initializeScreens() {
    _screens = {
      0: HomeTab(key: ScreenKeys.home, scrollController: _scrollController),
      1: const DoctorsListScreen(key: ScreenKeys.doctors),
      2: const PharmacyScreen(key: ScreenKeys.pharmacy),
      3: const ChatScreen(key: ScreenKeys.chat),
      4: const LabsListScreen(key: ScreenKeys.labs),
      5: const PatientDashboard(key: ScreenKeys.patient),
      6: const MoreScreen(key: ScreenKeys.more),
    };
  }

  void _onTabTap(int index) {
    if (index == 5 && !_isLoggedIn) {
      _openAuth();
      return;
    }

    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      // عند الانتقال بين التبويبات نبدأ بحالة مرئية دائمًا.
      _scrollManager.reset();
    } else {
      _scrollManager.show();
    }

    HapticFeedback.lightImpact();
  }

  void _openAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    ).then((_) => _checkLoginStatus());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      // مهم: ScrollDetector يحيط بكل IndexedStack، لذلك أي ScrollView
      // داخل الأطباء/الصيدلية/المختبرات/المزيد وغيرها يرسل إشعاره هنا.
      body: ScrollDetector(
        scrollManager: _scrollManager,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens.values.toList(growable: false),
        ),
      ),
      // نستخدم Stack حتى يتحرك الشريط خارج الشاشة بدون تغيير مساحة body.
      // هذا يمنع القفزة/إعادة تخطيط المحتوى أثناء التمرير.
      bottomNavigationBar: _buildAnimatedBottomNav(),
    );
  }

  Widget _buildAnimatedBottomNav() {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final navHeight = 60.0 + bottomPadding;

    return AnimatedBuilder(
      animation: _scrollManager,
      builder: (context, _) {
        final visible = _scrollManager.isVisible;

        return SizedBox(
          height: navHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !visible,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    offset: visible ? Offset.zero : const Offset(0, 1.25),
                    child: Material(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.12),
                      child: SafeArea(
                        top: false,
                        bottom: true,
                        child: CustomBottomNavigationBar(
                          currentIndex: _currentIndex,
                          onTap: _onTabTap,
                          scrollManager: _scrollManager,
                          scrollController: _scrollController,
                          isLoggedIn: _isLoggedIn,
                          onAuthRequired: _openAuth,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
