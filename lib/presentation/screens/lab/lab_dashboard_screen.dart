import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});
  @override State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  @override void initState(){super.initState(); _tabs=TabController(length:4,vsync:this);}
  @override void dispose(){_tabs.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final uid=_uid;
    if(uid==null)return Scaffold(body:Center(child:Text(_t(context,'يجب تسجيل الدخول'))));
    return Scaffold(
      appBar:AppBar(
        title:Text(_t(context,'لوحة المختبر')),backgroundColor:AppColors.primary,foregroundColor:Colors.white,
        bottom:TabBar(controller:_tabs,isScrollable:true,tabs:[
          Tab(icon:Icon(Icons.dashboard_outlined),text:_t(context,'نظرة عامة')),
          Tab(icon:Icon(Icons.science_outlined),text:_t(context,'الفحوصات')),
          Tab(icon:Icon(Icons.book_online_outlined),text:_t(context,'الحجوزات')),
          Tab(icon:Icon(Icons.settings_outlined),text:_t(context,'الإعدادات')),
        ])),
      body:TabBarView(controller:_tabs,children:[
        _OverviewTab(uid:uid),_TestsTab(uid:uid),_BookingsTab(uid:uid),_SettingsTab(uid:uid)
      ]));
  }
}

class _OverviewTab extends StatelessWidget{
  final String uid; const _OverviewTab({required this.uid});
  @override Widget build(BuildContext context)=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
    stream:FirebaseFirestore.instance.collection('lab_bookings').where('labId',isEqualTo:uid).snapshots(),
    builder:(context,b)=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream:FirebaseFirestore.instance.collection('lab_tests').where('labId',isEqualTo:uid).where('isActive',isEqualTo:true).snapshots(),
      builder:(context,t){
        final docs=b.data?.docs??[];
        int count(String s)=>docs.where((d)=>d.data()['status']?.toString()==s).length;
        return ListView(padding:const EdgeInsets.all(16),children:[
          _stat(context,'حجوزات جديدة',count('pending').toString(),Icons.notifications_active_outlined),
          _stat(context,'مكتملة',count('completed').toString(),Icons.check_circle_outline),
          _stat(context,'الفحوصات النشطة',(t.data?.size??0).toString(),Icons.science_outlined),
          _stat(context,'إجمالي الحجوزات',docs.length.toString(),Icons.assignment_outlined),
        ]);
      }));
  Widget _stat(BuildContext context,String title,String value,IconData icon)=>Card(margin:const EdgeInsets.only(bottom:12),child:ListTile(
    leading:CircleAvatar(backgroundColor:AppColors.primary.withOpacity(.12),child:Icon(icon,color:AppColors.primary)),
    title:Text(_t(context,title)),subtitle:Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold))));
}

class _TestsTab extends StatelessWidget{
  final String uid; const _TestsTab({required this.uid});
  Future<void> _form(BuildContext context,{String? id,Map<String,dynamic>? old}) async{
    final name=TextEditingController(text:old?['name']?.toString()??'');
    final desc=TextEditingController(text:old?['description']?.toString()??'');
    final price=TextEditingController(text:old?['price']?.toString()??'');
    final duration=TextEditingController(text:old?['duration']?.toString()??'');
    bool saving = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t(ctx,id == null ? 'إضافة فحص جديد' : 'تعديل الفحص'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: _t(ctx,'اسم الفحص'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: _t(ctx,'الوصف'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: price,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _t(ctx,'السعر'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: duration,
                        decoration: InputDecoration(
                          labelText: _t(ctx,'المدة'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      if (name.text.trim().isEmpty || price.text.trim().isEmpty) {
                        ToastService.showError(_t(ctx,'الاسم والسعر مطلوبان'));
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                      final data = <String, dynamic>{
                        'labId': uid,
                        'name': name.text.trim(),
                        'description': desc.text.trim(),
                        'price': double.tryParse(price.text.trim()) ?? 0,
                        'duration': duration.text.trim(),
                        'isActive': true,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };
                      if (id == null) {
                        data['createdAt'] = FieldValue.serverTimestamp();
                        await FirebaseFirestore.instance.collection('lab_tests').add(data);
                      } else {
                        await FirebaseFirestore.instance.collection('lab_tests').doc(id).update(data);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      ToastService.showSuccess(_t(ctx,id == null ? 'تمت إضافة الفحص' : 'تم تحديث الفحص'));
                      } catch (e) {
                        if (ctx.mounted) { setSheetState(() => saving = false); ToastService.showError(_t(ctx,'تعذر حفظ الفحص، حاول مرة أخرى')); }
                      }
                    },
                    child: saving ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)) : Text(_t(ctx,id == null ? 'حفظ' : 'حفظ التعديل')),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
    name.dispose();desc.dispose();price.dispose();duration.dispose();
  }
  @override Widget build(BuildContext context)=>Scaffold(
    body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream:FirebaseFirestore.instance.collection('lab_tests').where('labId',isEqualTo:uid).snapshots(),
      builder:(context,s){
        if(s.hasError)return Center(child:Text(AppStrings.of(context).translate('تعذر تحميل الفحوصات') + ': ' + s.error.toString()));
        if(!s.hasData)return const Center(child:CircularProgressIndicator());
        final docs=[...s.data!.docs]..sort((a,b){
          final x=a.data()['createdAt'],y=b.data()['createdAt'];
          return x is Timestamp&&y is Timestamp?y.compareTo(x):0;
        });
        if(docs.isEmpty)return Center(child:Text(AppStrings.of(context).translate('لا توجد فحوصات — أضف أول فحص')));
        return ListView.builder(padding:const EdgeInsets.all(16),itemCount:docs.length,itemBuilder:(_,i){
          final d=docs[i].data();
          return Card(child:ListTile(leading:const Icon(Icons.science,color:AppColors.primary),
            title:Text(d['name']?.toString()??_t(context,'فحص')),
            subtitle:Text((d['price']??0).toString()+' '+_t(context,'ر.ي')+' • '+(d['duration']??'-').toString()),
            trailing:PopupMenuButton<String>(itemBuilder:(_)=>[
              PopupMenuItem(value:'edit',child:Text(_t(context,'تعديل'))),PopupMenuItem(value:'delete',child:Text(_t(context,'حذف')))],
              onSelected:(v)async{
                if(v=='edit')await _form(context,id:docs[i].id,old:d);
                if(v=='delete'){await FirebaseFirestore.instance.collection('lab_tests').doc(docs[i].id).delete();ToastService.showSuccess(_t(context,'تم حذف الفحص'));}
              })));
        });
      }),
    floatingActionButton:FloatingActionButton.extended(onPressed:()=>_form(context),icon:const Icon(Icons.add),label:Text(_t(context,'إضافة فحص'))));
}

class _BookingsTab extends StatelessWidget{
  final String uid; const _BookingsTab({required this.uid});
  Stream<QuerySnapshot<Map<String,dynamic>>> _stream(String status){
    var q=FirebaseFirestore.instance.collection('lab_bookings').where('labId',isEqualTo:uid);
    return status.isEmpty?q.snapshots():q.where('status',isEqualTo:status).snapshots();
  }
  Future<void> _status(BuildContext context,String id,String status)async{
    await FirebaseFirestore.instance.collection('lab_bookings').doc(id).update({'status':status,'updatedAt':FieldValue.serverTimestamp()});
    ToastService.showSuccess(_t(context,'تم تحديث حالة الحجز'));
  }
  Future<void> _results(BuildContext context,String id)async{
    final p=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png']);
    if(p==null||p.files.single.path==null)return;
    try{
      final f=File(p.files.single.path!);final nc=NextcloudService();
      final u=await nc.uploadFile(file:f,path:'sehatak/lab_results/$uid',fileName:DateTime.now().millisecondsSinceEpoch.toString()+'_'+f.uri.pathSegments.last);
      if(!u.success||u.url==null)throw Exception(_t(context,'فشل رفع الملف'));
      await FirebaseFirestore.instance.collection('lab_bookings').doc(id).update({'resultUrl':u.url!,'status':'completed','completedAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp()});
      ToastService.showSuccess(_t(context,'تم إرسال النتيجة'));
    }catch(e){ToastService.showError(_t(context,'فشل إرسال النتيجة')+': '+e.toString());}
  }
  Widget _list(String status)=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
    stream:_stream(status),builder:(context,s){
      if(s.hasError)return Center(child:Text(AppStrings.of(context).translate('تعذر تحميل الحجوزات') + ': ' + s.error.toString()));
      if(!s.hasData)return const Center(child:CircularProgressIndicator());
      final docs=[...s.data!.docs]..sort((a,b){
        final x=a.data()['createdAt'],y=b.data()['createdAt'];
        return x is Timestamp&&y is Timestamp?y.compareTo(x):0;
      });
      if(docs.isEmpty)return Center(child:Text(AppStrings.of(context).translate('لا توجد حجوزات في هذه الحالة')));
      return ListView.builder(padding:const EdgeInsets.all(16),itemCount:docs.length,itemBuilder:(_,i){
        final d=docs[i].data(),id=docs[i].id,statusValue=d['status']?.toString()??status;
        return Card(child:ListTile(title:Text(d['patientName']?.toString()??_t(context,'مريض')),
          subtitle:Text((d['testName']??_t(context,'فحص')).toString()+' • '+(d['price']??d['totalPrice']??0).toString()+' ر.ي'),
          trailing:statusValue=='pending'?Row(mainAxisSize:MainAxisSize.min,children:[
            IconButton(onPressed:()=>_status(context,id,'confirmed'),icon:const Icon(Icons.check,color:Colors.green)),
            IconButton(onPressed:()=>_status(context,id,'cancelled'),icon:const Icon(Icons.close,color:Colors.red))])
          :statusValue=='confirmed'?IconButton(onPressed:()=>_results(context,id),icon:const Icon(Icons.upload_file,color:AppColors.primary))
          :const Icon(Icons.check_circle,color:Colors.green)));
      });
    });
  @override Widget build(BuildContext context)=>DefaultTabController(length:4,child:Column(children:[
    TabBar(isScrollable:true,tabs:[Tab(text:_t(context,'جديدة')),Tab(text:_t(context,'مؤكدة')),Tab(text:_t(context,'مكتملة')),Tab(text:_t(context,'ملغاة'))]),
    Expanded(child:TabBarView(children:[_list('pending'),_list('confirmed'),_list('completed'),_list('cancelled')]))]));
}

class _SettingsTab extends StatelessWidget{
  final String uid; const _SettingsTab({required this.uid});
  @override Widget build(BuildContext context)=>StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
    stream:FirebaseFirestore.instance.collection('labs').doc(uid).snapshots(),
    builder:(context,s){
      if(!s.hasData)return const Center(child:CircularProgressIndicator());
      final d=s.data!.data()??{};
      return ListView(padding:const EdgeInsets.all(16),children:[
        ListTile(leading:const Icon(Icons.biotech),title:Text(_t(context,'اسم المختبر')),subtitle:Text(d['name']?.toString()??_t(context,'غير محدد'))),
        ListTile(leading:const Icon(Icons.location_on_outlined),title:Text(_t(context,'العنوان')),subtitle:Text(d['address']?.toString()??d['location']?.toString()??_t(context,'غير محدد'))),
        ListTile(leading:const Icon(Icons.phone_outlined),title:Text(_t(context,'الهاتف')),subtitle:Text(d['phone']?.toString()??_t(context,'غير متوفر'))),
        ListTile(leading:const Icon(Icons.verified_outlined),title:Text(_t(context,'حالة التوثيق')),subtitle:Text(d['isVerified']==true?_t(context,'موثق'):_t(context,'قيد المراجعة'))),
      ]);
    });
}
