// ============================================================
// 📁 lib/core/models/article/article_model.dart
// 📰 نموذج المقال
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ArticleModel extends Equatable {
  final String id;
  final String title;
  final String? titleEn;
  final String? subtitle;
  final String? content;
  final String? summary;
  final String? imageUrl;
  final List<String>? images;
  final String? category;
  final List<String>? tags;
  final String? authorId;
  final String? authorName;
  final int views;
  final int likes;
  final int shares;
  final int commentsCount;
  final bool? isFeatured;
  final bool? isPublished;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ArticleModel({
    required this.id,
    required this.title,
    this.titleEn,
    this.subtitle,
    this.content,
    this.summary,
    this.imageUrl,
    this.images,
    this.category,
    this.tags,
    this.authorId,
    this.authorName,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.commentsCount = 0,
    this.isFeatured = false,
    this.isPublished = false,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleEn: data['titleEn'],
      subtitle: data['subtitle'],
      content: data['content'],
      summary: data['summary'],
      imageUrl: data['imageUrl'],
      images: List<String>.from(data['images'] ?? []),
      category: data['category'],
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'],
      authorName: data['authorName'],
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      shares: data['shares'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      isPublished: data['isPublished'] ?? false,
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleEn': titleEn,
      'subtitle': subtitle,
      'content': content,
      'summary': summary,
      'imageUrl': imageUrl,
      'images': images,
      'category': category,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'views': views,
      'likes': likes,
      'shares': shares,
      'commentsCount': commentsCount,
      'isFeatured': isFeatured,
      'isPublished': isPublished,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String get timeAgo {
    final date = publishedAt ?? createdAt;
    if (date == null) return 'الآن';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
  }

  @override
  List<Object?> get props => [id, title];
}
