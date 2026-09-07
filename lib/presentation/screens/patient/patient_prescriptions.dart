import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';

class PatientPrescriptions extends StatelessWidget {
  const PatientPrescriptions({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الوصفات الطبية'),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('تعذر تحميل الوصفات: ${snapshot.error}'),
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
            return const Center(child: Text('لا توجد وصفات طبية حالياً'));
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
                              'وصفة من ${data['doctorName'] ?? 'الطبيب'}',
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
                      if ((data['diagnosis'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('التشخيص: ${data['diagnosis']}'),
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
                            (medicine['name'] ?? medicine['medicine'] ?? '').toString(),
                          ),
                          subtitle: Text(_details(medicine)),
                        ),
                      if ((data['medicineInstructions'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'تعليمات الطبيب: ${data['medicineInstructions']}',
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
                          label: const Text('متابعة مواعيد الأدوية'),
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

  static String _details(Map<String, dynamic> medicine) {
    final dose = (medicine['dose'] ?? medicine['dosage'] ?? '').toString();
    final frequency = (medicine['frequency'] ?? '').toString();
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
