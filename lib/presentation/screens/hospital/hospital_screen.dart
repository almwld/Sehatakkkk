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
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _hospitals = [];
  final List<String> _filters = ['الكل', 'حكومي', 'خاص', 'جامعي', 'تخصصي'];

  final List<Map<String, dynamic>> _fallback = [
    {'id': '1', 'name': 'مستشفى الثورة العام', 'location': 'صنعاء', 'specialty': 'حكومي', 'rating': 4.8, 'reviews': 450, 'phone': '01-222222', 'image': ImageKit.hospital1, 'open': true, 'emergency': true, 'beds': 500},
    {'id': '2', 'name': 'المستشفى الجمهوري', 'location': 'صنعاء', 'specialty': 'حكومي', 'rating': 4.7, 'reviews': 380, 'phone': '01-999444', 'image': ImageKit.hospital2, 'open': true, 'emergency': true, 'beds': 450},
    {'id': '3', 'name': 'مستشفى الكويت الجامعي', 'location': 'صنعاء', 'specialty': 'جامعي', 'rating': 4.9, 'reviews': 520, 'phone': '01-333333', 'image': ImageKit.hospital3, 'open': true, 'emergency': true, 'beds': 400},
  ];

  @override
  void initState() { super.initState(); _loadHospitals(); }
  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  Future<void> _loadHospitals() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final snap = await _firestore.collection('hospitals').get();
      final remote = snap.docs.map((d) => <String, dynamic>{'id': d.id, ...d.data()}).where((h) => '${h['name'] ?? ''}'.trim().isNotEmpty).toList();
      if (mounted) setState(() { _hospitals = remote.isEmpty ? List<Map<String, dynamic>>.from(_fallback) : remote; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _hospitals = List<Map<String, dynamic>>.from(_fallback); _error = 'تعذر الاتصال ببيانات المستشفيات؛ تم عرض بيانات احتياطية.'; _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filteredHospitals {
    final q = _searchQuery.trim().toLowerCase();
    return _hospitals.where((h) {
      final type = '${h['specialty'] ?? h['type'] ?? h['category'] ?? ''}';
      final haystack = '${h['name'] ?? ''} ${h['location'] ?? h['address'] ?? ''} $type'.toLowerCase();
      return (_selectedFilter == 'الكل' || type == _selectedFilter) && (q.isEmpty || haystack.contains(q));
    }).toList();
  }

  String _image(Map<String, dynamic> h, int index) {
    final stored = '${h['imageUrl'] ?? h['image'] ?? ''}'.trim();
    if (stored.startsWith('http')) return stored;
    return [ImageKit.hospital1, ImageKit.hospital2, ImageKit.hospital3, ImageKit.hospital4, ImageKit.hospital5, ImageKit.hospital6][index % 6];
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredHospitals;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'المستشفيات', backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => _showSearchDialog())]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              if (_error != null) Container(width: double.infinity, padding: const EdgeInsets.all(8), color: AppColors.primary.withOpacity(.08), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.primary))),
              SizedBox(height: 50, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), itemCount: _filters.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) { final f = _filters[i]; final selected = f == _selectedFilter; return FilterChip(label: Text(f), selected: selected, onSelected: (_) => setState(() => _selectedFilter = f), selectedColor: AppColors.primary, labelStyle: TextStyle(color: selected ? Colors.white : (dark ? Colors.white : AppColors.primary))); })),
              Expanded(child: filtered.isEmpty ? _empty(dark) : RefreshIndicator(onRefresh: _loadHospitals, child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: filtered.length, itemBuilder: (_, i) => _card(filtered[i], i, dark))))
            ]),
    );
  }

  Widget _card(Map<String, dynamic> h, int index, bool dark) {
    final type = '${h['specialty'] ?? h['type'] ?? h['category'] ?? 'مستشفى'}';
    final rating = h['rating'] is num ? (h['rating'] as num).toDouble() : double.tryParse('${h['rating'] ?? 0}') ?? 0;
    final beds = h['beds'];
    return Card(margin: const EdgeInsets.only(bottom: 10), color: dark ? const Color(0xFF1A2540) : Colors.white, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => _showDetails(h, index), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: AppImage(imageUrl: _image(h, index), width: 80, height: 80)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${h['name'] ?? 'مستشفى'}', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: dark ? Colors.white : Colors.black87)), const SizedBox(height: 4), Text('${h['location'] ?? h['address'] ?? 'اليمن'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: dark ? Colors.grey[400] : Colors.grey[600])), const SizedBox(height: 6), Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(6)), child: Text(type, style: const TextStyle(fontSize: 10, color: AppColors.primary))), const SizedBox(width: 7), const Icon(Icons.star, size: 15, color: Colors.amber), Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)), if (beds != null) ...[const SizedBox(width: 7), Text('$beds سرير', style: const TextStyle(fontSize: 10, color: AppColors.primary))]])])), const Icon(Icons.arrow_forward_ios, size: 14)]))));
  }

  Widget _empty(bool dark) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_hospital_outlined, size: 64, color: dark ? Colors.grey[600] : Colors.grey[300]), const SizedBox(height: 12), Text('لا توجد مستشفيات مطابقة', style: TextStyle(color: dark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))]));

  void _showSearchDialog() {
    _searchController.text = _searchQuery;
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('بحث عن مستشفى'), content: TextField(controller: _searchController, autofocus: true, decoration: const InputDecoration(hintText: 'اسم المستشفى أو الموقع', prefixIcon: Icon(Icons.search))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), TextButton(onPressed: () { setState(() => _searchQuery = _searchController.text); Navigator.pop(context); }, child: const Text('بحث'))]));
  }

  void _showDetails(Map<String, dynamic> h, int index) {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: AppImage(imageUrl: _image(h, index), width: 64, height: 64)), const SizedBox(width: 12), Expanded(child: Text('${h['name'] ?? 'مستشفى'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]), const SizedBox(height: 16), Text('الموقع: ${h['location'] ?? h['address'] ?? 'غير محدد'}'), const SizedBox(height: 8), Text('الهاتف: ${h['phone'] ?? 'غير متوفر'}'), const SizedBox(height: 8), Text('التصنيف: ${h['specialty'] ?? h['type'] ?? h['category'] ?? 'مستشفى'}'), const SizedBox(height: 16), if (h['emergency'] == true) const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.emergency, color: Colors.red), title: Text('خدمة الطوارئ متاحة'))])));
  }
}
