import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/community/community_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/create_post_sheet.dart';

/// زر إنشاء منشور المجتمع في الواجهة الرئيسية.
/// يظهر للأطباء الموثقين فقط، ويبقى ظاهرًا عند بداية الصفحة ونهايتها،
/// ويختفي تدريجيًا أثناء التمرير بينهما.
class DoctorCommunityFab extends StatefulWidget {
  final ScrollController scrollController;
  final bool dark;
  final VoidCallback? onPostPublished;

  const DoctorCommunityFab({
    super.key,
    required this.scrollController,
    required this.dark,
    this.onPostPublished,
  });

  @override
  State<DoctorCommunityFab> createState() => _DoctorCommunityFabState();
}

class _DoctorCommunityFabState extends State<DoctorCommunityFab> {
  bool _doctor = false;
  bool _loadingRole = true;
  bool _openingComposer = false;
  bool _rotated = false;
  double _visibility = 1.0;

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

    const edgeDistance = 180.0;
    final pixels = position.pixels;
    final max = position.maxScrollExtent;

    double next;
    if (max <= edgeDistance * 2) {
      next = 1.0;
    } else if (pixels <= edgeDistance) {
      next = 1.0;
    } else if (pixels >= max - edgeDistance) {
      next = 1.0;
    } else {
      // اختفاء تدريجي بعد مغادرة البداية، ثم ظهور تدريجي قبل نهاية الصفحة.
      final distanceFromStart = pixels - edgeDistance;
      final distanceToEnd = max - edgeDistance - pixels;
      final fadeInStart = (distanceFromStart / edgeDistance).clamp(0.0, 1.0);
      final fadeInEnd = (distanceToEnd / edgeDistance).clamp(0.0, 1.0);
      next = fadeInStart < fadeInEnd ? fadeInStart : fadeInEnd;
    }

    if ((next - _visibility).abs() > 0.01 && mounted) {
      setState(() => _visibility = next);
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
      if (mounted) widget.onPostPublished?.call();
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

    final visible = _visibility > 0.01;
    return IgnorePointer(
      ignoring: !visible || _openingComposer,
      child: AnimatedOpacity(
        opacity: _visibility,
        duration: const Duration(milliseconds: 80),
        child: AnimatedScale(
          scale: 0.82 + (_visibility * 0.18),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
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
                      color: Colors.black.withOpacity(widget.dark ? .38 : .18),
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
    );
  }
}
