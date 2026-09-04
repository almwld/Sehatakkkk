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
  final bool isArchived;
  final bool isPinned;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final bool isMuted;

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
    this.isArchived = false,
    this.isPinned = false,
    this.createdAt,
    this.updatedAt,
    this.isMuted = false,
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
      isArchived: data['isArchived'] ?? false,
      isPinned: data['isPinned'] ?? false,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      isMuted: data['isMuted'] ?? false,
    );
  }

  // ✅ دوال مساعدة
  String getDisplayName(String userId) {
    if (isGroup) return groupName ?? 'مجموعة';
    final otherId = participants.firstWhere(
      (p) => p != userId,
      orElse: () => '',
    );
    return participantDetails[otherId]?['name'] ?? 'مستخدم';
  }

  String getDisplayPhoto(String userId) {
    if (isGroup) return groupPhoto ?? '';
    final otherId = participants.firstWhere(
      (p) => p != userId,
      orElse: () => '',
    );
    return participantDetails[otherId]?['photoUrl'] ?? '';
  }

  int getTotalUnreadCount() {
    return unreadCount.values.fold(0, (sum, count) => sum + count);
  }

  @override
  List<Object?> get props => [
    id, participants, participantDetails, lastMessage, lastMessageTime,
    lastMessageSenderId, unreadCount, isGroup, groupName, groupPhoto,
    isArchived, isPinned, createdAt, updatedAt, isMuted,
  ];
}
