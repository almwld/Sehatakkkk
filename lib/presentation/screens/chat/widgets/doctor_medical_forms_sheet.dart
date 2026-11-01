import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/services/chat_media_transfer_service.dart';
import 'package:sehatak/core/services/medical_document_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

Future<void> showDoctorMedicalForms({required BuildContext context,required String chatId,required String patientId,required String patientName}) async {
  if (!await MedicalDocumentService.instance.isVerifiedDoctor()) { ToastService.showError(AppStrings.of(context).translate('إنشاء النماذج الطبية متاح للطبيب الموثق فقط.')); return; }
  final doctorId=FirebaseAuth.instance.currentUser!.uid;
  final doctor=await MedicalDocumentService.instance.userData(doctorId);
  final patient=await MedicalDocumentService.instance.userData(patientId); patient['uid']=patientId;
  if (!context.mounted)return;
  final form=await showModalBottomSheet<String>(context:context,isScrollControlled:true,showDragHandle:true,builder:(_)=>const _FormPicker());
  if(form==null||!context.mounted)return;
  final values=await showDialog<Map<String,dynamic>>(context:context,builder:(_)=>_FormEditor(type:form,patientName:patientName));
  if(values==null||!context.mounted)return;
  values['chatId']=chatId;
  try {
    final file=await MedicalDocumentService.instance.buildPdf(formType:form,doctor:doctor,patient:patient,values:values);
    final docs=await FirebaseFirestore.instance.collection('medical_documents').where('localPath',isEqualTo:file.path).limit(1).get();
    final docId=docs.docs.isNotEmpty?docs.docs.first.id:'';
    await ChatMediaTransferService.instance.enqueue(chatId:chatId,sourceFile:file,type:'file',folder:'medical_documents',preview:'📄 ${_title(context,form)}',fileName:file.uri.pathSegments.last,fileSize:'PDF',mimeType:'application/pdf');
    if(docId.isNotEmpty)await MedicalDocumentService.instance.saveToLibrary(file:file,documentId:docId,title:_title(context,form),chatId:chatId,formType:form);
    if(context.mounted){ToastService.showSuccess('${AppStrings.of(context).translate('تم إنشاء وإرسال')} ${AppStrings.of(context).translate(_title(context,form))} كـ PDF.');if(form=='rx'||form=='labs')await _serviceOptions(context,form,docId,patientId);}
  } catch(e){debugPrint('medical form: $e');if(context.mounted)ToastService.showError(AppStrings.of(context).translate('تعذر إنشاء النموذج الطبي.'));}
}
String _title(BuildContext context,String type){final value={'rx':'الوصفة الطبية','labs':'طلب الفحوصات','report':'التقرير الطبي','sick_leave':'الإجازة المرضية','referral':'الإحالة الطبية'}[type]??'المستند الطبي';return AppStrings.of(context).translate(value);}

class _FormPicker extends StatelessWidget{const _FormPicker();@override Widget build(BuildContext context)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
 Padding(padding:const EdgeInsets.all(16),child:Text(AppStrings.of(context).translate('النماذج الطبية للطبيب'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800))),
 for(final e in const [('rx','💊','وصفة طبية / RX'),('labs','🧪','طلب فحوصات / Laboratory Request'),('report','📋','تقرير طبي / Medical Report'),('sick_leave','🗓️','إجازة مرضية / Sick Leave'),('referral','↗️','إحالة طبية / Medical Referral')])ListTile(leading:Text(e.$2,style:const TextStyle(fontSize:22)),title:Text(AppStrings.of(context).translate(e.$3)),onTap:()=>Navigator.pop(context,e.$1)),const SizedBox(height:8)]));}

class _FormEditor extends StatefulWidget{final String type;final String patientName;const _FormEditor({required this.type,required this.patientName});@override State<_FormEditor> createState()=>_FormEditorState();}
class _FormEditorState extends State<_FormEditor>{
 final c=<String,TextEditingController>{};final tests=<String>[];final medications=<Map<String,String>>[];
 @override void initState(){super.initState();for(final k in ['general','diagnosis','history','findings','plan','reason','from','to','days','notes','destination','details'])c[k]=TextEditingController();}
 @override void dispose(){for(final x in c.values)x.dispose();super.dispose();}
 Widget f(String key,String label,{int max=3})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c[key],maxLines:max,decoration:InputDecoration(labelText:AppStrings.of(context).translate(label),border:const OutlineInputBorder())));
 Future<void> addMed()async{final name=TextEditingController(),dose=TextEditingController(),dir=TextEditingController(),notes=TextEditingController();final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:Text(AppStrings.of(context).translate('دواء')),content:SingleChildScrollView(child:Column(children:[TextField(controller:name,decoration:const InputDecoration(labelText:AppStrings.of(context).translate('اسم الدواء'))),TextField(controller:dose,decoration:const InputDecoration(labelText:AppStrings.of(context).translate('الجرعة'))),TextField(controller:dir,decoration:const InputDecoration(labelText:AppStrings.of(context).translate('طريقة/تكرار الاستخدام'))),TextField(controller:notes,decoration:const InputDecoration(labelText:AppStrings.of(context).translate('ملاحظات')))])),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(AppStrings.of(context).translate('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(context,true),child:Text(AppStrings.of(context).translate('إضافة')))]));if(ok==true&&name.text.trim().isNotEmpty)setState(()=>medications.add({'name':name.text.trim(),'dose':dose.text.trim(),'directions':dir.text.trim(),'notes':notes.text.trim(),'index':'${medications.length+1}'}));for(final x in [name,dose,dir,notes])x.dispose();}
 @override Widget build(BuildContext context){
  Widget body;
  if(widget.type=='rx')body=Column(children:[for(final m in medications)ListTile(dense:true,title:Text(m['name']!),subtitle:Text('${m['dose']} • ${m['directions']}')),OutlinedButton.icon(onPressed:addMed,icon:const Icon(Icons.add),label:Text(AppStrings.of(context).translate('إضافة دواء'))),f('general',AppStrings.of(context).translate('تعليمات عامة'))]);
  else if (widget.type == 'labs') {
    body = ListView(
      children: [
        for (final group in _labGroups.entries)
          ExpansionTile(
            title: Text(AppStrings.of(context).translate(group.key)),
            children: [
              for (final t in group.value)
                CheckboxListTile(
                  value: tests.contains(t),
                  onChanged: (v) => setState(() => v == true ? tests.add(t) : tests.remove(t)),
                  title: Text(t),
                ),
            ],
          ),
        f('notes', AppStrings.of(context).translate('ملاحظات')),
      ],
    );
  }
  else body=SingleChildScrollView(child:Column(children:[f(widget.type=='report'?'diagnosis':widget.type=='sick_leave'?'reason':'destination',AppStrings.of(context).translate(widget.type=='report'?'التشخيص':widget.type=='sick_leave'?'سبب الإجازة':'الجهة المحال إليها')),if(widget.type=='report')...[f('history',AppStrings.of(context).translate('التاريخ المرضي')),f('findings',AppStrings.of(context).translate('الفحص والنتائج')),f('plan',AppStrings.of(context).translate('الخطة العلاجية'))]else if(widget.type=='sick_leave')...[f('from',AppStrings.of(context).translate('من')),f('to',AppStrings.of(context).translate('إلى')),f('days',AppStrings.of(context).translate('عدد الأيام')),f('notes',AppStrings.of(context).translate('ملاحظات'))]else...[f('reason',AppStrings.of(context).translate('سبب الإحالة')),f('details',AppStrings.of(context).translate('تفاصيل الإحالة'))]]));
  return AlertDialog(title:Text('${_title(context,widget.type)} — ${widget.patientName}'),content:SizedBox(width:500,height:MediaQuery.of(context).size.height*.62,child:body),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text(AppStrings.of(context).translate('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(context,_values()),child:Text(AppStrings.of(context).translate('إنشاء PDF')))]);
 }
 Map<String,dynamic> _values()=>{'medications':medications,'tests':tests,for(final e in c.entries)e.key:e.value.text.trim()};
}
const Map<String,List<String>> _labGroups={
 'تحاليل الدم':['CBC','ESR','CRP','Blood Film','Reticulocyte Count','Blood Group & Rh','PT/INR','aPTT','D-Dimer','Ferritin','Iron/TIBC'],
 'الكيمياء الحيوية':['Glucose Fasting','HbA1c','Lipid Profile','LFT','RFT','Electrolytes','Uric Acid','Calcium','Magnesium','Amylase','Lipase'],
 'الهرمونات':['TSH','FT4','FT3','T3','T4','FSH','LH','Prolactin','Testosterone','Estradiol','Progesterone','Cortisol','Vitamin D','Vitamin B12'],
 'البول والبراز':['Urinalysis','Urine Culture','Stool Analysis','Stool Culture','Occult Blood','H. pylori Stool Antigen'],
 'الميكروبيولوجي والمناعة':['Blood Culture','Wound Culture','Sputum Culture','Throat Swab Culture','HIV Ag/Ab','HBsAg','Anti-HCV','VDRL/RPR','ANA','RF'],
 'القلب':['Troponin I/T','CK-MB','BNP/NT-proBNP'],
 'أخرى':['Pregnancy Test hCG','PSA','CEA','AFP','CA-125','CA 19-9','CA 15-3']
};

Future<void> _serviceOptions(BuildContext context,String form,String documentId,String patientId) async{
 final isLab=form=='labs';final type=isLab?'lab':'pharmacy';
 final choice=await showModalBottomSheet<String>(context:context,showDragHandle:true,builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
  Padding(padding:const EdgeInsets.all(16),child:Text(AppStrings.of(context).translate(isLab?'اختيار طريقة تنفيذ الفحوصات':'اختيار طريقة صرف الوصفة'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800))),
  ListTile(leading:const Icon(Icons.storefront_outlined),title:Text(AppStrings.of(context).translate(isLab?'اختيار مختبر من المنصة':'اختيار صيدلية من المنصة')),onTap:()=>Navigator.pop(context,'facility')),
  ListTile(leading:const Icon(Icons.home_work_outlined),title:Text(AppStrings.of(context).translate(isLab?'سحب العينة من المنزل':'توصيل الدواء للمنزل')),onTap:()=>Navigator.pop(context,'home')),
  ListTile(leading:const Icon(Icons.directions_walk_outlined),title:Text(AppStrings.of(context).translate(isLab?'الذهاب إلى المختبر':'الاستلام من الصيدلية')),onTap:()=>Navigator.pop(context,'self')),
 ])));
 if(choice==null)return;
 String? fid,fn;
 if(choice=='facility'){
  final names=<Map<String,String>>[];
  for(final collection in isLab?['labs','laboratories']:['pharmacies']){
   try{final s=await FirebaseFirestore.instance.collection(collection).limit(30).get();for(final d in s.docs){final x=d.data();names.add({'id':d.id,'name':(x['name']??x['title']??AppStrings.of(context).translate('منشأة صحية')).toString()});}}catch(_){}
   if(names.isNotEmpty)break;
  }
  if(!context.mounted)return;
  final selected=await showModalBottomSheet<Map<String,String>>(context:context,showDragHandle:true,builder:(_)=>SafeArea(child:SizedBox(height:420,child:names.isEmpty?Center(child:Text(AppStrings.of(context).translate('لا توجد منشآت متاحة حالياً'))):ListView(children:[for(final n in names)ListTile(leading:Icon(isLab?Icons.biotech:Icons.local_pharmacy),title:Text(n['name']!),onTap:()=>Navigator.pop(context,n))]))));
  if(selected==null)return;fid=selected['id'];fn=selected['name'];
 }
 await MedicalDocumentService.instance.createServiceRequest(documentId:documentId,type:type,patientId:patientId,mode:choice,facilityId:fid,facilityName:fn);
 if(context.mounted)ToastService.showSuccess(AppStrings.of(context).translate('تم تسجيل طلب')+' '+AppStrings.of(context).translate(isLab?'الفحوصات':'الصيدلية')+AppStrings.of(context).translate('؛ يمكن متابعة حالته من الطلبات.'));
}