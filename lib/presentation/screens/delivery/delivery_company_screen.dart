import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/delivery/delivery_company_model.dart';
import 'package:sehatak/core/services/delivery_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class DeliveryCompanyScreen extends StatefulWidget {
  final String? selectedCompanyId;
  final Function(DeliveryCompanyModel) onSelect;
  final double distance;
  final String area;
  const DeliveryCompanyScreen({super.key, this.selectedCompanyId, required this.onSelect, this.distance = 5, required this.area});
  @override State<DeliveryCompanyScreen> createState() => _DeliveryCompanyScreenState();
}
class _DeliveryCompanyScreenState extends State<DeliveryCompanyScreen> {
  final _service = DeliveryService(); List<DeliveryCompanyModel> _companies = []; String? _selected; bool _loading = true;
  @override void initState() { super.initState(); _selected = widget.selectedCompanyId; _load(); }
  Future<void> _load() async { try { final all = await _service.getDeliveryCompanies(); final available = all.where((c) => _service.isAreaCovered(c, widget.area)).toList(); if (!mounted) return; setState(() { _companies = available; _selected ??= available.isEmpty ? null : available.first.id; _loading = false; }); } catch (_) { if (mounted) setState(() => _loading = false); } }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(title: 'اختر شركة التوصيل', backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: _loading ? const Center(child: CircularProgressIndicator()) : _companies.isEmpty ? const Center(child: Text('لا توجد شركات توصيل متاحة')) : Column(children: [
      Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _companies.length, itemBuilder: (_, i) { final c = _companies[i]; final selected = c.id == _selected; return Card(child: ListTile(onTap: () => setState(() => _selected = c.id), leading: const Icon(Icons.delivery_dining), title: Text(c.name), subtitle: Text('${c.rating} ★ • ${_service.calculateDeliveryFee(c, widget.distance).toStringAsFixed(0)} ريال • ${_service.estimateDeliveryTime(c, widget.distance)} دقيقة'), trailing: Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? AppColors.primary : Colors.grey))); })),
      Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _selected == null ? null : () { final c = _companies.firstWhere((x) => x.id == _selected); widget.onSelect(c); Navigator.pop(context); }, child: const Text('تأكيد التوصيل')))),
    ]));
  }
}
