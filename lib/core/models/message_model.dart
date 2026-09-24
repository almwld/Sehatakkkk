import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType { text, image, audio, video, file, location, contact, system, reaction, reply, deleted, call }

class MessageModel extends Equatable {
  final String id, chatId, senderId, senderName;
  final String? senderPhotoUrl, text;
  final Map<String, dynamic>? replyPreview;
  final MessageType type;
  final Timestamp? timestamp, clientTimestamp, readAt, deliveredAt, editedAt, pinnedAt;
  final bool isRead, isDelivered, isEdited, isDeleted, isPinned;
  final String? replyToId, idempotencyKey;
  final MessageModel? replyTo;
  final Map<String, String>? reactions;
  final Map<String, bool>? deletedFor;
  final Map<String, dynamic>? attachments, metadata;
  final String? imageUrl, audioUrl, fileUrl, videoUrl, locationUrl, locationAddress, audioDuration, fileSize, fileName, fileMimeType, thumbnailUrl;
  final double? locationLat, locationLng;

  const MessageModel({
    required this.id, required this.chatId, required this.senderId, required this.senderName,
    this.senderPhotoUrl, this.text, this.replyPreview, this.type = MessageType.text, this.timestamp, this.clientTimestamp,
    this.isRead = false, this.isDelivered = false, this.isEdited = false, this.isDeleted = false,
    this.replyToId, this.idempotencyKey, this.replyTo, this.reactions = const {}, this.deletedFor,
    this.attachments, this.metadata, this.imageUrl, this.audioUrl, this.fileUrl, this.videoUrl,
    this.locationUrl, this.locationAddress, this.locationLat, this.locationLng, this.audioDuration,
    this.fileSize, this.fileName, this.fileMimeType, this.thumbnailUrl, this.readAt, this.deliveredAt, this.editedAt, this.pinnedAt,
    this.isPinned = false,
  });

  factory MessageModel.fromFirestore(String id, Map<String, dynamic> d) {
    final serverTs = d['timestamp'] is Timestamp ? d['timestamp'] as Timestamp : null;
    final clientTs = d['clientTimestamp'] is Timestamp ? d['clientTimestamp'] as Timestamp : null;
    final effectiveTs = serverTs ?? clientTs ?? Timestamp.now();
    final ra = d['readAt'] is Timestamp ? d['readAt'] as Timestamp : null;
    final da = d['deliveredAt'] is Timestamp ? d['deliveredAt'] as Timestamp : null;
    final ea = d['editedAt'] is Timestamp ? d['editedAt'] as Timestamp : null;
    final pa = d['pinnedAt'] is Timestamp ? d['pinnedAt'] as Timestamp : null;
    final rawReply = d['replyPreview'];
    return MessageModel(
      id: id, chatId: d['chatId']?.toString() ?? '', senderId: d['senderId']?.toString() ?? '', senderName: d['senderName']?.toString() ?? '',
      senderPhotoUrl: d['senderPhotoUrl']?.toString(), text: d['text']?.toString(),
      replyPreview: rawReply is Map ? Map<String, dynamic>.from(rawReply) : null,
      type: MessageType.values.firstWhere((e) => e.name == d['type']?.toString(), orElse: () => MessageType.text), timestamp: effectiveTs, clientTimestamp: clientTs,
      isRead: d['isRead'] == true, isDelivered: d['isDelivered'] == true, isEdited: d['isEdited'] == true, isDeleted: d['isDeleted'] == true,
      replyToId: d['replyToId']?.toString(),
      idempotencyKey: d['idempotencyKey']?.toString(),
      reactions: d['reactions'] is Map ? Map<String, String>.from((d['reactions'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))) : <String, String>{},
      deletedFor: d['deletedFor'] is Map ? Map<String, bool>.from((d['deletedFor'] as Map).map((k, v) => MapEntry(k.toString(), v == true))) : <String, bool>{},
      attachments: d['attachments'] is Map ? Map<String, dynamic>.from(d['attachments']) : null, metadata: d['metadata'] is Map ? Map<String, dynamic>.from(d['metadata']) : null,
      imageUrl: d['imageUrl']?.toString(), audioUrl: d['audioUrl']?.toString(), fileUrl: d['fileUrl']?.toString(), videoUrl: d['videoUrl']?.toString(),
      locationUrl: d['locationUrl']?.toString(), locationAddress: d['locationAddress']?.toString(), locationLat: (d['locationLat'] as num?)?.toDouble(), locationLng: (d['locationLng'] as num?)?.toDouble(),
      audioDuration: d['audioDuration']?.toString(), fileSize: d['fileSize']?.toString(), fileName: d['fileName']?.toString(), fileMimeType: d['fileMimeType']?.toString(), thumbnailUrl: d['thumbnailUrl']?.toString(), readAt: ra, deliveredAt: da,
      isPinned: d['isPinned'] == true, editedAt: ea, pinnedAt: pa,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'chatId': chatId, 'senderId': senderId, 'senderName': senderName, 'senderPhotoUrl': senderPhotoUrl, 'text': text, 'type': type.name,
    'timestamp': timestamp ?? FieldValue.serverTimestamp(), 'clientTimestamp': clientTimestamp, 'isRead': isRead, 'isDelivered': isDelivered, 'isEdited': isEdited, 'isDeleted': isDeleted,
    'replyToId': replyToId, 'replyPreview': replyPreview, 'idempotencyKey': idempotencyKey, 'reactions': reactions, 'deletedFor': deletedFor, 'attachments': attachments, 'metadata': metadata,
    'imageUrl': imageUrl, 'audioUrl': audioUrl, 'fileUrl': fileUrl, 'videoUrl': videoUrl, 'locationUrl': locationUrl, 'locationAddress': locationAddress,
    'locationLat': locationLat, 'locationLng': locationLng, 'audioDuration': audioDuration, 'fileSize': fileSize, 'fileName': fileName, 'fileMimeType': fileMimeType,
    'thumbnailUrl': thumbnailUrl, 'readAt': readAt, 'deliveredAt': deliveredAt, 'editedAt': editedAt, 'pinnedAt': pinnedAt, 'isPinned': isPinned,
  };

  bool get isImage => type == MessageType.image; bool get isAudio => type == MessageType.audio; bool get isVideo => type == MessageType.video; bool get isFile => type == MessageType.file;
  bool get isLocation => type == MessageType.location; bool get isDeletedMessage => type == MessageType.deleted; bool get isText => type == MessageType.text; bool get isReply => type == MessageType.reply;
  bool get isCall => type == MessageType.call;
  bool get hasReactions => reactions?.isNotEmpty ?? false; bool get hasAttachments => attachments?.isNotEmpty ?? false;
  @override List<Object?> get props => [id, chatId, senderId, senderName, senderPhotoUrl, text, replyPreview, type, timestamp, clientTimestamp, isRead, isDelivered, isEdited, isDeleted, replyToId, idempotencyKey, replyTo, reactions, deletedFor, attachments, metadata, imageUrl, audioUrl, fileUrl, videoUrl, locationUrl, locationAddress, locationLat, locationLng, audioDuration, fileSize, fileName, fileMimeType, thumbnailUrl, readAt, deliveredAt, editedAt, pinnedAt, isPinned];
}
