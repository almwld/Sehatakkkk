import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/create_post_sheet.dart';

/// Floating community action shown on the Home tab.
/// Uses the same permission rules as CommunityScreen and opens the real post sheet.
class HomeCreatePostFab extends StatefulWidget {
  const HomeCreatePostFab({super.key});

  @override
  State<HomeCreatePostFab> createState() => _HomeCreatePostFabState();
}

class _HomeCreatePostFabState extends State<HomeCreatePostFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: .96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCreatePost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('سجل الدخول أولاً لإضافة منشور');
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data() ?? <String, dynamic>{};
    final verified = data['role']?.toString() == 'doctor' &&
        data['isVerified'] == true;

    if (!mounted) return;
    if (!verified) {
      _message('إضافة المنشورات متاحة للأطباء الموثقين فقط');
      return;
    }

    await CreatePostSheet.show(context);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: FloatingActionButton.extended(
        heroTag: 'home_create_post_fab',
        onPressed: _openCreatePost,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded, size: 27),
        label: const Text(
          'إضافة منشور',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
