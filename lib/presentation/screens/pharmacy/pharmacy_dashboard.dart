import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sehatak/core/constants/app_icons.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/toast_service.dart';

class PharmacyDashboard extends StatefulWidget {
  const PharmacyDashboard({super.key});
  @override
  State<PharmacyDashboard> createState() => _PharmacyDashboardState();
}

class _PharmacyDashboardState extends State<PharmacyDashboard> {
  Map<String, dynamic>? _pharmacy;
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;
  File? _productImage;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('يجب تسجيل الدخول');
      QuerySnapshot<Map<String, dynamic>> q = await FirebaseFirestore.instance.collection('pharmacies').where('ownerId', isEqualTo: uid).limit(1).get();
      if (q.docs.isEmpty) q = await FirebaseFirestore.instance.collection('pharmacies').where('userId', isEqualTo: uid).limit(1).get();
      if (q.docs.isEmpty) { _pharmacy = null; _products = []; } else {
        final d = q.docs.first.data(); _pharmacy = {...d, 'id': q.docs.first.id};
        var pq = await FirebaseFirestore.instance.collection('products').where('pharmacyId', isEqualTo: q.docs.first.id).limit(300).get();
        if (pq.docs.isEmpty && q.docs.first.id != uid) pq = await FirebaseFirestore.instance.collection('products').where('pharmacyId', isEqualTo: uid).limit(300).get();
        _products = pq.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      }
      if (mounted) setState(() => _error = null);
    } catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _create() async { if (mounted) ToastService.showError('ملف الصيدلية غير موجود أو لم يتم اعتماده بعد'); }

  Future<void> _pickProductImage() async {
    final source = await showModalBottomSheet<ImageSource>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.camera_alt), title: const Text('تصوير الصنف'), onTap: () => Navigator.pop(context, ImageSource.camera)), ListTile(leading: const Icon(Icons.photo_library), title: const Text('اختيار صورة'), onTap: () => Navigator.pop(context, ImageSource.gallery))])));
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1600);
    if (picked == null) return;
    _productImage = File(picked.path); if (mounted) setState(() {});
    return;
  }

  Future<void> _addProduct() async {
    if (_pharmacy == null || _pharmacy!['status'] != 'approved') return;
    final name = TextEditingController(), category = TextEditingController(text: 'أدوية'), price = TextEditingController(), stock = TextEditingController(text: '0'), drug = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('إضافة منتج'), content: SingleChildScrollView(child: Column(children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم المنتج')), TextField(controller: drug, decoration: const InputDecoration(labelText: 'معرّف الدواء الرسمي (اختياري)')), TextField(controller: category, decoration: const InputDecoration(labelText: 'الفئة')), TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر ر.ي')), TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المخزون')), const SizedBox(height: 10), if (_productImage != null) Image.file(_productImage!, height: 110, width: 110, fit: BoxFit.cover), OutlinedButton.icon(onPressed: _pickProductImage, icon: const Icon(Icons.image), label: const Text('رفع/تصوير صورة الصنف'))])), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ المنتج'))]));
    if (ok != true || name.text.trim().isEmpty || price.text.trim().isEmpty) return;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid; if (uid == null) throw StateError('يجب تسجيل الدخول'); String? imageUrl;
      if (_productImage != null) { final up = await NextcloudService().uploadFile(file: _productImage!, path: 'sehatak/products/'+uid, fileName: DateTime.now().millisecondsSinceEpoch.toString()+'_'+_productImage!.path.split('/').last); if (!up.success || up.url == null) throw StateError(up.error ?? 'فشل رفع صورة المنتج'); imageUrl = up.url; }
      await FirebaseFirestore.instance.collection('products').add({'name':name.text.trim(),'category':category.text.trim(),'price':double.tryParse(price.text)??0,'stock':int.tryParse(stock.text)??0,'drugId':drug.text.trim(),'imageUrl':imageUrl,'pharmacyId':_pharmacy!['id'],'sellerId':uid,'pharmacyName':_pharmacy!['name']??'','approvalStatus':'pending','isPublished':false,'isActive':true,'createdAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp()});
      _productImage=null; await _load(); if(mounted) ToastService.showSuccess('تم حفظ المنتج وإرساله للمراجعة');
    } catch(e){if(mounted) ToastService.showError('فشل: '+e.toString());}
  }

  Future<void> _editOffer(Map<String, dynamic> p) async { final id='${p['id']??''}'; if(id.isEmpty)return; final price=TextEditingController(text:'${p['price']??0}'), stock=TextEditingController(text:'${p['stock']??0}'); final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:Text('تعديل ${p['name']??'المنتج'}'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'السعر ر.ي')),TextField(controller:stock,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'المخزون'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('إلغاء')),ElevatedButton(onPressed:()=>Navigator.pop(context,true),child:const Text('حفظ'))])); if(ok!=true)return; try{await FirebaseFirestore.instance.collection('products').doc(id).update({'price':double.tryParse(price.text)??0,'stock':int.tryParse(stock.text)??0,'updatedAt':FieldValue.serverTimestamp()});await _load();if(mounted)ToastService.showSuccess('تم تحديث المنتج');}catch(e){if(mounted)ToastService.showError('فشل تحديث المنتج: '+e.toString());}}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الصيدلية'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
              : _pharmacy == null
                  ? Center(child: ElevatedButton.icon(onPressed: _create, icon: const Icon(Icons.local_pharmacy), label: const Text('تسجيل صيدليتي')))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.local_pharmacy)), title: Text('${_pharmacy!['name'] ?? ''}'), subtitle: Text('الحالة: ${_pharmacy!['status'] ?? 'pending'}'), trailing: Icon(_pharmacy!['status'] == 'approved' ? Icons.verified : Icons.hourglass_top, color: _pharmacy!['status'] == 'approved' ? Colors.green : Colors.orange))),
                          const SizedBox(height: 12),
                          Row(children: [Expanded(child: _metric('المنتجات', _products.length.toString())), Expanded(child: _metric('مقبولة', _products.where((p) => p['status'] == 'approved').length.toString())), Expanded(child: _metric('معلقة', _products.where((p) => p['status'] == 'pending').length.toString()))]),
                          const SizedBox(height: 16),
                          if (_pharmacy!['status'] == 'approved') ElevatedButton.icon(onPressed: _addProduct, icon: const Icon(Icons.add), label: const Text('إضافة منتج')),
                          const SizedBox(height: 12),
                          ..._products.map(_product),
                        ],
                      ),
                    ),
    );
  }

  Widget _metric(String a, String b) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Text(b, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)), Text(a, style: const TextStyle(fontSize: 11))])));

  Widget _product(Map<String, dynamic> p) {
    final approved = p['status'] == 'approved';
    return Card(
      child: ListTile(
        title: Text('${p['name'] ?? ''}'),
        subtitle: Text('${p['price'] ?? 0} ر.ي • مخزون ${p['stock'] ?? 0}'),
        trailing: approved
            ? IconButton(onPressed: () => _editOffer(p), icon: const Icon(Icons.edit, color: AppColors.primary))
            : Text('${p['status'] ?? ''}', style: TextStyle(color: p['status'] == 'rejected' ? Colors.red : Colors.orange, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
