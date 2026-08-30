// ============================================================
// 📱 شاشة المحادثات - إصلاح context
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';

// ... باقي الكود ...

// ✅ دوال مساعدة مع context
void _startChatWithDoctor(Map<String, dynamic> doctor, BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ToastService.showError('❌ يجب تسجيل الدخول');
    return;
  }

  try {
    final chatId = await context.read<ChatBloc>().createChat(
      doctorId: doctor['id'],
      doctorName: doctor['name'],
      patientId: user.uid,
      patientName: user.displayName ?? 'مريض',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          chatId: chatId,
          userId: user.uid,
          userName: doctor['name'],
          isDoctor: true,
        ),
      ),
    );
  } catch (e) {
    ToastService.showError('❌ فشل إنشاء المحادثة: $e');
  }
}

// ✅ دوال _createTestChat مع context
void _createTestChat(BuildContext context) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول');
      return;
    }

    final chatId = await context.read<ChatBloc>().createChat(
      doctorId: 'test_doctor',
      doctorName: 'د. أحمد (تجريبي)',
      patientId: user.uid,
      patientName: user.displayName ?? 'مريض',
    );

    ToastService.showSuccess('✅ تم إنشاء محادثة تجريبية');
    context.read<ChatBloc>().refreshChats();
  } catch (e) {
    ToastService.showError('❌ فشل إنشاء المحادثة: $e');
  }
}
