import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserParticipant extends Equatable {
  final String name;
  final String? photoUrl;
  final bool? isOnline;

  const UserParticipant({
    required this.name,
    this.photoUrl,
    this.isOnline,
  });

  factory UserParticipant.fromJson(Map<String, dynamic> json) {
    return UserParticipant(
      name: json['name'] ?? 'مستخدم',
      photoUrl: json['photoUrl'],
      isOnline: json['isOnline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
    };
  }

  @override
  List<Object?> get props => [name, photoUrl, isOnline];
}

class ChatEntity extends Equatable {
  final String id;
  final List<String> participants;
  final Map<String, UserParticipant> participantDetails;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final bool isGroup;
  final String? groupName;
  final String? groupPhoto;
  final bool isArchived;
  final bool isPinned;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isMuted;

  const ChatEntity({
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

  factory ChatEntity.fromFirestore(String id, Map<String, dynamic> data) {
    final participantDetails = <String, UserParticipant>{};
    final details = data['participantDetails'] as Map<String, dynamic>? ?? {};
    details.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        participantDetails[key] = UserParticipant.fromJson(value);
      }
    });

    return ChatEntity(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      participantDetails: participantDetails,
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      isGroup: data['isGroup'] as bool? ?? false,
      groupName: data['groupName'] as String?,
      groupPhoto: data['groupPhoto'] as String?,
      isArchived: data['isArchived'] as bool? ?? false,
      isPinned: data['isPinned'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isMuted: data['isMuted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    final details = <String, dynamic>{};
    participantDetails.forEach((key, value) {
      details[key] = value.toJson();
    });

    return {
      'participants': participants,
      'participantDetails': details,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'isArchived': isArchived,
      'isPinned': isPinned,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isMuted': isMuted,
    };
  }

  String getDisplayName(String userId) {
    if (isGroup) return groupName ?? 'مجموعة';
    final otherId = participants.firstWhere(
      (p) => p != userId,
      orElse: () => '',
    );
    return participantDetails[otherId]?.name ?? 'مستخدم';
  }

  String getDisplayPhoto(String userId) {
    if (isGroup) return groupPhoto ?? '';
    final otherId = participants.firstWhere(
      (p) => p != userId,
      orElse: () => '',
    );
    return participantDetails[otherId]?.photoUrl ?? '';
  }

  int getUnreadCount(String userId) => unreadCount[userId] ?? 0;
  bool hasUnread() => unreadCount.values.any((count) => count > 0);
  bool isParticipant(String userId) => participants.contains(userId);

  @override
  List<Object?> get props => [
    id, participants, participantDetails, lastMessage, lastMessageTime,
    lastMessageSenderId, unreadCount, isGroup, groupName, groupPhoto,
    isArchived, isPinned, createdAt, updatedAt, isMuted,
  ];
}
