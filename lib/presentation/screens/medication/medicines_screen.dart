import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});
  @override State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: _t('الأدوية'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('products').where('isPublished', isEqualTo: true).where('isActive', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(_t('تعذر تحميل الأدوية حالياً')));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          final locale = AppStrings.of(context).locale;
          final arabicLocale = const Locale('ar');
          final categoryLabels = <String, String>{};
          for (final document in docs) {
            final data = document.data();
            final arabicCategory =
                localizedField(data, 'category', arabicLocale).trim();
            if (arabicCategory.isNotEmpty) {
              categoryLabels[arabicCategory] = localizedField(
                data,
                'category',
                locale,
                fallback: arabicCategory,
              );
            }
          }
          final categories = <String>{'الكل', ...categoryLabels.keys};
          final filtered = docs.where((document) {
            final data = document.data();
            final query = _searchQuery.toLowerCase();
            final name = localizedField(
              data,
              'name',
              locale,
              fallback: localizedField(data, 'genericName', locale),
            );
            final genericName = localizedField(data, 'genericName', locale);
            final category = localizedField(data, 'category', locale);
            final arabicName = localizedField(
              data,
              'name',
              arabicLocale,
              fallback: localizedField(data, 'genericName', arabicLocale),
            );
            final arabicGenericName =
                localizedField(data, 'genericName', arabicLocale);
            final arabicCategory =
                localizedField(data, 'category', arabicLocale);
            final searchableText = [
              name,
              genericName,
              category,
              arabicName,
              arabicGenericName,
              arabicCategory,
            ].join(' ').toLowerCase();
            return (_selectedCategory == 'الكل' ||
                    arabicCategory == _selectedCategory) &&
                (query.isEmpty || searchableText.contains(query));
          }).toList();
          return Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(12,12,12,4), child: UnifiedSearchBar(controller: _searchController, onChanged: (v) => setState(() => _searchQuery = v.trim()), onClear: () { _searchController.clear(); setState(() => _searchQuery=''); }, hintText: _t('ابحث عن دواء...'), isDark: dark)),
            SizedBox(height: 40, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: categories.length, separatorBuilder: (_,__) => const SizedBox(width: 6), itemBuilder: (_,i) { final cat=categories.elementAt(i); final selected=_selectedCategory==cat; final categoryLabel = cat == 'الكل' ? _t(cat) : _t(categoryLabels[cat] ?? cat); return FilterChip(label: Text(categoryLabel, style: const TextStyle(fontSize: 11)), selected:selected, onSelected:(_)=>setState(()=>_selectedCategory=cat), selectedColor:AppColors.primary, labelStyle:TextStyle(color:selected?Colors.white:AppColors.primary)); })),
            Expanded(child: filtered.isEmpty ? Center(child: Text(_t('لا توجد أدوية متاحة حالياً'), style: TextStyle(color: dark?Colors.white70:Colors.black54))) : GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:.72, crossAxisSpacing:12, mainAxisSpacing:12), itemCount:filtered.length, itemBuilder:(_,i){ final m=filtered[i].data(); final image=m['imageUrl']?.toString() ?? m['image']?.toString() ?? ''; final localizedName=localizedField(m,'name',locale,fallback:localizedField(m,'genericName',locale,fallback:_t('دواء'))); return Container(decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:ClipRRect(borderRadius:const BorderRadius.vertical(top:Radius.circular(16)),child:image.isEmpty?Container(color:AppColors.primary.withOpacity(.06),child:const Icon(Icons.medication_outlined,size:42,color:AppColors.primary)):AppImage(imageUrl:image,width:double.infinity,height:double.infinity,fit:BoxFit.cover))),Padding(padding:const EdgeInsets.all(9),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_t(localizedName),maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12)),const SizedBox(height:4),Text(m['price'] is num ? AppStrings.of(context).formatCurrency(m['price'] as num) : _t('السعر غير متاح'),style:const TextStyle(color:AppColors.primary,fontWeight:FontWeight.bold)),]))])); })),
          ]);
        },
      ),
    );
  }
}
