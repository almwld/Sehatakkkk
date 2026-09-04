// ============================================================
// 🏠 HomeScreen - الشاشة الرئيسية
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
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

// ✅ مفاتيح ثابتة لكل شاشة
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
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatus();
    }
  }

  void _checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    final newStatus = user != null;
    if (_isLoggedIn != newStatus) {
      setState(() {
        _isLoggedIn = newStatus;
      });
    }
  }

  void _initializeScreens() {
    _screens = {
      0: HomeTab(
        key: ScreenKeys.home,
        scrollController: _scrollController,
      ),
      1: const DoctorsListScreen(key: ScreenKeys.doctors),
      2: const PharmacyScreen(key: ScreenKeys.pharmacy),
      3: const ChatScreen(key: ScreenKeys.chat),
      4: const LabsListScreen(key: ScreenKeys.labs),
      5: const PatientDashboard(key: ScreenKeys.patient),
      6: const MoreScreen(key: ScreenKeys.more),
    };
  }

  void _onTabTap(int index) {
    final protectedTabs = [3, 4, 5];
    if (protectedTabs.contains(index) && !_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      ).then((_) {
        _checkLoginStatus();
      });
      return;
    }

    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.values.toList(),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _scrollManager,
        builder: (context, _) {
          final isVisible = _scrollManager.isVisible;
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          final navHeight = 60.0 + bottomPadding;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            height: isVisible ? navHeight : 0,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: SafeArea(
              top: false,
              bottom: true,
              child: CustomBottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTap,
                scrollManager: _scrollManager,
                scrollController: _scrollController,
                isLoggedIn: _isLoggedIn,
                onAuthRequired: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  ).then((_) {
                    _checkLoginStatus();
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
