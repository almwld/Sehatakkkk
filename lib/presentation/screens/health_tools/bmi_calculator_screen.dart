import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});
  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  double _height = 170, _weight = 70;
  int _age = 25;
  bool _isMale = true;

  double get _bmi => _weight / ((_height / 100) * (_height / 100));

  String get _category {
    if (_bmi < 18.5) return _t('نقص وزن');
    if (_bmi < 25) return _t('وزن طبيعي');
    if (_bmi < 30) return _t('زيادة وزن');
    return _t('سمنة');
  }

  Color get _color {
    if (_bmi < 18.5) return AppColors.warning;
    if (_bmi < 25) return AppColors.success;
    if (_bmi < 30) return AppColors.amber;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text(_t('حاسبة BMI'), style: const TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            _gender(_t('ذكر'), Icons.male, _isMale, () => setState(() => _isMale = true)),
            const SizedBox(width: 10),
            _gender(_t('أنثى'), Icons.female, !_isMale, () => setState(() => _isMale = false)),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _color.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: _color.withOpacity(0.2))),
            child: Column(children: [
              Text(_t('مؤشر كتلة الجسم'), style: TextStyle(color: AppColors.grey)),
              Text(_bmi.toStringAsFixed(1), style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _color)),
              Text(_category, style: TextStyle(fontSize: 18, color: _color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${_t('الوزن المثالي:')} ${((_height - 100) * 0.9).toStringAsFixed(1)} - ${((_height - 100) * 1.1).toStringAsFixed(1)} ${_t('كجم')}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ]),
          ),
          _slider(_t('الطول (سم)'), _height, 100, 220, (v) => setState(() => _height = v)),
          _slider(_t('الوزن (كجم)'), _weight, 30, 200, (v) => setState(() => _weight = v)),
          _slider(_t('العمر'), _age.toDouble(), 1, 120, (v) => setState(() => _age = v.toInt())),
        ]),
      ),
    );
  }

  Widget _gender(String label, IconData icon, bool sel, VoidCallback tap) => Expanded(child: GestureDetector(onTap: tap, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: sel ? AppColors.primary.withOpacity(0.08) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? AppColors.primary : AppColors.outlineVariant)), child: Column(children: [Icon(icon, size: 40, color: sel ? AppColors.primary : AppColors.grey), const SizedBox(height: 8), Text(label, style: TextStyle(color: sel ? AppColors.primary : AppColors.grey, fontWeight: FontWeight.bold))]))));

  Widget _slider(String label, double value, double min, double max, Function(double) cb) => Container(margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text('${value.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary))]), Slider(value: value, min: min, max: max, activeColor: AppColors.primary, onChanged: cb)]));
}
