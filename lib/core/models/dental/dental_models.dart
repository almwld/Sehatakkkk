import 'package:cloud_firestore/cloud_firestore.dart';

class DentalDoctor {
  final String id,name,specialty,address,phone;
  final int experienceYears;
  final double rating;
  const DentalDoctor({required this.id,required this.name,required this.specialty,required this.experienceYears,required this.rating,required this.address,required this.phone});
  factory DentalDoctor.fromDoc(DocumentSnapshot<Map<String,dynamic>> doc){final d=doc.data()??const <String,dynamic>{};return DentalDoctor(id:doc.id,name:'${d['name']??'طبيب أسنان'}',specialty:'${d['specialty']??'طب الأسنان'}',experienceYears:(d['experienceYears'] as num?)?.toInt()??0,rating:(d['rating'] as num?)?.toDouble()??0,address:'${d['address']??''}',phone:'${d['phone']??''}');}
}
class DentalClinic {
  final String id,name,address,phone; final double rating; final bool isOpen;
  const DentalClinic({required this.id,required this.name,required this.address,required this.phone,required this.rating,required this.isOpen});
  factory DentalClinic.fromDoc(DocumentSnapshot<Map<String,dynamic>> doc){final d=doc.data()??const <String,dynamic>{};return DentalClinic(id:doc.id,name:'${d['name']??'عيادة أسنان'}',address:'${d['address']??''}',phone:'${d['phone']??''}',rating:(d['rating'] as num?)?.toDouble()??0,isOpen:d['isOpen']!=false);}
}
class DentalHospital {
  final String id,name,address,phone; final bool emergency;
  const DentalHospital({required this.id,required this.name,required this.address,required this.phone,required this.emergency});
  factory DentalHospital.fromDoc(DocumentSnapshot<Map<String,dynamic>> doc){final d=doc.data()??const <String,dynamic>{};return DentalHospital(id:doc.id,name:'${d['name']??'مستشفى'}',address:'${d['address']??''}',phone:'${d['phone']??''}',emergency:d['emergency']==true);}
}
class DentalTip {
  final String id,title,category,body;
  const DentalTip({required this.id,required this.title,required this.category,required this.body});
  factory DentalTip.fromDoc(DocumentSnapshot<Map<String,dynamic>> doc){final d=doc.data()??const <String,dynamic>{};return DentalTip(id:doc.id,title:'${d['title']??'نصيحة'}',category:'${d['category']??'عام'}',body:'${d['body']??''}');}
}