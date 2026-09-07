// ============================================================
// 🎁 CustomScrollWrapper - غلاف التمرير المخصص
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_navigation_bar.dart';

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

class _CustomScrollWrapperState extends State<CustomScrollWrapper>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const double _slideOffset = 1.2;
  static const double _navHeight = 56.0;

  late final GlobalScrollManager _scrollManager;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollManager = GlobalScrollManager();

    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, _slideOffset),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scrollManager.addListener(_onVisibilityChanged);
  }

  void _onVisibilityChanged() {
    if (!mounted) return;
    if (_scrollManager.isVisible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _scrollManager.removeListener(_onVisibilityChanged);
    _animationController.dispose();
    _scrollManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _scrollManager,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final navHeight = _navHeight + bottomPadding;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: navHeight,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Clip.none(
          child: SlideTransition(
            position: _slideAnimation,
            child: SizedBox(
              height: _navHeight,
              child: CustomBottomNavigationBar(
                currentIndex: widget.currentIndex,
                onTap: widget.onTap,
                scrollManager: _scrollManager,
                scrollController: widget.scrollController,
                isLoggedIn: widget.isLoggedIn,
                onAuthRequired: widget.onAuthRequired,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
