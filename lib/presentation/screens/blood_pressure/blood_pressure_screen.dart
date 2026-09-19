import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/health_metrics_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});
  @override State<BloodPressureScreen> createState()=>_BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen>{
  static const _cacheKey='blood_pressure_readings_v2';
  final _sys=TextEditingController(),_dia=TextEditingController(),_pulse=TextEditingController();
  List<Map<String,dynamic>> _readings=[]; bool _loading=true,_adding=false;

  @override void initState(){super.initState();_load();}
  @override void dispose(){_sys.dispose();_dia.dispose();_pulse.dispose();super.dispose();}

  Future<void> _load() async{
    final p=await SharedPreferences.getInstance(); final raw=p.getString(_cacheKey);
    if(raw!=null){try{_readings=List<Map<String,dynamic>>.from((jsonDecode(raw) as List).map((e)=>Map<String,dynamic>.from(e)));}catch(_){}}
    try{final d=await HealthMetricsService.read();if(_readings.isEmpty&&d['systolic'] is num&&d['diastolic'] is num){_readings=[{'systolic':d['systolic'],'diastolic':d['diastolic'],'pulse':d['heartRate']??0,'time':d['blood_pressure_at']??''}];}}catch(_){}
    if(mounted)setState(()=>_loading=false);
  }

  Future<void> _save() async{
    final s=int.tryParse(_sys.text.trim()),d=int.tryParse(_dia.text.trim()),p=int.tryParse(_pulse.text.trim());
    if(s==null||d==null||s<=0||d<=0||s>300||d>200){ToastService.showError('أدخل قياس ضغط صحيح');return;}
    final now=DateTime.now(); final item={'systolic':s,'diastolic':d,'pulse':p??0,'time':now.toIso8601String()};
    setState((){_readings.insert(0,item);_adding=false;});_sys.clear();_dia.clear();_pulse.clear();
    final prefs=await SharedPreferences.getInstance();await prefs.setString(_cacheKey,jsonEncode(_readings));
    try{await HealthMetricsService.update({'systolic':s,'diastolic':d,'heartRate':p??0,'blood_pressure_at':now.toIso8601String()});}catch(_){}
    if(mounted)ToastService.showSuccess('تم حفظ قياس الضغط');
  }

  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;final last=_readings.isEmpty?null:_readings.first;
    return Scaffold(backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF7FAFA),
      appBar:AppBar(title:const Text('ضغط الدم'),backgroundColor:AppColors.primary,foregroundColor:Colors.white),
      floatingActionButton:FloatingActionButton.extended(onPressed:()=>setState(()=>_adding=true),backgroundColor:AppColors.primary,icon:const Icon(Icons.add_rounded),label:const Text('إضافة قياس')),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat,
      body:_loading?const Center(child:CircularProgressIndicator()):Stack(children:[
        ListView(padding:const EdgeInsets.fromLTRB(16,16,16,100),children:[
          Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),borderRadius:BorderRadius.circular(24)),child:Column(children:[
            const Text('آخر قياس مسجل',style:TextStyle(color:Colors.white70)),const SizedBox(height:8),
            Text(last==null?'لا توجد قراءة':'${last['systolic']}/${last['diastolic']}',style:const TextStyle(color:Colors.white,fontSize:34,fontWeight:FontWeight.w900)),
            if(last!=null)Text('نبض ${last['pulse']} BPM',style:const TextStyle(color:Colors.white70,fontSize:12))
          ])),
          const SizedBox(height:16),const Text('القياسات المسجلة',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:10),
          if(_readings.isEmpty)Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(18)),child:const Text('لم تُدخل أي قراءة بعد. سجّل القياس الفعلي من جهازك ليظهر في المؤشرات الصحية.',textAlign:TextAlign.center))
          else ..._readings.map((r)=>_card(r,dark))
        ]),if(_adding)_dialog(dark)
      ]));
  }

  Widget _card(Map<String,dynamic> r,bool dark)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[
    Container(width:44,height:44,decoration:BoxDecoration(color:AppColors.primary.withOpacity(.1),borderRadius:BorderRadius.circular(12)),child:const Icon(Icons.monitor_heart_outlined,color:AppColors.primary)),
    const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${r['systolic']}/${r['diastolic']} mmHg',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text(_time(r['time']?.toString()??''),style:TextStyle(fontSize:11,color:dark?Colors.grey[400]:Colors.grey[600]))])),
    Text('نبض ${r['pulse']}',style:const TextStyle(fontSize:12))
  ]));

  Widget _dialog(bool dark) {
    return GestureDetector(
      onTap: () => setState(() => _adding = false),
      child: Container(color: Colors.black54, child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(22)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('إضافة قياس ضغط', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: TextField(controller: _sys, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الانقباضي', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _dia, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الانبساطي', border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: _pulse, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'النبض BPM (اختياري)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextButton(onPressed: () => setState(() => _adding = false), child: const Text('إلغاء'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('حفظ'))),
              ]),
            ]),
          ),
        ),
      )),
    );
  }
  String _time(String s){final d=DateTime.tryParse(s);return d==null?s:'${d.day}/${d.month} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';}
}
