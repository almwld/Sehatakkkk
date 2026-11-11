import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalDoctorsScreen extends StatelessWidget {
  const DentalDoctorsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.translate('أطباء الأسنان'))),
      body: StreamBuilder<List<DentalDoctor>>(
        stream: DentalService().streamDoctors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          if (data.isEmpty) return Center(child: Text(strings.translate('لا توجد بيانات لأطباء الأسنان')));
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final doctor = data[i];
              return Card(
                child: ListTile(
                  onTap: () => context.push(AppRouter.dentalDoctorDetail.replaceFirst(':id', doctor.id)),
                  title: Text(localizedField(doctor.sourceData, 'name', strings.locale, fallback: strings.translate(doctor.name))),
                  subtitle: Text('${localizedField(doctor.sourceData, 'specialty', strings.locale, fallback: strings.translate(doctor.specialty))} • ${doctor.experienceYears} ${strings.translate('سنوات خبرة')}'),
                  trailing: Text('★${doctor.rating.toStringAsFixed(1)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
