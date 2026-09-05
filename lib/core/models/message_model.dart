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
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final String? audioDuration;
  final String? fileSize;
  final String? fileName;
  final String? fileMimeType;
  final String? thumbnailUrl;
  final Timestamp? readAt;
  final Timestamp? deliveredAt;
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
    this.readAt,
    this.deliveredAt,
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
      metadata: data['metadata'],
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
      readAt: data['readAt'],
      deliveredAt: data['deliveredAt'],
      isPinned: data['isPinned'] ?? false,
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
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'locationUrl': locationUrl,
      'locationAddress': locationAddress,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'audioDuration': audioDuration,
      'fileSize': fileSize,
      'fileName': fileName,
      'fileMimeType': fileMimeType,
      'thumbnailUrl': thumbnailUrl,
      'readAt': readAt,
      'deliveredAt': deliveredAt,
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
      case 'contact': return MessageType.contact;
      case 'system': return MessageType.system;
      case 'reaction': return MessageType.reaction;
      case 'reply': return MessageType.reply;
      case 'deleted': return MessageType.deleted;
      default: return MessageType.text;
    }
  }

  bool get isImage => type == MessageType.image;
  bool get isAudio => type == MessageType.audio;
  bool get isVideo => type == MessageType.video;
  bool get isFile => type == MessageType.file;
  bool get isLocation => type == MessageType.location;
  bool get isDeletedMessage => type == MessageType.deleted;
  bool get isText => type == MessageType.text;
  bool get isReply => type == MessageType.reply;
  bool get hasReactions => reactions?.isNotEmpty ?? false;
  bool get hasAttachments => attachments?.isNotEmpty ?? false;

  @override
  List<Object?> get props => [
    id, chatId, senderId, senderName, senderPhotoUrl, text, type,
    timestamp, isRead, isDelivered, isEdited, isDeleted, replyToId,
    replyTo, reactions, attachments, metadata, imageUrl, audioUrl,
    fileUrl, locationUrl, locationAddress, locationLat, locationLng,
    audioDuration, fileSize, fileName, fileMimeType, thumbnailUrl,
    readAt, deliveredAt, isPinned,
  ];
}
