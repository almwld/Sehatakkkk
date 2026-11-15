import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});
  @override State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  String _field(Map<String, dynamic> data, String key, {String fallback = ''}) => localizedField(data, key, AppStrings.of(context).locale, fallback: fallback);
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _loadError;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _loadError = null; });
    try {
      final s = await FirebaseFirestore.instance.collection('hospitals').get();
      if (mounted) setState(() => _items = s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
    } catch (error, stack) {
      debugPrint('Hospital directory load failed: $error');
      debugPrintStack(stackTrace: stack);
      if (mounted) setState(() { _items = []; _loadError = error.toString(); });
    } finally { if (mounted) setState(() => _loading = false); }
  }

  String _img(Map<String, dynamic> h, int i) {
    final value = '${h['imageUrl'] ?? h['image'] ?? h['photoUrl'] ?? ''}';
    if (value.startsWith('http')) return value;
    return [ImageKit.hospital1, ImageKit.hospital2, ImageKit.hospital3][i % 3];
  }

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final q = _search.text.trim().toLowerCase();
    final filtered = _items.where((h) => q.isEmpty || '${_field(h, 'name')} ${_field(h, 'location', fallback: _field(h, 'address'))}'.toLowerCase().contains(q)).toList();
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: _t('المستشفيات'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 42, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(_t('تعذر تحميل المستشفيات')),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: Text(_t('إعادة المحاولة')),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    UnifiedSearchBar(controller: _search, onChanged: (_) => setState(() {}), hintText: _t('ابحث عن مستشفى')),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text(_t('لا توجد مستشفيات مطابقة'))),
                      )
                    else
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
        title: Text(_field(h, 'name', fallback: _t('مستشفى')), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${_field(h, 'location', fallback: _field(h, 'address', fallback: _t('اليمن')))}\n${_field(h, 'type', fallback: _field(h, 'specialty', fallback: _t('مستشفى')))}'),
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
          Row(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: AppImage(imageUrl: _img(h, i), width: 60, height: 60)), const SizedBox(width: 12), Expanded(child: Text(_field(h, 'name', fallback: _t('مستشفى')), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 14),
          Text('${_t('الموقع')}: ${_field(h, 'location', fallback: _field(h, 'address', fallback: _t('غير محدد')))}'),
          if (h['phone'] != null) Text('${_t('الهاتف')}: ${_field(h, 'phone')}'),
          if (h['emergency'] == true) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_t('الطوارئ متاحة'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ]),
      )),
    );
  }
}
