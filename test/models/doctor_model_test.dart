import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/core/models/doctor_model.dart';

void main() {
  group('DoctorModel', () {
    test('fromFirestore should create the canonical model', () {
      final doctor = DoctorModel.fromFirestore('1', {
        'name': 'د. أحمد',
        'specialty': 'باطنية',
        'rating': 4.9,
        'reviewsCount': 328,
        'photoUrl': 'doctor.png',
      });

      expect(doctor.id, '1');
      expect(doctor.name, 'د. أحمد');
      expect(doctor.specialty, 'باطنية');
      expect(doctor.rating, 4.9);
      expect(doctor.reviewsCount, 328);
      expect(doctor.photoUrl, 'doctor.png');
    });
  });
}
