import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVisible;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVisible = true,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'الرئيسية', 'index': 0},
    {'icon': Icons.person_search_rounded, 'label': 'الأطباء', 'index': 1},
    {'icon': Icons.local_pharmacy_rounded, 'label': 'الصيدلية', 'index': 2},
    {'icon': Icons.chat_rounded, 'label': 'الدردشة', 'index': 3, 'isSpecial': true},
    {'icon': Icons.science_rounded, 'label': 'مختبرات', 'index': 4},
    {'icon': Icons.folder_rounded, 'label': 'صحتي', 'index': 5},
    {'icon': Icons.grid_view_rounded, 'label': 'المزيد', 'index': 6},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCartIcon(bool isDark) {
    return Stack(
      children: [
        Icon(
          Icons.shopping_cart_rounded,
          color: widget.currentIndex == 2 ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
          size: 22,
        ),
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialChatButton(bool isDark, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onTap(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                children: [
                  Icon(
                    Icons.chat_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  if (widget.currentIndex == 3)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'الدردشة',
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? Colors.green : (isDark ? Colors.grey[500] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1121) : Colors.white,
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
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_rounded,
                        label: 'الرئيسية',
                        index: 0,
                        isSelected: widget.currentIndex == 0,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        icon: Icons.person_search_rounded,
                        label: 'الأطباء',
                        index: 1,
                        isSelected: widget.currentIndex == 1,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        icon: Icons.local_pharmacy_rounded,
                        label: 'الصيدلية',
                        index: 2,
                        isSelected: widget.currentIndex == 2,
                        isDark: isDark,
                        trailing: _buildCartIcon(isDark),
                      ),
                      _buildSpecialChatButton(isDark, widget.currentIndex == 3),
                      _buildNavItem(
                        icon: Icons.science_rounded,
                        label: 'مختبرات',
                        index: 4,
                        isSelected: widget.currentIndex == 4,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        icon: Icons.folder_rounded,
                        label: 'صحتي',
                        index: 5,
                        isSelected: widget.currentIndex == 5,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        icon: Icons.grid_view_rounded,
                        label: 'المزيد',
                        index: 6,
                        isSelected: widget.currentIndex == 6,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required bool isDark,
    Widget? trailing,
  }) {
    final color = isSelected ? AppColors.primary : (isDark ? Colors.grey[500] : Colors.grey[600]);

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
