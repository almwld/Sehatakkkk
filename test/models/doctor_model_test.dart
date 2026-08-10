import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/data/models/doctor_model.dart';

void main() {
  group('DoctorModel', () {
    test('fromJson should create correct model', () {
      const json = {
        'id': '1',
        'name': 'د. أحمد',
        'specialty': 'باطنية',
        'rating': 4.9,
        'reviews': 328,
        'image': 'doctor.png',
        'gender': 'male',
      };
      
      final doctor = DoctorModel.fromJson(json);
      
      expect(doctor.id, '1');
      expect(doctor.name, 'د. أحمد');
      expect(doctor.specialty, 'باطنية');
      expect(doctor.rating, 4.9);
      expect(doctor.reviews, 328);
    });
  });
}
