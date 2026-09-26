import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalConsultationScreen extends StatefulWidget {
  const DentalConsultationScreen({super.key});
  @override State<DentalConsultationScreen> createState() => _DentalConsultationState();
}

class _DentalConsultationState extends State<DentalConsultationScreen> {
  final q = TextEditingController();
  bool saving = false;
  @override void dispose() { q.dispose(); super.dispose(); }

  Future<void> send() async {
    final user = FirebaseAuth.instance.currentUser;
    final question = q.text.trim();
    if (user == null || question.isEmpty || saving) return;
    setState(() => saving = true);
    try {
      await DentalService().createConsultation(
        userId: user.uid, userName: user.displayName ?? 'مستخدم',
        doctorId: '', doctorName: '', question: question,
      );
      q.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الاستشارة')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استشارة الأسنان')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: q, maxLines: 6, decoration: const InputDecoration(labelText: 'اكتب سؤالك', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: saving ? null : send,
            child: Text(saving ? 'جارٍ الإرسال...' : 'إرسال الاستشارة'),
          )),
        ]),
      ),
    );
  }
}
