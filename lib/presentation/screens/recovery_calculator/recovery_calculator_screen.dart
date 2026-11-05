import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class RecoveryCalculatorScreen extends StatefulWidget {
  const RecoveryCalculatorScreen({super.key});
  @override
  State<RecoveryCalculatorScreen> createState() => _RecoveryCalculatorScreenState();
}

class _RecoveryCalculatorScreenState extends State<RecoveryCalculatorScreen> {
  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  String _condition = 'نزلة برد';
  int _age = 30;
  bool _smoker = false;
  bool _exercise = true;

  final Map<String, Map<String, dynamic>> _conditions = {
    'نزلة برد': {'min': 3, 'max': 7, 'unit': 'أيام', 'icon': '🤧', 'color': AppColors.info, 'advice': 'راحة، سوائل، فيتامين C'},
    'إنفلونزا': {'min': 5, 'max': 14, 'unit': 'أيام', 'icon': '🤒', 'color': AppColors.warning, 'advice': 'راحة تامة، سوائل، باراسيتامول'},
    'جرح بسيط': {'min': 7, 'max': 14, 'unit': 'أيام', 'icon': '🩹', 'color': AppColors.success, 'advice': 'تنظيف يومي، تغيير ضماد'},
    'كسر بسيط': {'min': 30, 'max': 60, 'unit': 'يوم', 'icon': '🦴', 'color': AppColors.error, 'advice': 'تثبيت، علاج طبيعي'},
    'شد عضلي': {'min': 3, 'max': 10, 'unit': 'أيام', 'icon': '💪', 'color': AppColors.purple, 'advice': 'راحة، كمادات، مسكن'},
    'عملية جراحية': {'min': 14, 'max': 30, 'unit': 'يوم', 'icon': '🏥', 'color': AppColors.teal, 'advice': 'متابعة طبية، راحة'},
  };

  int get _days {
    final c = _conditions[_condition]!;
    int d = ((c['min'] + c['max']) / 2).round();
    if (_smoker) d = (d * 1.5).round();
    if (_exercise) d = (d * 0.7).round();
    if (_age > 50) d = (d * 1.3).round();
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final c = _conditions[_condition]!;
    return Scaffold(
      appBar: CustomAppBar(title: Text(_t(context, 'حاسبة التعافي'), style: const TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 6, children: _conditions.keys.map((k) => ChoiceChip(label: Text('${_conditions[k]!['icon']} ${_t(context, k)}', style: const TextStyle(fontSize: 11)), selected: _condition == k, selectedColor: c['color'], labelStyle: TextStyle(color: _condition == k ? Colors.white : AppColors.darkGrey), onSelected: (_) => setState(() => _condition = k))).toList()),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [(c['color'] as Color).withOpacity(0.7), c['color']]), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Text(c['icon'], style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(_t(context, 'مدة التعافي المتوقعة'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text('$_days ${_t(context, c['unit'] as String)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              Text('${_t(context, 'من')} ${c['min']} ${_t(context, 'إلى')} ${c['max']} ${_t(context, c['unit'] as String)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 16),
          _slide(context, 'العمر', _age.toDouble(), 1, 100, (v) => setState(() => _age = v.toInt())),
          SwitchListTile(title: Text(_t(context, 'مدخن')), value: _smoker, activeColor: AppColors.primary, onChanged: (v) => setState(() => _smoker = v)),
          SwitchListTile(title: Text(_t(context, 'أمارس الرياضة')), value: _exercise, activeColor: AppColors.primary, onChanged: (v) => setState(() => _exercise = v)),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.05), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_t(context, '💡 نصائح'), style: const TextStyle(fontWeight: FontWeight.bold)), Text('• ${_t(context, c['advice'] as String)}', style: const TextStyle(fontSize: 12)),
          ])),
        ]),
      ),
    );
  }

  Widget _slide(BuildContext context, String label, double val, double min, double max, Function(double) cb) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)]), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_t(context, label)), Text('${val.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))]), Slider(value: val, min: min, max: max, activeColor: AppColors.primary, onChanged: cb)]));
}
