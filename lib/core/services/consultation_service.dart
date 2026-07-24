import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/consultation/consultation_model.dart';
import 'package:sehatak/core/models/consultation/consultation_status.dart';
import 'package:sehatak/core/models/lab/lab_choice.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ إنشاء استشارة جديدة
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

    await _firestore
        .collection('consultations')
        .doc(consultation.id)
        .set(consultation.toFirestore());

    return consultation;
  }

  // ✅ تحديث حالة الاستشارة
  Future<void> updateStatus({
    required String consultationId,
    required ConsultationStatus status,
    String? notes,
  }) async {
    final updates = {
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (notes != null) {
      updates['notes'] = notes;
    }

    if (status == ConsultationStatus.completed) {
      updates['completedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('consultations')
        .doc(consultationId)
        .update(updates);
  }

  // ✅ تحديث حالة المختبر
  Future<void> updateLab({
    required String consultationId,
    required String labChoice,
    String? labId,
    String? labName,
  }) async {
    await _firestore
        .collection('consultations')
        .doc(consultationId)
        .update({
      'labChoice': labChoice,
      'labId': labId,
      'labName': labName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إضافة نتائج المختبر
  Future<void> addLabResults({
    required String consultationId,
    required String labResult,
    required List<Map<String, dynamic>> labTests,
  }) async {
    await _firestore
        .collection('consultations')
        .doc(consultationId)
        .update({
      'labResult': labResult,
      'labTests': labTests,
      'status': ConsultationStatus.labDone.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إضافة الوصفة الطبية
  Future<void> addPrescription({
    required String consultationId,
    required List<Map<String, dynamic>> prescription,
    required List<String> medicines,
    required String medicineInstructions,
    String? diagnosis,
  }) async {
    await _firestore
        .collection('consultations')
        .doc(consultationId)
        .update({
      'prescription': prescription,
      'medicines': medicines,
      'medicineInstructions': medicineInstructions,
      'diagnosis': diagnosis,
      'status': ConsultationStatus.prescription.toString().split('.').last,
      'prescriptionDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ جلب استشارات المريض
  Stream<List<ConsultationModel>> getPatientConsultations(String patientId) {
    return _firestore
        .collection('consultations')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ConsultationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ جلب استشارات الطبيب
  Stream<List<ConsultationModel>> getDoctorConsultations(String doctorId) {
    return _firestore
        .collection('consultations')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ConsultationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ جلب استشارة محددة
  Future<ConsultationModel?> getConsultation(String consultationId) async {
    final doc = await _firestore
        .collection('consultations')
        .doc(consultationId)
        .get();

    if (!doc.exists) return null;
    return ConsultationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ✅ إلغاء الاستشارة
  Future<void> cancelConsultation({
    required String consultationId,
    required String reason,
  }) async {
    await _firestore
        .collection('consultations')
        .doc(consultationId)
        .update({
      'status': ConsultationStatus.cancelled.toString().split('.').last,
      'notes': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
