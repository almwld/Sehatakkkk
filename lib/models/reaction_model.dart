// ============================================================
// 📦 نموذج التفاعل
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionModel {
  final String id;
  final String messageId;
  final String chatId;
  final String userId;
  final String userName;
  final String userImage;
  final String emoji;
  final DateTime timestamp;

  ReactionModel({
    required this.id,
    required this.messageId,
    required this.chatId,
    required this.userId,
    required this.userName,
    this.userImage = '',
    required this.emoji,
    required this.timestamp,
  });

  factory ReactionModel.fromMap(Map<String, dynamic> map, String id) {
    return ReactionModel(
      id: id,
      messageId: map['messageId'] ?? '',
      chatId: map['chatId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'] ?? '',
      emoji: map['emoji'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'emoji': emoji,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
