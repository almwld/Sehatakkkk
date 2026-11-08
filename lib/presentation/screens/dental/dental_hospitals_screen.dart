import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalHospitalsScreen extends StatelessWidget {
  const DentalHospitalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.translate('مستشفيات الأسنان والطوارئ'))),
      body: StreamBuilder(
        stream: DentalService().streamHospitals(limit: 20),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.map((hospital) => Card(
              child: ListTile(
                leading: Icon(hospital.emergency ? Icons.emergency : Icons.local_hospital, color: hospital.emergency ? Colors.red : Colors.cyan),
                title: Text(localizedField(hospital.sourceData, 'name', strings.locale, fallback: strings.translate(hospital.name))),
                subtitle: Text('${localizedField(hospital.sourceData, 'address', strings.locale, fallback: hospital.address)}\n${hospital.phone}'),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}
