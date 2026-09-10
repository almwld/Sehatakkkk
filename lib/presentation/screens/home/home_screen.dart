// ============================================================
// 🏠 HomeScreen - الشاشة الرئيسية
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
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
  final ScrollController _scrollController = ScrollController();
  late final GlobalScrollManager _scrollManager;
  bool _isLoggedIn = false;
  bool _backPressedOnce = false;
  Timer? _backExitTimer;
  late final Map<int, Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollManager = GlobalScrollManager();
    _initializeScreens();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _backExitTimer?.cancel();
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
    final status = FirebaseAuth.instance.currentUser != null;
    if (_isLoggedIn != status && mounted) setState(() => _isLoggedIn = status);
  }

  void _initializeScreens() {
    _screens = {
      0: HomeTab(key: ScreenKeys.home, scrollController: _scrollController),
      1: const DoctorsListScreen(key: ScreenKeys.doctors),
      2: const PharmacyScreen(key: ScreenKeys.pharmacy),
      3: const ChatScreen(key: ScreenKeys.chat),
      4: const LabsListScreen(key: ScreenKeys.labs),
      5: const RoleBasedDashboardScreen(key: ScreenKeys.patient),
      6: const MoreScreen(key: ScreenKeys.more),
    };
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        _scrollManager.handleScrollDelta(6);
      } else if (notification.direction == ScrollDirection.forward) {
        _scrollManager.handleScrollDelta(-6);
      }
    } else if (notification is ScrollEndNotification &&
        notification.metrics.pixels <= notification.metrics.minScrollExtent + 2) {
      _scrollManager.show();
    }
    return false;
  }

  void _handleBackPress() {
    if (_backPressedOnce) {
      _backPressedOnce = false;
      _backExitTimer?.cancel();
      _backExitTimer = null;
      SystemNavigator.pop();
      return;
    }
    _backPressedOnce = true;
    ToastService.showInfo('اضغط مرة أخرى للخروج من التطبيق');
    _backExitTimer?.cancel();
    _backExitTimer = Timer(const Duration(seconds: 2), () {
      _backPressedOnce = false;
      _backExitTimer = null;
    });
  }

  void _onTabTap(int index) {
    if ((index == 3 || index == 4 || index == 5) && !_isLoggedIn) {
      _openAuth();
      return;
    }
    _scrollManager.show();
    if (_currentIndex != index) setState(() => _currentIndex = index);
    HapticFeedback.lightImpact();
  }

  void _openAuth() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())).then((_) => _checkLoginStatus());
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InheritedGoRouter(
      goRouter: AppRouter.router,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) _handleBackPress();
        },
        child: Scaffold(
          backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
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
                onTap: _onTabTap,
                scrollController: _scrollController,
                scrollManager: _scrollManager,
                isLoggedIn: _isLoggedIn,
                onAuthRequired: _openAuth,
              ),
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
  const _AnimatedBottomNavigationBar({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: visible ? 1 : 0,
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: visible ? 1 : 0,
            child: child,
          ),
        ),
      );
}
