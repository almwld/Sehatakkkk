import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

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
    if(uid==null)return const Scaffold(body:Center(child:Text('يجب تسجيل الدخول')));
    return Scaffold(
      appBar:AppBar(
        title:const Text('لوحة المختبر'),backgroundColor:AppColors.primary,foregroundColor:Colors.white,
        bottom:TabBar(controller:_tabs,isScrollable:true,tabs:const[
          Tab(icon:Icon(Icons.dashboard_outlined),text:'نظرة عامة'),
          Tab(icon:Icon(Icons.science_outlined),text:'الفحوصات'),
          Tab(icon:Icon(Icons.book_online_outlined),text:'الحجوزات'),
          Tab(icon:Icon(Icons.settings_outlined),text:'الإعدادات'),
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
          _stat('حجوزات جديدة',count('pending').toString(),Icons.notifications_active_outlined),
          _stat('مكتملة',count('completed').toString(),Icons.check_circle_outline),
          _stat('الفحوصات النشطة',(t.data?.size??0).toString(),Icons.science_outlined),
          _stat('إجمالي الحجوزات',docs.length.toString(),Icons.assignment_outlined),
        ]);
      }));
  Widget _stat(String title,String value,IconData icon)=>Card(margin:const EdgeInsets.only(bottom:12),child:ListTile(
    leading:CircleAvatar(backgroundColor:AppColors.primary.withOpacity(.12),child:Icon(icon,color:AppColors.primary)),
    title:Text(title),subtitle:Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold))));
}

class _TestsTab extends StatelessWidget{
  final String uid; const _TestsTab({required this.uid});
  Future<void> _form(BuildContext context,{String? id,Map<String,dynamic>? old}) async{
    final name=TextEditingController(text:old?['name']?.toString()??'');
    final desc=TextEditingController(text:old?['description']?.toString()??'');
    final price=TextEditingController(text:old?['price']?.toString()??'');
    final duration=TextEditingController(text:old?['duration']?.toString()??'');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
                  id == null ? 'إضافة فحص جديد' : 'تعديل الفحص',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'اسم الفحص',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
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
                        decoration: const InputDecoration(
                          labelText: 'السعر',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: duration,
                        decoration: const InputDecoration(
                          labelText: 'المدة',
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
                    onPressed: () async {
                      if (name.text.trim().isEmpty || price.text.trim().isEmpty) {
                        ToastService.showError('الاسم والسعر مطلوبان');
                        return;
                      }
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
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      ToastService.showSuccess(
                        id == null ? 'تمت إضافة الفحص' : 'تم تحديث الفحص',
                      );
                    },
                    child: Text(id == null ? 'حفظ' : 'حفظ التعديل'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    name.dispose();desc.dispose();price.dispose();duration.dispose();
  }
  @override Widget build(BuildContext context)=>Scaffold(
    body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream:FirebaseFirestore.instance.collection('lab_tests').where('labId',isEqualTo:uid).snapshots(),
      builder:(context,s){
        if(s.hasError)return Center(child:Text('تعذر تحميل الفحوصات: '+s.error.toString()));
        if(!s.hasData)return const Center(child:CircularProgressIndicator());
        final docs=[...s.data!.docs]..sort((a,b){
          final x=a.data()['createdAt'],y=b.data()['createdAt'];
          return x is Timestamp&&y is Timestamp?y.compareTo(x):0;
        });
        if(docs.isEmpty)return const Center(child:Text('لا توجد فحوصات — أضف أول فحص'));
        return ListView.builder(padding:const EdgeInsets.all(16),itemCount:docs.length,itemBuilder:(_,i){
          final d=docs[i].data();
          return Card(child:ListTile(leading:const Icon(Icons.science,color:AppColors.primary),
            title:Text(d['name']?.toString()??'فحص'),
            subtitle:Text((d['price']??0).toString()+' ر.ي • '+(d['duration']??'-').toString()),
            trailing:PopupMenuButton<String>(itemBuilder:(_)=>const[
              PopupMenuItem(value:'edit',child:Text('تعديل')),PopupMenuItem(value:'delete',child:Text('حذف'))],
              onSelected:(v)async{
                if(v=='edit')await _form(context,id:docs[i].id,old:d);
                if(v=='delete'){await FirebaseFirestore.instance.collection('lab_tests').doc(docs[i].id).delete();ToastService.showSuccess('تم حذف الفحص');}
              })));
        });
      }),
    floatingActionButton:FloatingActionButton.extended(onPressed:()=>_form(context),icon:const Icon(Icons.add),label:const Text('إضافة فحص')));
}

class _BookingsTab extends StatelessWidget{
  final String uid; const _BookingsTab({required this.uid});
  Stream<QuerySnapshot<Map<String,dynamic>>> _stream(String status){
    var q=FirebaseFirestore.instance.collection('lab_bookings').where('labId',isEqualTo:uid);
    return status.isEmpty?q.snapshots():q.where('status',isEqualTo:status).snapshots();
  }
  Future<void> _status(String id,String status)async{
    await FirebaseFirestore.instance.collection('lab_bookings').doc(id).update({'status':status,'updatedAt':FieldValue.serverTimestamp()});
    ToastService.showSuccess('تم تحديث حالة الحجز');
  }
  Future<void> _results(BuildContext context,String id)async{
    final p=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png']);
    if(p==null||p.files.single.path==null)return;
    try{
      final f=File(p.files.single.path!);final nc=NextcloudService();
      final u=await nc.uploadFile(file:f,path:'sehatak/lab_results/$uid',fileName:DateTime.now().millisecondsSinceEpoch.toString()+'_'+f.uri.pathSegments.last);
      if(!u.success||u.url==null)throw Exception('فشل رفع الملف');
      await FirebaseFirestore.instance.collection('lab_bookings').doc(id).update({'resultUrl':u.url!,'status':'completed','completedAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp()});
      ToastService.showSuccess('تم إرسال النتيجة');
    }catch(e){ToastService.showError('فشل إرسال النتيجة: '+e.toString());}
  }
  Widget _list(String status)=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
    stream:_stream(status),builder:(context,s){
      if(s.hasError)return Center(child:Text('تعذر تحميل الحجوزات: '+s.error.toString()));
      if(!s.hasData)return const Center(child:CircularProgressIndicator());
      final docs=[...s.data!.docs]..sort((a,b){
        final x=a.data()['createdAt'],y=b.data()['createdAt'];
        return x is Timestamp&&y is Timestamp?y.compareTo(x):0;
      });
      if(docs.isEmpty)return const Center(child:Text('لا توجد حجوزات في هذه الحالة'));
      return ListView.builder(padding:const EdgeInsets.all(16),itemCount:docs.length,itemBuilder:(_,i){
        final d=docs[i].data(),id=docs[i].id,statusValue=d['status']?.toString()??status;
        return Card(child:ListTile(title:Text(d['patientName']?.toString()??'مريض'),
          subtitle:Text((d['testName']??'فحص').toString()+' • '+(d['price']??d['totalPrice']??0).toString()+' ر.ي'),
          trailing:statusValue=='pending'?Row(mainAxisSize:MainAxisSize.min,children:[
            IconButton(onPressed:()=>_status(id,'confirmed'),icon:const Icon(Icons.check,color:Colors.green)),
            IconButton(onPressed:()=>_status(id,'cancelled'),icon:const Icon(Icons.close,color:Colors.red))])
          :statusValue=='confirmed'?IconButton(onPressed:()=>_results(context,id),icon:const Icon(Icons.upload_file,color:AppColors.primary))
          :const Icon(Icons.check_circle,color:Colors.green)));
      });
    });
  @override Widget build(BuildContext context)=>DefaultTabController(length:4,child:Column(children:[
    const TabBar(isScrollable:true,tabs:[Tab(text:'جديدة'),Tab(text:'مؤكدة'),Tab(text:'مكتملة'),Tab(text:'ملغاة')]),
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
        ListTile(leading:const Icon(Icons.biotech),title:const Text('اسم المختبر'),subtitle:Text(d['name']?.toString()??'غير محدد')),
        ListTile(leading:const Icon(Icons.location_on_outlined),title:const Text('العنوان'),subtitle:Text(d['address']?.toString()??d['location']?.toString()??'غير محدد')),
        ListTile(leading:const Icon(Icons.phone_outlined),title:const Text('الهاتف'),subtitle:Text(d['phone']?.toString()??'غير متوفر')),
        ListTile(leading:const Icon(Icons.verified_outlined),title:const Text('حالة التوثيق'),subtitle:Text(d['isVerified']==true?'موثق':'قيد المراجعة')),
      ]);
    });
}
