import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context).translate('حجوزاتي'))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(AppStrings.of(context).translate('خطأ') + ': ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text(AppStrings.of(context).translate('لا توجد حجوزات')));
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, i) {
              final data = snapshot.data!.docs[i].data();
              return ListTile(title: Text(data['providerName']?.toString() ?? AppStrings.of(context).translate('حجز')), subtitle: Text(data['status']?.toString() ?? 'pending'));
            },
          );
        },
      ),
    );
  }
}
