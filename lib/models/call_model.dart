// ============================================================
// 📦 نموذج المكالمة المتكامل
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================

  final String id;
  final String chatId;
  final String callerId;
  final String callerName;
  final String? callerImage;
  final String receiverId;
  final String receiverName;
  final String? receiverImage;
  final String type; // 'audio', 'video'
  final String status; // 'calling', 'ringing', 'connected', 'ended', 'missed', 'rejected'
  final int duration;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isVideo;
  final String? recordingUrl;
  final List<String> participants;
  final Map<String, bool> answeredBy;
  final bool isGroup;

  // ============================================================
  // 🏗️ المنشئ
  // ============================================================

  CallModel({
    required this.id,
    required this.chatId,
    required this.callerId,
    required this.callerName,
    this.callerImage,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
    required this.type,
    required this.status,
    this.duration = 0,
    required this.startedAt,
    this.endedAt,
    this.isVideo = false,
    this.recordingUrl,
    this.participants = const [],
    this.answeredBy = const {},
    this.isGroup = false,
  });

  // ============================================================
  // 🔄 التحويل من/إلى Map
  // ============================================================

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      id: id,
      chatId: map['chatId'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? 'مستخدم',
      callerImage: map['callerImage'],
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? 'مستخدم',
      receiverImage: map['receiverImage'],
      type: map['type'] ?? 'audio',
      status: map['status'] ?? 'calling',
      duration: map['duration'] ?? 0,
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
      isVideo: map['isVideo'] ?? false,
      recordingUrl: map['recordingUrl'],
      participants: List<String>.from(map['participants'] ?? []),
      answeredBy: Map<String, bool>.from(map['answeredBy'] ?? {}),
      isGroup: map['isGroup'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'callerId': callerId,
      'callerName': callerName,
      'callerImage': callerImage,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
      'type': type,
      'status': status,
      'duration': duration,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'isVideo': isVideo,
      'recordingUrl': recordingUrl,
      'participants': participants,
      'answeredBy': answeredBy,
      'isGroup': isGroup,
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================

  bool get isAudio => type == 'audio';
  bool get isVideoCall => type == 'video';
  bool get isIncoming => status == 'calling' || status == 'ringing';
  bool get isOutgoing => status == 'connected' || status == 'ended';
  bool get isMissed => status == 'missed';
  bool get isRejected => status == 'rejected';
  bool get isConnected => status == 'connected';
  bool get isEnded => status == 'ended';

  String get formattedDuration {
    final mins = (duration / 60).floor();
    final secs = duration % 60;
    if (mins > 0) {
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
    return '0:${secs.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (status) {
      case 'calling':
        return 'جاري الاتصال...';
      case 'ringing':
        return 'يرن...';
      case 'connected':
        return 'متصل';
      case 'ended':
        return 'منتهية';
      case 'missed':
        return 'فائتة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status;
    }
  }

  bool get isAnswered {
    if (answeredBy.isEmpty) return false;
    for (final entry in answeredBy.entries) {
      if (entry.value) return true;
    }
    return false;
  }

  String getOtherParticipant(String userId) {
    if (callerId == userId) return receiverName;
    return callerName;
  }

  String getOtherParticipantId(String userId) {
    if (callerId == userId) return receiverId;
    return callerId;
  }

  bool isParticipant(String userId) {
    return participants.contains(userId) || callerId == userId || receiverId == userId;
  }

  CallModel copyWith({
    String? status,
    int? duration,
    DateTime? endedAt,
    String? recordingUrl,
  }) {
    return CallModel(
      id: id,
      chatId: chatId,
      callerId: callerId,
      callerName: callerName,
      callerImage: callerImage,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverImage: receiverImage,
      type: type,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      isVideo: isVideo,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      participants: participants,
      answeredBy: answeredBy,
      isGroup: isGroup,
    );
  }
}
