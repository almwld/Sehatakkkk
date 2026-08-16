import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart'; // ✅ استيراد HomeTab الحقيقي
import 'package:sehatak/presentation/widgets/common/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ValueNotifier<bool> _isBottomBarVisible = ValueNotifier<bool>(true);
  late final PageController _pageController;
  late final List<ScrollController> _scrollControllers;

  final List<Widget> _screens = [
    HomeTab( // ✅ الآن يستخدم HomeTab الحقيقي
      scrollController: ScrollController(),
      isBottomBarVisible: ValueNotifier<bool>(true),
    ),
    const DoctorsListScreen(),
    const PharmacyScreen(),
    const ChatScreen(),
    const LabsListScreen(),
    const PatientDashboard(),
    const MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollControllers = List.generate(7, (index) => ScrollController());
    
    // ✅ تحديث HomeTab مع الـ scrollController الصحيح
    _screens[0] = HomeTab(
      scrollController: _scrollControllers[0],
      isBottomBarVisible: _isBottomBarVisible,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _isBottomBarVisible.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (isVisible) setState(() => isVisible = false);
            } else if (notification.direction == ScrollDirection.forward) {
            }
            return true;
          },
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isBottomBarVisible,
              builder: (context, isVisible, child) {
                return CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTap,
                  isVisible: isVisible,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
