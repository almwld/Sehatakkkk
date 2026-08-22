// ============================================================
// 📱 CustomBottomNavigationBar - شريط التنقل السفلي المخصص
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final ScrollController scrollController;
  final bool isLoggedIn;
  final VoidCallback onAuthRequired;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.scrollController,
    required this.isLoggedIn,
    required this.onAuthRequired,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState
    extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isVisible = true;
  double _lastScrollOffset = 0;
  bool _isScrollingDown = false;

  final double _showThreshold = 30.0;
  final double _hideThreshold = 80.0;
  final double _scrollVelocityThreshold = 2.0;

  // ✅ قائمة عناصر التنقل
  final List<NavItem> _navItems = [
    NavItem(
      index: 0,
      icon: Icons.home_rounded,
      label: 'الرئيسية',
      isProtected: false,
    ),
    NavItem(
      index: 1,
      icon: Icons.person_search_rounded,
      label: 'الأطباء',
      isProtected: false,
    ),
    NavItem(
      index: 2,
      icon: Icons.local_pharmacy_rounded,
      label: 'الصيدلية',
      isProtected: false,
    ),
    NavItem(
      index: 3,
      icon: Icons.chat_rounded,
      label: 'الدردشة',
      isProtected: true,
      isSpecial: true,
    ),
    NavItem(
      index: 4,
      icon: Icons.science_rounded,
      label: 'مختبرات',
      isProtected: true,
    ),
    NavItem(
      index: 5,
      icon: Icons.folder_rounded,
      label: 'صحتي',
      isProtected: true,
    ),
    NavItem(
      index: 6,
      icon: Icons.grid_view_rounded,
      label: 'المزيد',
      isProtected: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _animationController.forward();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final currentOffset = widget.scrollController.offset;
    final maxExtent = widget.scrollController.position.maxScrollExtent;

    if (maxExtent <= 0) return;

    final delta = currentOffset - _lastScrollOffset;
    final isScrollingDown = delta > _scrollVelocityThreshold;
    final isScrollingUp = delta < -_scrollVelocityThreshold;
    final isAtTop = currentOffset < _showThreshold;

    if (isAtTop && !_isVisible) {
      _showBar();
      _lastScrollOffset = currentOffset;
      return;
    }

    if (isScrollingDown && _isVisible && currentOffset > _hideThreshold) {
      _hideBar();
    } else if (isScrollingUp && !_isVisible && currentOffset > 50) {
      _showBar();
    }

    _lastScrollOffset = currentOffset;
  }

  void _hideBar() {
    if (!_isVisible) return;
    setState(() => _isVisible = false);
    _animationController.reverse();
  }

  void _showBar() {
    if (_isVisible) return;
    setState(() => _isVisible = true);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final heightFactor = _isVisible ? 1.0 : 0.0;

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: heightFactor,
            child: child,
          ),
        );
      },
      child: Container(
        height: 60, // ✅ تم التصغير من 75 إلى 60
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navItems.map((item) {
              if (item.isSpecial) {
                return _buildSpecialChatButton(item);
              }
              return _buildNavItem(item);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final isSelected = widget.currentIndex == item.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44, // ✅ تم التصغير من 50 إلى 44
        height: 52, // ✅ تم التصغير من 60 إلى 52
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
              child: Icon(
                item.icon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                size: isSelected ? 22 : 20, // ✅ تم التصغير من 26/24 إلى 22/20
              ),
            ),
            const SizedBox(height: 2), // ✅ تم التصغير من 4 إلى 2
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isSelected ? 1 : 0.7,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 9, // ✅ تم التصغير من 10 إلى 9
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                ),
              ),
            ),
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2, // ✅ تم التصغير من 3 إلى 2
                width: 16, // ✅ تم التصغير من 20 إلى 16
                margin: const EdgeInsets.only(top: 1), // ✅ تم التصغير من 2 إلى 1
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 4, // ✅ تم التصغير من 6 إلى 4
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 3), // ✅ تم التصغير من 5 إلى 3
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialChatButton(NavItem item) {
    final isSelected = widget.currentIndex == item.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52, // ✅ تم التصغير من 60 إلى 52
        height: 64, // ✅ تم التصغير من 75 إلى 64
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
              child: Container(
                width: 46, // ✅ تم التصغير من 54 إلى 46
                height: 46, // ✅ تم التصغير من 54 إلى 46
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3), // ✅ تم التصغير من 0.4 إلى 0.3
                      blurRadius: 14, // ✅ تم التصغير من 20 إلى 14
                      offset: const Offset(0, 4), // ✅ تم التصغير من 8 إلى 4
                      spreadRadius: 1, // ✅ تم التصغير من 2 إلى 1
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: Colors.white,
                      size: 24, // ✅ تم التصغير من 30 إلى 24
                    ),
                    if (isSelected)
                      Container(
                        width: 50, // ✅ تم التصغير من 60 إلى 50
                        height: 50, // ✅ تم التصغير من 60 إلى 50
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25), // ✅ تم التصغير من 0.3 إلى 0.25
                            width: 1.5, // ✅ تم التصغير من 2 إلى 1.5
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 1), // ✅ تم التصغير من 2 إلى 1
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isSelected ? 1 : 0.7,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 9, // ✅ تم التصغير من 10 إلى 9
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                ),
              ),
            ),
            const SizedBox(height: 1), // ✅ تم التصغير من 2 إلى 1
          ],
        ),
      ),
    );
  }

  void _handleTap(NavItem item) {
    if (item.isProtected && !widget.isLoggedIn) {
      widget.onAuthRequired();
      return;
    }

    HapticFeedback.lightImpact();
    widget.onTap(item.index);
  }
}

class NavItem {
  final int index;
  final IconData icon;
  final String label;
  final bool isProtected;
  final bool isSpecial;

  const NavItem({
    required this.index,
    required this.icon,
    required this.label,
    this.isProtected = false,
    this.isSpecial = false,
  });
}
