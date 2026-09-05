import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NotificationType { message, call, appointment, reminder, system, update, promotion }

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

  bool get isUnread => !isRead;
  bool get isMessage => type == NotificationType.message;
  bool get isCall => type == NotificationType.call;
  bool get isAppointment => type == NotificationType.appointment;

  @override
  List<Object?> get props => [
    id, userId, chatId, callId, title, body, type, data, isRead,
    createdAt, imageUrl, actionButtonText, actionRoute, isSilent,
  ];
}
