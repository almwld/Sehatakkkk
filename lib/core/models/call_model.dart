import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CallType { audio, video }
enum CallStatus { calling, ringing, connected, ended, missed, rejected, busy, cancelled }

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
      liveKitRoomName: data['liveKitRoomName'] ?? data['roomName'],
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
      case 'cancelled': return CallStatus.cancelled;
      default: return CallStatus.calling;
    }
  }

  bool get isAudioCall => callType == CallType.audio;
  bool get isVideoCallType => callType == CallType.video;
  bool get isActive => status == CallStatus.calling || status == CallStatus.ringing || status == CallStatus.connected;
  bool get isEnded => status == CallStatus.ended;
  bool get isMissed => status == CallStatus.missed;
  bool get isRejected => status == CallStatus.rejected;
  bool get isCancelled => status == CallStatus.cancelled;

  @override
  List<Object?> get props => [
    id, chatId, callerId, callerName, receiverId, receiverName,
    callType, status, startedAt, connectedAt, endedAt,
    durationSeconds, isAnswered, metadata, participants,
    liveKitRoomName, isVideoCall,
  ];
}
