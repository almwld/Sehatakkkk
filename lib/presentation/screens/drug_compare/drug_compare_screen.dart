import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class DrugCompareScreen extends StatefulWidget {
  const DrugCompareScreen({super.key});
  @override
  State<DrugCompareScreen> createState() => _DrugCompareScreenState();
}

class _DrugCompareScreenState extends State<DrugCompareScreen> {
  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  String _d1 = 'باراسيتامول';
  String _d2 = 'إيبوبروفين';

  Map<String, String> _info(String d) {
    switch (d) {
      case 'باراسيتامول': return {'cat': 'مسكن ألم', 'use': 'ألم، حمى', 'onset': '30-60 دقيقة', 'dur': '4-6 ساعات', 'preg': 'آمن', 'stomach': 'لطيف', 'price': 'رخيص'};
      case 'إيبوبروفين': return {'cat': 'مضاد التهاب', 'use': 'التهاب، ألم', 'onset': '30-60 دقيقة', 'dur': '6-8 ساعات', 'preg': 'خطر', 'stomach': 'قوي', 'price': 'رخيص'};
      case 'ديكلوفيناك': return {'cat': 'مضاد التهاب', 'use': 'مفاصل، عضلات', 'onset': '20-30 دقيقة', 'dur': '8-12 ساعات', 'preg': 'خطر', 'stomach': 'قوي', 'price': 'متوسط'};
      case 'نابروكسين': return {'cat': 'مضاد التهاب', 'use': 'نقرس، مفاصل', 'onset': 'ساعة', 'dur': '12 ساعة', 'preg': 'خطر', 'stomach': 'قوي', 'price': 'متوسط'};
      default: return {'cat': '', 'use': '', 'onset': '', 'dur': '', 'preg': '', 'stomach': '', 'price': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    final i1 = _info(_d1);
    final i2 = _info(_d2);
    return Scaffold(
      appBar: CustomAppBar(title: _t(context, 'مقارنة الأدوية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            Expanded(child: _drop(_d1, (v) => setState(() => _d1 = v!))),
            const Text(' VS ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            Expanded(child: _drop(_d2, (v) => setState(() => _d2 = v!))),
          ]),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            children: [
              _row(context, 'الميزة', _d1, _d2, true),
              _row(context, 'التصنيف', i1['cat']!, i2['cat']!),
              _row(context, 'الاستخدام', i1['use']!, i2['use']!),
              _row(context, 'البدء', i1['onset']!, i2['onset']!),
              _row(context, 'المدة', i1['dur']!, i2['dur']!),
              _row(context, 'الحمل', i1['preg']!, i2['preg']!),
              _row(context, 'المعدة', i1['stomach']!, i2['stomach']!),
              _row(context, 'السعر', i1['price']!, i2['price']!),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _drop(String val, Function(String?) cb) {
    return DropdownButtonFormField<String>(
      value: val,
      items: ['باراسيتامول','إيبوبروفين','ديكلوفيناك','نابروكسين'].map((k) => DropdownMenuItem(value: k, child: Text(_t(context, k), style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: cb,
    );
  }

  TableRow _row(BuildContext context, String l, String v1, String v2, [bool h = false]) {
    return TableRow(
      decoration: h ? BoxDecoration(color: AppColors.primary.withOpacity(0.1)) : null,
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(_t(context, l), style: TextStyle(fontWeight: h ? FontWeight.bold : FontWeight.normal, fontSize: 12))),
        Padding(padding: const EdgeInsets.all(10), child: Text(_t(context, v1), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
        Padding(padding: const EdgeInsets.all(10), child: Text(_t(context, v2), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
