import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class MedicalDocumentService {
  MedicalDocumentService._();
  static final instance = MedicalDocumentService._();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> isVerifiedDoctor() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final d = await _db.collection('users').doc(uid).get();
    final data = d.data() ?? {};
    return (data['role']?.toString() == 'doctor' || data['role']?.toString() == 'طبيب') &&
        data['isVerified'] != false;
  }

  Future<Map<String,dynamic>> userData(String uid) async {
    final d = await _db.collection('users').doc(uid).get();
    return d.data() ?? {};
  }

  Future<File> buildPdf({
    required String formType,
    required Map<String,dynamic> doctor,
    required Map<String,dynamic> patient,
    required Map<String,dynamic> values,
  }) async {
    final doc = pw.Document();
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'));
    final id = _db.collection('medical_documents').doc().id;
    final now = DateTime.now();
    final formTitle = {
      'rx':'وصفة طبية | Prescription / RX',
      'labs':'طلب فحوصات مخبرية | Laboratory Request',
      'report':'تقرير طبي | Medical Report',
      'sick_leave':'إجازة مرضية | Sick Leave Certificate',
      'referral':'إحالة طبية | Medical Referral',
    }[formType] ?? 'مستند طبي | Medical Document';

    pw.Widget line(String ar, String en, {bool strong=false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(textDirection: pw.TextDirection.rtl, children:[
        pw.Expanded(child: pw.Text(ar, textAlign: pw.TextAlign.right, style: pw.TextStyle(font:strong?bold:regular,fontSize:10))),
        pw.SizedBox(width:12),
        pw.Expanded(child: pw.Text(en, textAlign: pw.TextAlign.left, style: pw.TextStyle(font:strong?bold:regular,fontSize:9))),
      ]),
    );

    final doctorName = (doctor['name'] ?? doctor['displayName'] ?? 'الطبيب').toString();
    final doctorEn = (doctor['nameEn'] ?? doctor['englishName'] ?? doctorName).toString();
    final specialty = (doctor['specialty'] ?? doctor['specialization'] ?? 'طبيب').toString();
    final license = (doctor['licenseNumber'] ?? doctor['license'] ?? '').toString();
    final patientName = (patient['name'] ?? patient['displayName'] ?? 'المريض').toString();
    final patientEn = (patient['nameEn'] ?? patient['englishName'] ?? patientName).toString();

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32,28,32,30),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      build: (_) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children:[
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
              pw.Text(doctorName, style: pw.TextStyle(font:bold,fontSize:14)),
              pw.Text(specialty, style: pw.TextStyle(font:regular,fontSize:10)),
              if (license.isNotEmpty) pw.Text('ترخيص: $license', style: pw.TextStyle(font:regular,fontSize:8)),
            ])),
            pw.Expanded(child: pw.Column(children:[
              pw.Text('صحتك', style: pw.TextStyle(font:bold,fontSize:25,color:PdfColors.teal)),
              pw.Text('SEHATAK', style: pw.TextStyle(font:bold,fontSize:8,color:PdfColors.teal)),
            ])),
            pw.Expanded(child: pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.end,children:[
              pw.Text(patientName, style: pw.TextStyle(font:bold,fontSize:13)),
              pw.Text(patientEn,textDirection:pw.TextDirection.ltr,style:pw.TextStyle(font:regular,fontSize:9)),
              pw.Text('التاريخ / Date: ${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}',style:pw.TextStyle(font:regular,fontSize:8)),
            ])),
          ]),
          pw.SizedBox(height:10), pw.Divider(color:PdfColors.teal,thickness:1.5),
          pw.Center(child:pw.Text(formTitle,style:pw.TextStyle(font:bold,fontSize:16,color:PdfColors.teal))),
          pw.SizedBox(height:12),
          if (formType=='rx') ...[
            pw.TableHelper.fromTextArray(
              headers:['ملاحظات | Notes','التعليمات | Directions','الجرعة | Dose','الدواء | Medication','م'],
              data:((values['medications'] as List?)??[]).map((e){final m=Map<String,dynamic>.from(e as Map);return ['${m['notes']??''}','${m['directions']??''}','${m['dose']??''}','${m['name']??''}','${m['index']??''}'];}).toList(),
              headerStyle:pw.TextStyle(font:bold,fontSize:8,color:PdfColors.white),headerDecoration:const pw.BoxDecoration(color:PdfColors.teal),
              cellStyle:pw.TextStyle(font:regular,fontSize:7),cellAlignment:pw.Alignment.center,border:pw.TableBorder.all(color:PdfColors.grey400)),
            pw.SizedBox(height:10),line('تعليمات عامة: ${values['general']??''}','General instructions: ${values['generalEn']??values['general']??''}'),
          ] else if (formType=='labs') ...[
            pw.Text('الفحوصات المطلوبة / Requested Tests',style:pw.TextStyle(font:bold,fontSize:11)),pw.SizedBox(height:6),
            pw.Wrap(spacing:8,runSpacing:5,children:((values['tests'] as List?)??[]).map((e)=>pw.Container(padding:const pw.EdgeInsets.symmetric(horizontal:7,vertical:4),decoration:pw.BoxDecoration(border:pw.Border.all(color:PdfColors.teal),borderRadius:pw.BorderRadius.circular(4)),child:pw.Text('✓ $e',style:pw.TextStyle(font:regular,fontSize:8)))).toList()),
            pw.SizedBox(height:10),line('ملاحظات المختبر: ${values['notes']??''}','Lab notes: ${values['notesEn']??values['notes']??''}'),
          ] else if (formType=='report') ...[
            line('التشخيص: ${values['diagnosis']??''}','Diagnosis: ${values['diagnosisEn']??values['diagnosis']??''}',strong:true),
            line('التاريخ المرضي: ${values['history']??''}','Clinical history: ${values['historyEn']??values['history']??''}'),
            line('الفحص والنتائج: ${values['findings']??''}','Findings: ${values['findingsEn']??values['findings']??''}'),
            line('الخطة العلاجية: ${values['plan']??''}','Treatment plan: ${values['planEn']??values['plan']??''}'),
          ] else if (formType=='sick_leave') ...[
            line('سبب الإجازة: ${values['reason']??''}','Reason: ${values['reasonEn']??values['reason']??''}',strong:true),
            line('من: ${values['from']??''} إلى: ${values['to']??''}','From: ${values['from']??''} To: ${values['to']??''}'),
            line('عدد الأيام: ${values['days']??''}','Days: ${values['days']??''}'),
            line('ملاحظات: ${values['notes']??''}','Notes: ${values['notesEn']??values['notes']??''}'),
          ] else ...[
            line('الجهة المحال إليها: ${values['destination']??''}','Referred to: ${values['destinationEn']??values['destination']??''}',strong:true),
            line('سبب الإحالة: ${values['reason']??''}','Reason: ${values['reasonEn']??values['reason']??''}'),
            line('التفاصيل: ${values['details']??''}','Details: ${values['detailsEn']??values['details']??''}'),
          ],
          pw.Spacer(),pw.Divider(color:PdfColors.grey400),
          pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
            pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[pw.Text('توقيع الطبيب / Doctor signature',style:pw.TextStyle(font:regular,fontSize:9)),pw.SizedBox(height:25),pw.Text(doctorEn,textDirection:pw.TextDirection.ltr,style:pw.TextStyle(font:regular,fontSize:9))]),
            pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.end,children:[pw.Text('رقم المستند / Document ID',style:pw.TextStyle(font:regular,fontSize:8)),pw.Text(id,textDirection:pw.TextDirection.ltr,style:pw.TextStyle(font:regular,fontSize:7))]),
          ]),
        ])
      ),
    ));
    final dir=await getApplicationDocumentsDirectory();final folder=Directory(p.join(dir.path,'sehatak_medical_documents'));await folder.create(recursive:true);
    final file=File(p.join(folder.path,'${id}_${formType}.pdf'));await file.writeAsBytes(await doc.save(),flush:true);
    await _db.collection('medical_documents').doc(id).set({'id':id,'chatId':values['chatId'],'patientId':patient['uid']??patient['userId'],'doctorId':_auth.currentUser?.uid,'type':formType,'title':formTitle,'fileName':'${id}_${formType}.pdf','localPath':file.path,'createdAt':FieldValue.serverTimestamp(),'status':'issued','patientName':patientName,'doctorName':doctorName,'values':values});
    return file;
  }

  Future<void> saveToLibrary({required File file,required String documentId,required String title,required String chatId,required String formType}) async {
    final uid=_auth.currentUser?.uid;if(uid==null)return;
    await _db.collection('document_library').doc(documentId).set({'documentId':documentId,'ownerId':uid,'chatId':chatId,'title':title,'type':formType,'fileName':p.basename(file.path),'localPath':file.path,'createdAt':FieldValue.serverTimestamp()},SetOptions(merge:true));
  }
  Future<void> createServiceRequest({required String documentId,required String type,required String patientId,required String mode,String? facilityId,String? facilityName}) async {
    final ref=_db.collection('medical_requests').doc();await ref.set({'requestId':ref.id,'documentId':documentId,'type':type,'patientId':patientId,'doctorId':_auth.currentUser?.uid,'mode':mode,'facilityId':facilityId,'facilityName':facilityName,'status':'pending','createdAt':FieldValue.serverTimestamp()});
  }
  Future<void> shareFile(File file) async => Share.shareXFiles([XFile(file.path)],text:'مستند طبي من منصة صحتك');
  Future<void> printFile(File file) async => Printing.sharePdf(bytes:await file.readAsBytes(),filename:p.basename(file.path));
}