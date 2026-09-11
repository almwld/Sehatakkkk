import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/widgets/common/svg_icon.dart';

class HomeAppBar extends StatelessWidget {
  final bool isLoggedIn; final String userName; final VoidCallback onProfileTap; final int notificationCount, cartItemCount;
  const HomeAppBar({super.key, required this.isLoggedIn, required this.userName, required this.onProfileTap, this.notificationCount = 0, this.cartItemCount = 0});
  @override Widget build(BuildContext context) => Container(color: AppColors.primary, child: SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [GestureDetector(onTap: onProfileTap, child: CircleAvatar(radius: 28, backgroundImage: isLoggedIn ? const NetworkImage(ImageKit.profileAvatar) : null, child: !isLoggedIn ? const Icon(Icons.person) : null)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isLoggedIn ? 'مرحباً، $userName 👋' : 'منصة صحتك', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const Text('كيف تشعر اليوم؟', style: TextStyle(color: Colors.white70))])), _icon(context, ImageKit.notificationIcon, notificationCount, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))), _icon(context, ImageKit.cartIcon, cartItemCount, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())))]))));
  Widget _icon(BuildContext context, String path, int count, VoidCallback onTap) => Stack(children: [IconButton(onPressed: onTap, icon: SvgIcon(assetPath: path, size: 24, color: Colors.white)), if (count > 0) Positioned(right: 4, top: 4, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9))))]);
}
