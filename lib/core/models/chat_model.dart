// ============================================================
// 📦 ChatModel - نموذج المحادثة الموحد
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> participantDetails;
  final String? lastMessage;
  final Timestamp? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final bool isGroup;
  final String? groupName;
  final String? groupPhoto;
  final String? groupAdminId;
  final List<String>? groupAdmins;
  final bool isArchived;
  final bool isPinned;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? chatBackground;
  final bool isMuted;
  final Map<String, dynamic>? metadata;

  const ChatModel({
    required this.id,
    required this.participants,
    this.participantDetails = const {},
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = const {},
    this.isGroup = false,
    this.groupName,
    this.groupPhoto,
    this.groupAdminId,
    this.groupAdmins,
    this.isArchived = false,
    this.isPinned = false,
    this.createdAt,
    this.updatedAt,
    this.chatBackground,
    this.isMuted = false,
    this.metadata,
  });

  factory ChatModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatModel(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      participantDetails: Map<String, dynamic>.from(data['participantDetails'] ?? {}),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'],
      lastMessageSenderId: data['lastMessageSenderId'],
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'],
      groupPhoto: data['groupPhoto'],
      groupAdminId: data['groupAdminId'],
      groupAdmins: List<String>.from(data['groupAdmins'] ?? []),
      isArchived: data['isArchived'] ?? false,
      isPinned: data['isPinned'] ?? false,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      chatBackground: data['chatBackground'],
      isMuted: data['isMuted'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantDetails': participantDetails,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime ?? FieldValue.serverTimestamp(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'groupAdminId': groupAdminId,
      'groupAdmins': groupAdmins,
      'isArchived': isArchived,
      'isPinned': isPinned,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'chatBackground': chatBackground,
      'isMuted': isMuted,
      'metadata': metadata,
    };
  }

  String getOtherParticipantName(String userId) {
    if (isGroup) return groupName ?? 'مجموعة';
    final otherId = participants.firstWhere((p) => p != userId, orElse: () => '');
    return participantDetails[otherId]?['name'] ?? 'مستخدم';
  }

  String getOtherParticipantImage(String userId) {
    if (isGroup) return groupPhoto ?? '';
    final otherId = participants.firstWhere((p) => p != userId, orElse: () => '');
    return participantDetails[otherId]?['photoUrl'] ?? '';
  }

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  @override
  List<Object?> get props => [id, participants, lastMessage, lastMessageTime];
}
