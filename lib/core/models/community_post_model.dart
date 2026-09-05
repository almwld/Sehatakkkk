// ============================================================
// 📁 lib/core/models/community_post_model.dart
// 👥 نموذج منشور المجتمع
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityPostModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String title;
  final String? content;
  final String? imageUrl;
  final List<String>? images;
  final String? category;
  final List<String>? tags;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final bool isLiked;
  final bool isSaved;
  final bool isReported;
  final bool? isDoctorPost;
  final bool? isVerified;
  final bool? isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CommunityPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.title,
    this.content,
    this.imageUrl,
    this.images,
    this.category,
    this.tags,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.isReported = false,
    this.isDoctorPost = false,
    this.isVerified = false,
    this.isPublished = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CommunityPostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'مستخدم',
      userAvatar: data['userAvatar'],
      title: data['title'] ?? '',
      content: data['content'],
      imageUrl: data['imageUrl'],
      images: List<String>.from(data['images'] ?? []),
      category: data['category'],
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      shares: data['shares'] ?? 0,
      views: data['views'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      isSaved: data['isSaved'] ?? false,
      isReported: data['isReported'] ?? false,
      isDoctorPost: data['isDoctorPost'] ?? false,
      isVerified: data['isVerified'] ?? false,
      isPublished: data['isPublished'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'images': images,
      'category': category,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'isLiked': isLiked,
      'isSaved': isSaved,
      'isReported': isReported,
      'isDoctorPost': isDoctorPost,
      'isVerified': isVerified,
      'isPublished': isPublished,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CommunityPostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? images,
    String? category,
    List<String>? tags,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    bool? isLiked,
    bool? isSaved,
    bool? isReported,
    bool? isDoctorPost,
    bool? isVerified,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isReported: isReported ?? this.isReported,
      isDoctorPost: isDoctorPost ?? this.isDoctorPost,
      isVerified: isVerified ?? this.isVerified,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get timeAgo {
    if (createdAt == null) return 'الآن';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
  }

  @override
  List<Object?> get props => [id, userId, title];
}
