import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/advertisements/ad_management_screen.dart';
import 'package:sehatak/presentation/screens/platform/dashboard/platform_dashboard.dart';
import 'package:sehatak/presentation/screens/platform/marketplace_admin_dashboard.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});
  @override State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}
class _SuperAdminDashboardState extends State<SuperAdminDashboard> with SingleTickerProviderStateMixin {
  final _functions=FirebaseFunctions.instanceFor(region:'us-central1');
  final _title=TextEditingController(), _body=TextEditingController();
  late final TabController _tabs;
  String _target='all', _role='user', _type='admin_broadcast';
  bool _sending=false;
  static const roles=<String,String>{
    'user':'المستخدمون','doctor':'الأطباء','pharmacist':'الصيادلة','pharmacyOwner':'ملاك الصيدليات',
    'lab':'المختبرات','hospital':'المشافي','nurse':'الممرضون','paramedic':'المسعفون','delivery':'الموصلون','service':'الخدمات'
  };
  @override void initState(){super.initState();_tabs=TabController(length:4,vsync:this);}
  @override void dispose(){_tabs.dispose();_title.dispose();_body.dispose();super.dispose();}

  Future<void> _sendNotification() async {
    if(_title.text.trim().isEmpty||_body.text.trim().isEmpty){ToastService.showWarning('أدخل عنوان الإشعار ونصه');return;}
    setState(()=>_sending=true);
    try{
      final data=<String,dynamic>{'title':_title.text.trim(),'body':_body.text.trim(),'type':_type};
      if(_target=='role')data['role']=_role;
      if(_target=='user'){final id=await _chooseUser();if(id==null)return;data['userId']=id;}
      final result=await _functions.httpsCallable('adminSendNotification').call(data);
      final count=(result.data as Map)['count']??0;
      _title.clear();_body.clear();ToastService.showSuccess('تم إرسال الإشعار إلى '+count.toString()+' حساب');
    }catch(e){ToastService.showError('تعذر إرسال الإشعار: '+e.toString());}
    finally{if(mounted)setState(()=>_sending=false);}
  }

  Future<String?> _chooseUser() async {
    final snap=await FirebaseFirestore.instance.collection('users').limit(200).get();
    if(!mounted)return null;
    return showDialog<String>(context:context,builder:(c)=>AlertDialog(
      title:const Text('اختر المستخدم'),
      content:SizedBox(width:420,height:420,child:ListView(children:snap.docs.map((d){
        final x=d.data();
        return ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(x['name']?.toString()??'مستخدم'),
          subtitle:Text((x['email']?.toString()??'')+' • '+(x['role']?.toString()??'user')),onTap:()=>Navigator.pop(c,d.id));
      }).toList())),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('إلغاء'))],
    ));
  }

  Future<void> _userAction(String uid,String action) async {
    try{await _functions.httpsCallable('adminUpdateUser').call({'userId':uid,'action':action});if(mounted)ToastService.showSuccess('تم تنفيذ الإجراء');}
    catch(e){if(mounted)ToastService.showError('تعذر تنفيذ الإجراء: '+e.toString());}
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('لوحة المدير الأعلى'),backgroundColor:AppColors.primary,foregroundColor:Colors.white,
      actions:[IconButton(onPressed:()=>_tabs.animateTo(0),icon:const Icon(Icons.dashboard_outlined)),IconButton(onPressed:()=>FirebaseAuth.instance.signOut(),icon:const Icon(Icons.logout))],
      bottom:TabBar(controller:_tabs,tabs:const[Tab(text:'نظرة عامة'),Tab(text:'المستخدمون'),Tab(text:'الإشعارات'),Tab(text:'الخدمات')])),
    body:TabBarView(controller:_tabs,children:[_overview(),_users(),_notifications(),_services()]),
  );

  Widget _overview()=>RefreshIndicator(onRefresh:()async{setState((){});},child:ListView(padding:const EdgeInsets.all(16),children:[
    const Card(child:ListTile(leading:Icon(Icons.admin_panel_settings,color:AppColors.primary),title:Text('الإدارة العليا للمنصة'),subtitle:Text('الحسابات والتوثيق والإشعارات والإعلانات والسوق وسجل التدقيق.'))),
    const SizedBox(height:12),
    StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('users').snapshots(),builder:(c,s){
      final docs=s.data?.docs??const <QueryDocumentSnapshot<Map<String,dynamic>>>[];
      return GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,children:[
        _stat('المستخدمون',docs.length.toString(),Icons.people),
        _stat('النشطون',docs.where((d)=>d.data()['isSuspended']!=true).length.toString(),Icons.verified_user),
        _stat('الموقوفون',docs.where((d)=>d.data()['isSuspended']==true).length.toString(),Icons.block),
        _stat('المشرفون',docs.where((d)=>['admin','superAdmin'].contains(d.data()['role'])).length.toString(),Icons.security),
      ]);
    }),
    const SizedBox(height:12),
    _actionCard('إدارة التوثيق','مراجعة واعتماد الحسابات المهنية والمشافي',Icons.verified,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const PlatformDashboard()))),
    _actionCard('إدارة الإعلانات','إنشاء ومراجعة الحملات والإعلانات',Icons.campaign,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdManagementScreen()))),
    _actionCard('إدارة السوق','مراجعة منتجات الصيدليات وحالة النشر',Icons.storefront,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const MarketplaceAdminDashboard()))),
    _audit(),
  ]));

  Widget _stat(String t,String v,IconData i)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[Icon(i,color:AppColors.primary),const SizedBox(height:6),Text(v,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),Text(t)])));

  Widget _users()=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('users').orderBy('createdAt',descending:true).limit(200).snapshots(),builder:(c,s){
    if(s.hasError)return Center(child:Text('تعذر تحميل المستخدمين: '+s.error.toString()));
    if(!s.hasData)return const Center(child:CircularProgressIndicator());
    return ListView.separated(padding:const EdgeInsets.all(12),itemCount:s.data!.docs.length,separatorBuilder:(_,__)=>const SizedBox(height:6),itemBuilder:(c,i){
      final d=s.data!.docs[i],x=d.data(),uid=d.id,blocked=x['isSuspended']==true;
      return Card(child:ListTile(leading:CircleAvatar(child:Icon(blocked?Icons.block:Icons.person)),title:Text(x['name']?.toString()??'مستخدم'),
        subtitle:Text((x['email']?.toString()??'')+'\nالدور: '+(x['role']?.toString()??'user')+' • '+(blocked?'موقوف':'نشط')),isThreeLine:true,
        trailing:PopupMenuButton<String>(onSelected:(a)=>_userAction(uid,a),itemBuilder:(_)=>[
          PopupMenuItem(value:blocked?'unblock':'block',child:Text(blocked?'إلغاء الإيقاف':'إيقاف الحساب')),
          PopupMenuItem(value:x['isVerified']==true?'unverify':'verify',child:Text(x['isVerified']==true?'إلغاء التوثيق':'توثيق الحساب')),
          PopupMenuItem(value:x['accountDisabled']==true?'enable':'disable',child:Text(x['accountDisabled']==true?'تفعيل تسجيل الدخول':'تعطيل تسجيل الدخول')),
          const PopupMenuDivider(),
          ...roles.entries.map((e)=>PopupMenuItem(value:'role:'+e.key,child:Text('تعيين الدور: '+e.value))),
        ])));
    });
  });

  Widget _notifications()=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('إشعارات فورية',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
    const SizedBox(height:6),const Text('مستخدم محدد أو مجموعة حسب الدور أو جميع المستخدمين.'),
    const SizedBox(height:14),
    DropdownButtonFormField<String>(value:_target,decoration:const InputDecoration(labelText:'الجمهور'),items:const[
      DropdownMenuItem(value:'all',child:Text('كل المستخدمين')),DropdownMenuItem(value:'role',child:Text('حسب الدور')),DropdownMenuItem(value:'user',child:Text('مستخدم محدد'))],
      onChanged:(v){if(v!=null)setState(()=>_target=v);}),
    if(_target=='role')Padding(padding:const EdgeInsets.only(top:10),child:DropdownButtonFormField<String>(value:_role,decoration:const InputDecoration(labelText:'الدور'),items:roles.entries.map((e)=>DropdownMenuItem(value:e.key,child:Text(e.value))).toList(),onChanged:(v){if(v!=null)setState(()=>_role=v);})),
    const SizedBox(height:10),
    DropdownButtonFormField<String>(value:_type,decoration:const InputDecoration(labelText:'نوع الإشعار'),items:const['admin_broadcast','maintenance','announcement','important','promotion'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setState(()=>_type=v);}),
    const SizedBox(height:10),TextField(controller:_title,decoration:const InputDecoration(labelText:'عنوان الإشعار')),const SizedBox(height:10),TextField(controller:_body,maxLines:5,decoration:const InputDecoration(labelText:'نص الإشعار')),
    const SizedBox(height:14),SizedBox(height:52,child:FilledButton.icon(onPressed:_sending?null:_sendNotification,icon:const Icon(Icons.send),label:Text(_sending?'جارٍ الإرسال...':'إرسال فوراً'))),
  ]);

  Widget _services()=>ListView(padding:const EdgeInsets.all(16),children:[
    _actionCard('التوثيق المهني','الأطباء والمشافي والمختبرات وبقية الأدوار',Icons.verified,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const PlatformDashboard()))),
    _actionCard('الإعلانات','الحملات والإعلانات وإجراءات المراجعة',Icons.campaign,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdManagementScreen()))),
    _actionCard('منتجات الصيدليات','مراجعة واعتماد المنتجات قبل النشر',Icons.medication,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const MarketplaceAdminDashboard()))),
    _actionCard('الحسابات والصلاحيات','إيقاف وتفعيل وتوثيق وتغيير الدور',Icons.manage_accounts,()=>_tabs.animateTo(1)),
    _actionCard('الإشعارات الجماعية','مستخدم أو دور أو جميع المستخدمين',Icons.notifications_active,()=>_tabs.animateTo(2)),
    _actionCard('سجل التدقيق','مراجعة إجراءات الإدارة المسجلة',Icons.history,_showAudit),
  ]);

  Widget _actionCard(String t,String s,IconData i,VoidCallback onTap)=>Card(child:ListTile(leading:Icon(i,color:AppColors.primary),title:Text(t,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(s),trailing:const Icon(Icons.chevron_left),onTap:onTap));

  Widget _audit()=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('admin_audit_logs').orderBy('createdAt',descending:true).limit(10).snapshots(),builder:(c,s)=>Card(child:ListTile(leading:const Icon(Icons.history),title:const Text('آخر إجراءات الإدارة'),subtitle:Text((s.data?.size??0).toString()+' إجراء مسجل'),onTap:_showAudit)));

  void _showAudit()=>showModalBottomSheet(context:context,builder:(c)=>SizedBox(height:500,child:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('admin_audit_logs').orderBy('createdAt',descending:true).limit(50).snapshots(),builder:(c,s)=>ListView(children:(s.data?.docs??const[]).map((d)=>ListTile(title:Text(d.data()['action']?.toString()??''),subtitle:Text('الهدف: '+(d.data()['targetUserId']?.toString()??'-'))).toList())))));
}
