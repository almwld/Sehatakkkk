import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String id;
  final String doctorId;
  final String doctorName;
  final String? doctorImage;
  final String patientId;
  final String patientName;
  final String? patientImage;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> participants;
  final Map<String, int> unreadCount;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isGroup;
  final String? groupName;
  final String? groupImage;
  final bool isPinned;
  final bool isMuted;
  final DateTime? mutedUntil;
  final List<String> labels;
  final bool isArchived;
  final List<Map<String, dynamic>>? callHistory;
  final Map<String, dynamic>? lastCall;

  const ChatModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorImage,
    required this.patientId,
    required this.patientName,
    this.patientImage,
    required this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
    this.participants = const [],
    this.unreadCount = const {},
    this.isOnline = false,
    this.lastSeen,
    this.isGroup = false,
    this.groupName,
    this.groupImage,
    this.isPinned = false,
    this.isMuted = false,
    this.mutedUntil,
    this.labels = const [],
    this.isArchived = false,
    this.callHistory,
    this.lastCall,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorImage: data['doctorImage'],
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientImage: data['patientImage'],
      lastMessage: data['lastMessage'] ?? 'ابدأ المحادثة',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: List<String>.from(data['participants'] ?? []),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'],
      groupImage: data['groupImage'],
      isPinned: data['pinned'] ?? false,
      isMuted: data['muted'] ?? false,
      mutedUntil: (data['mutedUntil'] as Timestamp?)?.toDate(),
      labels: List<String>.from(data['labels'] ?? []),
      isArchived: data['isArchived'] ?? false,
      callHistory: data['callHistory'] != null
          ? List<Map<String, dynamic>>.from(data['callHistory'])
          : null,
      lastCall: data['lastCall'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'patientId': patientId,
      'patientName': patientName,
      'patientImage': patientImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'participants': participants,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupImage': groupImage,
      'pinned': isPinned,
      'muted': isMuted,
      'mutedUntil': mutedUntil != null ? Timestamp.fromDate(mutedUntil!) : null,
      'labels': labels,
      'isArchived': isArchived,
      'callHistory': callHistory,
      'lastCall': lastCall,
    };
  }

  @override
  List<Object?> get props => [
    id,
    doctorId,
    doctorName,
    patientId,
    patientName,
    lastMessage,
    lastMessageTime,
    createdAt,
    updatedAt,
    participants,
    unreadCount,
    isOnline,
    lastSeen,
    isGroup,
    isPinned,
    isMuted,
    labels,
    isArchived,
  ];
}
