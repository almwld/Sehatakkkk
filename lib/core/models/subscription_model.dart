import 'package:flutter/material.dart';

enum SubscriptionPlan {
  free,
  basic,
  standard,
  premium,
  enterprise,
}

class SubscriptionModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final SubscriptionPlan plan;
  final List<String> features;
  final bool isPopular;
  final String? badgeText;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.plan,
    required this.features,
    this.isPopular = false,
    this.badgeText,
  });

  // ✅ أيقونة الخطة (باستخدام SVG)
  String get iconPath {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'assets/icons/plans/free.svg';
      case SubscriptionPlan.basic:
        return 'assets/icons/plans/silver.svg';
      case SubscriptionPlan.standard:
        return 'assets/icons/plans/gold.svg';
      case SubscriptionPlan.premium:
        return 'assets/icons/plans/platinum.svg';
      case SubscriptionPlan.enterprise:
        return 'assets/icons/plans/platinum.svg';
    }
  }

  // ✅ اللون
  Color get color {
    switch (plan) {
      case SubscriptionPlan.free:
        return Colors.grey;
      case SubscriptionPlan.basic:
        return Colors.grey.shade400;
      case SubscriptionPlan.standard:
        return AppColors.primary;
      case SubscriptionPlan.premium:
        return Colors.amber;
      case SubscriptionPlan.enterprise:
        return Colors.purple;
    }
  }

  // ✅ الخطط المعرفة مسبقاً
  static List<SubscriptionModel> get plans => [
    SubscriptionModel(
      id: 'free',
      name: 'مجاني',
      description: 'للبدء والتجربة',
      price: 0,
      plan: SubscriptionPlan.free,
      features: [
        'استشارة عامة واحدة',
        'دردشة نصية محدودة',
        'تذكير مواعيد',
        'متابعة صحية أساسية',
      ],
    ),
    SubscriptionModel(
      id: 'basic',
      name: 'أساسي',
      description: 'للأفراد',
      price: 29.99,
      discountPrice: 19.99,
      plan: SubscriptionPlan.basic,
      features: [
        '5 استشارات عامة',
        'مكالمات صوتية',
        'دردشة غير محدودة',
        'تذكير بالأدوية',
        'متابعة صحية متقدمة',
      ],
    ),
    SubscriptionModel(
      id: 'standard',
      name: 'ذهبي',
      description: 'للعائلات',
      price: 49.99,
      discountPrice: 39.99,
      plan: SubscriptionPlan.standard,
      isPopular: true,
      badgeText: 'الأكثر شهرة',
      features: [
        '10 استشارات عامة',
        'مكالمات فيديو',
        'استشارات تخصصية',
        'دردشة غير محدودة',
        'تذكير بالأدوية',
        'متابعة صحية متقدمة',
        'أولوية الحجوزات',
      ],
    ),
    SubscriptionModel(
      id: 'premium',
      name: 'مميز',
      description: 'للأطباء والمختصين',
      price: 79.99,
      discountPrice: 59.99,
      plan: SubscriptionPlan.premium,
      features: [
        'استشارات غير محدودة',
        'مكالمات فيديو عالية الجودة',
        'جميع التخصصات',
        'دردشة غير محدودة',
        'تذكير بالأدوية',
        'متابعة صحية شاملة',
        'أولوية الحجوزات',
        'دعم فني 24/7',
        'تقارير صحية مفصلة',
      ],
    ),
    SubscriptionModel(
      id: 'enterprise',
      name: 'مؤسسي',
      description: 'للمؤسسات الطبية',
      price: 149.99,
      discountPrice: 119.99,
      plan: SubscriptionPlan.enterprise,
      features: [
        'جميع ميزات الباقة المميزة',
        'لوحة تحكم متقدمة',
        'إدارة فريق كامل',
        'تقارير وإحصائيات',
        'تكامل مع الأنظمة',
        'دعم مخصص 24/7',
      ],
    ),
  ];

  // ✅ الحصول على خطة حسب الـ ID
  static SubscriptionModel? getPlan(String id) {
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
