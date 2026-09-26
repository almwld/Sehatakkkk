import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';

class ProductRequestScreen extends StatefulWidget {
  final String pharmacyId;
  final String pharmacyName;
  const ProductRequestScreen({super.key, required this.pharmacyId, required this.pharmacyName});
  @override State<ProductRequestScreen> createState() => _ProductRequestScreenState();
}
class _ProductRequestScreenState extends State<ProductRequestScreen> {
  final _note = TextEditingController(); File? _image; String? _fileName; bool _sending = false;
  @override void dispose() { _note.dispose(); super.dispose(); }
  Future<void> _pick(ImageSource source) async { final p = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1600); if (p != null && mounted) setState(() { _image = File(p.path); _fileName = p.name; }); }
  Future<void> _pickFile() async { final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','jpg','jpeg','png']); final f = r?.files.single; if (f?.path != null && mounted) setState(() { _image = File(f!.path!); _fileName = f.name; }); }
  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجّل الدخول لإرسال طلب الصنف'))); return; }
    if (_image == null && _note.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف صورة للصنف أو اكتب وصفه'))); return; }
    setState(() => _sending = true);
    try {
      String? imageUrl; if (_image != null) { final up = await NextcloudService().uploadFile(file: _image!, path: 'sehatak/prescriptions/'+user.uid, fileName: DateTime.now().millisecondsSinceEpoch.toString()+'_'+(_fileName ?? _image!.path.split('/').last)); if (!up.success || up.url == null) throw StateError(up.error ?? 'فشل رفع الوصفة'); imageUrl = up.url; }
      await FirebaseFirestore.instance.collection('prescriptions').add({'patientId': user.uid, 'userId': user.uid, 'pharmacyId': widget.pharmacyId, 'pharmacyName': widget.pharmacyName, 'imageUrl': imageUrl, 'note': _note.text.trim(), 'status': 'pending', 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الصنف للصيدلية'), backgroundColor: AppColors.primary)); Navigator.pop(context);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إرسال الطلب: $e'))); } finally { if (mounted) setState(() => _sending = false); }
  }
  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(appBar: AppBar(title: const Text('طلب صنف مشابه'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('أرسل وصفة أو صورة الدواء إلى ${widget.pharmacyName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8), Text('يمكنك تصوير الوصفة، اختيار صورة، أو رفع ملف PDF.', style: TextStyle(color: dark ? Colors.white70 : Colors.grey)),
        const SizedBox(height: 16),
        if (_image != null) ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_image!, height: 260, fit: BoxFit.contain)) else Container(height: 220, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.06), borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('لم تتم إضافة صورة بعد'))),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _sending ? null : () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('تصوير الوصفة'))), const SizedBox(width: 6), Expanded(child: OutlinedButton.icon(onPressed: _sending ? null : () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('المعرض'))), const SizedBox(width: 6), Expanded(child: OutlinedButton.icon(onPressed: _sending ? null : _pickFile, icon: const Icon(Icons.picture_as_pdf), label: const Text('PDF')))]),
        const SizedBox(height: 16), TextField(controller: _note, maxLines: 4, decoration: const InputDecoration(labelText: 'ملاحظة أو اسم الصنف', hintText: 'مثال: أريد صنفاً مطابقاً أو بديلاً بنفس المادة الفعالة', border: OutlineInputBorder())),
        const SizedBox(height: 20), SizedBox(height: 52, child: ElevatedButton(onPressed: _sending ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: _sending ? const CircularProgressIndicator(color: Colors.white) : const Text('إرسال الطلب')))
      ]));
  }
}