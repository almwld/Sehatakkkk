// ============================================================
// 📊 NotificationModel - نموذج الإشعار
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  message,
  call,
  appointment,
  reminder,
  system,
  update,
  promotion,
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String? chatId;
  final String? callId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final Timestamp? createdAt;
  final String? imageUrl;
  final String? actionButtonText;
  final String? actionRoute;
  final bool isSilent;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.chatId,
    this.callId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    this.createdAt,
    this.imageUrl,
    this.actionButtonText,
    this.actionRoute,
    this.isSilent = false,
  });

  factory NotificationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      chatId: data['chatId'],
      callId: data['callId'],
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _parseNotificationType(data['type']),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'],
      imageUrl: data['imageUrl'],
      actionButtonText: data['actionButtonText'],
      actionRoute: data['actionRoute'],
      isSilent: data['isSilent'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'chatId': chatId,
      'callId': callId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'actionButtonText': actionButtonText,
      'actionRoute': actionRoute,
      'isSilent': isSilent,
    };
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'call': return NotificationType.call;
      case 'appointment': return NotificationType.appointment;
      case 'reminder': return NotificationType.reminder;
      case 'system': return NotificationType.system;
      case 'update': return NotificationType.update;
      case 'promotion': return NotificationType.promotion;
      default: return NotificationType.message;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? chatId,
    String? callId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    Timestamp? createdAt,
    String? imageUrl,
    String? actionButtonText,
    String? actionRoute,
    bool? isSilent,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chatId: chatId ?? this.chatId,
      callId: callId ?? this.callId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      actionButtonText: actionButtonText ?? this.actionButtonText,
      actionRoute: actionRoute ?? this.actionRoute,
      isSilent: isSilent ?? this.isSilent,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, chatId, callId, title, body, type, data, isRead,
    createdAt, imageUrl, actionButtonText, actionRoute, isSilent,
  ];

  // ✅ المساعدات
  bool get isMessage => type == NotificationType.message;
  bool get isCall => type == NotificationType.call;
  bool get isAppointment => type == NotificationType.appointment;
  bool get isReminder => type == NotificationType.reminder;
  bool get isSystemNotification => type == NotificationType.system;
  bool get hasAction => actionButtonText != null && actionRoute != null;
  bool get isUnread => !isRead;
  String getTimeAgo() {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!.toDate());
    if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    }
    if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    }
    if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    }
    return 'الآن';
  }
}
