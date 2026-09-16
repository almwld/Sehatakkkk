import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/eye/eye_models.dart';

class EyeService {
  final FirebaseFirestore _firestore;
  EyeService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<EyeDoctor>> streamDoctors({String? specialty, int limit = 20}) {
    Query<Map<String, dynamic>> query = _firestore.collection('eye_doctors').orderBy('rating', descending: true).limit(limit);
    if (specialty != null && specialty.trim().isNotEmpty) query = _firestore.collection('eye_doctors').where('specialty', isEqualTo: specialty.trim()).orderBy('rating', descending: true).limit(limit);
    return query.snapshots().map((s) => s.docs.map((d) => EyeDoctor.fromFirestore(d.id, d.data())).toList());
  }
  Future<List<EyeDoctor>> getTopDoctors({int limit = 6}) async => (await _firestore.collection('eye_doctors').orderBy('rating', descending: true).limit(limit).get()).docs.map((d) => EyeDoctor.fromFirestore(d.id, d.data())).toList();
  Future<EyeDoctor?> getDoctor(String id) async { final d = await _firestore.collection('eye_doctors').doc(id).get(); return d.exists ? EyeDoctor.fromFirestore(d.id, d.data()!) : null; }

  Stream<List<EyeClinic>> streamClinics({int limit = 20}) => _firestore.collection('eye_clinics').orderBy('rating', descending: true).limit(limit).snapshots().map((s) => s.docs.map((d) => EyeClinic.fromFirestore(d.id, d.data())).toList());
  Future<EyeClinic?> getClinic(String id) async { final d = await _firestore.collection('eye_clinics').doc(id).get(); return d.exists ? EyeClinic.fromFirestore(d.id, d.data()!) : null; }

  Stream<List<EyeTip>> streamTips({String? category, int limit = 20}) => _firestore.collection('eye_tips').where('isPublished', isEqualTo: true).orderBy('createdAt', descending: true).limit(limit).snapshots().map((s) {
    final list = s.docs.map((d) => EyeTip.fromFirestore(d.id, d.data())).toList();
    return category == null || category.trim().isEmpty ? list : list.where((tip) => tip.category == category.trim()).toList();
  });
  Stream<List<EyeHospital>> streamHospitals({int limit = 10}) => _firestore.collection('eye_hospitals').orderBy('createdAt', descending: true).limit(limit).snapshots().map((s) => s.docs.map((d) => EyeHospital.fromFirestore(d.id, d.data())).toList());

  Future<String> createConsultation({required String userId, required String userName, required String doctorId, required String doctorName, required String question}) async {
    final ref = await _firestore.collection('eye_consultations').add({'userId': userId, 'userName': userName, 'doctorId': doctorId, 'doctorName': doctorName, 'question': question.trim(), 'answer': null, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp(), 'answeredAt': null});
    return ref.id;
  }
  Stream<List<EyeConsultation>> streamMyConsultations(String userId) => _firestore.collection('eye_consultations').where('userId', isEqualTo: userId).snapshots().map((s) {
    final list = s.docs.map((d) => EyeConsultation.fromFirestore(d.id, d.data())).toList();
    list.sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));
    return list;
  });
  Future<void> answerConsultation(String id, String answer) => _firestore.collection('eye_consultations').doc(id).update({'answer': answer.trim(), 'status': 'answered', 'answeredAt': FieldValue.serverTimestamp()});
}
