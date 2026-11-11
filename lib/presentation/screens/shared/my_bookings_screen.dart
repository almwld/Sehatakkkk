import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  String _statusText(BuildContext context, String value) {
    final status = value.trim();
    switch (status.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
      case 'pending':
      case 'awaiting_confirmation':
        return _t(context, 'قيد الانتظار');
      case 'confirmed':
      case 'accepted':
        return _t(context, 'مؤكد');
      case 'completed':
      case 'done':
        return _t(context, 'مكتمل');
      case 'cancelled':
      case 'canceled':
        return _t(context, 'ملغي');
      case 'in_progress':
      case 'ongoing':
        return _t(context, 'قيد التنفيذ');
      case 'rejected':
        return _t(context, 'مرفوض');
      case 'rescheduled':
        return _t(context, 'تم إعادة الجدولة');
      case 'no_show':
        return _t(context, 'لم يحضر');
      default:
        return _t(context, status.isEmpty ? 'غير محدد' : status);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context).translate('حجوزاتي'))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(_t(context, 'تعذر تحميل الحجوزات.')));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text(AppStrings.of(context).translate('لا توجد حجوزات')));
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, i) {
              final data = snapshot.data!.docs[i].data();
              return ListTile(
                title: Text(localizedField(
                  data,
                  'providerName',
                  AppStrings.of(context).locale,
                  fallback: localizedField(
                    data,
                    'doctorName',
                    AppStrings.of(context).locale,
                    fallback: _t(context, 'حجز'),
                  ),
                )),
                subtitle: Text(_statusText(context, data['status']?.toString() ?? 'pending')),
              );
            },
          );
        },
      ),
    );
  }
}
