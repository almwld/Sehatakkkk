import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HospitalCompareScreen extends StatefulWidget {
  const HospitalCompareScreen({super.key});
  @override State<HospitalCompareScreen> createState() => _HospitalCompareScreenState();
}
class _HospitalCompareScreenState extends State<HospitalCompareScreen> {
  final Set<int> _sel = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: const Text('مقارنة المستشفيات', style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream: FirebaseFirestore.instance.collection('hospitals').where('isActive', isEqualTo: true).snapshots(),
        builder: (context,s) {
          if (s.hasError) return const Center(child: Text('تعذر تحميل المستشفيات حالياً'));
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final hospitals=s.data!.docs;
          if (hospitals.isEmpty) return const Center(child: Text('لا توجد مستشفيات متاحة حالياً'));
          final selected=_sel.where((i)=>i<hospitals.length).toList();
          return SingleChildScrollView(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            if(selected.length>=2) SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(columns:[const DataColumn(label:Text('الميزة')), ...selected.map((i)=>DataColumn(label:Text(hospitals[i].data()['name']?.toString() ?? 'مستشفى')))],rows:[
              _row('التقييم','rating',Icons.star,hospitals,selected),
              _row('الأسرة','beds',Icons.bed,hospitals,selected),
              _row('الأطباء','doctors',Icons.person,hospitals,selected),
              _row('طوارئ','emergency',Icons.warning,hospitals,selected,isBool:true),
              _row('عناية','icu',Icons.monitor_heart,hospitals,selected,isBool:true),
            ])),
            const SizedBox(height:16),
            Text('اختر للمقارنة (${selected.length}/2+)',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
            ...List.generate(hospitals.length,(i){final h=hospitals[i].data();final selectedNow=_sel.contains(i);return Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:selectedNow?AppColors.primary:Colors.transparent,width:2)),child:Row(children:[const Icon(Icons.local_hospital,color:AppColors.error,size:28),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(h['name']?.toString()??'مستشفى',style:const TextStyle(fontWeight:FontWeight.bold)),Text('${h['beds'] ?? '--'} سرير • ${h['doctors'] ?? '--'} طبيب',style:const TextStyle(fontSize:10,color:AppColors.grey))])),Checkbox(value:selectedNow,activeColor:AppColors.primary,onChanged:(v)=>setState(()=>v==true?_sel.add(i):_sel.remove(i))) ]));}),
          ]));
        },
      ),
    );
  }
  DataRow _row(String l,String k,IconData i,List<QueryDocumentSnapshot<Map<String,dynamic>>> hs,List<int> selected,{bool isBool=false})=>DataRow(cells:[DataCell(Row(children:[Icon(i,size:16,color:AppColors.primary),const SizedBox(width:6),Text(l,style:const TextStyle(fontSize:12))])),...selected.map((si){final v=hs[si].data()[k];return DataCell(isBool?Icon(v==true?Icons.check:Icons.close,color:v==true?AppColors.success:AppColors.error,size:18):Text(v?.toString() ?? '--',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12)));})]);
}
