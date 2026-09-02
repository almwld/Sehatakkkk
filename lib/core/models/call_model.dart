// ============================================================
// 📊 CallModel - نموذج المكالمة
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }
enum CallStatus { calling, ringing, connected, ended, missed, rejected, busy }

class CallModel extends Equatable {
  final String id;
  final String chatId;
  final String callerId;
  final String callerName;
  final String? callerPhotoUrl;
  final String receiverId;
  final String receiverName;
  final String? receiverPhotoUrl;
  final CallType callType;
  final CallStatus status;
  final Timestamp? startedAt;
  final Timestamp? connectedAt;
  final Timestamp? endedAt;
  final int? durationSeconds;
  final bool isAnswered;
  final Map<String, dynamic>? metadata;
  final List<String>? participants;
  final String? liveKitRoomName;
  final bool isVideoCall;

  const CallModel({
    required this.id,
    required this.chatId,
    required this.callerId,
    required this.callerName,
    this.callerPhotoUrl,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhotoUrl,
    required this.callType,
    this.status = CallStatus.calling,
    this.startedAt,
    this.connectedAt,
    this.endedAt,
    this.durationSeconds,
    this.isAnswered = false,
    this.metadata,
    this.participants,
    this.liveKitRoomName,
    this.isVideoCall = false,
  });

  factory CallModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CallModel(
      id: id,
      chatId: data['chatId'] ?? '',
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? '',
      callerPhotoUrl: data['callerPhotoUrl'],
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      receiverPhotoUrl: data['receiverPhotoUrl'],
      callType: _parseCallType(data['callType']),
      status: _parseCallStatus(data['status']),
      startedAt: data['startedAt'],
      connectedAt: data['connectedAt'],
      endedAt: data['endedAt'],
      durationSeconds: data['durationSeconds'],
      isAnswered: data['isAnswered'] ?? false,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      participants: List<String>.from(data['participants'] ?? []),
      liveKitRoomName: data['liveKitRoomName'],
      isVideoCall: data['isVideoCall'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'callerId': callerId,
      'callerName': callerName,
      'callerPhotoUrl': callerPhotoUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhotoUrl': receiverPhotoUrl,
      'callType': callType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startedAt': startedAt ?? FieldValue.serverTimestamp(),
      'connectedAt': connectedAt,
      'endedAt': endedAt,
      'durationSeconds': durationSeconds,
      'isAnswered': isAnswered,
      'metadata': metadata,
      'participants': participants,
      'liveKitRoomName': liveKitRoomName ?? chatId,
      'isVideoCall': isVideoCall,
    };
  }

  static CallType _parseCallType(String? type) {
    switch (type) {
      case 'video': return CallType.video;
      default: return CallType.audio;
    }
  }

  static CallStatus _parseCallStatus(String? status) {
    switch (status) {
      case 'ringing': return CallStatus.ringing;
      case 'connected': return CallStatus.connected;
      case 'ended': return CallStatus.ended;
      case 'missed': return CallStatus.missed;
      case 'rejected': return CallStatus.rejected;
      case 'busy': return CallStatus.busy;
      default: return CallStatus.calling;
    }
  }

  CallModel copyWith({
    String? id,
    String? chatId,
    String? callerId,
    String? callerName,
    String? callerPhotoUrl,
    String? receiverId,
    String? receiverName,
    String? receiverPhotoUrl,
    CallType? callType,
    CallStatus? status,
    Timestamp? startedAt,
    Timestamp? connectedAt,
    Timestamp? endedAt,
    int? durationSeconds,
    bool? isAnswered,
    Map<String, dynamic>? metadata,
    List<String>? participants,
    String? liveKitRoomName,
    bool? isVideoCall,
  }) {
    return CallModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerPhotoUrl: callerPhotoUrl ?? this.callerPhotoUrl,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhotoUrl: receiverPhotoUrl ?? this.receiverPhotoUrl,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      connectedAt: connectedAt ?? this.connectedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isAnswered: isAnswered ?? this.isAnswered,
      metadata: metadata ?? this.metadata,
      participants: participants ?? this.participants,
      liveKitRoomName: liveKitRoomName ?? this.liveKitRoomName,
      isVideoCall: isVideoCall ?? this.isVideoCall,
    );
  }

  @override
  List<Object?> get props => [
    id, chatId, callerId, callerName, callerPhotoUrl, receiverId,
    receiverName, receiverPhotoUrl, callType, status, startedAt,
    connectedAt, endedAt, durationSeconds, isAnswered, metadata,
    participants, liveKitRoomName, isVideoCall,
  ];

  // ✅ المساعدات
  bool get isAudioCall => callType == CallType.audio;
  bool get isVideoCallType => callType == CallType.video;
  bool get isActive => status == CallStatus.calling || status == CallStatus.ringing || status == CallStatus.connected;
  bool get isEnded => status == CallStatus.ended;
  bool get isMissed => status == CallStatus.missed;
  bool get isRejected => status == CallStatus.rejected;
  bool get isIncomingCall => status == CallStatus.calling && !isAnswered;
  bool get isOutgoingCall => status == CallStatus.calling && isAnswered;
  String getDurationFormatted() {
    if (durationSeconds == null) return '00:00';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
