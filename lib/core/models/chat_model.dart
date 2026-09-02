class ChatModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final String patientId;
  final String patientName;
  final String patientImage;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;

  const ChatModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImage,
    required this.patientId,
    required this.patientName,
    required this.patientImage,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.unreadCount,
    required this.isOnline,
    required this.isGroup,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: _string(json['chatId'] ?? json['id']),
      doctorId: _string(json['doctorId']),
      doctorName: _string(json['doctorName']),
      doctorImage: _string(json['doctorImage']),
      patientId: _string(json['patientId']),
      patientName: _string(json['patientName']),
      patientImage: _string(json['patientImage']),
      participants: _stringList(json['participants']),
      lastMessage: _string(json['lastMessage']),
      lastMessageTime: _date(json['lastMessageTime']),
      createdAt: _date(json['createdAt']),
      unreadCount: _int(json['unreadCount']),
      isOnline: json['isOnline'] == true,
      isGroup: json['isGroup'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'patientId': patientId,
      'patientName': patientName,
      'patientImage': patientImage,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isGroup': isGroup,
    };
  }

  ChatModel copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatModel(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorImage: doctorImage,
      patientId: patientId,
      patientName: patientName,
      patientImage: patientImage,
      participants: participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isGroup: isGroup,
    );
  }

  static String _string(dynamic value) {
    return value?.toString() ?? '';
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
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
