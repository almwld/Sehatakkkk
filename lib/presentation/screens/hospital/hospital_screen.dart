import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});
  @override State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final s = await FirebaseFirestore.instance.collection('hospitals').where('cityNormalized', isEqualTo: 'صنعاء').get();
      if (mounted) setState(() => _items = s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
    } catch (_) {
      if (mounted) setState(() => _items = []);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  String _img(Map<String, dynamic> h, int i) {
    final value = '${h['imageUrl'] ?? h['image'] ?? ''}';
    if (value.startsWith('http')) return value;
    return [ImageKit.hospital1, ImageKit.hospital2, ImageKit.hospital3][i % 3];
  }

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final q = _search.text.trim().toLowerCase();
    final filtered = _items.where((h) => q.isEmpty || '${h['name'] ?? ''} ${h['location'] ?? ''}'.toLowerCase().contains(q)).toList();
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'المستشفيات', backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'ابحث عن مستشفى', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          ...filtered.asMap().entries.map((e) => _card(e.value, e.key, dark)),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> h, int i, bool dark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: AppImage(imageUrl: _img(h, i), width: 70, height: 70, fit: BoxFit.cover)),
        title: Text('${h['name'] ?? 'مستشفى'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${h['location'] ?? h['address'] ?? 'اليمن'}\n${h['type'] ?? h['specialty'] ?? 'مستشفى'}'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_left),
        onTap: () => _details(h, i),
      ),
    );
  }

  void _details(Map<String, dynamic> h, int i) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: AppImage(imageUrl: _img(h, i), width: 60, height: 60)), const SizedBox(width: 12), Expanded(child: Text('${h['name'] ?? 'مستشفى'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 14),
          Text('الموقع: ${h['location'] ?? h['address'] ?? 'غير محدد'}'),
          if (h['phone'] != null) Text('الهاتف: ${h['phone']}'),
          if (h['emergency'] == true) const Padding(padding: EdgeInsets.only(top: 10), child: Text('الطوارئ متاحة', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ]),
      )),
    );
  }
}
