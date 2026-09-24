import 'package:flutter/material.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/health_metrics_service.dart';

class BloodOxygenScreen extends StatefulWidget {
  const BloodOxygenScreen({super.key});
  @override State<BloodOxygenScreen> createState() => _BloodOxygenScreenState();
}

class _BloodOxygenScreenState extends State<BloodOxygenScreen> {
  final _controller = TextEditingController();
  bool _saving = false;
  @override void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _save() async {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 50 || value > 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل نسبة أكسجين مقاسة بين 50% و100%.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await HealthMetricsService.update({'bloodOxygen': value});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ القراءة المقاسة.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر الحفظ: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: CustomAppBar(title: const Text('نسبة الأكسجين'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const Icon(Icons.bloodtype_rounded, size: 80, color: AppColors.purple),
      const SizedBox(height: 16),
      const Text('إدخال قراءة حقيقية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('استخدم جهاز قياس أكسجين معتمداً ثم أدخل القراءة هنا. لا يستخدم التطبيق الكاميرا لتخمين SpO₂.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      TextField(controller: _controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SpO₂ %', border: OutlineInputBorder(), suffixText: '%')),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'جاري الحفظ...' : 'حفظ القراءة'))),
    ])),
  );
}