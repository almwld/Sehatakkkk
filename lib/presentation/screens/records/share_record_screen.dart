import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ShareRecordScreen extends StatefulWidget {
  final String recordId;
  final String recordTitle;

  const ShareRecordScreen({super.key, required this.recordId, required this.recordTitle});

  @override
  State<ShareRecordScreen> createState() => _ShareRecordScreenState();
}

class _ShareRecordScreenState extends State<ShareRecordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _shareWithEmail() async {
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد الإلكتروني'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ✅ البحث عن المستخدم
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailCtrl.text.trim())
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('المستخدم غير موجود'), backgroundColor: AppColors.error),
        );
        setState(() => _isLoading = false);
        return;
      }

      final targetUserId = userQuery.docs.first.id;
      
      // ✅ مشاركة الملف
      await _firestore.collection('shared_records').add({
        'recordId': widget.recordId,
        'recordTitle': widget.recordTitle,
        'sharedBy': _auth.currentUser!.uid,
        'sharedWith': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم مشاركة الملف بنجاح'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل المشاركة: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shareLink() {
    Share.share(
      '📄 تم مشاركة ملف طبي معك من منصة صحتك\n'
      'الملف: ${widget.recordTitle}\n'
      'يمكنك عرضه عبر التطبيق.',
      subject: 'ملف طبي من صحتك',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مشاركة الملف', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مشاركة عبر البريد الإلكتروني', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('أدخل البريد الإلكتروني للمستخدم الذي تريد مشاركة الملف معه', style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _shareWithEmail,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text('مشاركة عبر الرابط', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('قم بإنشاء رابط للملف لمشاركته مع أي شخص', style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareLink,
                icon: const Icon(Icons.link),
                label: const Text('إنشاء رابط مشاركة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text('مشاركة عبر وسائل التواصل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _socialButton(Icons.whatsapp, Colors.green, () {}),
                _socialButton(Icons.facebook, Colors.blue, () {}),
                _socialButton(Icons.telegram, Colors.blue, () {}),
                _socialButton(Icons.email, Colors.red, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
