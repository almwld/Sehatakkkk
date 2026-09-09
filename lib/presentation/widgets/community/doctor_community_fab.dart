import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/community/community_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/create_post_sheet.dart';

/// زر إنشاء منشور المجتمع. يظهر للأطباء الموثقين فقط ويتحرك مع التمرير.
class DoctorCommunityFab extends StatefulWidget {
  final ScrollController scrollController;
  final bool dark;

  const DoctorCommunityFab({super.key, required this.scrollController, required this.dark});

  @override
  State<DoctorCommunityFab> createState() => _DoctorCommunityFabState();
}

class _DoctorCommunityFabState extends State<DoctorCommunityFab> {
  bool _visible = true;
  bool _doctor = false;
  bool _loadingRole = true;
  double _lastPixels = 0;

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
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snapshot.data() ?? <String, dynamic>{};
      final isDoctor = data['role']?.toString() == 'doctor' && data['isVerified'] == true;
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
    final pixels = position.pixels;
    final atStart = pixels <= position.minScrollExtent + 4;
    final atEnd = pixels >= position.maxScrollExtent - 4;
    final directionDown = pixels > _lastPixels;
    final directionUp = pixels < _lastPixels;
    _lastPixels = pixels;

    bool next = _visible;
    if (atStart || atEnd) {
      next = true;
    } else if (directionDown) {
      next = false;
    } else if (directionUp) {
      next = true;
    }
    if (next != _visible && mounted) setState(() => _visible = next);
  }

  Future<void> _openComposer() async {
    if (!_doctor) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => CommunityBloc(),
        child: const CreatePostSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole || !_doctor) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 1.6),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openComposer,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(widget.dark ? .35 : .16),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 9),
                    Text('منشور جديد', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
