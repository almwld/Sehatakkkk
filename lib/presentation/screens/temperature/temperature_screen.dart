import 'package:flutter/material.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/health_metrics_service.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});
  @override State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _save() async {
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (value == null || value < 30 || value > 45) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل درجة حرارة مقاسة بين 30 و45 °C.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await HealthMetricsService.update({'temperature': value});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ درجة الحرارة المقاسة.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر الحفظ: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: CustomAppBar(title: const Text('درجة الحرارة'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const Icon(Icons.thermostat_rounded, size: 80, color: AppColors.orange),
      const SizedBox(height: 16),
      const Text('إدخال قراءة حقيقية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('استخدم ميزان حرارة فعلياً ثم أدخل القراءة هنا. التطبيق لا يحاكي قياس الحرارة.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      TextField(controller: _controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'درجة الحرارة °C', border: OutlineInputBorder(), suffixText: '°C')),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'جاري الحفظ...' : 'حفظ القراءة'))),
    ])),
  );
}