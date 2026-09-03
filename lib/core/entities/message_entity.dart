import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  audio,
  video,
  file,
  location,
  deleted,
}

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String? text;
  final MessageType type;
  final DateTime? timestamp;
  final bool isRead;
  final bool isDelivered;
  final bool isDeleted;
  final bool isEdited;
  final String? replyToId;
  final Map<String, String>? reactions;
  final Map<String, dynamic>? attachments;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final int? audioDuration;
  final String? fileSize;
  final String? fileName;
  final String? fileMimeType;
  final String? thumbnailUrl;
  final bool isPinned;

  const MessageEntity({
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
    this.isDeleted = false,
    this.isEdited = false,
    this.replyToId,
    this.reactions,
    this.attachments,
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

  factory MessageEntity.fromFirestore(String id, Map<String, dynamic> data) {
    return MessageEntity(
      id: id,
      chatId: data['chatId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] as String?,
      text: data['text'] as String?,
      type: _parseMessageType(data['type'] as String?),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isRead: data['isRead'] as bool? ?? false,
      isDelivered: data['isDelivered'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isEdited: data['isEdited'] as bool? ?? false,
      replyToId: data['replyToId'] as String?,
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      attachments: data['attachments'] as Map<String, dynamic>?,
      locationAddress: data['locationAddress'] as String?,
      locationLat: (data['locationLat'] as num?)?.toDouble(),
      locationLng: (data['locationLng'] as num?)?.toDouble(),
      audioDuration: data['audioDuration'] as int?,
      fileSize: data['fileSize'] as String?,
      fileName: data['fileName'] as String?,
      fileMimeType: data['fileMimeType'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      isPinned: data['isPinned'] as bool? ?? false,
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
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isDeleted': isDeleted,
      'isEdited': isEdited,
      'replyToId': replyToId,
      'reactions': reactions,
      'attachments': attachments,
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

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'audio': return MessageType.audio;
      case 'video': return MessageType.video;
      case 'file': return MessageType.file;
      case 'location': return MessageType.location;
      case 'deleted': return MessageType.deleted;
      default: return MessageType.text;
    }
  }

  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isAudio => type == MessageType.audio;
  bool get isVideo => type == MessageType.video;
  bool get isFile => type == MessageType.file;
  bool get isLocation => type == MessageType.location;
  bool get isDeletedMessage => type == MessageType.deleted;
  bool get hasReactions => reactions?.isNotEmpty ?? false;
  bool get hasAttachments => attachments?.isNotEmpty ?? false;

  @override
  List<Object?> get props => [
    id, chatId, senderId, senderName, senderPhotoUrl, text, type,
    timestamp, isRead, isDelivered, isDeleted, isEdited, replyToId,
    reactions, attachments, locationAddress, locationLat, locationLng,
    audioDuration, fileSize, fileName, fileMimeType, thumbnailUrl,
    isPinned,
  ];
}
