import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      lastMessage: data['lastMessage'] ?? 'ابدأ المحادثة',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ✅ الحصول على اسم الطرف الآخر
  String getOtherName(String userId) {
    if (userId == doctorId) return patientName;
    if (userId == patientId) return doctorName;
    return 'مستخدم';
  }

  // ✅ التحقق من أن المستخدم هو الطبيب
  bool isDoctor(String userId) {
    return userId == doctorId;
  }

  // ✅ الحصول على عدد الرسائل غير المقروءة (محاكاة)
  int getUnreadCount(String userId) {
    // يمكن تحسين هذا باستخدام حقل unreadCount في Firestore
    return 0;
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
  ];
}
