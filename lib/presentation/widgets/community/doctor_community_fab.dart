import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/community/community_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/create_post_sheet.dart';

/// زر إنشاء منشور المجتمع في الواجهة الرئيسية.
/// يظهر للأطباء الموثقين فقط، ويختفي أثناء التمرير داخل الصفحة
/// ويظهر عند بداية الصفحة أو نهايتها.
class DoctorCommunityFab extends StatefulWidget {
  final ScrollController scrollController;
  final bool dark;

  const DoctorCommunityFab({
    super.key,
    required this.scrollController,
    required this.dark,
  });

  @override
  State<DoctorCommunityFab> createState() => _DoctorCommunityFabState();
}

class _DoctorCommunityFabState extends State<DoctorCommunityFab> {
  bool _visible = true;
  bool _doctor = false;
  bool _loadingRole = true;
  bool _openingComposer = false;
  bool _rotated = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _loadRole();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingRole = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = snapshot.data() ?? <String, dynamic>{};
      final isDoctor =
          data['role']?.toString() == 'doctor' && data['isVerified'] == true;

      if (mounted) {
        setState(() {
          _doctor = isDoctor;
          _loadingRole = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRole = false);
    }
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position;
    if (!position.hasContentDimensions) return;

    const edgeTolerance = 8.0;
    final atStart =
        position.pixels <= position.minScrollExtent + edgeTolerance;
    final atEnd =
        position.pixels >= position.maxScrollExtent - edgeTolerance;

    // مخفي أثناء التمرير في منتصف الصفحة، ويظهر فقط عند البداية أو النهاية.
    final nextVisible = atStart || atEnd;
    if (nextVisible != _visible && mounted) {
      setState(() => _visible = nextVisible);
    }
  }

  Future<void> _openComposer() async {
    if (!_doctor || _openingComposer || !mounted) return;

    setState(() {
      _openingComposer = true;
      _rotated = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider(
          create: (_) => CommunityBloc(),
          child: const CreatePostSheet(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingComposer = false;
          _rotated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole || !_doctor) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !_visible || _openingComposer,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 1.25),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: _visible ? 1 : 0.82,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openComposer,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          widget.dark ? .38 : .18,
                        ),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AnimatedRotation(
                    turns: _rotated ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOutCubic,
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
