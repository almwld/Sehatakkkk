// ============================================================
// 📊 ChatModel - نموذج المحادثة
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

  // ✅ المصنع لإنشاء النموذج من Firestore
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

  // ✅ تحويل إلى Map لإرساله إلى Firestore
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

  // ✅ نسخة محدثة
  ChatModel copyWith({
    String? id,
    List<String>? participants,
    Map<String, dynamic>? participantDetails,
    String? lastMessage,
    Timestamp? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    bool? isGroup,
    String? groupName,
    String? groupPhoto,
    String? groupAdminId,
    List<String>? groupAdmins,
    bool? isArchived,
    bool? isPinned,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? chatBackground,
    bool? isMuted,
    Map<String, dynamic>? metadata,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantDetails: participantDetails ?? this.participantDetails,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupPhoto: groupPhoto ?? this.groupPhoto,
      groupAdminId: groupAdminId ?? this.groupAdminId,
      groupAdmins: groupAdmins ?? this.groupAdmins,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chatBackground: chatBackground ?? this.chatBackground,
      isMuted: isMuted ?? this.isMuted,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id, participants, participantDetails, lastMessage, lastMessageTime,
    lastMessageSenderId, unreadCount, isGroup, groupName, groupPhoto,
    groupAdminId, groupAdmins, isArchived, isPinned, createdAt, updatedAt,
    chatBackground, isMuted, metadata,
  ];

  // ✅ المساعدات
  bool get isIndividualChat => !isGroup;
  bool get hasUnreadMessages => unreadCount.values.any((count) => count > 0);
  int getTotalUnreadCount() {
    return unreadCount.values.fold(0, (sum, count) => sum + count);
  }
  bool isParticipant(String userId) => participants.contains(userId);
  String getOtherParticipant(String userId) {
    if (isGroup) return '';
    return participants.firstWhere((p) => p != userId, orElse: () => '');
  }
  String getDisplayName(String currentUserId) {
    if (isGroup) return groupName ?? 'مجموعة';
    final otherId = getOtherParticipant(currentUserId);
    return participantDetails[otherId]?['name'] ?? 'مستخدم';
  }
  String getDisplayPhoto(String currentUserId) {
    if (isGroup) return groupPhoto ?? '';
    final otherId = getOtherParticipant(currentUserId);
    return participantDetails[otherId]?['photoUrl'] ?? '';
  }
}
