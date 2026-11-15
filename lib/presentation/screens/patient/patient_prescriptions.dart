import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';

class PatientPrescriptions extends StatelessWidget {
  String _localizedField(BuildContext context, Map<String, dynamic> data, String field, {String fallback = ''}) =>
      localizedField(data, field, AppStrings.of(context).locale, fallback: fallback);

  const PatientPrescriptions({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (uid == null) {
      return Scaffold(
        body: Center(child: Text(AppStrings.of(context).translate('يرجى تسجيل الدخول'))),
      );
    }

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(AppStrings.of(context).translate('الوصفات الطبية')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .where('patientId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Patient prescriptions stream failed: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppStrings.of(context).translate('تعذر تحميل الوصفات')),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final prescription = doc.data()['prescription'];
            return prescription is List && prescription.isNotEmpty;
          }).toList();

          if (docs.isEmpty) {
            return Center(child: Text(AppStrings.of(context).translate('لا توجد وصفات طبية حالياً')));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data();
              final rawItems = data['prescription'];
              final items = rawItems is List
                  ? rawItems
                      .whereType<Map>()
                      .map((item) => Map<String, dynamic>.from(item))
                      .toList()
                  : <Map<String, dynamic>>[];
              final date = _date(data['prescriptionDate'] ?? data['createdAt']);
              final doctorName = _localizedField(
                context,
                data,
                'doctorName',
                fallback: AppStrings.of(context).translate('الطبيب'),
              );
              final diagnosis = _localizedField(context, data, 'diagnosis');
              final medicineInstructions = _localizedField(
                context,
                data,
                'medicineInstructions',
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${AppStrings.of(context).translate('وصفة من')} $doctorName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (date != null)
                            Text(
                              DateFormat('yyyy/MM/dd').format(date),
                              style: const TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
                      if (diagnosis.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('${AppStrings.of(context).translate('التشخيص')}: $diagnosis'),
                      ],
                      const Divider(height: 24),
                      for (final medicine in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x1A0A8F83),
                            child: Icon(Icons.medication, color: AppColors.primary),
                          ),
                          title: Text(
                            _localizedField(context, medicine, 'name', fallback: _localizedField(context, medicine, 'medicine')),
                          ),
                          subtitle: Text(_details(context, medicine)),
                        ),
                      if (medicineInstructions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${AppStrings.of(context).translate('تعليمات الطبيب:')} $medicineInstructions',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MedicationReminderScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_active),
                          label: Text(AppStrings.of(context).translate('متابعة مواعيد الأدوية')),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _details(BuildContext context, Map<String, dynamic> medicine) {
    final dose = _localizedField(context, medicine, 'dose',
        fallback: _localizedField(context, medicine, 'dosage'));
    final frequency = _localizedField(context, medicine, 'frequency');
    final times = medicine['times'] is List
        ? (medicine['times'] as List).join('، ')
        : (medicine['time'] ?? '').toString();
    return [dose, frequency, times].where((value) => value.isNotEmpty).join(' • ');
  }

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
