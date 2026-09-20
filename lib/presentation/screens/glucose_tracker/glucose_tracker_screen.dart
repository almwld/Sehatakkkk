import 'package:flutter/material.dart';
import 'package:sehatak/core/services/health_tracking_service.dart';
import 'package:sehatak/presentation/widgets/futuristic/glass_card.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_background.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_app_bar.dart';
import 'package:sehatak/presentation/widgets/futuristic/holographic_number.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_line_chart.dart';
import 'package:sehatak/presentation/widgets/futuristic/glass_bottom_sheet.dart';
class GlucoseTrackerScreen extends StatefulWidget{const GlucoseTrackerScreen({super.key});@override State<GlucoseTrackerScreen> createState()=>_S();}
class _S extends State<GlucoseTrackerScreen>{
 List<double>h=[];double latest=0;final c=TextEditingController();
 @override void initState(){super.initState();_load();}@override void dispose(){c.dispose();super.dispose();}
 Future<void>_load()async{final r=await HealthTrackingService.history('glucose',days:30);if(!mounted)return;setState(()=>h=r.map((e)=>(e['value']as num?)?.toDouble()??0).where((e)=>e>0).toList().reversed.toList());if(h.isNotEmpty)latest=h.last;}
 String get st=>latest<70?'منخفض':latest<=140?'طبيعي':latest<=200?'مرتفع':'خطر';
 void _add(){c.clear();showModalBottomSheet(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(_)=>GlassBottomSheet(title:'إضافة قياس السكر',child:Column(children:[
  TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'mg/dL',labelStyle:TextStyle(color:Colors.white54))),const SizedBox(height:14),
  SizedBox(width:double.infinity,child:ElevatedButton(onPressed:()async{final v=double.tryParse(c.text);if(v==null||v<=0)return;await HealthTrackingService.save({'blood_sugar':v,'blood_sugar_at':DateTime.now().toIso8601String()});if(!mounted)return;Navigator.pop(context);await _load();},child:const Text('حفظ'))),
 ])));}

 @override Widget build(BuildContext c)=>Scaffold(backgroundColor:const Color(0xFF0A0E1A),appBar:FuturisticAppBar(title:'تتبع السكر',actions:[IconButton(onPressed:_add,icon:const Icon(Icons.add))]),body:FuturisticBackground(glowColor:const Color(0xFFFF9F43),child:ListView(padding:const EdgeInsets.all(16),children:[
  GlassCard(glowColor:const Color(0xFFFF9F43),child:Column(children:[const Icon(Icons.water_drop_rounded,color:Color(0xFFFF9F43),size:52),HolographicNumber(value:latest==0?'--':latest.round().toString(),unit:'mg/dL • $st',color:const Color(0xFFFF9F43))])),
  const SizedBox(height:12),GlassCard(child:h.length>1?FuturisticLineChart(values:h,color:const Color(0xFFFF9F43)):const SizedBox(height:130,child:Center(child:Text('أضف قياسات فعلية لعرض الرسم',style:TextStyle(color:Colors.white54))))),
 ]));
}