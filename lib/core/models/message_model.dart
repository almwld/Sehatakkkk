class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final String type;
  final DateTime? timestamp;
  final bool isRead;
  final bool isDelivered;

  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;

  final String? fileName;
  final String? replyToMessageId;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.isDelivered,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.locationUrl,
    this.fileName,
    this.replyToMessageId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: _string(json['messageId'] ?? json['id']),
      chatId: _string(json['chatId']),
      senderId: _string(json['senderId']),
      senderName: _string(json['senderName']),
      text: _string(json['text']),
      type: _string(json['type']).isEmpty
          ? 'text'
          : _string(json['type']),
      timestamp: _date(
        json['timestamp'] ?? json['createdAt'],
      ),
      isRead: json['isRead'] == true,
      isDelivered: json['isDelivered'] == true,
      imageUrl: _nullableString(json['imageUrl']),
      audioUrl: _nullableString(json['audioUrl']),
      fileUrl: _nullableString(json['fileUrl']),
      locationUrl: _nullableString(json['locationUrl']),
      fileName: _nullableString(json['fileName']),
      replyToMessageId:
          _nullableString(json['replyToMessageId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type,
      'timestamp': timestamp?.toIso8601String(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (locationUrl != null) 'locationUrl': locationUrl,
      if (fileName != null) 'fileName': fileName,
      if (replyToMessageId != null)
        'replyToMessageId': replyToMessageId,
    };
  }

  MessageModel copyWith({
    bool? isRead,
    bool? isDelivered,
  }) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      fileUrl: fileUrl,
      locationUrl: locationUrl,
      fileName: fileName,
      replyToMessageId: replyToMessageId,
    );
  }

  static String _string(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final valueString = value.toString();

    return valueString.isEmpty ? null : valueString;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is Map) {
      final seconds = value['_seconds'] ?? value['seconds'];
      final nanoseconds =
          value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;

      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds.toInt() * 1000 +
              (nanoseconds is num
                  ? nanoseconds.toInt() ~/ 1000000
                  : 0),
        );
      }
    }

    return null;
  }
}
