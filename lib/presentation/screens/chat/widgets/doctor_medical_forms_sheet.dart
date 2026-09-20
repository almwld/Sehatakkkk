import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/services/chat_media_transfer_service.dart';
import 'package:sehatak/core/services/medical_document_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

Future<void> showDoctorMedicalForms({required BuildContext context,required String chatId,required String patientId,required String patientName}) async {
  if (!await MedicalDocumentService.instance.isVerifiedDoctor()) { ToastService.showError('إنشاء النماذج الطبية متاح للطبيب الموثق فقط.'); return; }
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
    await ChatMediaTransferService.instance.enqueue(chatId:chatId,sourceFile:file,type:'file',folder:'medical_documents',preview:'📄 ${_title(form)}',fileName:file.uri.pathSegments.last,fileSize:'PDF',mimeType:'application/pdf');
    if(docId.isNotEmpty)await MedicalDocumentService.instance.saveToLibrary(file:file,documentId:docId,title:_title(form),chatId:chatId,formType:form);
    if(context.mounted){ToastService.showSuccess('تم إنشاء وإرسال ${_title(form)} كـ PDF.');if(form=='rx'||form=='labs')await _serviceOptions(context,form,docId,patientId);}
  } catch(e){debugPrint('medical form: $e');if(context.mounted)ToastService.showError('تعذر إنشاء النموذج الطبي.');}
}
String _title(String type)=>{'rx':'الوصفة الطبية','labs':'طلب الفحوصات','report':'التقرير الطبي','sick_leave':'الإجازة المرضية','referral':'الإحالة الطبية'}[type]??'المستند الطبي';

class _FormPicker extends StatelessWidget{const _FormPicker();@override Widget build(BuildContext context)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
 const Padding(padding:EdgeInsets.all(16),child:Text('النماذج الطبية للطبيب',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800))),
 for(final e in const [('rx','💊','وصفة طبية / RX'),('labs','🧪','طلب فحوصات / Laboratory Request'),('report','📋','تقرير طبي / Medical Report'),('sick_leave','🗓️','إجازة مرضية / Sick Leave'),('referral','↗️','إحالة طبية / Medical Referral')])ListTile(leading:Text(e.$2,style:const TextStyle(fontSize:22)),title:Text(e.$3),onTap:()=>Navigator.pop(context,e.$1)),const SizedBox(height:8)]));}

class _FormEditor extends StatefulWidget{final String type;final String patientName;const _FormEditor({required this.type,required this.patientName});@override State<_FormEditor> createState()=>_FormEditorState();}
class _FormEditorState extends State<_FormEditor>{
 final c=<String,TextEditingController>{};final tests=<String>[];final medications=<Map<String,String>>[];
 @override void initState(){super.initState();for(final k in ['general','diagnosis','history','findings','plan','reason','from','to','days','notes','destination','details'])c[k]=TextEditingController();}
 @override void dispose(){for(final x in c.values)x.dispose();super.dispose();}
 Widget f(String key,String label,{int max=3})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c[key],maxLines:max,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
 Future<void> addMed()async{final name=TextEditingController(),dose=TextEditingController(),dir=TextEditingController(),notes=TextEditingController();final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:const Text('دواء'),content:SingleChildScrollView(child:Column(children:[TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الدواء')),TextField(controller:dose,decoration:const InputDecoration(labelText:'الجرعة')),TextField(controller:dir,decoration:const InputDecoration(labelText:'طريقة/تكرار الاستخدام')),TextField(controller:notes,decoration:const InputDecoration(labelText:'ملاحظات'))])),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('إضافة'))]));if(ok==true&&name.text.trim().isNotEmpty)setState(()=>medications.add({'name':name.text.trim(),'dose':dose.text.trim(),'directions':dir.text.trim(),'notes':notes.text.trim(),'index':'${medications.length+1}'}));for(final x in [name,dose,dir,notes])x.dispose();}
 @override Widget build(BuildContext context){
  Widget body;
  if(widget.type=='rx')body=Column(children:[for(final m in medications)ListTile(dense:true,title:Text(m['name']!),subtitle:Text('${m['dose']} • ${m['directions']}')),OutlinedButton.icon(onPressed:addMed,icon:const Icon(Icons.add),label:const Text('إضافة دواء')),f('general','تعليمات عامة')]);
  else if (widget.type == 'labs') {
    body = ListView(
      children: [
        for (final group in _labGroups.entries)
          ExpansionTile(
            title: Text(group.key),
            children: [
              for (final t in group.value)
                CheckboxListTile(
                  value: tests.contains(t),
                  onChanged: (v) => setState(() => v == true ? tests.add(t) : tests.remove(t)),
                  title: Text(t),
                ),
            ],
          ),
        f('notes', 'ملاحظات'),
      ],
    );
  }
  else body=SingleChildScrollView(child:Column(children:[f(widget.type=='report'?'diagnosis':widget.type=='sick_leave'?'reason':'destination',widget.type=='report'?'التشخيص':widget.type=='sick_leave'?'سبب الإجازة':'الجهة المحال إليها'),if(widget.type=='report')...[f('history','التاريخ المرضي'),f('findings','الفحص والنتائج'),f('plan','الخطة العلاجية')]else if(widget.type=='sick_leave')...[f('from','من'),f('to','إلى'),f('days','عدد الأيام'),f('notes','ملاحظات')]else...[f('reason','سبب الإحالة'),f('details','تفاصيل الإحالة')]]));
  return AlertDialog(title:Text('${_title(widget.type)} — ${widget.patientName}'),content:SizedBox(width:500,height:MediaQuery.of(context).size.height*.62,child:body),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(context,_values()),child:const Text('إنشاء PDF'))]);
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
  Padding(padding:const EdgeInsets.all(16),child:Text(isLab?'اختيار طريقة تنفيذ الفحوصات':'اختيار طريقة صرف الوصفة',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800))),
  ListTile(leading:const Icon(Icons.storefront_outlined),title:Text(isLab?'اختيار مختبر من المنصة':'اختيار صيدلية من المنصة'),onTap:()=>Navigator.pop(context,'facility')),
  ListTile(leading:const Icon(Icons.home_work_outlined),title:Text(isLab?'سحب العينة من المنزل':'توصيل الدواء للمنزل'),onTap:()=>Navigator.pop(context,'home')),
  ListTile(leading:const Icon(Icons.directions_walk_outlined),title:Text(isLab?'الذهاب إلى المختبر':'الاستلام من الصيدلية'),onTap:()=>Navigator.pop(context,'self')),
 ])));
 if(choice==null)return;
 String? fid,fn;
 if(choice=='facility'){
  final names=<Map<String,String>>[];
  for(final collection in isLab?['labs','laboratories']:['pharmacies']){
   try{final s=await FirebaseFirestore.instance.collection(collection).limit(30).get();for(final d in s.docs){final x=d.data();names.add({'id':d.id,'name':(x['name']??x['title']??'منشأة صحية').toString()});}}catch(_){}
   if(names.isNotEmpty)break;
  }
  if(!context.mounted)return;
  final selected=await showModalBottomSheet<Map<String,String>>(context:context,showDragHandle:true,builder:(_)=>SafeArea(child:SizedBox(height:420,child:names.isEmpty?const Center(child:Text('لا توجد منشآت متاحة حالياً')):ListView(children:[for(final n in names)ListTile(leading:Icon(isLab?Icons.biotech:Icons.local_pharmacy),title:Text(n['name']!),onTap:()=>Navigator.pop(context,n))]))));
  if(selected==null)return;fid=selected['id'];fn=selected['name'];
 }
 await MedicalDocumentService.instance.createServiceRequest(documentId:documentId,type:type,patientId:patientId,mode:choice,facilityId:fid,facilityName:fn);
 if(context.mounted)ToastService.showSuccess('تم تسجيل طلب ${isLab?'الفحوصات':'الصيدلية'}؛ يمكن متابعة حالته من الطلبات.');
}