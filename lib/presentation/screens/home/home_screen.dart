import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';  // ✅ إضافة هذا الاستيراد
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/health_score_service.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';
import 'package:sehatak/app_router.dart';

// ============================================================
// 📱 HomeScreen - الشاشة الرئيسية (نسخة مطورة)
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ValueNotifier<bool> _isBottomBarVisible = ValueNotifier<bool>(true);
  late final List<Widget> _screens;
  late final List<ScrollController> _scrollControllers;
  
  double _healthScore = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // ✅ إنشاء ScrollController لكل تبويب
    _scrollControllers = List.generate(7, (index) => ScrollController());
    
    // ✅ إضافة مستمعين للتمرير لكل تبويب
    for (int i = 0; i < _scrollControllers.length; i++) {
      _scrollControllers[i].addListener(() {
        _handleScroll(_scrollControllers[i]);
      });
    }

    _screens = [
      HomeTab(scrollController: _scrollControllers[0]),
      const DoctorsListScreen(),
      const PharmacyScreen(),
      const ChatScreen(),
      const LabsListScreen(),
      const PatientDashboard(),
      const MoreScreen(),
    ];
    
    _loadHealthScore();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _loadHealthScore() async {
    final score = await HealthScoreService.calculateHealthScore();
    setState(() => _healthScore = score);
  }

  @override
  void dispose() {
    _isBottomBarVisible.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  void _navigateWithAuth(VoidCallback action) {
    if (_isLoggedIn) {
      action();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  void _onTabTap(int index) {
    // ✅ عند تغيير التبويب، إظهار الشريط السفلي
    _isBottomBarVisible.value = true;
    
    if (index == 3 || index == 4 || index == 5) {
      _navigateWithAuth(() => setState(() => _currentIndex = index));
    } else {
      setState(() => _currentIndex = index);
    }
  }

  // ✅ معالجة التمرير - إخفاء/إظهار الشريط السفلي
  void _handleScroll(ScrollController controller) {
    if (!controller.hasClients) return;
    
    final position = controller.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    
    // ✅ إذا كان في أعلى الصفحة، إظهار الشريط
    if (currentScroll <= 10) {
      _isBottomBarVisible.value = true;
      return;
    }
    
    // ✅ إذا كان في أسفل الصفحة، إظهار الشريط
    if (currentScroll >= maxScroll - 10) {
      _isBottomBarVisible.value = true;
      return;
    }
    
    // ✅ بناءً على اتجاه التمرير (باستخدام ScrollDirection من flutter/rendering)
    if (position.userScrollDirection == ScrollDirection.reverse) {
      _isBottomBarVisible.value = false;
    } else if (position.userScrollDirection == ScrollDirection.forward) {
      _isBottomBarVisible.value = true;
    }
  }

  // ✅ إعادة تعيين حالة الشريط السفلي عند تغيير التبويب
  void _resetBottomBar() {
    _isBottomBarVisible.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ المحتوى الرئيسي
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _screens[_currentIndex],
          ),
          
          // ✅ الشريط السفلي مع أنيميشن
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isBottomBarVisible,
              builder: (context, isVisible, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isVisible ? 68 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
                          _buildNavItem(1, Icons.person_search_rounded, 'الأطباء'),
                          _buildNavItem(2, Icons.local_pharmacy_rounded, 'الصيدلية'),
                          _buildChatButton(),
                          _buildNavItem(4, Icons.science_rounded, 'مختبرات'),
                          _buildNavItem(5, Icons.folder_rounded, 'صحتي'),
                          _buildNavItem(6, Icons.grid_view_rounded, 'المزيد'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    final color = selected ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: SizedBox(
        width: 48,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
            if (selected)
              Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    final selected = _currentIndex == 3;
    return GestureDetector(
      onTap: () => _onTabTap(3),
      child: SizedBox(
        width: 56,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'الدردشة',
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : Colors.grey,
              ),
            ),
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}
