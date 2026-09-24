import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});
  @override State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
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
      appBar: CustomAppBar(title: 'الأدوية', backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('products').where('isPublished', isEqualTo: true).where('isActive', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('تعذر تحميل الأدوية حالياً'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          final categories = <String>{'الكل', ...docs.map((d) => d.data()['category']?.toString()).whereType<String>().where((x) => x.isNotEmpty)};
          final filtered = docs.where((d) {
            final x = d.data();
            final q = _searchQuery.toLowerCase();
            final text = '${x['name'] ?? ''} ${x['genericName'] ?? ''} ${x['category'] ?? ''}'.toLowerCase();
            return (_selectedCategory == 'الكل' || x['category']?.toString() == _selectedCategory) && (q.isEmpty || text.contains(q));
          }).toList();
          return Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(12,12,12,4), child: UnifiedSearchBar(controller: _searchController, onChanged: (v) => setState(() => _searchQuery = v.trim()), onClear: () { _searchController.clear(); setState(() => _searchQuery=''); }, hintText: 'ابحث عن دواء...', isDark: dark)),
            SizedBox(height: 40, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: categories.length, separatorBuilder: (_,__) => const SizedBox(width: 6), itemBuilder: (_,i) { final cat=categories.elementAt(i); final selected=_selectedCategory==cat; return FilterChip(label: Text(cat, style: const TextStyle(fontSize: 11)), selected:selected, onSelected:(_)=>setState(()=>_selectedCategory=cat), selectedColor:AppColors.primary, labelStyle:TextStyle(color:selected?Colors.white:AppColors.primary)); })),
            Expanded(child: filtered.isEmpty ? Center(child: Text('لا توجد أدوية متاحة حالياً', style: TextStyle(color: dark?Colors.white70:Colors.black54))) : GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:.72, crossAxisSpacing:12, mainAxisSpacing:12), itemCount:filtered.length, itemBuilder:(_,i){ final m=filtered[i].data(); final image=m['imageUrl']?.toString() ?? m['image']?.toString() ?? ''; return Container(decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:ClipRRect(borderRadius:const BorderRadius.vertical(top:Radius.circular(16)),child:image.isEmpty?Container(color:AppColors.primary.withOpacity(.06),child:const Icon(Icons.medication_outlined,size:42,color:AppColors.primary)):AppImage(imageUrl:image,width:double.infinity,height:double.infinity,fit:BoxFit.cover))),Padding(padding:const EdgeInsets.all(9),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m['name']?.toString() ?? m['genericName']?.toString() ?? 'دواء',maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12)),const SizedBox(height:4),Text(m['price'] != null ? '${m['price']} ر.ي' : 'السعر غير متاح',style:const TextStyle(color:AppColors.primary,fontWeight:FontWeight.bold)),]))])); })),
          ]);
        },
      ),
    );
  }
}
