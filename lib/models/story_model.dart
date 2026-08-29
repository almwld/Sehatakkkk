// ============================================================
// 📦 نموذج الحالة (Story) المتكامل
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================

  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String? imageUrl;
  final String? videoUrl;
  final String text;
  final String? backgroundColor;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewers;
  final List<Map<String, dynamic>> replies;
  final bool isVideo;
  final bool isImage;
  final bool isText;
  final String? location;
  final double? latitude;
  final double? longitude;

  // ============================================================
  // 🏗️ المنشئ
  // ============================================================

  StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    this.imageUrl,
    this.videoUrl,
    this.text = '',
    this.backgroundColor,
    required this.createdAt,
    required this.expiresAt,
    this.viewers = const [],
    this.replies = const [],
    this.isVideo = false,
    this.isImage = false,
    this.isText = true,
    this.location,
    this.latitude,
    this.longitude,
  });

  // ============================================================
  // 🔄 التحويل من/إلى Map
  // ============================================================

  factory StoryModel.fromMap(Map<String, dynamic> map, String id) {
    return StoryModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'مستخدم',
      userImage: map['userImage'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      text: map['text'] ?? '',
      backgroundColor: map['backgroundColor'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(hours: 24)),
      viewers: List<String>.from(map['viewers'] ?? []),
      replies: List<Map<String, dynamic>>.from(map['replies'] ?? []),
      isVideo: map['isVideo'] ?? false,
      isImage: map['isImage'] ?? false,
      isText: map['isText'] ?? true,
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'text': text,
      'backgroundColor': backgroundColor,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt,
      'viewers': viewers,
      'replies': replies,
      'isVideo': isVideo,
      'isImage': isImage,
      'isText': isText,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isViewed {
    // TODO: تنفيذ التحقق من المشاهدة
    return false;
  }

  int get viewCount => viewers.length;
  int get replyCount => replies.length;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;

  String get mediaType {
    if (hasVideo) return 'video';
    if (hasImage) return 'image';
    return 'text';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} ي';
  }

  StoryModel copyWith({
    List<String>? viewers,
    List<Map<String, dynamic>>? replies,
  }) {
    return StoryModel(
      id: id,
      userId: userId,
      userName: userName,
      userImage: userImage,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      text: text,
      backgroundColor: backgroundColor,
      createdAt: createdAt,
      expiresAt: expiresAt,
      viewers: viewers ?? this.viewers,
      replies: replies ?? this.replies,
      isVideo: isVideo,
      isImage: isImage,
      isText: isText,
      location: location,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
