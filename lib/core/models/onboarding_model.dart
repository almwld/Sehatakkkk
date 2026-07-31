import 'package:flutter/material.dart';
import 'package:sehatak/core/models/user_model.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? tips;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.tips,
  });
}

class OnboardingContent {
  static List<OnboardingPageModel> getPages(UserRole role) {
    switch (role) {
      case UserRole.user:
        return _userPages;
      case UserRole.doctor:
        return _doctorPages;
      case UserRole.pharmacist:
        return _pharmacistPages;
      case UserRole.lab:
        return _labPages;
      default:
        return _userPages;
    }
  }

  static String getAccountTypeName(UserRole role) {
    switch (role) {
      case UserRole.user: return 'مستخدم';
      case UserRole.doctor: return 'طبيب';
      case UserRole.pharmacist: return 'صيدلي';
      case UserRole.lab: return 'مختبر';
      default: return 'مستخدم';
    }
  }

  static Color getAccountTypeColor(UserRole role) {
    switch (role) {
      case UserRole.user: return Colors.blue;
      case UserRole.doctor: return Colors.teal;
      case UserRole.pharmacist: return Colors.green;
      case UserRole.lab: return Colors.purple;
      default: return Colors.grey;
    }
  }

  static final List<OnboardingPageModel> _userPages = [
    OnboardingPageModel(
      title: '👤 حسابك الصحي',
      description: 'سجل بياناتك الصحية وتابع حالتك بشكل دائم',
      icon: Icons.person,
      color: Colors.blue,
      tips: ['سجل تاريخك الطبي', 'تابع أدويتك', 'احصل على تذكيرات'],
    ),
    OnboardingPageModel(
      title: '📅 حجز المواعيد',
      description: 'احجز موعدك مع أفضل الأطباء في دقائق',
      icon: Icons.calendar_today,
      color: Colors.purple,
      tips: ['اختر الطبيب المناسب', 'اختر الوقت المناسب', 'تأكيد فوري'],
    ),
    OnboardingPageModel(
      title: '💊 طلب الأدوية',
      description: 'اطلب أدويتك من أقرب صيدلية',
      icon: Icons.local_pharmacy,
      color: Colors.green,
      tips: ['توصيل للمنزل', 'أسعار تنافسية', 'جودة مضمونة'],
    ),
  ];

  static final List<OnboardingPageModel> _doctorPages = [
    OnboardingPageModel(
      title: '👨‍⚕️ مرحباً دكتور',
      description: 'أهلاً بك في منصة صحتك الطبية',
      icon: Icons.local_hospital,
      color: Colors.teal,
      tips: ['إدارة مرضاك', 'جدولة مواعيدك', 'تواصل مع المرضى'],
    ),
    OnboardingPageModel(
      title: '📋 إدارة المواعيد',
      description: 'استقبل المرضى وقم بإدارة جدول مواعيدك اليومي',
      icon: Icons.calendar_month,
      color: Colors.teal,
      tips: ['جدول مرن', 'إشعارات فورية', 'تذكير المرضى'],
    ),
    OnboardingPageModel(
      title: '💬 تواصل مع مرضاك',
      description: 'استقبل استشارات المرضى عبر المحادثة الفورية',
      icon: Icons.chat,
      color: Colors.green,
      tips: ['دردشة فورية', 'مكالمات فيديو', 'مشاركة الملفات'],
    ),
  ];

  static final List<OnboardingPageModel> _pharmacistPages = [
    OnboardingPageModel(
      title: '💊 مرحباً صيدلي',
      description: 'أهلاً بك في منصة صحتك للصيدليات',
      icon: Icons.local_pharmacy,
      color: Colors.green,
      tips: ['عرض منتجاتك', 'إدارة المخزون', 'استقبال الطلبات'],
    ),
    OnboardingPageModel(
      title: '📦 إدارة المنتجات',
      description: 'أضف منتجاتك الصيدلانية وعرضها للعملاء',
      icon: Icons.inventory,
      color: Colors.teal,
      tips: ['صور المنتجات', 'أسعار تنافسية', 'توفر المخزون'],
    ),
  ];

  static final List<OnboardingPageModel> _labPages = [
    OnboardingPageModel(
      title: '🔬 مرحباً مختبر',
      description: 'أهلاً بك في منصة صحتك للمختبرات',
      icon: Icons.science,
      color: Colors.purple,
      tips: ['عرض خدماتك', 'استقبال الفحوصات', 'نتائج دقيقة'],
    ),
    OnboardingPageModel(
      title: '📊 إدارة الفحوصات',
      description: 'أضف خدماتك المخبرية وعرضها للعملاء',
      icon: Icons.list_alt,
      color: Colors.teal,
      tips: ['قائمة الفحوصات', 'أسعار شفافة', 'وقت النتائج'],
    ),
  ];
}
