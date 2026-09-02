import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكالمات'),
      ),
      body: const Center(
        child: Text(
          'لا يوجد سجل مكالمات متاح من Backend الحالي.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
