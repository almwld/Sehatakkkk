import 'package:flutter/material.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalDoctorDetailScreen extends StatelessWidget {
  final String doctorId;
  const DentalDoctorDetailScreen({super.key, required this.doctorId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل طبيب الأسنان')),
      body: FutureBuilder<DentalDoctor?>(
        future: DentalService().getDoctor(doctorId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final doctor = snapshot.data;
          if (doctor == null) return const Center(child: Text('الطبيب غير متوفر'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(doctor.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(doctor.specialty, textAlign: TextAlign.center),
              Text('التقييم: ${doctor.rating.toStringAsFixed(1)}'),
              Text('الخبرة: ${doctor.experienceYears} سنة'),
              Text('العنوان: ${doctor.address}'),
              Text('الهاتف: ${doctor.phone}'),
            ],
          );
        },
      ),
    );
  }
}
