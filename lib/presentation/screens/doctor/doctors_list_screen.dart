import '../../../bloc/doctor_bloc/doctor_bloc.dart';
import '../../../core/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/chat_service.dart';
import '../chat/chat_detail_screen.dart';
import 'doctor_details_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    context.read<DoctorBloc>().add(LoadDoctors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأطباء'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DoctorError) {
            return Center(child: Text(state.message));
          }
          if (state is DoctorLoaded) {
            if (state.doctors.isEmpty) {
              return const Center(child: Text('لا يوجد أطباء'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.doctors.length,
              itemBuilder: (context, index) {
                final doctor = state.doctors[index];
                return _buildDoctorCard(doctor);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
            doctor.name.isNotEmpty ? doctor.name[0] : 'ط',
            style: const TextStyle(color: Colors.teal),
          ),
        ),
        title: Text(doctor.name),
        subtitle: Text(doctor.specialty),
        trailing: IconButton(
          icon: const Icon(Icons.chat, color: Colors.teal),
          onPressed: () => _startChat(doctor),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorDetailsScreen(doctor: doctor),
            ),
          );
        },
      ),
    );
  }

  void _startChat(DoctorModel doctor) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تسجيل الدخول')),
        );
        return;
      }

      final chatId = await _chatService.createChat(
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
