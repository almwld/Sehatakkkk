import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalClinicsScreen extends StatelessWidget {
  const DentalClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عيادات الأسنان')),
      body: StreamBuilder<List<DentalClinic>>(
        stream: DentalService().streamClinics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('لا توجد عيادات أسنان'));
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: data.map((clinic) {
              return Card(
                child: ListTile(
                  onTap: () => context.push(
                    AppRouter.dentalClinicDetail.replaceFirst(':id', clinic.id),
                  ),
                  title: Text(clinic.name),
                  subtitle: Text(clinic.address),
                  trailing: Text(clinic.isOpen ? 'مفتوح' : 'مغلق'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
