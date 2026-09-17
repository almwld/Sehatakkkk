import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';
import 'package:sehatak/core/services/status_service.dart';
import 'package:sehatak/core/models/status_model.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';
import 'package:sehatak/presentation/screens/edit_profile/edit_profile_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/favorites/favorite_doctors_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class PatientProfile extends StatefulWidget {
  final String? userId;
  const PatientProfile({super.key, this.userId});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _statusService = StatusService();
  Map<String, dynamic> _userData = {};
  bool _loading = true;

  String get _profileId => widget.userId?.trim().isNotEmpty == true
      ? widget.userId!.trim()
      : (_auth.currentUser?.uid ?? '');

  bool get _isOwnProfile => _profileId.isNotEmpty && _profileId == _auth.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _profileId;
    if (uid.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final snap = await _firestore.collection('users').doc(uid).get();
      final data = snap.data() ?? <String, dynamic>{};
      final user = _auth.currentUser;
      if (data.isEmpty && _isOwnProfile && user != null) {
        data.addAll({'name': user.displayName ?? 'مستخدم', 'email': user.email ?? '', 'photoUrl': user.photoURL});
      }
      if (mounted) setState(() { _userData = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _value(String key, [String fallback = '']) {
    final value = _userData[key];
    return value == null || value.toString().trim().isEmpty ? fallback : value.toString();
  }

  int? _count(String key) {
    final value = _userData[key];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _edit() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
    if (mounted) await _loadUser();
  }

  void _favoriteDoctors() => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteDoctorsScreen()));
  void _settings() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final name = _value('name', _auth.currentUser?.displayName ?? 'مستخدم');
    final email = _value('email', _auth.currentUser?.email ?? '');
    final photo = _value('photoUrl', _auth.currentUser?.photoURL ?? '');

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ملفي الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isOwnProfile) IconButton(icon: LocalAssetIcon(AppImages.uiEditButton, color: Colors.white, size: 22), onPressed: _edit),
          if (_isOwnProfile) IconButton(icon: LocalAssetIcon(AppImages.uiSettingsGear, color: Colors.white, size: 22), onPressed: _settings),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadUser,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                children: [
                  _header(name, email, photo, dark),
                  const SizedBox(height: 14),
                  _stats(dark),
                  const SizedBox(height: 16),
                  _stories(name, photo, dark),
                  const SizedBox(height: 16),
                  _posts(dark),
                  const SizedBox(height: 16),
                  _accountSections(dark),
                ],
              ),
            ),
    );
  }

  Widget _header(String name, String email, String photo, bool dark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        _storyAvatar(name, photo, 48),
        const SizedBox(height: 10),
        Text(name, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black87)),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(email, style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.grey[600])),
        ],
        if (_value('bio').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(_value('bio'), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.4, color: dark ? Colors.white70 : Colors.black54)),
        ],
      ]),
    );
  }

  Widget _storyAvatar(String name, String photo, double radius) {
    return StreamBuilder<UserStatusModel?>(
      stream: _profileId.isEmpty ? Stream.value(null) : _statusService.streamUserStatus(_profileId),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final hasStatus = status?.isValid == true && status!.stories.isNotEmpty;
        final avatar = Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: hasStatus ? AppColors.primary : Colors.transparent, width: 3)),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primary.withOpacity(.10),
            backgroundImage: photo.isEmpty ? null : NetworkImage(photo),
            child: photo.isEmpty ? Text(name.isEmpty ? 'م' : name.characters.first, style: TextStyle(fontSize: radius * .7, color: AppColors.primary, fontWeight: FontWeight.w900)) : null,
          ),
        );
        return GestureDetector(
          onTap: hasStatus ? () {
            _statusService.markViewed(status!);
            Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerScreen(status: status)));
          } : null,
          child: avatar,
        );
      },
    );
  }

  Widget _stats(bool dark) {
    return Row(children: [
      Expanded(child: _stat('المنشورات', _count('postsCount'), dark)),
      const SizedBox(width: 8),
      Expanded(child: _stat('المتابعون', _count('followersCount'), dark)),
      const SizedBox(width: 8),
      Expanded(child: _stat('يتابع', _count('followingCount'), dark)),
    ]);
  }

  Widget _stat(String label, int? value, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 5),
      decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value?.toString() ?? '--', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : Colors.grey[600])),
      ]),
    );
  }

  Widget _stories(String name, String photo, bool dark) {
    return _card(dark, 'الحالة اليومية', AppImages.uiUserProfile, StreamBuilder<UserStatusModel?>(
      stream: _profileId.isEmpty ? Stream.value(null) : _statusService.streamUserStatus(_profileId),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final hasStatus = status?.isValid == true && status!.stories.isNotEmpty;
        return Row(children: [
          GestureDetector(
            onTap: hasStatus ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerScreen(status: status!))) : null,
            child: Column(children: [
              _storyAvatar(name, photo, 28),
              const SizedBox(height: 5),
              Text(hasStatus ? 'عرض الحالة' : 'لا توجد حالة', style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : Colors.grey[700])),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(hasStatus ? 'الحالة اليومية متاحة من دائرة صورة المستخدم.' : 'عند نشر حالة ستظهر هنا ويمكن فتحها من دائرة صورة المستخدم.', style: TextStyle(fontSize: 12, height: 1.45, color: dark ? Colors.white70 : Colors.grey[700]))),
        ]);
      },
    ));
  }

  Widget _posts(bool dark) {
    if (_profileId.isEmpty) return _card(dark, 'منشورات المجتمع', AppImages.uiUserProfile, const Text('سجّل الدخول لعرض منشورات الحساب.'));
    return _card(dark, 'منشورات المجتمع', AppImages.uiUserProfile, StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('community_posts').where('userId', isEqualTo: _profileId).where('isPublished', isEqualTo: true).limit(20).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('تعذر تحميل منشورات المجتمع.');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        final docs = [...snapshot.data!.docs];
        docs.sort((a, b) {
          final av = a.data()['createdAt'];
          final bv = b.data()['createdAt'];
          final at = av is Timestamp ? av.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
          final bt = bv is Timestamp ? bv.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });
        if (docs.isEmpty) return const Text('لا توجد منشورات منشورة لهذا الحساب حالياً.');
        return Column(children: docs.map((doc) => _post(doc, dark)).toList());
      },
    ));
  }

  Widget _post(QueryDocumentSnapshot<Map<String, dynamic>> doc, bool dark) {
    final data = doc.data();
    final title = (data['title'] ?? '').toString();
    final content = (data['content'] ?? '').toString();
    var image = (data['imageUrl'] ?? '').toString();
    final images = data['images'];
    if (image.isEmpty && images is List && images.isNotEmpty) image = images.first.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: dark ? const Color(0xFF102A2A) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (title.isNotEmpty) Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black87)),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(content, maxLines: 5, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.45, color: dark ? Colors.white70 : Colors.black87)),
        ],
        if (image.isNotEmpty) ...[
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(12), child: AppImage(imageUrl: image, height: 180, width: double.infinity, fit: BoxFit.cover)),
        ],
      ]),
    );
  }

  Widget _accountSections(bool dark) {
    return _card(dark, 'حساب المستخدم', AppImages.uiUserProfile, Column(children: [
      _tile('assets/images/ui/favorites.png', 'الأطباء المفضلون', 'الوصول إلى الأطباء المضافين للمفضلة', _favoriteDoctors, dark),
      _tile(AppImages.uiSettingsGear, 'التفضيلات', 'إدارة تفضيلات الحساب والخدمات', _settings, dark),
      _tile(AppImages.uiUserProfile, 'المتابعات', 'الحسابات التي يتابعها المستخدم', null, dark),
      if (_isOwnProfile) _tile(AppImages.uiEditButton, 'تعديل الملف', 'تحديث تفاصيل الحساب', _edit, dark),
    ]));
  }

  Widget _card(bool dark, String title, String icon, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [LocalAssetIcon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black87))]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _tile(String icon, String title, String subtitle, VoidCallback? onTap, bool dark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: LocalAssetIcon(icon, color: AppColors.primary, size: 21)),
      title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : Colors.grey[600])),
      trailing: onTap == null ? null : LocalAssetIcon(AppImages.uiEditButton, color: AppColors.primary, size: 14),
      onTap: onTap,
    );
  }
}
