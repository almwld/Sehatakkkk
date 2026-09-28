import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/health_metrics_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/add_action_button.dart';
import 'package:sehatak/presentation/widgets/health/health_chart.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});
  @override State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final _sys=TextEditingController(), _dia=TextEditingController(), _pulse=TextEditingController();
  StreamSubscription<Map<String,dynamic>>? _sub;
  List<Map<String,dynamic>> _readings=[];
  Map<String,dynamic> _history={};
  bool _loading=true,_adding=false,_saving=false;

  @override void initState(){super.initState();_listen();}
  void _listen(){
    _sub=HealthMetricsService.watch().listen((data){
      if(!mounted)return;
      final history=Map<String,dynamic>.from(data['blood_pressure_history'] as Map? ?? {});
      final readings=<Map<String,dynamic>>[];
      final keys=history.keys.toList()..sort((a,b)=>b.compareTo(a));
      for(final key in keys){
        final item=history[key];
        if(item is Map){
          readings.add({'systolic':item['systolic'],'diastolic':item['diastolic'],'pulse':item['pulse'],'time':item['time']??key});
        }
      }
      if(readings.isEmpty&&data['systolic'] is num&&data['diastolic'] is num){
        readings.add({'systolic':data['systolic'],'diastolic':data['diastolic'],'pulse':data['heartRate']??0,'time':data['blood_pressure_at']??''});
      }
      setState(()=>{_readings=readings,_history=history,_loading=false});
    });
  }
  @override void dispose(){_sub?.cancel();_sys.dispose();_dia.dispose();_pulse.dispose();super.dispose();}

  Future<void> _save() async{
    final s=int.tryParse(_sys.text.trim()),d=int.tryParse(_dia.text.trim()),p=int.tryParse(_pulse.text.trim());
    if(s==null||d==null||s<=0||d<=0||s>300||d>200){ToastService.showError('أدخل قياس ضغط صحيح');return;}
    setState(()=>_saving=true);
    try{
      final now=DateTime.now(),dateKey=_formatDate(now);
      await HealthMetricsService.update({'systolic':s,'diastolic':d,'heartRate':p??0,'blood_pressure_at':now.toIso8601String(),'blood_pressure_history':{dateKey:{'systolic':s,'diastolic':d,'pulse':p??0,'time':now.toIso8601String()}}});
      if(!mounted)return;
      setState(()=>{_adding=false,_saving=false});_sys.clear();_dia.clear();_pulse.clear();
      ToastService.showSuccess('تم حفظ القياس');
    }catch(e){if(!mounted)return;setState(()=>_saving=false);ToastService.showError('فشل الحفظ: $e');}
  }

  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark,last=_readings.isEmpty?null:_readings.first;
    return Scaffold(
      backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF7FAFA),
      appBar:AppBar(title:const Text('ضغط الدم'),backgroundColor:AppColors.primary,foregroundColor:Colors.white),
      floatingActionButton:AddActionButton(onPressed:()=>setState(()=>_adding=true),variant:AddButtonVariant.fab,label:'إضافة قراءة',heroTag:'bp_add_reading'),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat,
      body:_loading?const Center(child:CircularProgressIndicator()):Stack(children:[
        ListView(padding:const EdgeInsets.fromLTRB(16,16,16,100),children:[
          Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),borderRadius:BorderRadius.circular(24)),child:Column(children:[
            const Text('آخر قياس مسجل',style:TextStyle(color:Colors.white70)),const SizedBox(height:8),
            Text(last==null?'لا توجد قراءة':'${last['systolic']}/${last['diastolic']}',style:const TextStyle(color:Colors.white,fontSize:34,fontWeight:FontWeight.w900)),
            if(last!=null)Text('نبض ${last['pulse']} BPM',style:const TextStyle(color:Colors.white70,fontSize:12))
          ])),
          const SizedBox(height:16),const Text('التطور الأسبوعي',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:10),
          const SizedBox(height:220,child:HealthChart(historyKey:'blood_pressure_history',valueKey:'systolic',unit:'mmHg',color:AppColors.error,days:7)),
          const SizedBox(height:16),const Text('القياسات المسجلة',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:10),
          if(_readings.isEmpty)Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(18)),child:const Text('لم تُدخل أي قراءة بعد. سجّل القياس الفعلي من جهازك ليظهر في المؤشرات الصحية.',textAlign:TextAlign.center))
          else ..._readings.map((r)=>_card(r,dark))
        ]),if(_adding)_dialog(dark)
      ])
    );
  }

  Widget _card(Map<String,dynamic> r,bool dark)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[
    Container(width:44,height:44,decoration:BoxDecoration(color:AppColors.primary.withOpacity(.1),borderRadius:BorderRadius.circular(12)),child:const Icon(Icons.monitor_heart_outlined,color:AppColors.primary)),const SizedBox(width:12),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${r['systolic']}/${r['diastolic']} mmHg',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text(_time(r['time']?.toString()??''),style:TextStyle(fontSize:11,color:dark?Colors.grey[400]:Colors.grey[600]))])),
    Text('نبض ${r['pulse']}',style:const TextStyle(fontSize:12))
  ]));

  Widget _dialog(bool dark)=>GestureDetector(onTap:()=>setState(()=>_adding=false),child:Container(color:Colors.black54,child:Center(child:GestureDetector(onTap:(){},child:Container(
    margin:const EdgeInsets.all(24),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(22)),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      const Text('إضافة قياس ضغط',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:14),
      Row(children:[Expanded(child:TextField(controller:_sys,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الانقباضي',border:OutlineInputBorder()))),const SizedBox(width:10),Expanded(child:TextField(controller:_dia,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الانبساطي',border:OutlineInputBorder())))]),
      const SizedBox(height:12),TextField(controller:_pulse,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'النبض BPM (اختياري)',border:OutlineInputBorder())),const SizedBox(height:16),
      Row(children:[Expanded(child:TextButton(onPressed:_saving?null:()=>setState(()=>_adding=false),child:const Text('إلغاء'))),const SizedBox(width:10),Expanded(child:ElevatedButton(onPressed:_saving?null:_save,style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white),child:_saving?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Text('حفظ')))])
    ])
  ))));

  String _formatDate(DateTime d)=>'${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String _time(String s){final d=DateTime.tryParse(s);return d==null?s:'${d.day}/${d.month} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';}
}
