import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';

class DentalService {
  final FirebaseFirestore _firestore;
  DentalService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<DentalDoctor>> streamDoctors({String? specialty, int limit = 20}) {
    Query<Map<String, dynamic>> query = _firestore.collection('dental_doctors').orderBy('rating', descending: true).limit(limit);
    if (specialty != null && specialty.trim().isNotEmpty) query = _firestore.collection('dental_doctors').where('specialty', isEqualTo: specialty.trim()).orderBy('rating', descending: true).limit(limit);
    return query.snapshots().map((s) => s.docs.map((d) => DentalDoctor.fromFirestore(d.id, d.data())).toList());
  }
  Future<List<DentalDoctor>> getTopDoctors({int limit = 6}) async => (await _firestore.collection('dental_doctors').orderBy('rating', descending: true).limit(limit).get()).docs.map((d) => DentalDoctor.fromFirestore(d.id, d.data())).toList();
  Future<DentalDoctor?> getDoctor(String id) async { final d = await _firestore.collection('dental_doctors').doc(id).get(); return d.exists ? DentalDoctor.fromFirestore(d.id, d.data()!) : null; }

  Stream<List<DentalClinic>> streamClinics({int limit = 20}) => _firestore.collection('dental_clinics').orderBy('rating', descending: true).limit(limit).snapshots().map((s) => s.docs.map((d) => DentalClinic.fromFirestore(d.id, d.data())).toList());
  Future<DentalClinic?> getClinic(String id) async { final d = await _firestore.collection('dental_clinics').doc(id).get(); return d.exists ? DentalClinic.fromFirestore(d.id, d.data()!) : null; }

  Stream<List<DentalTip>> streamTips({String? category, int limit = 20}) => _firestore.collection('dental_tips').where('isPublished', isEqualTo: true).orderBy('createdAt', descending: true).limit(limit).snapshots().map((s) {
    final list = s.docs.map((d) => DentalTip.fromFirestore(d.id, d.data())).toList();
    return category == null || category.trim().isEmpty ? list : list.where((tip) => tip.category == category.trim()).toList();
  });
  Stream<List<DentalHospital>> streamHospitals({int limit = 10}) => _firestore.collection('dental_hospitals').orderBy('createdAt', descending: true).limit(limit).snapshots().map((s) => s.docs.map((d) => DentalHospital.fromFirestore(d.id, d.data())).toList());

  Future<String> createConsultation({required String userId, required String userName, required String doctorId, required String doctorName, required String question}) async {
    final ref = await _firestore.collection('dental_consultations').add({'userId': userId, 'userName': userName, 'doctorId': doctorId, 'doctorName': doctorName, 'question': question.trim(), 'answer': null, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp(), 'answeredAt': null});
    return ref.id;
  }
  Stream<List<DentalConsultation>> streamMyConsultations(String userId) => _firestore.collection('dental_consultations').where('userId', isEqualTo: userId).snapshots().map((s) {
    final list = s.docs.map((d) => DentalConsultation.fromFirestore(d.id, d.data())).toList();
    list.sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));
    return list;
  });
  Future<void> answerConsultation(String id, String answer) => _firestore.collection('dental_consultations').doc(id).update({'answer': answer.trim(), 'status': 'answered', 'answeredAt': FieldValue.serverTimestamp()});
}
