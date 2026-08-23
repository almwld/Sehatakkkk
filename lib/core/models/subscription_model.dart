import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan {
  free,        // مجاني
  basic,       // أساسي
  standard,    // ستاندرد
  premium,     // بريميوم
  enterprise,  // مؤسسي
}

enum SubscriptionStatus {
  active,      // نشط
  expired,     // منتهي
  cancelled,   // ملغي
  pending,     // قيد الانتظار
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String? providerId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final int messagesLimit;
  final int bookingsLimit;
  final int adsLimit;
  final double commissionRate;
  final List<String> features;
  final bool isAutoRenew;
  final DateTime? cancelledAt;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    this.providerId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.messagesLimit,
    required this.bookingsLimit,
    required this.adsLimit,
    required this.commissionRate,
    required this.features,
    this.isAutoRenew = false,
    this.cancelledAt,
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);
  int get remainingDays => endDate.difference(DateTime.now()).inDays;
  double get usagePercentage {
    final total = endDate.difference(startDate).inDays;
    final used = DateTime.now().difference(startDate).inDays;
    return used / total;
  }

  String get planName {
    switch (plan) {
      case SubscriptionPlan.free: return 'مجاني';
      case SubscriptionPlan.basic: return 'أساسي';
      case SubscriptionPlan.standard: return 'ستاندرد';
      case SubscriptionPlan.premium: return 'بريميوم';
      case SubscriptionPlan.enterprise: return 'مؤسسي';
    }
  }

  String get statusText {
    switch (status) {
      case SubscriptionStatus.active: return 'نشط';
      case SubscriptionStatus.expired: return 'منتهي';
      case SubscriptionStatus.cancelled: return 'ملغي';
      case SubscriptionStatus.pending: return 'قيد الانتظار';
    }
  }

  Color get statusColor {
    switch (status) {
      case SubscriptionStatus.active: return Colors.green;
      case SubscriptionStatus.expired: return Colors.red;
      case SubscriptionStatus.cancelled: return Colors.orange;
      case SubscriptionStatus.pending: return Colors.amber;
    }
  }

  IconData get planIcon {
    switch (plan) {
      case SubscriptionPlan.free: return Icons.emoji_events;
      case SubscriptionPlan.basic: return Icons.star_border;
      case SubscriptionPlan.standard: return Icons.star;
      case SubscriptionPlan.premium: return Icons.star_half;
      case SubscriptionPlan.enterprise: return Icons.workspace_premium;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'providerId': providerId,
      'plan': plan.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'price': price,
      'messagesLimit': messagesLimit,
      'bookingsLimit': bookingsLimit,
      'adsLimit': adsLimit,
      'commissionRate': commissionRate,
      'features': features,
      'isAutoRenew': isAutoRenew,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SubscriptionModel(
      id: id,
      userId: data['userId'] ?? '',
      providerId: data['providerId'],
      plan: _parsePlan(data['plan'] ?? 'free'),
      status: _parseStatus(data['status'] ?? 'pending'),
      startDate: DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(data['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      price: data['price']?.toDouble() ?? 0,
      messagesLimit: data['messagesLimit'] ?? 0,
      bookingsLimit: data['bookingsLimit'] ?? 0,
      adsLimit: data['adsLimit'] ?? 0,
      commissionRate: data['commissionRate']?.toDouble() ?? 0.15,
      features: List<String>.from(data['features'] ?? []),
      isAutoRenew: data['isAutoRenew'] ?? false,
      cancelledAt: data['cancelledAt'] != null ? DateTime.parse(data['cancelledAt']) : null,
      paymentMethod: data['paymentMethod'],
      transactionId: data['transactionId'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  static SubscriptionPlan _parsePlan(String value) {
    switch (value) {
      case 'basic': return SubscriptionPlan.basic;
      case 'standard': return SubscriptionPlan.standard;
      case 'premium': return SubscriptionPlan.premium;
      case 'enterprise': return SubscriptionPlan.enterprise;
      default: return SubscriptionPlan.free;
    }
  }

  static SubscriptionStatus _parseStatus(String value) {
    switch (value) {
      case 'active': return SubscriptionStatus.active;
      case 'expired': return SubscriptionStatus.expired;
      case 'cancelled': return SubscriptionStatus.cancelled;
      default: return SubscriptionStatus.pending;
    }
  }
}

class SubscriptionPlans {
  static final List<Map<String, dynamic>> plans = [
    {
      'id': 'free',
      'name': 'مجاني',
      'price': 0,
      'messages': 5,
      'bookings': 3,
      'ads': 0,
      'commission': 0.20,
      'features': ['5 رسائل', '3 حجوزات', 'عمولة 20%'],
      'color': 0xFF9E9E9E,
      'icon': Icons.emoji_events,
    },
    {
      'id': 'basic',
      'name': 'أساسي',
      'price': 5000,
      'messages': 30,
      'bookings': 15,
      'ads': 1,
      'commission': 0.15,
      'features': ['30 رسالة', '15 حجز', '1 إعلان', 'عمولة 15%'],
      'color': 0xFF2196F3,
      'icon': Icons.star_border,
    },
    {
      'id': 'standard',
      'name': 'ستاندرد',
      'price': 15000,
      'messages': 100,
      'bookings': 50,
      'ads': 3,
      'commission': 0.12,
      'features': ['100 رسالة', '50 حجز', '3 إعلانات', 'عمولة 12%', 'أولوية الدعم'],
      'color': 0xFF9C27B0,
      'icon': Icons.star,
    },
    {
      'id': 'premium',
      'name': 'بريميوم',
      'price': 35000,
      'messages': 300,
      'bookings': 150,
      'ads': 10,
      'commission': 0.10,
      'features': ['300 رسالة', '150 حجز', '10 إعلانات', 'عمولة 10%', 'دعم 24/7', 'خصم 20% على الكشوفات'],
      'color': 0xFFFF6F00,
      'icon': Icons.star_half,
    },
    {
      'id': 'enterprise',
      'name': 'مؤسسي',
      'price': 100000,
      'messages': 1000,
      'bookings': 500,
      'ads': 30,
      'commission': 0.08,
      'features': ['1000 رسالة', '500 حجز', '30 إعلان', 'عمولة 8%', 'دعم مخصص', 'مدير حساب', 'تخصيص كامل'],
      'color': 0xFFD32F2F,
      'icon': Icons.workspace_premium,
    },
  ];

  static Map<String, dynamic>? getPlan(String id) {
    try {
      return plans.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
