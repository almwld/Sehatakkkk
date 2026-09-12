import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CallTestReportScreen extends StatefulWidget {
  const CallTestReportScreen({super.key});
  @override State<CallTestReportScreen> createState()=>_CallTestReportScreenState();
}
class _CallTestReportScreenState extends State<CallTestReportScreen>{
  final tests=<String,Map<String,String?>>{
    'foreground':{'title':'Foreground','status':null,'notes':''},'background':{'title':'Background','status':null,'notes':''},'terminated':{'title':'Terminated','status':null,'notes':''},'locked':{'title':'Locked Screen','status':null,'notes':''},'dnd':{'title':'Do Not Disturb','status':null,'notes':''},'battery':{'title':'Battery Saver','status':null,'notes':''},'multiple':{'title':'Multiple Calls','status':null,'notes':''},'network':{'title':'Poor Network','status':null,'notes':''},
  };
  @override Widget build(BuildContext context){final pass=tests.values.where((x)=>x['status']=='pass').length;final fail=tests.values.where((x)=>x['status']=='fail').length;return Scaffold(appBar:AppBar(title:const Text('تقرير اختبار المكالمات'),actions:[IconButton(onPressed:_share,icon:const Icon(Icons.share))]),body:Column(children:[Padding(padding:const EdgeInsets.all(16),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[_stat('نجح',pass),_stat('فشل',fail),_stat('لم يختبر',tests.length-pass-fail),_stat('النسبة',tests.isEmpty?0:(pass*100~/tests.length))])),Expanded(child:ListView(padding:const EdgeInsets.all(16),children:tests.entries.map((e)=>_card(e.key,e.value)).toList()))]));}
  Widget _stat(String t,int n)=>Column(children:[Text('$n',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),Text(t)]);
  Widget _card(String key,Map<String,String?> t)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[Row(children:[Expanded(child:Text(t['title']!,style:const TextStyle(fontWeight:FontWeight.bold))),IconButton(onPressed:()=>setState(()=>t['status']='pass'),icon:Icon(Icons.check_circle,color:t['status']=='pass'?Colors.green:Colors.grey)),IconButton(onPressed:()=>setState(()=>t['status']='fail'),icon:Icon(Icons.cancel,color:t['status']=='fail'?Colors.red:Colors.grey))]),TextField(initialValue:t['notes'],decoration:const InputDecoration(hintText:'ملاحظات'),onChanged:(v)=>t['notes']=v)])));
  Future<void> _share() async {final b=StringBuffer('Sehatak - Incoming Call Test Report\n${DateTime.now()}\n\n');for(final t in tests.values){b.writeln('${t['title']}: ${t['status']=='pass'?'PASS':t['status']=='fail'?'FAIL':'NOT TESTED'}');if((t['notes']??'').isNotEmpty)b.writeln('Notes: ${t['notes']}');}final dir=await getTemporaryDirectory();final f=File('${dir.path}/sehatak_call_test_report.txt');await f.writeAsString(b.toString());await Share.shareXFiles([XFile(f.path)],text:'Sehatak Incoming Call Test Report');}
}
