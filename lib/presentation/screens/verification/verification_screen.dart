import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class VerificationScreen extends StatefulWidget {
  final dynamic userModel;
  const VerificationScreen({super.key, this.userModel});
  @override State<VerificationScreen> createState()=>_VerificationScreenState();
}
class _VerificationScreenState extends State<VerificationScreen>{
  bool _loading=true,_submitting=false,_verified=false;
  String _status='notSubmitted',_role='user',_name='',_specialty='',_license='',_experience=''; String? _error;
  final _functions=FirebaseFunctions.instanceFor(region:'us-central1');
  static const _labels=<String,String>{'doctor':'طبيب','nurse':'ممرض','midwife':'قابلة وتوليد','physiotherapist':'أخصائي علاج طبيعي','pharmacist':'صيدلي','lab':'مختبر','paramedic':'مسعف','delivery':'موصل طلبات','service':'خدمي'};
  String get _roleLabel=>_labels[_role]??'الحساب المهني';
  List<String> get _requirements=>switch(_role){
    'doctor'=>['الاسم الكامل','التخصص الطبي','رقم الترخيص/المزاولة','سنوات الخبرة'],
    'pharmacist'=>['الاسم الكامل','التخصص','رقم الترخيص/المزاولة','سنوات الخبرة'],
    'lab'=>['اسم المختبر/المسؤول','التخصص أو نوع الخدمة','رقم الترخيص','سنوات الخبرة'],
    'nurse'||'midwife'||'physiotherapist'||'paramedic'=>['الاسم الكامل','التخصص','رقم الترخيص/المزاولة','سنوات الخبرة'],
    _=>['الاسم الكامل','بيانات الدور المهني','رقم الترخيص أو التصريح','الخبرة'],
  };
  @override void initState(){super.initState();_loadStatus();}
  Future<void> _loadStatus() async{try{
    final user=FirebaseAuth.instance.currentUser;if(user==null)throw Exception('يجب تسجيل الدخول أولاً');
    final snap=await FirebaseFirestore.instance.collection('users').doc(user.uid).get();final d=snap.data();
    if(!snap.exists||d==null)throw Exception('بيانات الحساب غير موجودة');if(!mounted)return;
    setState((){_role=d['role']?.toString()??'user';_name=d['name']?.toString()??'';_specialty=d['specialty']?.toString()??'';_license=d['licenseNumber']?.toString()??'';_experience=d['experience']?.toString()??'';_status=d['verificationStatus']?.toString()??'notSubmitted';_verified=d['isVerified']==true;_loading=false;});
  }catch(e){if(mounted)setState((){_error=e.toString().replaceFirst('Exception: ','');_loading=false;});}}
  Future<void> _submit() async{if(_submitting||_verified)return;setState(()=>_submitting=true);try{
    final result=await _functions.httpsCallable('submitVerificationRequest').call();if(!mounted)return;
    setState(()=>_status=result.data is Map&&result.data['status']!=null?result.data['status'].toString():'pending');
    ToastService.showSuccess('تم إرسال طلب توثيق $_roleLabel إلى المشرف للمراجعة');
  }on FirebaseFunctionsException catch(e){if(mounted)ToastService.showError(e.message??'تعذر إرسال طلب التوثيق');}catch(_){if(mounted)ToastService.showError('تعذر إرسال طلب التوثيق');}finally{if(mounted)setState(()=>_submitting=false);}}
  String get _title=>_verified?'الحساب موثق':_status=='pending'?'طلب التوثيق قيد المراجعة':_status=='rejected'?'يحتاج طلب التوثيق إلى تحديث':'توثيق حساب $_roleLabel';
  String get _description=>_verified?'تم اعتماد حسابك من مشرف المنصة.':_status=='pending'?'تم إرسال بياناتك إلى المشرف. سيصلك إشعار عند صدور القرار.':_status=='rejected'?'راجع بياناتك المطلوبة ثم أعد إرسال الطلب للمراجعة.':'أكمل المتطلبات التالية ثم أرسل الطلب إلى مشرف المنصة لاعتماد حسابك.';
  Widget _requirementsCard(bool dark)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('متطلبات التوثيق',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold)),const SizedBox(height:10),
    ..._requirements.map((item)=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.check_circle_outline,size:20,color:AppColors.primary),const SizedBox(width:8),Expanded(child:Text(item,style:TextStyle(color:dark?Colors.white70:Colors.black87)))]))),
  ])));
  Widget _dataCard()=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[_row('الاسم',_name),if(_specialty.isNotEmpty)_row('التخصص',_specialty),_row('رقم الترخيص',_license.isEmpty?'غير مضاف':_license),_row('الخبرة',_experience.isEmpty?'غير مضافة':'$_experience سنة')])));
  Widget _row(String t,String v)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:105,child:Text(t,style:const TextStyle(fontWeight:FontWeight.w600))),Expanded(child:Text(v.isEmpty?'غير متوفر':v))]));
  @override Widget build(BuildContext context){final dark=Theme.of(context).brightness==Brightness.dark;Widget body;
    if(_loading)body=const Center(child:CircularProgressIndicator(color:AppColors.primary));else if(_error!=null)body=Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.error_outline,size:56),const SizedBox(height:12),Text(_error!,textAlign:TextAlign.center),const SizedBox(height:20),ElevatedButton(onPressed:_loadStatus,child:const Text('إعادة المحاولة'))])));
    else body=Center(child:SingleChildScrollView(padding:const EdgeInsets.all(20),child:Column(children:[Icon(_verified?Icons.verified:Icons.assignment_turned_in_outlined,size:76,color:AppColors.primary),const SizedBox(height:14),Text(_title,textAlign:TextAlign.center,style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:dark?Colors.white:Colors.black87)),const SizedBox(height:8),Text(_description,textAlign:TextAlign.center,style:TextStyle(color:dark?Colors.white70:Colors.grey.shade700)),const SizedBox(height:20),_requirementsCard(dark),const SizedBox(height:12),_dataCard(),const SizedBox(height:20),if(!_verified&&_status!='pending')SizedBox(width:double.infinity,height:50,child:ElevatedButton(onPressed:_submitting?null:_submit,style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white),child:_submitting?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Text('إرسال طلب التوثيق للمشرف'))),const SizedBox(height:12),SizedBox(width:double.infinity,height:50,child:OutlinedButton(onPressed:()=>Navigator.pop(context),child:Text(_verified?'متابعة إلى التطبيق':'العودة')))])));
    return Scaffold(backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF8FAFC),appBar:CustomAppBar(title:'توثيق الحساب',backgroundColor:AppColors.primary,foregroundColor:Colors.white,elevation:0),body:body);
  }
}