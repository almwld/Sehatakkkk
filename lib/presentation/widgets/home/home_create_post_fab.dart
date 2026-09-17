import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/create_post_sheet.dart';

/// Floating community action shown on the Home tab.
/// It is visible only at the start/end of the feed and hidden while scrolling.
class HomeCreatePostFab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeCreatePostFab({super.key, this.scrollController});

  @override
  State<HomeCreatePostFab> createState() => _HomeCreatePostFabState();
}

class _HomeCreatePostFabState extends State<HomeCreatePostFab>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _tapController;
  late final Animation<double> _pulse;
  bool _pressed = false;
  bool _visible = true;

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
      duration: const Duration(milliseconds: 320),
    );

    widget.scrollController?.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibility());
  }

  void _handleScroll() => _updateVisibility();

  void _updateVisibility() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    final atStart = position.pixels <= position.minScrollExtent + 1;
    final atEnd = position.pixels >= position.maxScrollExtent - 1;
    final nextVisible = atStart || atEnd;
    if (nextVisible != _visible && mounted) {
      setState(() => _visible = nextVisible);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_handleScroll);
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _openCreatePost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showInfo('سجل الدخول أولاً لإضافة منشور');
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
      ToastService.showInfo('إضافة المنشورات متاحة للأطباء الموثقين فقط');
      return;
    }

    await CreatePostSheet.show(context);
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
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulse, _tapController]),
          builder: (context, child) {
            final scale = _pulse.value * (1 - (_tapController.value * .08));
            return Transform.scale(scale: scale, child: child);
          },
          child: AnimatedRotation(
            turns: _tapController.value / 2,
            duration: const Duration(milliseconds: 320),
            child: FloatingActionButton(
              heroTag: 'home_create_post_fab',
              onPressed: _pressed ? null : _handleTap,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
