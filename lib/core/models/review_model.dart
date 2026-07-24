import 'package:cloud_firestore/cloud_firestore.dart';

enum ReviewTarget {
  doctor,      // طبيب
  pharmacy,    // صيدلية
  lab,         // مختبر
  hospital,    // مستشفى
  delivery,    // شركة توصيل
  service,     // خدمة
  product,     // منتج
  order,       // طلب
}

enum ReviewRating {
  one(1),
  two(2),
  three(3),
  four(4),
  five(5);

  final int value;
  const ReviewRating(this.value);

  static ReviewRating fromInt(int value) {
    return ReviewRating.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReviewRating.five,
    );
  }
}

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final ReviewTarget target;
  final String targetId;
  final String targetName;
  final double rating;
  final String? comment;
  final List<String>? images;
  final List<String>? tags;
  final bool isVerified;
  final bool isAnonymous;
  final int likes;
  final int dislikes;
  final List<String>? likedBy;
  final List<String>? dislikedBy;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? bookingId;
  final String? orderId;
  final String? providerResponse;
  final DateTime? providerResponseAt;
  final List<Map<String, dynamic>>? replies;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.target,
    required this.targetId,
    required this.targetName,
    required this.rating,
    this.comment,
    this.images,
    this.tags,
    this.isVerified = false,
    this.isAnonymous = false,
    this.likes = 0,
    this.dislikes = 0,
    this.likedBy,
    this.dislikedBy,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.bookingId,
    this.orderId,
    this.providerResponse,
    this.providerResponseAt,
    this.replies,
  });

  String get targetText {
    switch (target) {
      case ReviewTarget.doctor: return 'طبيب';
      case ReviewTarget.pharmacy: return 'صيدلية';
      case ReviewTarget.lab: return 'مختبر';
      case ReviewTarget.hospital: return 'مستشفى';
      case ReviewTarget.delivery: return 'توصيل';
      case ReviewTarget.service: return 'خدمة';
      case ReviewTarget.product: return 'منتج';
      case ReviewTarget.order: return 'طلب';
    }
  }

  IconData get targetIcon {
    switch (target) {
      case ReviewTarget.doctor: return Icons.local_hospital;
      case ReviewTarget.pharmacy: return Icons.local_pharmacy;
      case ReviewTarget.lab: return Icons.science;
      case ReviewTarget.hospital: return Icons.medical_services;
      case ReviewTarget.delivery: return Icons.delivery_dining;
      case ReviewTarget.service: return Icons.stars;
      case ReviewTarget.product: return Icons.inventory;
      case ReviewTarget.order: return Icons.shopping_bag;
    }
  }

  Color get targetColor {
    switch (target) {
      case ReviewTarget.doctor: return Colors.blue;
      case ReviewTarget.pharmacy: return Colors.green;
      case ReviewTarget.lab: return Colors.purple;
      case ReviewTarget.hospital: return Colors.red;
      case ReviewTarget.delivery: return Colors.orange;
      case ReviewTarget.service: return Colors.teal;
      case ReviewTarget.product: return Colors.pink;
      case ReviewTarget.order: return Colors.amber;
    }
  }

  double get averageRating => rating;

  String get ratingText {
    switch (rating.toInt()) {
      case 1: return 'سيء';
      case 2: return 'ضعيف';
      case 3: return 'جيد';
      case 4: return 'جيد جداً';
      case 5: return 'ممتاز';
      default: return '';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'target': target.toString().split('.').last,
      'targetId': targetId,
      'targetName': targetName,
      'rating': rating,
      'comment': comment,
      'images': images,
      'tags': tags,
      'isVerified': isVerified,
      'isAnonymous': isAnonymous,
      'likes': likes,
      'dislikes': dislikes,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'bookingId': bookingId,
      'orderId': orderId,
      'providerResponse': providerResponse,
      'providerResponseAt': providerResponseAt?.toIso8601String(),
      'replies': replies,
    };
  }

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      target: _parseTarget(data['target'] ?? 'service'),
      targetId: data['targetId'] ?? '',
      targetName: data['targetName'] ?? '',
      rating: data['rating']?.toDouble() ?? 0,
      comment: data['comment'],
      images: List<String>.from(data['images'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      isVerified: data['isVerified'] ?? false,
      isAnonymous: data['isAnonymous'] ?? false,
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      dislikedBy: List<String>.from(data['dislikedBy'] ?? []),
      metadata: data['metadata'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      bookingId: data['bookingId'],
      orderId: data['orderId'],
      providerResponse: data['providerResponse'],
      providerResponseAt: data['providerResponseAt'] != null ? DateTime.parse(data['providerResponseAt']) : null,
      replies: List<Map<String, dynamic>>.from(data['replies'] ?? []),
    );
  }

  static ReviewTarget _parseTarget(String value) {
    switch (value) {
      case 'doctor': return ReviewTarget.doctor;
      case 'pharmacy': return ReviewTarget.pharmacy;
      case 'lab': return ReviewTarget.lab;
      case 'hospital': return ReviewTarget.hospital;
      case 'delivery': return ReviewTarget.delivery;
      case 'product': return ReviewTarget.product;
      case 'order': return ReviewTarget.order;
      default: return ReviewTarget.service;
    }
  }

  ReviewModel copyWith({
    String? comment,
    double? rating,
    int? likes,
    int? dislikes,
    List<String>? likedBy,
    List<String>? dislikedBy,
    bool? isVerified,
    bool? isAnonymous,
    DateTime? updatedAt,
    String? providerResponse,
    DateTime? providerResponseAt,
    List<Map<String, dynamic>>? replies,
  }) {
    return ReviewModel(
      id: id,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      target: target,
      targetId: targetId,
      targetName: targetName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images,
      tags: tags,
      isVerified: isVerified ?? this.isVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      likedBy: likedBy ?? this.likedBy,
      dislikedBy: dislikedBy ?? this.dislikedBy,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookingId: bookingId,
      orderId: orderId,
      providerResponse: providerResponse ?? this.providerResponse,
      providerResponseAt: providerResponseAt ?? this.providerResponseAt,
      replies: replies ?? this.replies,
    );
  }
}
