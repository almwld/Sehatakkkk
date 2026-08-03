import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan {
  free,
  basic,
  premium,
  family,
  enterprise,
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
  trial,
}

enum PaymentProvider {
  jeeb,
  stripe,
  paypal,
  wallet,
}

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String? currency;
  final PaymentProvider paymentProvider;
  final String? transactionId;
  final bool autoRenew;
  final List<String> features;
  final int? trialDays;
  final DateTime? trialEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.price,
    this.currency = 'YER',
    required this.paymentProvider,
    this.transactionId,
    this.autoRenew = false,
    this.features = const [],
    this.trialDays,
    this.trialEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == SubscriptionStatus.active || status == SubscriptionStatus.trial;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isTrial => status == SubscriptionStatus.trial;
  bool get needsRenewal => isActive && endDate.isBefore(DateTime.now().add(const Duration(days: 7)));
  int get remainingDays => endDate.difference(DateTime.now()).inDays;

  String get planName {
    switch (plan) {
      case SubscriptionPlan.free: return 'مجاني';
      case SubscriptionPlan.basic: return 'أساسي';
      case SubscriptionPlan.premium: return 'مميز';
      case SubscriptionPlan.family: return 'عائلي';
      case SubscriptionPlan.enterprise: return 'مؤسسي';
    }
  }

  String get planIcon {
    switch (plan) {
      case SubscriptionPlan.free: return '🎁';
      case SubscriptionPlan.basic: return '🥈';
      case SubscriptionPlan.premium: return '🥇';
      case SubscriptionPlan.family: return '👨‍👩‍👧‍👦';
      case SubscriptionPlan.enterprise: return '🏢';
    }
  }

  Color get planColor {
    switch (plan) {
      case SubscriptionPlan.free: return Colors.grey;
      case SubscriptionPlan.basic: return Colors.blue;
      case SubscriptionPlan.premium: return Colors.amber;
      case SubscriptionPlan.family: return Colors.green;
      case SubscriptionPlan.enterprise: return Colors.deepPurple;
    }
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'plan': plan.toString().split('.').last,
    'status': status.toString().split('.').last,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'price': price,
    'currency': currency,
    'paymentProvider': paymentProvider.toString().split('.').last,
    'transactionId': transactionId,
    'autoRenew': autoRenew,
    'features': features,
    'trialDays': trialDays,
    'trialEndDate': trialEndDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SubscriptionModel.fromFirestore(Map<String, dynamic> data, String id) => SubscriptionModel(
    id: id,
    userId: data['userId'] ?? '',
    plan: _parsePlan(data['plan'] ?? 'free'),
    status: _parseStatus(data['status'] ?? 'pending'),
    startDate: DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
    endDate: DateTime.parse(data['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
    price: data['price']?.toDouble() ?? 0,
    currency: data['currency'] ?? 'YER',
    paymentProvider: _parseProvider(data['paymentProvider'] ?? 'wallet'),
    transactionId: data['transactionId'],
    autoRenew: data['autoRenew'] ?? false,
    features: data['features'] != null ? List<String>.from(data['features']) : [],
    trialDays: data['trialDays'],
    trialEndDate: data['trialEndDate'] != null ? DateTime.parse(data['trialEndDate']) : null,
    createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
  );

  static SubscriptionPlan _parsePlan(String value) {
    switch (value) {
      case 'basic': return SubscriptionPlan.basic;
      case 'premium': return SubscriptionPlan.premium;
      case 'family': return SubscriptionPlan.family;
      case 'enterprise': return SubscriptionPlan.enterprise;
      default: return SubscriptionPlan.free;
    }
  }

  static SubscriptionStatus _parseStatus(String value) {
    switch (value) {
      case 'active': return SubscriptionStatus.active;
      case 'expired': return SubscriptionStatus.expired;
      case 'cancelled': return SubscriptionStatus.cancelled;
      case 'pending': return SubscriptionStatus.pending;
      case 'trial': return SubscriptionStatus.trial;
      default: return SubscriptionStatus.pending;
    }
  }

  static PaymentProvider _parseProvider(String value) {
    switch (value) {
      case 'stripe': return PaymentProvider.stripe;
      case 'paypal': return PaymentProvider.paypal;
      case 'jeeb': return PaymentProvider.jeeb;
      default: return PaymentProvider.wallet;
    }
  }
}

class SubscriptionPlanDetails {
  final SubscriptionPlan plan;
  final String name;
  final String icon;
  final Color color;
  final double priceMonthly;
  final double priceYearly;
  final double? discount;
  final List<String> features;
  final bool isPopular;
  final int? trialDays;
  final String? description;

  SubscriptionPlanDetails({
    required this.plan,
    required this.name,
    required this.icon,
    required this.color,
    required this.priceMonthly,
    required this.priceYearly,
    this.discount,
    required this.features,
    this.isPopular = false,
    this.trialDays,
    this.description,
  });

  static List<SubscriptionPlanDetails> get allPlans => [
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.free,
      name: 'مجاني',
      icon: '🎁',
      color: Colors.grey,
      priceMonthly: 0,
      priceYearly: 0,
      features: [
        '✅ 5 استشارات شهرياً',
        '✅ ملف صحي أساسي',
        '✅ تذكير الأدوية',
        '✅ دعم أساسي',
      ],
      description: 'للبدء مع منصة صحتك',
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.basic,
      name: 'أساسي',
      icon: '🥈',
      color: Colors.blue,
      priceMonthly: 99,
      priceYearly: 990,
      discount: 16,
      features: [
        '✅ 20 استشارة شهرياً',
        '✅ ملف صحي متقدم',
        '✅ تذكير الأدوية',
        '✅ متابعة الوزن والضغط',
        '✅ دعم優先',
        '✅ خصم 10% على الفحوصات',
      ],
      description: 'للمستخدمين النشطين',
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.premium,
      name: 'مميز',
      icon: '🥇',
      color: Colors.amber,
      priceMonthly: 199,
      priceYearly: 1990,
      discount: 16,
      isPopular: true,
      features: [
        '✅ غير محدود من الاستشارات',
        '✅ ملف صحي شامل',
        '✅ تذكير الأدوية المتقدم',
        '✅ متابعة جميع المؤشرات الحيوية',
        '✅ دعم مميز 24/7',
        '✅ خصم 20% على الفحوصات',
        '✅ استشارات فيديو مجانية',
        '✅ تقارير صحية شهرية',
      ],
      trialDays: 7,
      description: 'التجربة الكاملة لمنصة صحتك',
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.family,
      name: 'عائلي',
      icon: '👨‍👩‍👧‍👦',
      color: Colors.green,
      priceMonthly: 299,
      priceYearly: 2990,
      discount: 16,
      features: [
        '✅ 5 حسابات عائلية',
        '✅ غير محدود من الاستشارات',
        '✅ ملفات صحية لكل فرد',
        '✅ تذكير الأدوية للعائلة',
        '✅ متابعة جميع المؤشرات',
        '✅ دعم مميز 24/7',
        '✅ خصم 25% على الفحوصات',
        '✅ تقارير صحية للعائلة',
        '✅ جدول مواعيد عائلي',
      ],
      description: 'للعائلة بأكملها',
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.enterprise,
      name: 'مؤسسي',
      icon: '🏢',
      color: Colors.deepPurple,
      priceMonthly: 499,
      priceYearly: 4990,
      discount: 16,
      features: [
        '✅ 20+ حساب موظف',
        '✅ غير محدود من الاستشارات',
        '✅ نظام إدارة الصحة المؤسسي',
        '✅ تقارير إدارية متقدمة',
        '✅ دعم مخصص 24/7',
        '✅ خصم 30% على الفحوصات',
        '✅ تكامل مع نظام الشركة',
        '✅ مدير صحة مخصص',
        '✅ تحليلات وتقارير متقدمة',
      ],
      trialDays: 14,
      description: 'للشركات والمؤسسات',
    ),
  ];

  static SubscriptionPlanDetails getPlanDetails(SubscriptionPlan plan) {
    return allPlans.firstWhere((p) => p.plan == plan, orElse: () => allPlans[0]);
  }

  static List<SubscriptionPlanDetails> get visiblePlans {
    return allPlans.where((p) => p.plan != SubscriptionPlan.free).toList();
  }
}
