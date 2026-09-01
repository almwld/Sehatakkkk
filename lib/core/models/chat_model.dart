import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  // ✅ الحقول الأساسية
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
  
  // ✅ المشاركون والقراءة
  final List<String> participants;
  final Map<String, int> unreadCount;
  
  // ✅ حالة المستخدم
  final bool isOnline;
  final DateTime? lastSeen;
  
  // ✅ المجموعات
  final bool isGroup;
  final String? groupName;
  final String? groupImage;
  
  // ✅ إعدادات المحادثة
  final bool isPinned;
  final bool isMuted;
  final DateTime? mutedUntil;
  final List<String> labels;
  final bool isArchived;
  
  // ✅ سجل المكالمات
  final List<CallHistoryModel>? callHistory;
  final CallHistoryModel? lastCall;

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
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
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
          ? (data['callHistory'] as List)
              .map((c) => CallHistoryModel.fromMap(c))
              .toList()
          : null,
      lastCall: data['lastCall'] != null
          ? CallHistoryModel.fromMap(data['lastCall'])
          : null,
    );
  }

  factory ChatModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatModel(
      id: documentId,
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
          ? (data['callHistory'] as List)
              .map((c) => CallHistoryModel.fromMap(
                    Map<String, dynamic>.from(c),
                  ))
              .toList()
          : null,
      lastCall: data['lastCall'] != null
          ? CallHistoryModel.fromMap(
              Map<String, dynamic>.from(data['lastCall']),
            )
          : null,
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
      'callHistory': callHistory?.map((c) => c.toMap()).toList(),
      'lastCall': lastCall?.toMap(),
    };
  }

  // ✅ دوال مساعدة
  String getOtherName(String userId) {
    if (userId == doctorId) return patientName;
    if (userId == patientId) return doctorName;
    return 'مستخدم';
  }

  bool isDoctor(String userId) {
    return userId == doctorId;
  }

  bool isParticipant(String userId) {
    return participants.contains(userId) || userId == doctorId || userId == patientId;
  }

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  String getImage(String userId) {
    if (userId == doctorId) return doctorImage ?? '';
    if (userId == patientId) return patientImage ?? '';
    return '';
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

// ============================================================
// 📞 نموذج سجل المكالمات
// ============================================================

class CallHistoryModel extends Equatable {
  final String callerId;
  final String callerName;
  final int duration;
  final String type;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;

  const CallHistoryModel({
    required this.callerId,
    required this.callerName,
    required this.duration,
    required this.type,
    required this.status,
    required this.startedAt,
    this.endedAt,
  });

  factory CallHistoryModel.fromMap(Map<String, dynamic> map) {
    return CallHistoryModel(
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      duration: map['duration'] ?? 0,
      type: map['type'] ?? 'audio',
      status: map['status'] ?? 'missed',
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'duration': duration,
      'type': type,
      'status': status,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }

  @override
  List<Object?> get props => [callerId, callerName, duration, type, status, startedAt, endedAt];
}
