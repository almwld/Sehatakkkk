import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalDoctorDetailScreen extends StatelessWidget {
  final String doctorId;
  const DentalDoctorDetailScreen({super.key, required this.doctorId});
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.translate('تفاصيل طبيب الأسنان'))),
      body: FutureBuilder<DentalDoctor?>(
        future: DentalService().getDoctor(doctorId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final doctor = snapshot.data;
          if (doctor == null) return Center(child: Text(strings.translate('الطبيب غير متوفر')));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(localizedField(doctor.sourceData, 'name', strings.locale, fallback: strings.translate(doctor.name)), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(localizedField(doctor.sourceData, 'specialty', strings.locale, fallback: strings.translate(doctor.specialty)), textAlign: TextAlign.center),
              Text('${strings.translate('التقييم: ')}${doctor.rating.toStringAsFixed(1)}'),
              Text('${strings.translate('الخبرة: ')}${doctor.experienceYears} ${strings.translate('سنة')}'),
              Text('${strings.translate('العنوان: ')}${localizedField(doctor.sourceData, 'address', strings.locale, fallback: doctor.address)}'),
              Text('${strings.translate('الهاتف: ')}${doctor.phone}'),
            ],
          );
        },
      ),
    );
  }
}
