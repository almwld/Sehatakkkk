import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/constants/imagekit.dart';

void main() {
  group('DoctorModel', () {
    test('fromFirestore should create the canonical model', () {
      final doctor = DoctorModel.fromFirestore('1', {
        'name': 'د. أحمد',
        'specialty': 'باطنية',
        'rating': 4.9,
        'reviewsCount': 328,
        'photoUrl': 'https://legacy.example/doctor.png',
      });

      expect(doctor.id, '1');
      expect(doctor.name, 'د. أحمد');
      expect(doctor.specialty, 'باطنية');
      expect(doctor.rating, 4.9);
      expect(doctor.reviewsCount, 328);
      expect(doctor.photoUrl, ImageKit.doctor1);
    });

    test('uses a custom photo only when it was uploaded to Nextcloud', () {
      final doctor = DoctorModel.fromFirestore('2', {
        'name': 'د. سارة',
        'specialty': 'أطفال',
        'imageUrl': 'https://nextcloud.example/profile/download',
        'photoStorage': 'nextcloud',
      });
      expect(doctor.photoUrl, 'https://nextcloud.example/profile/download');
    });
  });
}
