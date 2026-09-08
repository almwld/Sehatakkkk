import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MarketplaceAdminDashboard extends StatefulWidget {
  const MarketplaceAdminDashboard({super.key});
  @override
  State<MarketplaceAdminDashboard> createState() => _MarketplaceAdminDashboardState();
}

class _MarketplaceAdminDashboardState extends State<MarketplaceAdminDashboard> {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  List<Map<String, dynamic>> _products = [], _pharmacies = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final r = await _functions.httpsCallable('getMarketplaceReviewQueue').call();
      final d = Map<String, dynamic>.from(r.data as Map);
      _products = (d['products'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _pharmacies = (d['pharmacies'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (mounted) setState(() => _error = null);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'تعذر تحميل قائمة المراجعة');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reviewProduct(String id, String decision) async {
    try {
      await _functions.httpsCallable('reviewPharmacyProduct').call({'submissionId': id, 'decision': decision, 'note': ''});
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _reviewPharmacy(String id, String decision) async {
    try {
      await _functions.httpsCallable('reviewPharmacy').call({'pharmacyId': id, 'decision': decision, 'note': ''});
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة Marketplace'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _section(
                        'طلبات اعتماد الصيدليات',
                        _pharmacies,
                        (p) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p['name'] ?? 'صيدلية'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${p['address'] ?? ''}'),
                            Text('الترخيص: ${p['licenseNumber'] ?? 'غير مسجل'}'),
                            _actions(() => _reviewPharmacy('${p['id']}', 'reject'), () => _reviewPharmacy('${p['id']}', 'approve')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        'منتجات معلقة',
                        _products,
                        (p) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p['name'] ?? 'منتج'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${p['category'] ?? ''} • ${p['price'] ?? 0} ر.ي • مخزون ${p['stock'] ?? 0}'),
                            Text('الصيدلية: ${p['pharmacyId'] ?? ''}'),
                            _actions(() => _reviewProduct('${p['id']}', 'reject'), () => _reviewProduct('${p['id']}', 'approve')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _section(String title, List<Map<String, dynamic>> items, Widget Function(Map<String, dynamic>) builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title (${items.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('لا توجد طلبات معلقة'))),
        ...items.map((p) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: builder(p)))),
      ],
    );
  }

  Widget _actions(VoidCallback reject, VoidCallback approve) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: reject, child: const Text('رفض'))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(onPressed: approve, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('اعتماد'))),
        ],
      ),
    );
  }
}
