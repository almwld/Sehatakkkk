// ============================================================
// 📦 نموذج الإشعار (Notification)
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'message', 'call', 'story', 'appointment', 'prescription'
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final bool isSilent;

  // ============================================================
  // 🏗️ المنشئ
  // ============================================================

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.payload = const {},
    this.isRead = false,
    required this.createdAt,
    this.imageUrl,
    this.isSilent = false,
  });

  // ============================================================
  // 🔄 التحويل من/إلى Map
  // ============================================================

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'message',
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      isSilent: map['isSilent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'isSilent': isSilent,
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================

  bool get isMessage => type == 'message';
  bool get isCall => type == 'call';
  bool get isStory => type == 'story';
  bool get isAppointment => type == 'appointment';
  bool get isPrescription => type == 'prescription';

  String get icon {
    switch (type) {
      case 'message':
        return '💬';
      case 'call':
        return '📞';
      case 'story':
        return '📸';
      case 'appointment':
        return '📅';
      case 'prescription':
        return '💊';
      default:
        return '🔔';
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return 'منذ ${diff.inDays ~/ 7} أسبوع';
  }
}
