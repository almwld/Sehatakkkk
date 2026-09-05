// ============================================================
// 📁 lib/core/models/tip/tip_model.dart
// 💡 نموذج النصيحة
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TipModel extends Equatable {
  final String id;
  final String title;
  final String? titleEn;
  final String? subtitle;
  final String? content;
  final String? imageUrl;
  final String? category;
  final String? icon;
  final int views;
  final int likes;
  final int shares;
  final bool? isFeatured;
  final bool? isPublished;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TipModel({
    required this.id,
    required this.title,
    this.titleEn,
    this.subtitle,
    this.content,
    this.imageUrl,
    this.category,
    this.icon,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.isFeatured = false,
    this.isPublished = false,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TipModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleEn: data['titleEn'],
      subtitle: data['subtitle'],
      content: data['content'],
      imageUrl: data['imageUrl'],
      category: data['category'],
      icon: data['icon'],
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      shares: data['shares'] ?? 0,
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
      'imageUrl': imageUrl,
      'category': category,
      'icon': icon,
      'views': views,
      'likes': likes,
      'shares': shares,
      'isFeatured': isFeatured,
      'isPublished': isPublished,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, title];
}
