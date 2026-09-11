import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class StressMeterScreen extends StatefulWidget {
  const StressMeterScreen({super.key});
  @override State<StressMeterScreen> createState() => _StressMeterScreenState();
}
class _StressMeterScreenState extends State<StressMeterScreen> {
  double _stressLevel = 0;
  String get _stressText { if (_stressLevel <= 2) return 'منخفض 😊'; if (_stressLevel <= 4) return 'متوسط 😐'; if (_stressLevel <= 6) return 'مرتفع 😰'; return 'شديد جداً 😱'; }
  Color get _stressColor { if (_stressLevel <= 2) return AppColors.success; if (_stressLevel <= 4) return AppColors.warning; if (_stressLevel <= 6) return Colors.orange; return AppColors.error; }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: const Text('مقياس التوتر'), backgroundColor: AppColors.purple, foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('كيف تشعر اليوم؟', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 40),
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: _stressColor.withOpacity(.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _stressColor, width: 2)), child: Column(children: [
        Text(_stressText, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _stressColor)), const SizedBox(height: 20),
        Slider(value: _stressLevel, min: 0, max: 10, divisions: 10, activeColor: _stressColor, label: _stressLevel.round().toString(), onChanged: (v) => setState(() => _stressLevel = v)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('مرتاح', style: TextStyle(color: AppColors.grey)), Text('${_stressLevel.round()}/10', style: const TextStyle(fontWeight: FontWeight.bold)), const Text('متوتر', style: TextStyle(color: AppColors.grey))]),
      ])), const SizedBox(height: 40),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => ToastService.showSuccess(context, 'تم تسجيل مستوى التوتر: ${_stressLevel.round()} / 10'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('تسجيل النتيجة', style: TextStyle(fontSize: 16, color: Colors.white))))
    ])));
}
