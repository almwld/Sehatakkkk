// ============================================================
// 📦 MessageModel - نموذج الرسالة الموحد
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType { text, image, audio, video, file, location, reply, deleted }

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String? text;
  final MessageType type;
  final Timestamp? timestamp;
  final bool isRead;
  final bool isDelivered;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId;
  final Map<String, String>? reactions;
  final Map<String, dynamic>? attachments;
  final Map<String, dynamic>? metadata;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final int? audioDuration;
  final String? fileSize;
  final String? fileName;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    this.text,
    this.type = MessageType.text,
    this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
    this.reactions,
    this.attachments,
    this.metadata,
    this.locationAddress,
    this.locationLat,
    this.locationLng,
    this.audioDuration,
    this.fileSize,
    this.fileName,
  });

  factory MessageModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MessageModel(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      text: data['text'],
      type: _parseType(data['type']),
      timestamp: data['timestamp'],
      isRead: data['isRead'] ?? false,
      isDelivered: data['isDelivered'] ?? false,
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      replyToId: data['replyToId'],
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      attachments: data['attachments'],
      metadata: data['metadata'],
      locationAddress: data['locationAddress'],
      locationLat: data['locationLat']?.toDouble(),
      locationLng: data['locationLng']?.toDouble(),
      audioDuration: data['audioDuration'],
      fileSize: data['fileSize'],
      fileName: data['fileName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'type': type.toString().split('.').last,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'replyToId': replyToId,
      'reactions': reactions,
      'attachments': attachments,
      'metadata': metadata,
      'locationAddress': locationAddress,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'audioDuration': audioDuration,
      'fileSize': fileSize,
      'fileName': fileName,
    };
  }

  static MessageType _parseType(String? type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'audio': return MessageType.audio;
      case 'video': return MessageType.video;
      case 'file': return MessageType.file;
      case 'location': return MessageType.location;
      case 'reply': return MessageType.reply;
      case 'deleted': return MessageType.deleted;
      default: return MessageType.text;
    }
  }

  @override
  List<Object?> get props => [id, chatId, senderId, text, type, timestamp];
}
