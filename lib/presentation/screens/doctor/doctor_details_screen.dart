import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/services/chat_service.dart';
import '../chat/chat_detail_screen.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final DoctorModel doctor;
  
  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.teal.shade100,
                child: Text(
                  doctor.name.isNotEmpty ? doctor.name[0] : 'ط',
                  style: const TextStyle(fontSize: 40, color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                doctor.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                doctor.specialty,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            if (doctor.hospital != null)
              _buildInfoRow('🏥', doctor.hospital!),
            if (doctor.experienceYears != null)
              _buildInfoRow('📅', '${doctor.experienceYears} سنوات خبرة'),
            if (doctor.rating != null)
              _buildInfoRow('⭐', '${doctor.rating} (${doctor.reviewsCount ?? 0} تقييم)'),
            if (doctor.about != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نبذة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(doctor.about!),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startChat(context),
                icon: const Icon(Icons.chat),
                label: const Text('بدء محادثة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _startChat(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تسجيل الدخول')),
        );
        return;
      }

      final chatService = ChatService();
      final chatId = await chatService.createChat(
        doctorId: doctor.id,
        doctorName: doctor.name,
        patientName: user.displayName ?? 'مريض',
      );

      if (chatId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chatId: chatId),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء المحادثة: $e')),
      );
    }
  }
}
