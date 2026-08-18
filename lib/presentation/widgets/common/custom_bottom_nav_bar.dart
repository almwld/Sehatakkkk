// ============================================================
// 📱 CustomBottomNavigationBar - شريط التنقل السفلي المخصص
// ============================================================

import 'package:flutter/material.dart';
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

  // قائمة عناصر التنقل
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
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // إضافة مستمع للتمرير
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // 🎯 معالجة التمرير لإخفاء/إظهار الشريط
  // ============================================================

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final currentOffset = widget.scrollController.offset;
    final maxExtent = widget.scrollController.position.maxScrollExtent;

    // منع التمرير عندما يكون المحتوى أقل من الشاشة
    if (maxExtent <= 0) return;

    final delta = currentOffset - _lastScrollOffset;
    final isScrollingDown = delta > 0;
    final isAtTop = currentOffset < 50;

    // إظهار الشريط عند الوصول للأعلى
    if (isAtTop && !_isVisible) {
      _showBar();
      _lastScrollOffset = currentOffset;
      return;
    }

    // إخفاء الشريط عند التمرير للأسفل
    if (isScrollingDown && _isVisible && currentOffset > 100) {
      _hideBar();
    }
    // إظهار الشريط عند التمرير للأعلى
    else if (!isScrollingDown && !_isVisible && currentOffset > 50) {
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

  // ============================================================
  // 🎨 بناء الواجهة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final slideOffset = (1 - _slideAnimation.value) *
            100; // مسافة الانزلاق للأسفل
        return Transform.translate(
          offset: Offset(0, _isVisible ? 0 : slideOffset),
          child: child,
        );
      },
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navItems.map((item) {
              // زر الدردشة الخاص
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

  // ============================================================
  // 🔘 عناصر التنقل
  // ============================================================

  Widget _buildNavItem(NavItem item) {
    final isSelected = widget.currentIndex == item.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة مع تأثير التحجيم
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..scale(isSelected ? 1.1 : 1.0),
              child: Icon(
                item.icon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // النص مع تأثير التلاشي
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1 : 0.7,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                ),
              ),
            ),
            // المؤشر السفلي
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 💬 زر الدردشة الخاص (بارز)
  // ============================================================

  Widget _buildSpecialChatButton(NavItem item) {
    final isSelected = widget.currentIndex == item.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // الزر الدائري البارز
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(isSelected ? 1.1 : 1.0),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الأيقونة
                    Icon(
                      item.icon,
                      color: Colors.white,
                      size: 30,
                    ),
                    // تأثير التموج (Ripple)
                    if (isSelected)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            // النص
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1 : 0.7,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎯 معالجة الضغط
  // ============================================================

  void _handleTap(NavItem item) {
    // التحقق من المصادقة للعناصر المحمية
    if (item.isProtected && !widget.isLoggedIn) {
      widget.onAuthRequired();
      return;
    }

    // إضافة تأثير اهتزاز عند الضغط
    HapticFeedback.lightImpact();

    // تغيير التبويب
    widget.onTap(item.index);
  }
}

// ============================================================
// 📦 نموذج عنصر التنقل
// ============================================================

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
