// ============================================================
// 📦 نموذج المحادثة - نسخة مبسطة
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String? doctorImage;
  final String patientId;
  final String patientName;
  final String? patientImage;
  String lastMessage;
  DateTime lastMessageTime;
  final DateTime createdAt;
  final List<String> participants;
  Map<String, int> unreadCount;
  bool isOnline;
  bool isGroup;
  String? groupName;
  String? groupImage;
  List<String> admins;

  ChatModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorImage,
    required this.patientId,
    required this.patientName,
    this.patientImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.participants,
    required this.unreadCount,
    this.isOnline = false,
    this.isGroup = false,
    this.groupName,
    this.groupImage,
    this.admins = const [],
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? 'طبيب',
      doctorImage: map['doctorImage'],
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? 'مريض',
      patientImage: map['patientImage'],
      lastMessage: map['lastMessage'] ?? 'ابدأ المحادثة',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: List<String>.from(map['participants'] ?? []),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      isOnline: map['isOnline'] ?? false,
      isGroup: map['isGroup'] ?? false,
      groupName: map['groupName'],
      groupImage: map['groupImage'],
      admins: List<String>.from(map['admins'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'patientId': patientId,
      'patientName': patientName,
      'patientImage': patientImage,
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': createdAt,
      'participants': participants,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupImage': groupImage,
      'admins': admins,
    };
  }

  String getOtherParticipantId(String userId) {
    return participants.firstWhere((id) => id != userId);
  }

  String getOtherParticipantName(String userId) {
    if (isGroup) {
      return groupName ?? 'مجموعة';
    }
    if (doctorId == userId) return patientName;
    return doctorName;
  }

  String getOtherParticipantImage(String userId) {
    if (isGroup) {
      return groupImage ?? '';
    }
    if (doctorId == userId) return patientImage ?? '';
    return doctorImage ?? '';
  }

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }
}
