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
    final collection = uid == _auth.currentUser?.uid ? 'users' : 'public_profiles';
    final d = await _db.collection(collection).doc(uid).get();
    return d.data() ?? {};
  }

  Future<File> buildPdf({
    required String formType,
    required Map<String, dynamic> doctor,
    required Map<String, dynamic> patient,
    required Map<String, dynamic> values,
    String languageCode = 'ar',
  }) async {
    final code = const {'ar', 'en', 'fr'}.contains(languageCode)
        ? languageCode
        : 'ar';
    final isArabic = code == 'ar';
    final direction = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final doc = pw.Document();
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'),
    );
    final id = _db.collection('medical_documents').doc().id;
    final now = DateTime.now();

    String label(String ar, String en, String fr) {
      if (code == 'fr') return fr;
      if (code == 'en') return en;
      return ar;
    }

    String localizedField(
      Map<String, dynamic> source,
      List<String> fields, {
      required String fallback,
    }) {
      final suffix = code == 'en' ? 'En' : code == 'fr' ? 'Fr' : '';
      if (suffix.isNotEmpty) {
        for (final field in fields) {
          final candidate = source['$field$suffix'];
          if (candidate != null && candidate.toString().trim().isNotEmpty) {
            return candidate.toString().trim();
          }
        }
        if (fields.contains('name')) {
          final alias = source[code == 'en' ? 'englishName' : 'frenchName'];
          if (alias != null && alias.toString().trim().isNotEmpty) {
            return alias.toString().trim();
          }
        }
      }
      for (final field in fields) {
        final candidate = source[field];
        if (candidate != null && candidate.toString().trim().isNotEmpty) {
          return candidate.toString().trim();
        }
      }
      return fallback;
    }

    final formTitles = <String, List<String>>{
      'rx': ['وصفة طبية', 'Prescription / RX', 'Ordonnance / RX'],
      'labs': [
        'طلب فحوصات مخبرية',
        'Laboratory Request',
        'Demande d’analyses',
      ],
      'report': ['تقرير طبي', 'Medical Report', 'Rapport médical'],
      'sick_leave': [
        'إجازة مرضية',
        'Sick Leave Certificate',
        'Certificat d’arrêt de travail',
      ],
      'referral': [
        'إحالة طبية',
        'Medical Referral',
        'Lettre d’orientation médicale',
      ],
    };
    final titleParts = formTitles[formType] ??
        ['مستند طبي', 'Medical Document', 'Document médical'];
    final formTitle = code == 'fr'
        ? titleParts[2]
        : code == 'en'
            ? titleParts[1]
            : titleParts[0];

    pw.Widget line(
      String ar,
      String en, {
      String? fr,
      bool strong = false,
    }) {
      final text = code == 'fr' ? (fr ?? en) : code == 'en' ? en : ar;
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Text(
          text,
          textDirection: direction,
          textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            font: strong ? bold : regular,
            fontSize: 10,
          ),
        ),
      );
    }

    final doctorName = localizedField(
      doctor,
      ['name', 'displayName'],
      fallback: label('الطبيب', 'Doctor', 'Médecin'),
    );
    final specialty = localizedField(
      doctor,
      ['specialty', 'specialization'],
      fallback: label('طبيب', 'Doctor', 'Médecin'),
    );
    final license = (doctor['licenseNumber'] ?? doctor['license'] ?? '')
        .toString();
    final patientName = localizedField(
      patient,
      ['name', 'displayName'],
      fallback: label('المريض', 'Patient', 'Patient'),
    );
    final doctorNameForRecord =
        (doctor['name'] ?? doctor['displayName'] ?? doctorName).toString();
    final patientNameForRecord =
        (patient['name'] ?? patient['displayName'] ?? patientName).toString();
    final dateText =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 30),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) => pw.Directionality(
          textDirection: direction,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          doctorName,
                          textDirection: direction,
                          style: pw.TextStyle(font: bold, fontSize: 14),
                        ),
                        pw.Text(
                          specialty,
                          textDirection: direction,
                          style: pw.TextStyle(font: regular, fontSize: 10),
                        ),
                        if (license.isNotEmpty)
                          pw.Text(
                            '${label('ترخيص', 'License', 'Licence')}: $license',
                            textDirection: direction,
                            style: pw.TextStyle(font: regular, fontSize: 8),
                          ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'صحتك',
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 25,
                            color: PdfColors.teal,
                          ),
                        ),
                        pw.Text(
                          'SEHATAK',
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 8,
                            color: PdfColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          patientName,
                          textDirection: direction,
                          style: pw.TextStyle(font: bold, fontSize: 13),
                        ),
                        pw.Text(
                          '${label('التاريخ', 'Date', 'Date')}: $dateText',
                          textDirection: direction,
                          style: pw.TextStyle(font: regular, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.teal, thickness: 1.5),
              pw.Center(
                child: pw.Text(
                  formTitle,
                  textDirection: direction,
                  style: pw.TextStyle(
                    font: bold,
                    fontSize: 16,
                    color: PdfColors.teal,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              if (formType == 'rx') ...[
                pw.TableHelper.fromTextArray(
                  headers: [
                    label('ملاحظات', 'Notes', 'Remarques'),
                    label('التعليمات', 'Directions', 'Instructions'),
                    label('الجرعة', 'Dose', 'Posologie'),
                    label('الدواء', 'Medication', 'Médicament'),
                    label('م', 'No.', 'N°'),
                  ],
                  data: ((values['medications'] as List?) ?? [])
                      .map((e) {
                        final medication = Map<String, dynamic>.from(e as Map);
                        return [
                          '${medication['notes'] ?? ''}',
                          '${medication['directions'] ?? ''}',
                          '${medication['dose'] ?? ''}',
                          '${medication['name'] ?? ''}',
                          '${medication['index'] ?? ''}',
                        ];
                      })
                      .toList(),
                  headerStyle: pw.TextStyle(
                    font: bold,
                    fontSize: 8,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.teal,
                  ),
                  cellStyle: pw.TextStyle(font: regular, fontSize: 7),
                  cellAlignment: pw.Alignment.center,
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                ),
                pw.SizedBox(height: 10),
                line(
                  'تعليمات عامة: ${values['general'] ?? ''}',
                  'General instructions: ${values['generalEn'] ?? values['general'] ?? ''}',
                  fr: 'Instructions générales : ${values['generalFr'] ?? values['general'] ?? ''}',
                ),
              ] else if (formType == 'labs') ...[
                pw.Text(
                  label(
                    'الفحوصات المطلوبة',
                    'Requested tests',
                    'Analyses demandées',
                  ),
                  textDirection: direction,
                  style: pw.TextStyle(font: bold, fontSize: 11),
                ),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: ((values['tests'] as List?) ?? [])
                      .map(
                        (test) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.teal),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            '✓ $test',
                            textDirection: direction,
                            style: pw.TextStyle(font: regular, fontSize: 8),
                          ),
                        ),
                      )
                      .toList(),
                ),
                pw.SizedBox(height: 10),
                line(
                  'ملاحظات المختبر: ${values['notes'] ?? ''}',
                  'Lab notes: ${values['notesEn'] ?? values['notes'] ?? ''}',
                  fr: 'Notes du laboratoire : ${values['notesFr'] ?? values['notes'] ?? ''}',
                ),
              ] else if (formType == 'report') ...[
                line(
                  'التشخيص: ${values['diagnosis'] ?? ''}',
                  'Diagnosis: ${values['diagnosisEn'] ?? values['diagnosis'] ?? ''}',
                  fr: 'Diagnostic : ${values['diagnosisFr'] ?? values['diagnosis'] ?? ''}',
                  strong: true,
                ),
                line(
                  'التاريخ المرضي: ${values['history'] ?? ''}',
                  'Clinical history: ${values['historyEn'] ?? values['history'] ?? ''}',
                  fr: 'Antécédents médicaux : ${values['historyFr'] ?? values['history'] ?? ''}',
                ),
                line(
                  'الفحص والنتائج: ${values['findings'] ?? ''}',
                  'Findings: ${values['findingsEn'] ?? values['findings'] ?? ''}',
                  fr: 'Examen et résultats : ${values['findingsFr'] ?? values['findings'] ?? ''}',
                ),
                line(
                  'الخطة العلاجية: ${values['plan'] ?? ''}',
                  'Treatment plan: ${values['planEn'] ?? values['plan'] ?? ''}',
                  fr: 'Plan de traitement : ${values['planFr'] ?? values['plan'] ?? ''}',
                ),
              ] else if (formType == 'sick_leave') ...[
                line(
                  'سبب الإجازة: ${values['reason'] ?? ''}',
                  'Reason: ${values['reasonEn'] ?? values['reason'] ?? ''}',
                  fr: 'Motif : ${values['reasonFr'] ?? values['reason'] ?? ''}',
                  strong: true,
                ),
                line(
                  'من: ${values['from'] ?? ''} إلى: ${values['to'] ?? ''}',
                  'From: ${values['from'] ?? ''} to: ${values['to'] ?? ''}',
                  fr: 'Du : ${values['from'] ?? ''} au : ${values['to'] ?? ''}',
                ),
                line(
                  'عدد الأيام: ${values['days'] ?? ''}',
                  'Number of days: ${values['days'] ?? ''}',
                  fr: 'Nombre de jours : ${values['days'] ?? ''}',
                ),
                line(
                  'ملاحظات: ${values['notes'] ?? ''}',
                  'Notes: ${values['notesEn'] ?? values['notes'] ?? ''}',
                  fr: 'Remarques : ${values['notesFr'] ?? values['notes'] ?? ''}',
                ),
              ] else ...[
                line(
                  'الجهة المحال إليها: ${values['destination'] ?? ''}',
                  'Referred to: ${values['destinationEn'] ?? values['destination'] ?? ''}',
                  fr: 'Orienté vers : ${values['destinationFr'] ?? values['destination'] ?? ''}',
                  strong: true,
                ),
                line(
                  'سبب الإحالة: ${values['reason'] ?? ''}',
                  'Reason: ${values['reasonEn'] ?? values['reason'] ?? ''}',
                  fr: 'Motif : ${values['reasonFr'] ?? values['reason'] ?? ''}',
                ),
                line(
                  'التفاصيل: ${values['details'] ?? ''}',
                  'Details: ${values['detailsEn'] ?? values['details'] ?? ''}',
                  fr: 'Détails : ${values['detailsFr'] ?? values['details'] ?? ''}',
                ),
              ],
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        label(
                          'توقيع الطبيب',
                          'Doctor signature',
                          'Signature du médecin',
                        ),
                        textDirection: direction,
                        style: pw.TextStyle(font: regular, fontSize: 9),
                      ),
                      pw.SizedBox(height: 25),
                      pw.Text(
                        doctorName,
                        textDirection: direction,
                        style: pw.TextStyle(font: regular, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        label('رقم المستند', 'Document ID', 'Numéro du document'),
                        textDirection: direction,
                        style: pw.TextStyle(font: regular, fontSize: 8),
                      ),
                      pw.Text(
                        id,
                        textDirection: pw.TextDirection.ltr,
                        style: pw.TextStyle(font: regular, fontSize: 7),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'sehatak_medical_documents'));
    await folder.create(recursive: true);
    final file = File(p.join(folder.path, '${id}_${formType}.pdf'));
    await file.writeAsBytes(await doc.save(), flush: true);
    await _db.collection('medical_documents').doc(id).set({
      'id': id,
      'chatId': values['chatId'],
      'patientId': patient['uid'] ?? patient['userId'],
      'doctorId': _auth.currentUser?.uid,
      'type': formType,
      'title': formTitle,
      'fileName': '${id}_${formType}.pdf',
      'localPath': file.path,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'issued',
      'patientName': patientNameForRecord,
      'doctorName': doctorNameForRecord,
      'values': values,
    });
    return file;
  }
  Future<void> saveToLibrary({required File file,required String documentId,required String title,required String chatId,required String formType}) async {
    final uid=_auth.currentUser?.uid;if(uid==null)return;
    await _db.collection('document_library').doc(documentId).set({'documentId':documentId,'ownerId':uid,'chatId':chatId,'title':title,'type':formType,'fileName':p.basename(file.path),'localPath':file.path,'createdAt':FieldValue.serverTimestamp()},SetOptions(merge:true));
  }
  Future<void> createServiceRequest({required String documentId,required String type,required String patientId,required String mode,String? facilityId,String? facilityName}) async {
    final ref=_db.collection('medical_requests').doc();await ref.set({'requestId':ref.id,'documentId':documentId,'type':type,'patientId':patientId,'doctorId':_auth.currentUser?.uid,'mode':mode,'facilityId':facilityId,'facilityName':facilityName,'status':'pending','createdAt':FieldValue.serverTimestamp()});
  }
  Future<void> shareFile(File file) async => Share.shareXFiles([XFile(file.path)],text:'مستند طبي من منصة صحتك | Medical document from Sehatak | Document médical de Sehatak');
  Future<void> printFile(File file) async => Printing.sharePdf(bytes:await file.readAsBytes(),filename:p.basename(file.path));
}