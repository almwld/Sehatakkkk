import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/consultation/consultation_model.dart';
import 'package:sehatak/core/models/consultation/consultation_status.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ConsultationModel> createConsultation({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? doctorSpecialty,
    required String symptoms,
    String? description,
    List<String>? images,
    List<String>? voiceNotes,
    bool isUrgent = false,
    double? fee,
  }) async {
    final consultation = ConsultationModel(
      id: _firestore.collection('consultations').doc().id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      symptoms: symptoms,
      description: description,
      images: images,
      voiceNotes: voiceNotes,
      isUrgent: isUrgent,
      fee: fee,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('consultations').doc(consultation.id).set(consultation.toFirestore());
    return consultation;
  }

  Future<void> updateStatus({required String consultationId, required ConsultationStatus status, String? notes}) async {
    final updates = <String, dynamic>{'status': status.name, 'updatedAt': FieldValue.serverTimestamp()};
    if (notes != null) updates['notes'] = notes;
    if (status == ConsultationStatus.completed) updates['completedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('consultations').doc(consultationId).update(updates);
  }

  Future<void> updateLab({required String consultationId, required String labChoice, String? labId, String? labName}) async {
    await _firestore.collection('consultations').doc(consultationId).update({
      'labChoice': labChoice,
      'labId': labId,
      'labName': labName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addLabResults({required String consultationId, required String labResult, required List<Map<String, dynamic>> labTests}) async {
    await _firestore.collection('consultations').doc(consultationId).update({
      'labResult': labResult,
      'labTests': labTests,
      'status': ConsultationStatus.labDone.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addPrescription({
    required String consultationId,
    required List<Map<String, dynamic>> prescription,
    required List<String> medicines,
    required String medicineInstructions,
    String? diagnosis,
  }) async {
    final ref = _firestore.collection('consultations').doc(consultationId);
    final snapshot = await ref.get();
    if (!snapshot.exists) throw Exception('الاستشارة غير موجودة');
    final consultation = snapshot.data()!;
    final currentUser = _auth.currentUser;
    if (currentUser == null || consultation['doctorId'] != currentUser.uid) throw Exception('غير مصرح للطبيب بتعديل هذه الاستشارة');

    final batch = _firestore.batch();
    batch.update(ref, {
      'prescription': prescription,
      'medicines': medicines,
      'medicineInstructions': medicineInstructions,
      'diagnosis': diagnosis,
      'status': ConsultationStatus.prescription.name,
      'prescriptionDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // كل دواء يكتبه الطبيب يصبح خطة دوائية للمريض. لا نخمن أوقات الجرعات؛
    // نستخدم فقط time/times التي حددها الطبيب، حتى يكون التنبيه الطبي دقيقاً.
    final patientId = consultation['patientId']?.toString();
    if (patientId == null || patientId.isEmpty) throw Exception('المريض غير مرتبط بالاستشارة');
    final medicationCollection = _firestore.collection('users').doc(patientId).collection('medications');
    for (var i = 0; i < prescription.length; i++) {
      final item = Map<String, dynamic>.from(prescription[i]);
      final name = (item['name'] ?? item['medicine'] ?? item['medication'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final rawTimes = item['times'] ?? item['scheduleTimes'];
      final times = rawTimes is List ? rawTimes.whereType<String>().where((e) => e.trim().isNotEmpty).toList() : <String>[];
      final singleTime = item['time']?.toString().trim();
      if (times.isEmpty && singleTime != null && singleTime.isNotEmpty) times.add(singleTime);
      final medicationRef = medicationCollection.doc('rx_${consultationId}_$i');
      batch.set(medicationRef, {
        'name': name,
        'dose': (item['dose'] ?? item['dosage'] ?? '').toString(),
        'frequency': (item['frequency'] ?? '').toString(),
        'time': times.isNotEmpty ? times.first : '',
        'times': times,
        'instructions': (item['instructions'] ?? medicineInstructions).toString(),
        'notes': (item['notes'] ?? '').toString(),
        'doctorId': currentUser.uid,
        'doctorName': consultation['doctorName'] ?? '',
        'consultationId': consultationId,
        'userId': patientId,
        'active': true,
        'reminderEnabled': times.isNotEmpty,
        'taken': false,
        'startDate': FieldValue.serverTimestamp(),
        'endDate': item['endDate'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Stream<List<ConsultationModel>> getPatientConsultations(String patientId) => _firestore.collection('consultations').where('patientId', isEqualTo: patientId).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => ConsultationModel.fromFirestore(d.data(), d.id)).toList());

  Stream<List<ConsultationModel>> getDoctorConsultations(String doctorId) => _firestore.collection('consultations').where('doctorId', isEqualTo: doctorId).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => ConsultationModel.fromFirestore(d.data(), d.id)).toList());

  Future<ConsultationModel?> getConsultation(String consultationId) async {
    final doc = await _firestore.collection('consultations').doc(consultationId).get();
    if (!doc.exists) return null;
    return ConsultationModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> cancelConsultation({required String consultationId, required String reason}) async {
    await _firestore.collection('consultations').doc(consultationId).update({'status': ConsultationStatus.cancelled.name, 'notes': reason, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
