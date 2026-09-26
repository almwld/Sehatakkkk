import 'package:flutter/material.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalClinicDetailScreen extends StatelessWidget {
  final String clinicId;

  const DentalClinicDetailScreen({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل عيادة الأسنان')),
      body: FutureBuilder<DentalClinic?>(
        future: DentalService().getClinic(clinicId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clinic = snapshot.data;
          if (clinic == null) {
            return const Center(child: Text('العيادة غير متوفرة'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                clinic.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(clinic.address),
              Text('الهاتف: ${clinic.phone}'),
              Text('التقييم: ${clinic.rating.toStringAsFixed(1)}'),
              Text(clinic.isOpen ? 'مفتوح الآن' : 'مغلق الآن'),
            ],
          );
        },
      ),
    );
  }
}
