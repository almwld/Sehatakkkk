import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CallType { audio, video }

enum CallStatus {
  calling,
  ringing,
  connected,
  ended,
  missed,
  rejected,
  busy,
  cancelled,
}

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

  factory CallModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return CallModel(
      id: id,
      chatId: data['chatId']?.toString() ?? '',
      callerId: data['callerId']?.toString() ?? '',
      callerName: data['callerName']?.toString() ?? 'مستخدم',
      callerPhotoUrl: data['callerPhotoUrl']?.toString(),
      receiverId: data['receiverId']?.toString() ?? '',
      receiverName: data['receiverName']?.toString() ?? 'مستخدم',
      receiverPhotoUrl: data['receiverPhotoUrl']?.toString(),
      callType: _parseCallType(data['callType']),
      status: _parseCallStatus(data['status']),
      startedAt: data['startedAt'] is Timestamp
          ? data['startedAt'] as Timestamp
          : null,
      connectedAt: data['connectedAt'] is Timestamp
          ? data['connectedAt'] as Timestamp
          : null,
      endedAt: data['endedAt'] is Timestamp
          ? data['endedAt'] as Timestamp
          : null,
      durationSeconds: data['durationSeconds'] is num
          ? (data['durationSeconds'] as num).toInt()
          : null,
      isAnswered: data['isAnswered'] == true,
      metadata: data['metadata'] is Map
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
      participants: data['participants'] is List
          ? List<String>.from(data['participants'])
          : null,
      liveKitRoomName:
          data['liveKitRoomName']?.toString() ??
          data['roomName']?.toString(),
      isVideoCall: data['isVideoCall'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'chatId': chatId,
      'callerId': callerId,
      'callerName': callerName,
      'callerPhotoUrl': callerPhotoUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhotoUrl': receiverPhotoUrl,
      'callType': callType.name,
      'status': status.name,
      'startedAt': startedAt ?? FieldValue.serverTimestamp(),
      'connectedAt': connectedAt,
      'endedAt': endedAt,
      'durationSeconds': durationSeconds,
      'isAnswered': isAnswered,
      'metadata': metadata,
      'participants': participants,
      'liveKitRoomName': liveKitRoomName,
      'isVideoCall': isVideoCall,
    };
  }

  static CallType _parseCallType(dynamic value) {
    return value?.toString() == 'video'
        ? CallType.video
        : CallType.audio;
  }

  static CallStatus _parseCallStatus(dynamic value) {
    switch (value?.toString()) {
      case 'ringing':
        return CallStatus.ringing;
      case 'connected':
        return CallStatus.connected;
      case 'ended':
        return CallStatus.ended;
      case 'missed':
        return CallStatus.missed;
      case 'rejected':
        return CallStatus.rejected;
      case 'busy':
        return CallStatus.busy;
      case 'cancelled':
        return CallStatus.cancelled;
      default:
        return CallStatus.calling;
    }
  }

  bool get isAudioCall => callType == CallType.audio;

  bool get isVideoCallType => callType == CallType.video;

  bool get isActive =>
      status == CallStatus.calling ||
      status == CallStatus.ringing ||
      status == CallStatus.connected;

  bool get isEnded => status == CallStatus.ended;

  bool get isMissed => status == CallStatus.missed;

  bool get isRejected => status == CallStatus.rejected;

  bool get isCancelled => status == CallStatus.cancelled;

  bool isIncomingFor(String userId) =>
      receiverId == userId && callerId != userId;

  bool isOutgoingFor(String userId) =>
      callerId == userId && receiverId != userId;

  @override
  List<Object?> get props => [
        id,
        chatId,
        callerId,
        callerName,
        callerPhotoUrl,
        receiverId,
        receiverName,
        receiverPhotoUrl,
        callType,
        status,
        startedAt,
        connectedAt,
        endedAt,
        durationSeconds,
        isAnswered,
        metadata,
        participants,
        liveKitRoomName,
        isVideoCall,
      ];
}
