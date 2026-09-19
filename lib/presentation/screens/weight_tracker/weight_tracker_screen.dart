import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/health_metrics_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});
  @override State<WeightTrackerScreen> createState()=>_WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen>{
  static const _cacheKey='weight_history_v3';
  final _weight=TextEditingController(),_note=TextEditingController();
  List<Map<String,dynamic>> _history=[]; double? _target; bool _loading=true;
  @override void initState(){super.initState();_load();}
  @override void dispose(){_weight.dispose();_note.dispose();super.dispose();}

  Future<void> _load() async{
    final p=await SharedPreferences.getInstance();final raw=p.getString(_cacheKey);
    if(raw!=null){try{_history=List<Map<String,dynamic>>.from((jsonDecode(raw) as List).map((e)=>Map<String,dynamic>.from(e)));}catch(_){}}
    _target=p.getDouble('target_weight');
    try{final d=await HealthMetricsService.read();final w=d['weight'];if(_history.isEmpty&&w is num&&w>0)_history=[{'weight':w.toDouble(),'date':d['weight_at']??DateTime.now().toIso8601String(),'note':''}];}catch(_){}
    if(mounted)setState(()=>_loading=false);
  }

  Future<void> _saveWeight() async{
    final v=double.tryParse(_weight.text.trim());
    if(v==null||v<=0||v>500){ToastService.showError('أدخل وزناً صحيحاً');return;}
    final now=DateTime.now();_history.insert(0,{'weight':v,'date':now.toIso8601String(),'note':_note.text.trim()});
    final p=await SharedPreferences.getInstance();await p.setString(_cacheKey,jsonEncode(_history));
    try{await HealthMetricsService.update({'weight':v,'weight_at':now.toIso8601String()});}catch(_){}
    _weight.clear();_note.clear();if(mounted){setState((){});ToastService.showSuccess('تم تسجيل الوزن');}
  }

  Future<void> _setTarget() async{
    final c=TextEditingController(text:_target?.toString()??'');
    final v=await showDialog<double>(context:context,builder:(_)=>AlertDialog(title:const Text('الوزن المستهدف'),content:TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'كجم')),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('إلغاء')),ElevatedButton(onPressed:(){final n=double.tryParse(c.text);if(n!=null&&n>0)Navigator.pop(context,n);},child:const Text('حفظ'))]));
    c.dispose();if(v!=null){final p=await SharedPreferences.getInstance();await p.setDouble('target_weight',v);setState(()=>_target=v);}
  }

  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;final latest=_history.isEmpty?null:_history.first;
    return Scaffold(backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF7FAFA),appBar:AppBar(title:const Text('تتبع الوزن'),backgroundColor:AppColors.primary,foregroundColor:Colors.white,actions:[IconButton(onPressed:_setTarget,icon:const Icon(Icons.track_changes_outlined))]),
      floatingActionButton:FloatingActionButton.extended(onPressed:()=>_addSheet(dark),backgroundColor:AppColors.primary,icon:const Icon(Icons.add_rounded),label:const Text('إضافة وزن')),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat,
      body:_loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.fromLTRB(16,16,16,100),children:[
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),borderRadius:BorderRadius.circular(24)),child:Row(children:[
          Container(width:58,height:58,decoration:BoxDecoration(color:Colors.white.withOpacity(.14),shape:BoxShape.circle),child:const Icon(Icons.monitor_weight_outlined,color:Colors.white,size:30)),
          const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('آخر وزن مسجل',style:TextStyle(color:Colors.white70)),const SizedBox(height:4),Text(latest==null?'لا يوجد': '${latest['weight']} كجم',style:const TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w900)),if(_target!=null)Text('الهدف: ${_target} كجم',style:const TextStyle(color:Colors.white70,fontSize:11))]))
        ])),const SizedBox(height:18),const Text('السجل',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:10),
        if(_history.isEmpty)Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(18)),child:const Text('لا توجد بيانات وزن بعد. أضف قياسك الفعلي.',textAlign:TextAlign.center))
        else ..._history.map((r)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[const Icon(Icons.monitor_weight_outlined,color:AppColors.primary),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${r['weight']} كجم',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text(_time(r['date']?.toString()??''),style:TextStyle(fontSize:11,color:dark?Colors.grey[400]:Colors.grey[600])),if((r['note']??'').toString().isNotEmpty)Text(r['note'].toString(),style:const TextStyle(fontSize:11))]))]))
      ]));
  }

  Future<void> _addSheet(bool dark) async{
    _weight.clear();_note.clear();
    await showModalBottomSheet(context:context,isScrollControlled:true,showDragHandle:true,builder:(_)=>Padding(padding:EdgeInsets.fromLTRB(20,10,20,20+MediaQuery.of(context).viewInsets.bottom),child:Column(mainAxisSize:MainAxisSize.min,children:[
      const Text('إضافة قياس وزن',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:14),
      TextField(controller:_weight,keyboardType:const TextInputType.numberWithOptions(decimal:true),textAlign:TextAlign.center,decoration:const InputDecoration(labelText:'الوزن بالكيلوجرام',border:OutlineInputBorder())),
      const SizedBox(height:10),TextField(controller:_note,decoration:const InputDecoration(labelText:'ملاحظة اختيارية',border:OutlineInputBorder())),const SizedBox(height:16),
      SizedBox(width:double.infinity,child:ElevatedButton(onPressed:(){Navigator.pop(context);_saveWeight();},style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white),child:const Text('حفظ القياس')))
    ]));
  }
  String _time(String s){final d=DateTime.tryParse(s);return d==null?s:'${d.day}/${d.month} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';}
}
