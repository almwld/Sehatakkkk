import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_kit_service.dart';

class ProductRequestScreen extends StatefulWidget {
  final String pharmacyId;
  final String pharmacyName;
  const ProductRequestScreen({super.key, required this.pharmacyId, required this.pharmacyName});
  @override State<ProductRequestScreen> createState() => _ProductRequestScreenState();
}
class _ProductRequestScreenState extends State<ProductRequestScreen> {
  final _note = TextEditingController(); File? _image; bool _sending = false;
  @override void dispose() { _note.dispose(); super.dispose(); }
  Future<void> _pick(ImageSource source) async { final p = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1600); if (p != null && mounted) setState(() => _image = File(p.path)); }
  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجّل الدخول لإرسال طلب الصنف'))); return; }
    if (_image == null && _note.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف صورة للصنف أو اكتب وصفه'))); return; }
    setState(() => _sending = true);
    try {
      String? imageUrl; if (_image != null) imageUrl = await ImageKitService().uploadImage(file: _image!, folder: '/images/product_requests');
      await FirebaseFirestore.instance.collection('pharmacy_product_requests').add({'patientId': user.uid, 'pharmacyId': widget.pharmacyId, 'pharmacyName': widget.pharmacyName, 'imageUrl': imageUrl, 'note': _note.text.trim(), 'status': 'pending', 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الصنف للصيدلية'), backgroundColor: AppColors.primary)); Navigator.pop(context);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إرسال الطلب: $e'))); } finally { if (mounted) setState(() => _sending = false); }
  }
  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(appBar: AppBar(title: const Text('طلب صنف مشابه'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('أرسل صورة الصنف الذي تبحث عنه إلى ${widget.pharmacyName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8), Text('يمكنك تصوير العبوة الآن أو اختيار صورة موجودة في الهاتف.', style: TextStyle(color: dark ? Colors.white70 : Colors.grey)),
        const SizedBox(height: 16),
        if (_image != null) ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_image!, height: 260, fit: BoxFit.contain)) else Container(height: 220, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.06), borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('لم تتم إضافة صورة بعد'))),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _sending ? null : () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('تصوير الصنف'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: _sending ? null : () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('رفع صورة')))]),
        const SizedBox(height: 16), TextField(controller: _note, maxLines: 4, decoration: const InputDecoration(labelText: 'ملاحظة أو اسم الصنف', hintText: 'مثال: أريد صنفاً مطابقاً أو بديلاً بنفس المادة الفعالة', border: OutlineInputBorder())),
        const SizedBox(height: 20), SizedBox(height: 52, child: ElevatedButton(onPressed: _sending ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: _sending ? const CircularProgressIndicator(color: Colors.white) : const Text('إرسال الطلب')))
      ]));
  }
}