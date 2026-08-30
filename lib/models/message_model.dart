// ============================================================
// 📦 نموذج الرسالة
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  String text;
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
  bool isEncrypted;
  bool isSelfDestruct;
  int selfDestructDuration;
  Map<String, int> reactions;
  final String? fileName;
  final String? fileSize;

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
    this.isEncrypted = false,
    this.isSelfDestruct = false,
    this.selfDestructDuration = 0,
    this.reactions = const {},
    this.fileName,
    this.fileSize,
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
      isEncrypted: map['isEncrypted'] ?? false,
      isSelfDestruct: map['isSelfDestruct'] ?? false,
      selfDestructDuration: map['selfDestructDuration'] ?? 0,
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
      fileName: map['fileName'],
      fileSize: map['fileSize'],
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
      'isEncrypted': isEncrypted,
      'isSelfDestruct': isSelfDestruct,
      'selfDestructDuration': selfDestructDuration,
      'reactions': reactions,
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isAudio => type == 'audio';
  bool get isFile => type == 'file';
  bool get isLocation => type == 'location';
  bool get isVideo => type == 'video';
  
  bool get isMe {
    final user = FirebaseAuth.instance.currentUser;
    return senderId == user?.uid;
  }

  String get getFileName {
    if (fileName != null && fileName!.isNotEmpty) return fileName!;
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      final parts = fileUrl!.split('/');
      return parts.last;
    }
    return 'ملف';
  }

  String get getFileSizeFormatted {
    if (fileSize != null && fileSize!.isNotEmpty) {
      return fileSize!;
    }
    return '0 KB';
  }
}
