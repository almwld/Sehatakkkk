import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/core/widgets/scroll_detector.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_nav_bar.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  bool _isBottomBarVisible = true;
  final ScrollController _scrollController = ScrollController();
  final GlobalScrollManager _scrollManager = GlobalScrollManager();

  late final List<Widget> _screens;

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
    final newStatus = user != null;
    if (_isLoggedIn != newStatus && mounted) {
      setState(() {
        _isLoggedIn = newStatus;
      });
    }
  }

  void _initializeScreens() {
    _screens = [
      HomeTab(
        scrollController: _scrollController,
        isBottomBarVisible: ValueNotifier<bool>(_isBottomBarVisible),
        scrollManager: _scrollManager, // ✅ الآن HomeTab يقبل scrollManager
      ),
      const DoctorsListScreen(),
      const PharmacyScreen(),
      const ChatScreen(),
      const LabsListScreen(),
      const PatientDashboard(),
      const MoreScreen(),
    ];
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
        children: _screens,
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
        scrollManager: _scrollManager,
      ),
    );
  }
}
