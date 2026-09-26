import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/child_model.dart';

class ChildService{
  ChildService._(); static final instance=ChildService._(); final _db=FirebaseFirestore.instance; final _auth=FirebaseAuth.instance;
  String get _uid{final u=_auth.currentUser;if(u==null)throw StateError('يجب تسجيل الدخول');return u.uid;}
  CollectionReference<Map<String,dynamic>> get _children=>_db.collection('users').doc(_uid).collection('children');
  Stream<List<ChildModel>> streamChildren()=>_children.where('isActive',isEqualTo:true).snapshots().map((s){final x=s.docs.map((d)=>ChildModel.fromFirestore(d.id,d.data())).toList();x.sort((a,b)=>(a.createdAt??DateTime.fromMillisecondsSinceEpoch(0)).compareTo(b.createdAt??DateTime.fromMillisecondsSinceEpoch(0)));return x;});
  Stream<ChildModel?> streamChild(String id)=>_children.doc(id).snapshots().map((d)=>!d.exists||d.data()?['isActive']==false?null:ChildModel.fromFirestore(d.id,d.data()!));
  Future<String> addChild({required String name,required DateTime birthDate,required String gender,double? weight,double? height,double? headCircumference,String? bloodType,String? photoUrl,String? notes})async{final r=await _children.add({'name':name.trim(),'birthDate':Timestamp.fromDate(birthDate),'gender':gender=='female'?'female':'male','weight':weight,'height':height,'headCircumference':headCircumference,'bloodType':bloodType,'photoUrl':photoUrl,'notes':notes,'isActive':true,'createdAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp()});return r.id;}
  Future<void> updateChild(String id,Map<String,dynamic>d)=>_children.doc(id).update({...d,'updatedAt':FieldValue.serverTimestamp()});
  Future<void> deleteChild(String id)=>updateChild(id,{'isActive':false});
  CollectionReference<Map<String,dynamic>> _growth(String id)=>_children.doc(id).collection('growth');
  Stream<List<Map<String,dynamic>>> streamGrowth(String id)=>_growth(id).orderBy('date',descending:true).snapshots().map((s)=>s.docs.map((d)=>{'id':d.id,...d.data()}).toList());
  Future<void> addGrowth(String id,{required double weight,required double height,double? headCircumference,DateTime? date})async{await _growth(id).add({'date':date==null?FieldValue.serverTimestamp():Timestamp.fromDate(date),'weight':weight,'height':height,'headCircumference':headCircumference});await updateChild(id,{'weight':weight,'height':height,'headCircumference':headCircumference});}
  CollectionReference<Map<String,dynamic>> _records(String id)=>_children.doc(id).collection('records');
  Stream<List<Map<String,dynamic>>> streamRecords(String id)=>_records(id).orderBy('date',descending:true).snapshots().map((s)=>s.docs.map((d)=>{'id':d.id,...d.data()}).toList());
  Future<void> addRecord(String id,{required String type,required String title,String? description,DateTime? date,List<String>? attachments})=>_records(id).add({'type':type,'title':title.trim(),'description':description?.trim()??'','date':date==null?FieldValue.serverTimestamp():Timestamp.fromDate(date),'attachments':attachments??const [],'createdAt':FieldValue.serverTimestamp()});
  Future<void> deleteRecord(String id,String recordId)=>_records(id).doc(recordId).delete();
}
