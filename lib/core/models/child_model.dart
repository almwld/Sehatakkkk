import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id,name,gender;
  final DateTime birthDate;
  final double? weight,height,headCircumference;
  final String? bloodType,photoUrl,notes;
  final bool isActive;
  final DateTime? createdAt,updatedAt;
  const ChildModel({required this.id,required this.name,required this.birthDate,required this.gender,this.weight,this.height,this.headCircumference,this.bloodType,this.photoUrl,this.notes,this.isActive=true,this.createdAt,this.updatedAt});
  int get ageInMonths{final n=DateTime.now();var m=(n.year-birthDate.year)*12+n.month-birthDate.month;if(n.day<birthDate.day)m--;return m<0?0:m;}
  String get ageLabel{final m=ageInMonths;if(m<1)return DateTime.now().difference(birthDate).inDays.clamp(0,99999).toString()+' يوم';if(m<24)return m.toString()+' شهر';final y=m~/12,r=m%12;return r>0?y.toString()+' سنة و'+r.toString()+' شهر':y.toString()+' سنة';}
  factory ChildModel.fromFirestore(String id,Map<String,dynamic>d){DateTime pd(dynamic v){if(v is Timestamp)return v.toDate();if(v is DateTime)return v;if(v is String)return DateTime.tryParse(v)??DateTime.now();return DateTime.now();}DateTime? p(dynamic v)=>v is Timestamp?v.toDate():v is DateTime?v:v is String?DateTime.tryParse(v):null;return ChildModel(id:id,name:d['name']?.toString().trim().isNotEmpty==true?d['name'].toString():'طفل',birthDate:pd(d['birthDate']),gender:d['gender']=='female'?'female':'male',weight:(d['weight']as num?)?.toDouble(),height:(d['height']as num?)?.toDouble(),headCircumference:(d['headCircumference']as num?)?.toDouble(),bloodType:d['bloodType']?.toString(),photoUrl:d['photoUrl']?.toString(),notes:d['notes']?.toString(),isActive:d['isActive']!=false,createdAt:p(d['createdAt']),updatedAt:p(d['updatedAt']));}
  Map<String,dynamic> toFirestore()=>{'name':name,'birthDate':Timestamp.fromDate(birthDate),'gender':gender,'weight':weight,'height':height,'headCircumference':headCircumference,'bloodType':bloodType,'photoUrl':photoUrl,'notes':notes,'isActive':isActive,'updatedAt':FieldValue.serverTimestamp()};
}
