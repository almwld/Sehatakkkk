import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/pregnancy/pregnancy_models.dart';
class PregnancyService {
 final FirebaseFirestore _db=FirebaseFirestore.instance;
 CollectionReference<Map<String,dynamic>> get _doctors=>_db.collection('pregnancy_doctors'); CollectionReference<Map<String,dynamic>> get _clinics=>_db.collection('pregnancy_clinics'); CollectionReference<Map<String,dynamic>> get _tips=>_db.collection('pregnancy_tips'); CollectionReference<Map<String,dynamic>> get _hospitals=>_db.collection('pregnancy_hospitals'); CollectionReference<Map<String,dynamic>> get _consultations=>_db.collection('pregnancy_consultations'); CollectionReference<Map<String,dynamic>> get _trackers=>_db.collection('pregnancy_trackers');
 Stream<List<PregnancyDoctor>> streamDoctors({String? specialty,int limit=20}){Query<Map<String,dynamic>> q=_doctors.limit(limit);if(specialty!=null&&specialty.isNotEmpty)q=q.where('specialty',isEqualTo:specialty);return q.snapshots().map((s)=>s.docs.map((d)=>PregnancyDoctor.fromFirestore(d.id,d.data())).toList());}
 Future<List<PregnancyDoctor>> getTopDoctors({int limit=6})async{final s=await _doctors.orderBy('rating',descending:true).limit(limit).get();return s.docs.map((d)=>PregnancyDoctor.fromFirestore(d.id,d.data())).toList();}
 Future<PregnancyDoctor?> getDoctor(String id)async{final d=await _doctors.doc(id).get();return d.exists?PregnancyDoctor.fromFirestore(d.id,d.data()!):null;}
 Stream<List<PregnancyClinic>> streamClinics({int limit=20})=>_clinics.limit(limit).snapshots().map((s)=>s.docs.map((d)=>PregnancyClinic.fromFirestore(d.id,d.data())).toList());
 Future<List<PregnancyClinic>> getNearbyClinics(GeoPoint center,double radiusKm)async{final s=await _clinics.limit(100).get();return s.docs.map((d)=>PregnancyClinic.fromFirestore(d.id,d.data())).where((c)=>c.location!=null&&_distance(center,c.location!)<=radiusKm).toList();}
 double _distance(GeoPoint a,GeoPoint b){const r=6371.0;final p=math.pi/180;final dLat=(b.latitude-a.latitude)*p,dLon=(b.longitude-a.longitude)*p;final x=math.sin(dLat/2)*math.sin(dLat/2)+math.cos(a.latitude*p)*math.cos(b.latitude*p)*math.sin(dLon/2)*math.sin(dLon/2);return r*2*math.atan2(math.sqrt(x),math.sqrt(1-x));}
 Stream<List<PregnancyTip>> streamTips({String? category,int limit=20}){Query<Map<String,dynamic>> q=_tips.where('isPublished',isEqualTo:true).limit(limit);if(category!=null&&category.isNotEmpty)q=q.where('category',isEqualTo:category);return q.snapshots().map((s)=>s.docs.map((d)=>PregnancyTip.fromFirestore(d.id,d.data())).toList());}
 Stream<List<PregnancyHospital>> streamHospitals({int limit=10})=>_hospitals.limit(limit).snapshots().map((s)=>s.docs.map((d)=>PregnancyHospital.fromFirestore(d.id,d.data())).toList());
 Future<String> createConsultation({required String userId,required String question,String doctorId=''})async{final ref=_consultations.doc();await ref.set({'userId':userId,'doctorId':doctorId,'question':question,'status':'pending','answer':'','createdAt':FieldValue.serverTimestamp()});return ref.id;}
 Stream<List<PregnancyConsultation>> streamMyConsultations(String userId)=>_consultations.where('userId',isEqualTo:userId).snapshots().map((s)=>s.docs.map((d)=>PregnancyConsultation.fromFirestore(d.id,d.data())).toList());
 Future<PregnancyTracker?> getTracker(String uid)async{final d=await _trackers.doc(uid).get();return d.exists?PregnancyTracker.fromFirestore(uid,d.data()!):null;}
 Stream<PregnancyTracker?> streamTracker(String uid)=>_trackers.doc(uid).snapshots().map((d)=>d.exists?PregnancyTracker.fromFirestore(uid,d.data()!):null);
 Future<void> updateTracker(String uid,Map<String,dynamic> data)async=>_trackers.doc(uid).set(data,SetOptions(merge:true));
 Future<int> calculateWeek(DateTime dueDate)async{final days=dueDate.difference(DateTime.now()).inDays;return (40-(days/7).floor()).clamp(0,40);}
}
