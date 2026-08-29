// ============================================================
// 📄 lib/presentation/screens/home/home_screen.dart
// 🏠 الشاشة الرئيسية للتطبيق
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
import 'package:sehatak/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';

// ✅ مفاتيح ثابتة لكل شاشة - تمنع فقدان الحالة
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
  bool _isBottomBarVisible = true;

  // ✅ استخدام Map بدلاً من List للحفاظ على المفاتيح
  late final Map<int, Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
    _initializeScreens();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    // ✅ تجنب setState إذا لم يتغير شيء
    final newStatus = user != null;
    if (_isLoggedIn != newStatus && mounted) {
      setState(() {
        _isLoggedIn = newStatus;
      });
    }
  }

  void _initializeScreens() {
    // ✅ استخدام ValueKey لكل شاشة يمنع فقدان الحالة
    _screens = {
      0: HomeTab(
        key: ScreenKeys.home,
        scrollController: _scrollController,
        isBottomBarVisible: ValueNotifier<bool>(_isBottomBarVisible),
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

    if (_currentIndex != index && mounted) {
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
        // ✅ استخدام values من Map مع المفاتيح الثابتة
        children: _screens.values.toList(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
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
    );
  }
}
