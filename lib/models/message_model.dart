// ============================================================
// 📦 نموذج الرسالة - MessageModel
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;
  final DateTime timestamp;
  bool isRead;
  bool isDelivered;
  final String type;
  String? replyTo;
  String? replyToText;
  bool isDeleted;
  Map<String, int> reactions;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.locationUrl,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    required this.type,
    this.replyTo,
    this.replyToText,
    this.isDeleted = false,
    this.reactions = const {},
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'مستخدم',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      fileUrl: map['fileUrl'],
      locationUrl: map['locationUrl'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      isDelivered: map['isDelivered'] ?? false,
      type: map['type'] ?? 'text',
      replyTo: map['replyTo'],
      replyToText: map['replyToText'],
      isDeleted: map['isDeleted'] ?? false,
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'locationUrl': locationUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'type': type,
      'replyTo': replyTo,
      'replyToText': replyToText,
      'isDeleted': isDeleted,
      'reactions': reactions,
    };
  }

  bool get isMe {
    final user = FirebaseAuth.instance.currentUser;
    return senderId == user?.uid;
  }
}
