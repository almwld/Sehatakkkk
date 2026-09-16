import 'package:cloud_firestore/cloud_firestore.dart';

Timestamp? _timestamp(dynamic value) {
  if (value is Timestamp) return value;
  if (value is DateTime) return Timestamp.fromDate(value);
  return null;
}

double _double(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
bool _bool(dynamic value) => value == true || value == 1 || '$value'.toLowerCase() == 'true';
List<String> _strings(dynamic value) => value is Iterable ? value.map((e) => '$e').toList() : <String>[];
Map<String, String> _stringMap(dynamic value) => value is Map ? value.map((key, value) => MapEntry('$key', '$value')) : <String, String>{};

class DentalDoctor {
  final String id, name, specialty;
  final String? photoUrl, clinicId, address, phone;
  final double rating;
  final int reviewCount, experienceYears;
  final double? consultationFee;
  final bool isAvailable, isVerified;
  final Timestamp? createdAt;

  const DentalDoctor({required this.id, required this.name, required this.specialty, this.photoUrl, required this.rating, required this.reviewCount, required this.experienceYears, this.clinicId, this.address, this.phone, this.consultationFee, required this.isAvailable, required this.isVerified, this.createdAt});

  factory DentalDoctor.fromFirestore(String id, Map<String, dynamic> data) => DentalDoctor(
    id: id, name: '${data['name'] ?? ''}', specialty: '${data['specialty'] ?? ''}', photoUrl: data['photoUrl'] as String?,
    rating: _double(data['rating']), reviewCount: _int(data['reviewCount']), experienceYears: _int(data['experienceYears']),
    clinicId: data['clinicId'] as String?, address: data['address'] as String?, phone: data['phone'] as String?,
    consultationFee: data['consultationFee'] == null ? null : _double(data['consultationFee']), isAvailable: _bool(data['isAvailable']), isVerified: _bool(data['isVerified']), createdAt: _timestamp(data['createdAt']),
  );

  Map<String, dynamic> toFirestore() => {
    'name': name, 'specialty': specialty, 'photoUrl': photoUrl, 'rating': rating, 'reviewCount': reviewCount, 'experienceYears': experienceYears,
    'clinicId': clinicId, 'address': address, 'phone': phone, 'consultationFee': consultationFee, 'isAvailable': isAvailable, 'isVerified': isVerified, 'createdAt': createdAt,
  };
}

class DentalClinic {
  final String id, name, address;
  final String? phone, imageUrl;
  final double rating;
  final int reviewCount;
  final GeoPoint? location;
  final Map<String, String> workingHours;
  final List<String> services;
  final bool isOpen;
  final Timestamp? createdAt;

  const DentalClinic({required this.id, required this.name, required this.address, this.phone, this.imageUrl, required this.rating, required this.reviewCount, this.location, required this.workingHours, required this.services, required this.isOpen, this.createdAt});
  factory DentalClinic.fromFirestore(String id, Map<String, dynamic> data) => DentalClinic(id: id, name: '${data['name'] ?? ''}', address: '${data['address'] ?? ''}', phone: data['phone'] as String?, imageUrl: data['imageUrl'] as String?, rating: _double(data['rating']), reviewCount: _int(data['reviewCount']), location: data['location'] is GeoPoint ? data['location'] as GeoPoint : null, workingHours: _stringMap(data['workingHours']), services: _strings(data['services']), isOpen: _bool(data['isOpen']), createdAt: _timestamp(data['createdAt']));
  Map<String, dynamic> toFirestore() => {'name': name, 'address': address, 'phone': phone, 'imageUrl': imageUrl, 'rating': rating, 'reviewCount': reviewCount, 'location': location, 'workingHours': workingHours, 'services': services, 'isOpen': isOpen, 'createdAt': createdAt};
}

class DentalTip {
  final String id, title, body, category;
  final String? imageUrl;
  final bool isPublished;
  final Timestamp? createdAt;
  const DentalTip({required this.id, required this.title, required this.body, this.imageUrl, required this.category, required this.isPublished, this.createdAt});
  factory DentalTip.fromFirestore(String id, Map<String, dynamic> data) => DentalTip(id: id, title: '${data['title'] ?? ''}', body: '${data['body'] ?? ''}', imageUrl: data['imageUrl'] as String?, category: '${data['category'] ?? ''}', isPublished: _bool(data['isPublished']), createdAt: _timestamp(data['createdAt']));
  Map<String, dynamic> toFirestore() => {'title': title, 'body': body, 'imageUrl': imageUrl, 'category': category, 'isPublished': isPublished, 'createdAt': createdAt};
}

class DentalHospital {
  final String id, name, address;
  final String? phone, imageUrl;
  final bool emergency;
  final List<String> departments;
  final GeoPoint? location;
  final Timestamp? createdAt;
  const DentalHospital({required this.id, required this.name, required this.address, this.phone, this.imageUrl, required this.emergency, required this.departments, this.location, this.createdAt});
  factory DentalHospital.fromFirestore(String id, Map<String, dynamic> data) => DentalHospital(id: id, name: '${data['name'] ?? ''}', address: '${data['address'] ?? ''}', phone: data['phone'] as String?, imageUrl: data['imageUrl'] as String?, emergency: _bool(data['emergency']), departments: _strings(data['departments']), location: data['location'] is GeoPoint ? data['location'] as GeoPoint : null, createdAt: _timestamp(data['createdAt']));
  Map<String, dynamic> toFirestore() => {'name': name, 'address': address, 'phone': phone, 'imageUrl': imageUrl, 'emergency': emergency, 'departments': departments, 'location': location, 'createdAt': createdAt};
}

class DentalConsultation {
  final String id, userId, userName, doctorId, doctorName, question;
  final String? answer;
  final String status;
  final Timestamp? createdAt, answeredAt;
  const DentalConsultation({required this.id, required this.userId, required this.userName, required this.doctorId, required this.doctorName, required this.question, this.answer, required this.status, this.createdAt, this.answeredAt});
  factory DentalConsultation.fromFirestore(String id, Map<String, dynamic> data) => DentalConsultation(id: id, userId: '${data['userId'] ?? ''}', userName: '${data['userName'] ?? ''}', doctorId: '${data['doctorId'] ?? ''}', doctorName: '${data['doctorName'] ?? ''}', question: '${data['question'] ?? ''}', answer: data['answer'] as String?, status: '${data['status'] ?? 'pending'}', createdAt: _timestamp(data['createdAt']), answeredAt: _timestamp(data['answeredAt']));
  Map<String, dynamic> toFirestore() => {'userId': userId, 'userName': userName, 'doctorId': doctorId, 'doctorName': doctorName, 'question': question, 'answer': answer, 'status': status, 'createdAt': createdAt, 'answeredAt': answeredAt};
}
