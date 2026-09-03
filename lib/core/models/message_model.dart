import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  audio,
  video,
  file,
  location,
  contact,
  system,
  reaction,
  reply,
  deleted,
}

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
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final int? audioDuration;
  final String? fileSize;
  final String? fileName;
  final String? fileMimeType;
  final String? thumbnailUrl;
  final bool isPinned;

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
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.locationUrl,
    this.locationAddress,
    this.locationLat,
    this.locationLng,
    this.audioDuration,
    this.fileSize,
    this.fileName,
    this.fileMimeType,
    this.thumbnailUrl,
    this.isPinned = false,
  });

  factory MessageModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MessageModel(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      text: data['text'],
      type: _parseMessageType(data['type']),
      timestamp: data['timestamp'],
      isRead: data['isRead'] ?? false,
      isDelivered: data['isDelivered'] ?? false,
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      replyToId: data['replyToId'],
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      attachments: data['attachments'] as Map<String, dynamic>?,
      imageUrl: data['imageUrl'],
      audioUrl: data['audioUrl'],
      fileUrl: data['fileUrl'],
      locationUrl: data['locationUrl'],
      locationAddress: data['locationAddress'],
      locationLat: (data['locationLat'] as num?)?.toDouble(),
      locationLng: (data['locationLng'] as num?)?.toDouble(),
      audioDuration: data['audioDuration'],
      fileSize: data['fileSize'],
      fileName: data['fileName'],
      fileMimeType: data['fileMimeType'],
      thumbnailUrl: data['thumbnailUrl'],
      isPinned: data['isPinned'] ?? false,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'audio': return MessageType.audio;
      case 'video': return MessageType.video;
      case 'file': return MessageType.file;
      case 'location': return MessageType.location;
      case 'contact': return MessageType.contact;
      case 'system': return MessageType.system;
      case 'reaction': return MessageType.reaction;
      case 'reply': return MessageType.reply;
      case 'deleted': return MessageType.deleted;
      default: return MessageType.text;
    }
  }

  @override
  List<Object?> get props => [id, chatId, senderId, text, type, timestamp];
}
