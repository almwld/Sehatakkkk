// ============================================================
// 📊 MessageModel - نموذج الرسالة
// ============================================================

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
  final MessageModel? replyTo;
  final Map<String, String>? reactions;
  final Map<String, dynamic>? attachments;
  final Map<String, dynamic>? metadata;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final String? audioDuration;
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
    this.replyTo,
    this.reactions = const {},
    this.attachments,
    this.metadata,
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

  // ✅ المصنع لإنشاء النموذج من Firestore
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
      attachments: Map<String, dynamic>.from(data['attachments'] ?? {}),
      metadata: data['metadata'],
      locationAddress: data['locationAddress'],
      locationLat: data['locationLat'],
      locationLng: data['locationLng'],
      audioDuration: data['audioDuration'],
      fileSize: data['fileSize'],
      fileName: data['fileName'],
      fileMimeType: data['fileMimeType'],
      thumbnailUrl: data['thumbnailUrl'],
      isPinned: data['isPinned'] ?? false,
    );
  }

  // ✅ تحويل إلى Map لإرساله إلى Firestore
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
      'fileMimeType': fileMimeType,
      'thumbnailUrl': thumbnailUrl,
      'isPinned': isPinned,
    };
  }

  // ✅ دالة مساعدة لتحويل النوع من String إلى Enum
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

  // ✅ نسخة محدثة
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? text,
    MessageType? type,
    Timestamp? timestamp,
    bool? isRead,
    bool? isDelivered,
    bool? isEdited,
    bool? isDeleted,
    String? replyToId,
    MessageModel? replyTo,
    Map<String, String>? reactions,
    Map<String, dynamic>? attachments,
    Map<String, dynamic>? metadata,
    String? locationAddress,
    double? locationLat,
    double? locationLng,
    String? audioDuration,
    String? fileSize,
    String? fileName,
    String? fileMimeType,
    String? thumbnailUrl,
    bool? isPinned,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId ?? this.replyToId,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      locationAddress: locationAddress ?? this.locationAddress,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      audioDuration: audioDuration ?? this.audioDuration,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      fileMimeType: fileMimeType ?? this.fileMimeType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  List<Object?> get props => [
    id, chatId, senderId, senderName, senderPhotoUrl, text, type,
    timestamp, isRead, isDelivered, isEdited, isDeleted, replyToId,
    replyTo, reactions, attachments, metadata, locationAddress,
    locationLat, locationLng, audioDuration, fileSize, fileName,
    fileMimeType, thumbnailUrl, isPinned,
  ];

  // ✅ المساعدات
  bool get isSentByCurrentUser => false; // سيتم تحديدها من خلال AuthService
  bool get hasReactions => reactions?.isNotEmpty ?? false;
  bool get isAudio => type == MessageType.audio;
  bool get isImage => type == MessageType.image;
  bool get isVideo => type == MessageType.video;
  bool get isFile => type == MessageType.file;
  bool get isLocation => type == MessageType.location;
  bool get isText => type == MessageType.text;
  bool get isReply => type == MessageType.reply;
  bool get isSystem => type == MessageType.system;
  bool get isDeletedMessage => type == MessageType.deleted;
  bool get hasAttachments => attachments?.isNotEmpty ?? false;
  String getStatusString() {
    if (isDeleted) return 'تم الحذف';
    if (isRead) return 'مقروء';
    if (isDelivered) return 'تم التسليم';
    return 'مرسل';
  }
}
