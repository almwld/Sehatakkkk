import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _tapController;
  late final Animation<double> _pulse;
  late final Animation<double> _tapScale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: .96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _tapScale = Tween<double>(begin: 1, end: .92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
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

  Future<void> _handleTap() async {
    if (_pressed) return;
    setState(() => _pressed = true);
    await _tapController.forward();
    await _tapController.reverse();
    if (!mounted) return;
    setState(() => _pressed = false);
    await _openCreatePost();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _tapScale]),
      builder: (context, child) {
        final scale = _pulse.value * _tapScale.value;
        return Transform.scale(scale: scale, child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_pressed ? .12 : .28),
              blurRadius: _pressed ? 8 : 18,
              spreadRadius: _pressed ? 0 : 1,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: 'home_create_post_fab',
          onPressed: _pressed ? null : _handleTap,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 27),
          label: const Text(
            'إضافة منشور',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
