import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/toast_service.dart';

class PharmacyDashboard extends StatefulWidget {
  const PharmacyDashboard({super.key});
  @override
  State<PharmacyDashboard> createState() => _PharmacyDashboardState();
}

class _PharmacyDashboardState extends State<PharmacyDashboard> {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  Map<String, dynamic>? _pharmacy;
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final r = await _functions.httpsCallable('getMyPharmacy').call();
      final d = Map<String, dynamic>.from(r.data as Map);
      if (d['exists'] == true) {
        _pharmacy = Map<String, dynamic>.from(d['pharmacy'] as Map);
        final p = await _functions.httpsCallable('getMyPharmacyProducts').call({'pharmacyId': _pharmacy!['id']});
        final pd = Map<String, dynamic>.from(p.data as Map);
        _products = (pd['products'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        _pharmacy = null;
        _products = [];
      }
      if (mounted) setState(() => _error = null);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'تعذر تحميل لوحة الصيدلية');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final name = TextEditingController(), phone = TextEditingController(), address = TextEditingController(), license = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الصيدلية'),
        content: SingleChildScrollView(child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم الصيدلية')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'الهاتف')),
          TextField(controller: address, decoration: const InputDecoration(labelText: 'العنوان')),
          TextField(controller: license, decoration: const InputDecoration(labelText: 'رقم الترخيص')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('إرسال')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _functions.httpsCallable('createPharmacyProfile').call({'name': name.text.trim(), 'phone': phone.text.trim(), 'address': address.text.trim(), 'licenseNumber': license.text.trim()});
      await _load();
      if (mounted) ToastService.showSuccess('تم إرسال طلب تسجيل الصيدلية');
    } catch (e) {
      if (mounted) ToastService.showError(e.toString());
    }
  }

  Future<void> _addProduct() async {
    if (_pharmacy == null || _pharmacy!['status'] != 'approved') return;
    final name = TextEditingController(), category = TextEditingController(text: 'أدوية'), price = TextEditingController(), stock = TextEditingController(text: '0'), drug = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة منتج'),
        content: SingleChildScrollView(child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم المنتج')),
          TextField(controller: drug, decoration: const InputDecoration(labelText: 'معرّف الدواء الرسمي (اختياري)')),
          TextField(controller: category, decoration: const InputDecoration(labelText: 'الفئة')),
          TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر ر.ي')),
          TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المخزون')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('إرسال للمراجعة')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _functions.httpsCallable('submitPharmacyProduct').call({'pharmacyId': _pharmacy!['id'], 'name': name.text.trim(), 'category': category.text.trim(), 'price': double.tryParse(price.text) ?? 0, 'stock': int.tryParse(stock.text) ?? 0, 'drugId': drug.text.trim()});
      await _load();
      if (mounted) ToastService.showSuccess('تم إرسال المنتج للمراجعة');
    } catch (e) {
      if (mounted) ToastService.showError(e.toString());
    }
  }

  Future<void> _editOffer(Map<String, dynamic> p) async {
    final productId = '${p['productId'] ?? ''}';
    if (productId.isEmpty || _pharmacy == null) return;
    final price = TextEditingController(text: '${p['price'] ?? 0}'), stock = TextEditingController(text: '${p['stock'] ?? 0}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تعديل ${p['name'] ?? 'المنتج'}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر ر.ي')),
          TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المخزون')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _functions.httpsCallable('updatePharmacyProductOffer').call({'pharmacyId': _pharmacy!['id'], 'productId': productId, 'price': double.tryParse(price.text) ?? 0, 'stock': int.tryParse(stock.text) ?? 0});
      await _load();
      if (mounted) ToastService.showSuccess('تم تحديث العرض والمخزون');
    } catch (e) {
      if (mounted) ToastService.showError(e.toString());
    }
  }

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
