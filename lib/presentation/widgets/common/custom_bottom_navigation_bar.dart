import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final ScrollController? scrollController;
  final GlobalScrollManager? scrollManager;
  final bool isLoggedIn;
  final VoidCallback onAuthRequired;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.scrollController,
    this.scrollManager,
    required this.isLoggedIn,
    required this.onAuthRequired,
  });

  static const double _barHeight = 48.75;
  static const double _itemHeight = 48.75;
  static const double _chatSize = 50.7; // 39 * 1.30
  static const double _chatIconSize = 26.0; // 20 * 1.30

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = AppStrings.of(context);
    final navItems = [
      NavItem(index: 0, icon: Icons.home_rounded, label: strings.home),
      NavItem(index: 1, icon: Icons.person_search_rounded, label: strings.doctors),
      NavItem(index: 2, icon: Icons.local_pharmacy_rounded, label: strings.pharmacy),
      NavItem(index: 3, icon: Icons.chat_rounded, label: strings.chat, isProtected: true, isSpecial: true),
      NavItem(index: 4, icon: Icons.science_rounded, label: strings.laboratories, isProtected: true),
      NavItem(index: 5, icon: Icons.folder_rounded, label: strings.myHealth, isProtected: true),
      NavItem(index: 6, icon: Icons.grid_view_rounded, label: strings.more),
    ];
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: Container(
        height: _barHeight + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 4),
        clipBehavior: Clip.none,
        decoration: BoxDecoration(color: backgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))]),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: navItems.map((item) => item.isSpecial ? _buildSpecialChatButton(item, isDark) : _buildNavItem(item, isDark)).toList()),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final color = isSelected ? AppColors.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500);
    return Expanded(child: GestureDetector(onTap: () => _handleTap(item), behavior: HitTestBehavior.opaque, child: SizedBox(height: _itemHeight, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(item.icon, color: color, size: 19), const SizedBox(height: 2), _buildItemLabel(item, color, isSelected), const SizedBox(height: 1), AnimatedContainer(duration: const Duration(milliseconds: 200), width: isSelected ? 10 : 0, height: 2, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))]))));
  }


  Widget _buildItemLabel(NavItem item, Color color, bool isSelected) {
    final style = TextStyle(
      fontSize: 8,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      color: color,
    );
    if (item.index != 5) {
      return Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? const <String, dynamic>{};
        final role = (data['role'] ?? data['type'] ?? data['accountType'] ?? data['userType'] ?? '')
            .toString().trim().toLowerCase();
        var label = item.label;
        final strings = AppStrings.of(context);
        if (role == 'doctor' || role == 'dentist' || role == 'ophthalmology') {
          label = strings.translate('ملف الطبيب');
        } else if (role == 'pharmacist' || role == 'pharmacy' || role == 'pharmacyowner') {
          label = strings.translate('ملف الصيدلي');
        } else if (role == 'lab') {
          label = strings.translate('ملف المختبر');
        } else if (['hospital', 'clinic', 'medical_center', 'dental', 'eye_clinic'].contains(role)) {
          label = strings.translate('ملف المنشأة');
        } else if (role == 'paramedic') {
          label = strings.translate('ملف المسعف');
        } else if (role == 'admin' || role == 'superadmin') {
          label = strings.translate('لوحة الإدارة');
        } else if (role.isNotEmpty && role != 'user' && role != 'patient') {
          label = strings.translate('ملفي المهني');
        }
        return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
      },
    );
  }

  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Expanded(child: GestureDetector(onTap: () => _handleTap(item), behavior: HitTestBehavior.opaque, child: SizedBox(height: _itemHeight, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [OverflowBox(minWidth: 0, maxWidth: double.infinity, minHeight: 0, maxHeight: 100, alignment: Alignment.topCenter, child: Transform.translate(offset: const Offset(0, -18), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: _chatSize, height: _chatSize, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 9, spreadRadius: 1.8, offset: const Offset(0, 3))]), child: const Icon(Icons.chat_rounded, color: Colors.white, size: _chatIconSize)), const SizedBox(height: 1), Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, color: isSelected ? AppColors.primary : inactiveColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500))])))]))));
  }

  void _handleTap(NavItem item) {
    if (item.isProtected && !isLoggedIn) {
      onAuthRequired();
      return;
    }
    onTap(item.index);
    scrollManager?.show();
  }
}

class NavItem {
  final int index;
  final IconData icon;
  final String label;
  final bool isProtected;
  final bool isSpecial;

  const NavItem({required this.index, required this.icon, required this.label, this.isProtected = false, this.isSpecial = false});
}
