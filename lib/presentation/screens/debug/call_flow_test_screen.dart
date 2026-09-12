import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/notification_sender.dart';
import 'package:sehatak/presentation/screens/chat/incoming_call_screen.dart';

class CallFlowTestScreen extends StatefulWidget {
  const CallFlowTestScreen({super.key});
  @override State<CallFlowTestScreen> createState() => _CallFlowTestScreenState();
}

class _CallFlowTestScreenState extends State<CallFlowTestScreen> {
  final receiver = TextEditingController();
  final results = <Map<String,String>>[];
  bool busy = false;
  void add(String title,String status,[String message='']) => setState(() => results.insert(0, {'title':title,'status':status,'message':message}));

  Future<void> run(String title, Future<String> Function() action) async {
    if(busy)return; setState(()=>busy=true); add(title,'running');
    try { final m=await action(); setState(()=>results[0]={'title':title,'status':'pass','message':m}); }
    catch(e){setState(()=>results[0]={'title':title,'status':'fail','message':e.toString()});}
    finally{if(mounted)setState(()=>busy=false);}
  }

  Future<String> checkFcm() async {
    final t=await FirebaseMessaging.instance.getToken(); if(t==null||t.isEmpty) throw Exception('لا يوجد FCM token');
    return 'FCM token موجود (${t.length} chars)';
  }
  Future<String> checkNotificationServer() async => (await NotificationSender.instance.isHealthy()) ? 'Notification Server OK' : 'Notification Server غير متاح';
  Future<String> checkFirestore() async { final s=await FirebaseFirestore.instance.collection('calls').where('participants',arrayContains:FirebaseAuth.instance.currentUser!.uid).limit(5).get(); return 'calls visible: ${s.docs.length}'; }
  Future<String> checkIncomingUi() async { if(!mounted) return 'not mounted'; Navigator.of(context).push(MaterialPageRoute(builder:(_)=>IncomingCallScreen(callId:'ui_test_${DateTime.now().millisecondsSinceEpoch}',callerName:'د. اختبار',callerId:'test-caller',chatId:'test-chat',isVideo:false,onCallAnswered:(_){},),fullscreenDialog:true)); return 'IncomingCallScreen opened directly'; }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('اختبار مسار المكالمة')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      TextField(controller:receiver,decoration:const InputDecoration(labelText:'UID المستقبل (اختياري)',border:OutlineInputBorder())),
      const SizedBox(height:12),
      _button('فحص FCM Token',()=>run('FCM Token',checkFcm)),
      _button('فحص Notification Server',()=>run('Notification Server',checkNotificationServer)),
      _button('فحص Firestore calls',()=>run('Firestore',checkFirestore)),
      _button('فتح IncomingCallScreen مباشرة',()=>run('IncomingCallScreen UI',checkIncomingUi)),
      const Divider(height:28),
      ...results.map((r)=>Card(child:ListTile(leading:Icon(r['status']=='pass'?Icons.check_circle:r['status']=='fail'?Icons.error:Icons.hourglass_top),title:Text(r['title']!),subtitle:Text(r['message']!))))
    ]));
  Widget _button(String t,VoidCallback f)=>Padding(padding:const EdgeInsets.only(bottom:8),child:SizedBox(width:double.infinity,child:ElevatedButton(onPressed:busy?null:f,child:Text(t))));
  @override void dispose(){receiver.dispose();super.dispose();}
}
