import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';

class DentalService {
  final FirebaseFirestore _db=FirebaseFirestore.instance;
  Stream<List<DentalDoctor>> streamDoctors()=>_db.collection('dental_doctors').snapshots().map((s)=>s.docs.map(DentalDoctor.fromDoc).toList());
  Stream<List<DentalClinic>> streamClinics()=>_db.collection('dental_clinics').snapshots().map((s)=>s.docs.map(DentalClinic.fromDoc).toList());
  Stream<List<DentalHospital>> streamHospitals({int limit=20})=>_db.collection('dental_hospitals').limit(limit).snapshots().map((s)=>s.docs.map(DentalHospital.fromDoc).toList());
  Stream<List<DentalTip>> streamTips({int limit=30})=>_db.collection('dental_tips').limit(limit).snapshots().map((s)=>s.docs.map(DentalTip.fromDoc).toList());
  Future<DentalDoctor?> getDoctor(String id)async{final d=await _db.collection('dental_doctors').doc(id).get();return d.exists?DentalDoctor.fromDoc(d):null;}
  Future<DentalClinic?> getClinic(String id)async{final d=await _db.collection('dental_clinics').doc(id).get();return d.exists?DentalClinic.fromDoc(d):null;}
  Future<void> createConsultation({required String userId,required String userName,required String doctorId,required String doctorName,required String question})async{await _db.collection('dental_consultations').add({'userId':userId,'userName':userName,'doctorId':doctorId,'doctorName':doctorName,'question':question,'status':'pending','createdAt':FieldValue.serverTimestamp()});}
}