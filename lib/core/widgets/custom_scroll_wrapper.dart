// ============================================================
// 🎁 CustomScrollWrapper - غلاف التمرير المخصص
// يغلف التطبيق بالكامل ويضيف حركة الشريط السفلي لكل الشاشات
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/core/widgets/scroll_detector.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_nav_bar.dart';

class CustomScrollWrapper extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTap;
  final bool isLoggedIn;
  final VoidCallback onAuthRequired;
  final ScrollController scrollController;

  const CustomScrollWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
    required this.isLoggedIn,
    required this.onAuthRequired,
    required this.scrollController,
  });

  @override
  State<CustomScrollWrapper> createState() => _CustomScrollWrapperState();
}

class _CustomScrollWrapperState extends State<CustomScrollWrapper> {
  late final GlobalScrollManager _scrollManager;

  @override
  void initState() {
    super.initState();
    _scrollManager = GlobalScrollManager();
  }

  @override
  void dispose() {
    _scrollManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _scrollManager,
      child: Scaffold(
        body: ScrollDetector(
          scrollManager: _scrollManager,
          child: widget.child,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _scrollManager,
      builder: (context, isVisible, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isVisible ? 60 : 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
              child: CustomBottomNavigationBar(
                currentIndex: widget.currentIndex,
                onTap: widget.onTap,
                scrollManager: _scrollManager,
                isLoggedIn: widget.isLoggedIn,
                onAuthRequired: widget.onAuthRequired,
                scrollController: widget.scrollController,
              ),
            ),
          ),
        );
      },
    );
  }
}
