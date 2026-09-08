// ============================================================
// 🏠 HomeScreen - الشاشة الرئيسية
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_navigation_bar.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab_pro.dart';

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
  bool _isLoggedIn = false;
  bool _isBottomNavVisible = true;
  late final Map<int, Widget> _screens;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); _checkLoginStatus(); _initializeScreens(); }
  @override
  void dispose() { _scrollController.dispose(); WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { if (state == AppLifecycleState.resumed) _checkLoginStatus(); }

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

  void _setBottomNavVisibility(bool visible) { if (_isBottomNavVisible == visible || !mounted) return; setState(() => _isBottomNavVisible = visible); }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) _setBottomNavVisibility(false);
      if (notification.direction == ScrollDirection.forward) _setBottomNavVisibility(true);
    } else if (notification is ScrollEndNotification && notification.metrics.pixels <= notification.metrics.minScrollExtent + 2) {
      _setBottomNavVisibility(true);
    }
    return false;
  }

  void _onTabTap(int index) {
    if ((index == 3 || index == 4 || index == 5) && !_isLoggedIn) { _openAuth(); return; }
    _setBottomNavVisibility(true);
    if (_currentIndex != index) setState(() => _currentIndex = index);
    HapticFeedback.lightImpact();
  }

  void _openAuth() { Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())).then((_) => _checkLoginStatus()); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: NotificationListener<ScrollNotification>(onNotification: _handleScrollNotification, child: IndexedStack(index: _currentIndex, children: _screens.values.toList(growable: false))),
      bottomNavigationBar: _AnimatedBottomNavigationBar(visible: _isBottomNavVisible, child: CustomBottomNavigationBar(currentIndex: _currentIndex, onTap: _onTabTap, isLoggedIn: _isLoggedIn, onAuthRequired: _openAuth)),
    );
  }
}

class _AnimatedBottomNavigationBar extends StatelessWidget {
  final bool visible;
  final Widget child;
  const _AnimatedBottomNavigationBar({required this.visible, required this.child});
  @override
  Widget build(BuildContext context) => AnimatedSize(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic, alignment: Alignment.topCenter, child: AnimatedOpacity(duration: const Duration(milliseconds: 160), opacity: visible ? 1 : 0, child: ClipRect(child: Align(alignment: Alignment.topCenter, heightFactor: visible ? 1 : 0, child: child))));
}
