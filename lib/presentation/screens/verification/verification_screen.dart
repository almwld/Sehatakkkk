import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class VerificationScreen extends StatefulWidget {
  final dynamic userModel;
  const VerificationScreen({super.key, this.userModel});
  @override State<VerificationScreen> createState()=>_VerificationScreenState();
}
class _VerificationScreenState extends State<VerificationScreen>{
  final _name=TextEditingController(),_age=TextEditingController(),_license=TextEditingController(),_experience=TextEditingController(),_specialty=TextEditingController(),_academic=TextEditingController();
  final Map<String,List<Map<String,dynamic>>> _docs={};
  bool _loading=true,_submitting=false,_verified=false;
  String _status='notSubmitted',_role='user'; String? _error;
  static const _labels=<String,String>{'doctor':'طبيب','nurse':'ممرض','midwife':'قابلة وتوليد','physiotherapist':'أخصائي علاج طبيعي','pharmacist':'صيدلي','lab':'مختبر','paramedic':'مسعف','hospital':'مستشفى','clinic':'عيادة','medical_center':'مركز طبي','dentist':'طبيب أسنان','dental':'عيادة أسنان','ophthalmology':'طبيب عيون','eye_clinic':'مركز عيون','optometrist':'أخصائي بصريات','veterinarian':'طبيب بيطري','delivery':'موصل طلبات','service':'خدمي'};
  String get _roleLabel=>_labels[_role]??'الحساب المهني';
  List<String> get _specialRequirements{switch(_role){case 'lab':return ['ترخيص المختبر','نطاق الفحوصات والخدمات','المسؤول الفني'];case 'hospital':return ['ترخيص المنشأة','الأقسام والخدمات','بيانات المسؤول'];case 'dental':case 'dentist':return ['ترخيص طب الأسنان','التخصص والخدمات السنية'];case 'ophthalmology':case 'eye_clinic':case 'optometrist':return ['ترخيص العيون/البصريات','الخدمات والأجهزة'];default:return ['رقم الترخيص أو المزاولة','التخصص والخدمات'];}}
  @override void initState(){super.initState();_load();}
  @override void dispose(){for(final c in [_name,_age,_license,_experience,_specialty,_academic])c.dispose();super.dispose();}
  Future<void> _load() async{try{final u=FirebaseAuth.instance.currentUser;if(u==null)throw Exception('يجب تسجيل الدخول أولاً');final s=await FirebaseFirestore.instance.collection('users').doc(u.uid).get();final request=await FirebaseFirestore.instance.collection('verification_requests').doc(u.uid).get();final d=s.data()??{};final rd=request.data()??{};final docs=rd['documents'];if(docs is Map){_docs..clear()..addAll(docs.map((k,v)=>MapEntry(k.toString(),v is List?v.map<Map<String,dynamic>>((x)=>x is Map?Map<String,dynamic>.from(x):<String,dynamic>{}).toList():<Map<String,dynamic>>[])));}if(!mounted)return;setState((){_role=d['role']?.toString()??'user';_name.text=d['name']?.toString()??d['displayName']?.toString()??'';_age.text=d['age']?.toString()??'';_academic.text=d['academicSummary']?.toString()??'';_license.text=d['licenseNumber']?.toString()??'';_experience.text=d['experience']?.toString()??'';_specialty.text=d['specialty']?.toString()??'';_status=rd['status']?.toString()??d['verificationStatus']?.toString()??'notSubmitted';_verified=d['isVerified']==true;_loading=false;});}catch(e){if(mounted)setState((){_error=e.toString();_loading=false;});}}
  Future<void> _pick(String category) async{final result=await FilePicker.platform.pickFiles(allowMultiple:true,type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png']);if(result==null)return;final u=FirebaseAuth.instance.currentUser;if(u==null)return;setState(()=>_submitting=true);try{final list=<Map<String,dynamic>>[];final nextcloud=NextcloudService();for(final x in result.files){if(x.path==null)continue;final file=File(x.path!);final size=await file.length();if(size>12*1024*1024)throw Exception('حجم الملف '+x.name+' أكبر من 12MB');final upload=await nextcloud.uploadFile(file:file,path:'sehatak/verification/'+u.uid+'/'+category,fileName:DateTime.now().millisecondsSinceEpoch.toString()+'_'+x.name);if(!upload.success||upload.url==null)throw Exception(upload.error??'فشل رفع الملف '+x.name);list.add({'name':x.name,'url':upload.url!,'uploadedAt':DateTime.now().toIso8601String()});}setState(()=>_docs[category]=[...(_docs[category]??[]),...list]);ToastService.showSuccess('تم رفع '+list.length.toString()+' ملف');}catch(e){ToastService.showError(e.toString().replaceFirst('Exception: ',''));}finally{if(mounted)setState(()=>_submitting=false);}}

  Future<void> _submitVerification() async {
    if (_submitting || _verified) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      ToastService.showError('يجب تسجيل الدخول أولاً');
      return;
    }
    if (_name.text.trim().isEmpty || _license.text.trim().isEmpty || _specialty.text.trim().isEmpty) {
      ToastService.showError('أكمل الاسم والتخصص ورقم الترخيص قبل الإرسال');
      return;
    }
    if ((_docs['identity'] ?? []).isEmpty) {
      ToastService.showError('ارفع الهوية والمستندات الرسمية أولاً');
      return;
    }
    setState(() => _submitting = true);
    try {
      final documents = <String, dynamic>{
        for (final entry in _docs.entries) entry.key: entry.value,
      };
      await FirebaseFirestore.instance.collection('verification_requests').doc(u.uid).set({
        'userId': u.uid,
        'role': _role,
        'name': _name.text.trim(),
        'age': int.tryParse(_age.text.trim()),
        'licenseNumber': _license.text.trim(),
        'experience': _experience.text.trim(),
        'specialty': _specialty.text.trim(),
        'academicSummary': _academic.text.trim(),
        'documents': documents,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('users').doc(u.uid).update({
        'verificationStatus': 'pending',
        'verificationRequestId': u.uid,
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
        'licenseNumber': _license.text.trim(),
        'experience': _experience.text.trim(),
        'specialty': _specialty.text.trim(),
        'academicSummary': _academic.text.trim(),
      });
      if (mounted) setState(() => _status = 'pending');
      ToastService.showSuccess('تم إرسال طلب التوثيق للمراجعة');
    } catch (e) {
      ToastService.showError('تعذر إرسال طلب التوثيق');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _field(TextEditingController c,String label,{TextInputType? type})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c,keyboardType:type,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
  Widget _upload(String key,String title)=>Card(child:ListTile(leading:const Icon(Icons.upload_file,color:AppColors.primary),title:Text(title),subtitle:Text((_docs[key]??[]).length.toString()+' ملف مرفوع'),trailing:IconButton(onPressed:_submitting?null:()=>_pick(key),icon:const Icon(Icons.add_circle_outline))));
  @override Widget build(BuildContext context){if(_loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));if(_error!=null)return Scaffold(body:Center(child:Text(_error!)));final dark=Theme.of(context).brightness==Brightness.dark;return Scaffold(backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF8FAFC),appBar:CustomAppBar(title:'توثيق حساب '+_roleLabel,backgroundColor:AppColors.primary,foregroundColor:Colors.white,elevation:0),bottomNavigationBar:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(16,8,16,12),child:SizedBox(width:double.infinity,child:ElevatedButton.icon(onPressed:(_submitting||_verified||_status=='pending')?null:_submitVerification,icon:Icon(_status=='pending'?Icons.hourglass_top_rounded:Icons.send_rounded),label:Text(_status=='pending'?'طلب التوثيق قيد المراجعة':_submitting?'جاري إرسال طلب التوثيق...':'إرسال طلب التوثيق والتحقق من المستندات'),style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white,padding:const EdgeInsets.symmetric(vertical:15))))),body:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(children:[Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_verified?'الحساب موثق':_status=='pending'?'الطلب قيد المراجعة':'يجب توثيق حسابك',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:8),Text(_verified?'تم اعتماد حسابك ويمكنك استخدام ميزات دورك.':_status=='pending'?'تم إرسال ملفك إلى المشرف وستصلك النتيجة عبر الإشعارات.':'لاستخدام ميزات '+_roleLabel+' يجب استكمال التوثيق وإرفاق المؤهلات والمستندات المطلوبة.')]))),const SizedBox(height:12),_field(_name,'الاسم الكامل'),_field(_age,'العمر',type:TextInputType.number),_field(_specialty,'التخصص'),_field(_license,'رقم الترخيص/المزاولة'),_field(_experience,'سنوات الخبرة'),_field(_academic,'ملخص السجل الأكاديمي'),const SizedBox(height:6),..._specialRequirements.map((x)=>Align(alignment:AlignmentDirectional.centerStart,child:Padding(padding:const EdgeInsets.only(bottom:6),child:Text('• '+x)))),_upload('academicRecord','السجل الأكاديمي'),_upload('certificates','الشهادات والمؤهلات'),_upload('professionalRecord','السجل المهني/الخبرات'),_upload('healthRecord','السجل الصحي/اللياقة المهنية'),_upload('identity','الهوية والمستندات الرسمية'),const SizedBox(height:10),const Text('الملفات المدعومة: PDF و JPG و PNG — الحد الأقصى 12MB للملف.',style:TextStyle(color:Colors.grey,fontSize:12)),const SizedBox(height:80)])));}
}
