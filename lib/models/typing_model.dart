// ============================================================
// 📦 نموذج حالة الكتابة (Typing)
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class TypingModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================

  final String userId;
  final String chatId;
  final String userName;
  final String? userImage;
  final bool isTyping;
  final DateTime timestamp;

  // ============================================================
  // 🏗️ المنشئ
  // ============================================================

  TypingModel({
    required this.userId,
    required this.chatId,
    required this.userName,
    this.userImage,
    required this.isTyping,
    required this.timestamp,
  });

  // ============================================================
  // 🔄 التحويل من/إلى Map
  // ============================================================

  factory TypingModel.fromMap(Map<String, dynamic> map) {
    return TypingModel(
      userId: map['userId'] ?? '',
      chatId: map['chatId'] ?? '',
      userName: map['userName'] ?? 'مستخدم',
      userImage: map['userImage'],
      isTyping: map['isTyping'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'chatId': chatId,
      'userName': userName,
      'userImage': userImage,
      'isTyping': isTyping,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================

  bool get isActive {
    final diff = DateTime.now().difference(timestamp);
    return diff.inSeconds < 5;
  }

  String get typingText {
    if (!isTyping) return '';
    return '$userName يكتب...';
  }
}
