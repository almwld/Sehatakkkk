import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const _DoctorDashboard();
}

class _DoctorDashboard extends StatefulWidget {
  const _DoctorDashboard();
  @override
  State<_DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<_DoctorDashboard> {
  final ImagePicker _picker = ImagePicker();
  final NextcloudService _nextcloud = NextcloudService();
  String _avatarUrl = '';
  String _doctorName = 'الطبيب';
  String _doctorEmail = '';
  bool _uploadingAvatar = false;

  @override
  void initState() { super.initState(); _loadDoctorProfile(); }

  Future<void> _loadDoctorProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _doctorName = (data['name'] ?? user.displayName ?? 'الطبيب').toString();
        _doctorEmail = (data['email'] ?? user.email ?? '').toString();
        _avatarUrl = _firstNonEmpty([data['avatar'], data['photoUrl'], user.photoURL]);
      });
    } catch (e) { debugPrint('Doctor profile load failed: $e'); }
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_uploadingAvatar) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ToastService.showError('❌ يرجى تسجيل الدخول أولاً'); return; }
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (image == null) return;
      setState(() => _uploadingAvatar = true);
      ToastService.showInfo('⏳ جاري رفع صورة الحساب إلى Nextcloud...');
      await _nextcloud.loadConfig();
      final result = await _nextcloud.uploadFile(file: File(image.path), path: 'profiles/${user.uid}', fileName: 'avatar.jpg', createShare: true);
      final url = (result.url ?? '').trim();
      if (!result.success || url.isEmpty) throw StateError(result.error ?? 'تعذر الحصول على رابط الصورة');
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'avatar': url, 'photoUrl': url, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _avatarUrl = url);
      ToastService.showSuccess('✅ تم تحديث صورة الطبيب بنجاح');
    } catch (e) {
      debugPrint('Doctor avatar upload failed: $e');
      ToastService.showError('❌ فشل رفع صورة الحساب: $e');
    } finally { if (mounted) setState(() => _uploadingAvatar = false); }
  }

  Widget _doctorHeader(bool dark) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      GestureDetector(onTap: _pickAndUploadAvatar, child: Stack(children: [
        Container(width: 68, height: 68, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: ClipOval(child: _avatarUrl.isNotEmpty ? CachedNetworkImage(imageUrl: _avatarUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => _initialAvatar()) : _initialAvatar())),
        Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: _uploadingAvatar ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.camera_alt, size: 15, color: AppColors.primary))),
      ])),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('لوحة الطبيب', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(_doctorName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        if (_doctorEmail.isNotEmpty) Text(_doctorEmail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 5),
        const Text('اضغط على الصورة لتحديث صورة الحساب', style: TextStyle(color: Colors.white70, fontSize: 10)),
      ])),
    ]),
  );

  Widget _initialAvatar() => Container(color: Colors.white, alignment: Alignment.center, child: Text(_doctorName.isNotEmpty ? _doctorName.characters.first : 'ط', style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w900)));

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('لوحة الطبيب'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _doctorHeader(dark), const SizedBox(height: 14), _statGrid(uid, dark), const SizedBox(height: 14),
        _action(context, 'assets/images/services/calendar_booking.png', 'المواعيد', 'متابعة المواعيد والحجوزات', AppRouter.consultation),
        _action(context, 'assets/images/services/medical_community.png', 'مجتمع صحتك', 'عرض المنشورات والتعليقات والمشاركات', AppRouter.community),
        _action(context, 'assets/images/services/medical_records.png', 'السجلات الطبية', 'الوصول المصرح إلى بيانات المرضى', AppRouter.appointments),
        _action(context, 'assets/images/services/wallet.png', 'المحفظة', 'المعاملات والأرصدة', AppRouter.wallet),
      ]),
    );
  }

  Widget _statGrid(String? uid, bool dark) => FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
    future: uid == null ? null : FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: uid).get(),
    builder: (_, snap) {
      final count = snap.data?.docs.length ?? 0;
      return Row(children: [Expanded(child: _stat('المواعيد', '$count', 'assets/images/services/calendar_booking.png', dark)), const SizedBox(width: 10), Expanded(child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(future: uid == null ? null : FirebaseFirestore.instance.collection('community_posts').where('userId', isEqualTo: uid).get(), builder: (_, posts) => _stat('المنشورات', '${posts.data?.docs.length ?? 0}', 'assets/images/services/medical_community.png', dark)))]);
    },
  );

  Widget _stat(String title, String value, String asset, bool dark) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [LocalAssetIcon(asset, size: 36), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : Colors.grey[600])), Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF173131)))]))]));

  Widget _action(BuildContext context, String asset, String title, String subtitle, String route) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(onTap: () => context.push(route), borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [LocalAssetIcon(asset, size: 42), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[600]))]))]))),
  );
}
