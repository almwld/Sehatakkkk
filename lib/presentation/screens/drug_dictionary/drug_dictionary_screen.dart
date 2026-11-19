import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class DrugDictionaryScreen extends StatefulWidget {
  const DrugDictionaryScreen({super.key});
  @override
  State<DrugDictionaryScreen> createState() => _DrugDictionaryScreenState();
}

class _DrugDictionaryScreenState extends State<DrugDictionaryScreen> {
  String _query = '';
  
  final List<Map<String, String>> _drugs = const [
    {'name': 'باراسيتامول', 'cat': 'مسكن ألم'},
    {'name': 'ايبوبروفين', 'cat': 'مضاد التهاب'},
    {'name': 'اموكسيسيلين', 'cat': 'مضاد حيوي'},
    {'name': 'اوميبرازول', 'cat': 'مضاد حموضة'},
    {'name': 'ميتفورمين', 'cat': 'خافض سكر'},
    {'name': 'سيتريزين', 'cat': 'مضاد حساسية'},
    {'name': 'ديكلوفيناك', 'cat': 'مضاد التهاب'},
    {'name': 'ازيثرومايسين', 'cat': 'مضاد حيوي'},
    {'name': 'ليفوثيروكسين', 'cat': 'هرمون درقي'},
    {'name': 'فيتامين د', 'cat': 'مكمل'},
    {'name': 'وارفارين', 'cat': 'مميع دم'},
    {'name': 'كلوبيدوجريل', 'cat': 'مضاد صفائح'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty ? _drugs : _drugs.where((d) => d['name']!.contains(_query) || d['cat']!.contains(_query)).toList();

    return Scaffold(
      appBar: CustomAppBar(title: Text(_localizedUiText(context, 'قاموس الأدوية'), style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: UnifiedSearchBar(onChanged: (v) => setState(() => _query = v), hintText: _localizedUiText(context, 'ابحث عن دواء...')),
        ),
        Expanded(
          child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: filtered.length, itemBuilder: (ctx, i) {
            final d = filtered[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)]),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('💊', style: TextStyle(fontSize: 20)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(_localizedUiText(context, d['cat']!), style: TextStyle(fontSize: 10, color: AppColors.primary)),
                ])),
              ]),
            );
          }),
        ),
      ]),
    );
  }
}


String _localizedUiText(BuildContext context, String value) =>
    AppStrings.of(context).translate(value);
