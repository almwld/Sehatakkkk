import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<ScrollController> _scrollControllers;
  final ValueNotifier<bool> _isBottomBarVisible = ValueNotifier<bool>(true);
  bool _isDark = false;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'الرئيسية', 'index': 0},
    {'icon': Icons.person_search_rounded, 'label': 'الأطباء', 'index': 1},
    {'icon': Icons.local_pharmacy_rounded, 'label': 'الصيدلية', 'index': 2},
    {'icon': Icons.chat_rounded, 'label': 'الدردشة', 'index': 3},
    {'icon': Icons.science_rounded, 'label': 'مختبرات', 'index': 4},
    {'icon': Icons.folder_rounded, 'label': 'صحتي', 'index': 5},
    {'icon': Icons.grid_view_rounded, 'label': 'المزيد', 'index': 6},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0);
    _scrollControllers = List.generate(7, (index) => ScrollController());
    
    // ✅ منع العودة إلى Splash
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        // ✅ منع الخروج من التطبيق عند الضغط على Back
        return false;
      }
      return null;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _isBottomBarVisible.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDark = Theme.of(context).brightness == Brightness.dark;
  }

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
    if (_scrollControllers[index].hasClients) {
      _scrollControllers[index].animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return HomeTab(
          scrollController: _scrollControllers[0],
          isBottomBarVisible: _isBottomBarVisible,
        );
      case 1:
        return const DoctorsListScreen();
      case 2:
        return const PharmacyScreen();
      case 3:
        return const ChatScreen();
      case 4:
        return const LabsListScreen();
      case 5:
        return const PatientDashboard();
      case 6:
        return const MoreScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isBottomBarVisible,
      builder: (context, visible, child) {
        return AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 250),
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF0B1121) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _navItems.map((item) {
                      final index = item['index'] as int;
                      final isSelected = _currentIndex == index;
                      final color = isSelected ? AppColors.primary : (_isDark ? Colors.grey[500] : Colors.grey[600]);
                      
                      return GestureDetector(
                        onTap: () => _onTabTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: color,
                              size: 24,
                            ),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // ✅ منع الخروج من التطبيق عند الضغط على Back
        // ✅ بدلاً من ذلك، إظهار رسالة تأكيد الخروج
        if (_currentIndex != 0) {
          _onTabTap(0);
          return false;
        }
        // ✅ طلب تأكيد الخروج من التطبيق
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('خروج'),
            content: const Text('هل تريد الخروج من التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('خروج'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: _isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(7, (index) => _buildTabContent(index)),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
