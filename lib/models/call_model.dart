import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String id;
  final String callerId;
  final String receiverId;
  final String? callerName;
  final String? receiverName;
  final String callType;
  final String status;
  final Timestamp? startedAt;
  final Timestamp? endedAt;
  final Timestamp? createdAt;
  final String? roomId;

  const CallModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    this.callerName,
    this.receiverName,
    this.callType = 'audio',
    this.status = 'initiated',
    this.startedAt,
    this.endedAt,
    this.createdAt,
    this.roomId,
  });

  factory CallModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return CallModel(
      id: id,
      callerId: data['callerId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      callerName: data['callerName'] as String?,
      receiverName: data['receiverName'] as String?,
      callType: data['callType'] as String? ?? 'audio',
      status: data['status'] as String? ?? 'initiated',
      startedAt: data['startedAt'] as Timestamp?,
      endedAt: data['endedAt'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp?,
      roomId: data['roomId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'receiverName': receiverName,
      'callType': callType,
      'status': status,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'createdAt': createdAt,
      'roomId': roomId,
    };
  }
}
