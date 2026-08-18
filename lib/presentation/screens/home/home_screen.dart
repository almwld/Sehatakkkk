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

  // ✅ قائمة الشاشات
  final List<Widget> _screens = [];

  // ✅ عناصر التنقل
  final List<NavItemConfig> _navItems = [
    const NavItemConfig(index: 0, icon: Icons.home_rounded, label: 'الرئيسية'),
    const NavItemConfig(index: 1, icon: Icons.person_search_rounded, label: 'الأطباء'),
    const NavItemConfig(index: 2, icon: Icons.local_pharmacy_rounded, label: 'الصيدلية'),
    const NavItemConfig(index: 3, icon: Icons.chat_rounded, label: 'الدردشة', isSpecial: true),
    const NavItemConfig(index: 4, icon: Icons.science_rounded, label: 'مختبرات'),
    const NavItemConfig(index: 5, icon: Icons.folder_rounded, label: 'صحتي'),
    const NavItemConfig(index: 6, icon: Icons.grid_view_rounded, label: 'المزيد'),
  ];

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
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  void _initializeScreens() {
    _screens.clear();
    _screens.addAll([
      HomeTab(
        scrollController: _scrollController,
        isBottomBarVisible: ValueNotifier<bool>(_isBottomBarVisible),
      ),
      const DoctorsListScreen(),
      const PharmacyScreen(),
      const ChatScreen(),
      const LabsListScreen(),
      const PatientDashboard(),
      const MoreScreen(),
    ]);
  }

  void _onTabTap(int index) {
    // ✅ التحقق من المصادقة للتبويبات المحمية
    final protectedTabs = [3, 4, 5]; // الدردشة، مختبرات، صحتي
    if (protectedTabs.contains(index) && !_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      ).then((_) {
        _checkLoginStatus();
      });
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    // ✅ تأثير اهتزاز خفيف
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
      ),
    );
  }
}

// ============================================================
// 📦 نموذج عنصر التنقل
// ============================================================
class NavItemConfig {
  final int index;
  final IconData icon;
  final String label;
  final bool isSpecial;
  final bool isProtected;

  const NavItemConfig({
    required this.index,
    required this.icon,
    required this.label,
    this.isSpecial = false,
    this.isProtected = false,
  });
}
