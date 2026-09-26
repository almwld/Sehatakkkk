import 'package:flutter/material.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalTipsScreen extends StatelessWidget {
  const DentalTipsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نصائح صحة الأسنان')),
      body: StreamBuilder(
        stream: DentalService().streamTips(limit: 30),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.map((tip) => Card(
              child: ExpansionTile(
                title: Text(tip.title),
                subtitle: Text(tip.category),
                children: [Padding(padding: const EdgeInsets.all(16), child: Text(tip.body))],
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}
