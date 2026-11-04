import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class ShareRecordScreen extends StatefulWidget {
  final String recordId;
  final String recordTitle;
  const ShareRecordScreen({super.key, required this.recordId, required this.recordTitle});
  @override State<ShareRecordScreen> createState() => _ShareRecordScreenState();
}
class _ShareRecordScreenState extends State<ShareRecordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String _t(String value) => AppStrings.of(context).translate(value);

  Future<void> _shareWithEmail() async {
    if (_emailCtrl.text.isEmpty) { ToastService.showError(context, _t('يرجى إدخال البريد الإلكتروني')); return; }
    setState(() => _isLoading = true);
    try {
      final userQuery = await _firestore.collection('users').where('email', isEqualTo: _emailCtrl.text.trim()).get();
      if (userQuery.docs.isEmpty) { ToastService.showError(context, _t('المستخدم غير موجود')); return; }
      final currentUser = _auth.currentUser;
      if (currentUser == null) { ToastService.showError(context, _t('يرجى تسجيل الدخول')); return; }
      await _firestore.collection('shared_records').add({'recordId': widget.recordId, 'recordTitle': widget.recordTitle, 'sharedBy': currentUser.uid, 'sharedWith': userQuery.docs.first.id, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp()});
      if (mounted) { ToastService.showSuccess(context, _t('تم مشاركة الملف بنجاح')); Navigator.pop(context); }
    } catch (e) { if (mounted) ToastService.showError(context, '${_t('فشل المشاركة:')} $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _shareLink() => Share.share(
    '${_t('تم مشاركة ملف طبي معك من منصة صحتك')}\n${_t('الملف:')} ${widget.recordTitle}\n${_t('يمكنك عرضه عبر التطبيق.')}',
    subject: _t('ملف طبي من صحتك'),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: Text(_t('مشاركة الملف'), style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_t('مشاركة عبر البريد الإلكتروني'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(_t('أدخل البريد الإلكتروني للمستخدم الذي تريد مشاركة الملف معه'), style: const TextStyle(color: AppColors.grey)),
      const SizedBox(height: 12),
      TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textAlign: TextAlign.right, decoration: InputDecoration(labelText: _t('البريد الإلكتروني'), prefixIcon: const Icon(Icons.email, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: IconButton(icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send), onPressed: _isLoading ? null : _shareWithEmail))),
      const SizedBox(height: 24), const Divider(), const SizedBox(height: 24),
      Text(_t('مشاركة عبر الرابط'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text(_t('قم بإنشاء رابط للملف لمشاركته مع أي شخص'), style: const TextStyle(color: AppColors.grey)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _shareLink, icon: const Icon(Icons.link), label: Text(_t('إنشاء رابط مشاركة')), style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)))),
      const SizedBox(height: 24), const Divider(), const SizedBox(height: 24),
      Text(_t('مشاركة عبر وسائل التواصل'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_socialButton(Icons.chat, Colors.green, _shareLink), _socialButton(Icons.facebook, Colors.blue, _shareLink), _socialButton(Icons.send, Colors.blue, _shareLink), _socialButton(Icons.email, Colors.red, _shareLink)]),
    ])),
  );

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.3))), child: Icon(icon, color: color, size: 24)));

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }
}
