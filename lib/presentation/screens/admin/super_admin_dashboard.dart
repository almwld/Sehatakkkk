import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});
  @override State<SuperAdminDashboard> createState()=>_SuperAdminDashboardState();
}
class _SuperAdminDashboardState extends State<SuperAdminDashboard>{
  bool _loading=true; Map<String,dynamic> _report={};
  final _functions=FirebaseFunctions.instanceFor(region:'us-central1');
  @override void initState(){super.initState();_load();}
  Future<void> _load() async{try{final r=await _functions.httpsCallable('getSuperAdminDailyReport').call();if(mounted)setState(()=>_report=Map<String,dynamic>.from(r.data as Map));}catch(e){if(mounted)ToastService.showError(e.toString());}finally{if(mounted)setState(()=>_loading=false);}}
  @override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('الإدارة العليا للمنصة'),backgroundColor:AppColors.primary,foregroundColor:Colors.white,actions:[IconButton(onPressed:_load,icon:const Icon(Icons.refresh))]),body:_loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(16),children:[
    Card(child:ListTile(leading:const Icon(Icons.admin_panel_settings,color:AppColors.primary),title:const Text('المدير الأعلى'),subtitle:const Text('صلاحية التحكم والإشراف الأعلى على المنصة'))),
    const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('تقرير اليوم',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:8),Text('التاريخ: '+(_report['date']?.toString()??'')),Text('إجمالي إجراءات المشرفين: '+(_report['totalActions']?.toString()??'0')),const Divider(),...Map<String,dynamic>.from((_report['actions'] as Map?)??{}).entries.map((e)=>ListTile(dense:true,title:Text(e.key),trailing:Text(e.value.toString(),style:const TextStyle(fontWeight:FontWeight.bold))))]))),
    const SizedBox(height:12),const Card(child:ListTile(leading:Icon(Icons.security),title:Text('سجل التدقيق'),subtitle:Text('تُسجل قرارات التوثيق وإجراءات الإدارة مع صاحب الإجراء والتاريخ.'))),
  ]));}
}
