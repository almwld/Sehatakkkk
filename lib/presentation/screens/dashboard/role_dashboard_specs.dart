import 'package:flutter/material.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/constants/roles.dart';

/// إعداد مستقل لكل دور مهني: الاسم، المؤشرات، الخدمات، والأدوات التشغيلية.
class RoleDashboardSpec {
  const RoleDashboardSpec({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.primaryCollection,
    required this.primaryMetric,
    required this.secondaryMetric,
    required this.financialMetric,
    required this.actions,
  });

  final String role;
  final String title;
  final String subtitle;
  final String primaryCollection;
  final String primaryMetric;
  final String secondaryMetric;
  final String financialMetric;
  final List<DashboardActionSpec> actions;
}

class DashboardActionSpec {
  const DashboardActionSpec(this.title, this.subtitle, this.route, this.icon);
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}

class RoleDashboardSpecs {
  static RoleDashboardSpec forRole(String role) {
    return _specs[role] ?? _specs['nurse']!;
  }

  static final Map<String, RoleDashboardSpec> _specs = {
    'nurse': const RoleDashboardSpec(
      role: 'nurse', title: 'التمريض', subtitle: 'متابعة الرعاية والمرضى والمهام اليومية',
      primaryCollection: 'appointments', primaryMetric: 'المواعيد', secondaryMetric: 'الحجوزات', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('رعاية المرضى', 'متابعة المواعيد والحالات والمهام التمريضية', AppRouter.appointments, Icons.health_and_safety),
        DashboardActionSpec('خدمات التمريض', 'إدارة الخدمات التي تقدمها للمرضى', AppRouter.services, Icons.medical_services),
        DashboardActionSpec('التواصل الصحي', 'التواصل المباشر مع المرضى', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
    'midwife': const RoleDashboardSpec(
      role: 'midwife', title: 'القبالة', subtitle: 'متابعة حالات الأمومة والرعاية والمتابعة الدورية',
      primaryCollection: 'appointments', primaryMetric: 'المتابعات', secondaryMetric: 'الحجوزات', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('متابعة الحالات', 'المواعيد والحجوزات والمتابعات', AppRouter.appointments, Icons.pregnant_woman),
        DashboardActionSpec('خدمات القبالة', 'إدارة خدمات الأمومة والرعاية', AppRouter.services, Icons.health_and_safety),
        DashboardActionSpec('التواصل الصحي', 'التواصل مع الحالات', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
    'physiotherapist': const RoleDashboardSpec(
      role: 'physiotherapist', title: 'العلاج الطبيعي', subtitle: 'إدارة الجلسات وخطط المتابعة وإعادة التأهيل',
      primaryCollection: 'appointments', primaryMetric: 'الجلسات', secondaryMetric: 'الحجوزات', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('الجلسات والمواعيد', 'متابعة الجلسات والحجوزات', AppRouter.appointments, Icons.accessibility_new),
        DashboardActionSpec('خدمات العلاج الطبيعي', 'إدارة خدمات التأهيل والعلاج', AppRouter.services, Icons.fitness_center),
        DashboardActionSpec('التواصل الصحي', 'التواصل مع الحالات', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
    'lab': const RoleDashboardSpec(
      role: 'lab', title: 'المختبر', subtitle: 'إدارة طلبات الفحوصات والخدمات المخبرية',
      primaryCollection: 'bookings', primaryMetric: 'طلبات الفحوصات', secondaryMetric: 'الحجوزات', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('طلبات الفحوصات', 'متابعة الطلبات والحجوزات المخبرية', AppRouter.appointments, Icons.science),
        DashboardActionSpec('الخدمات المخبرية', 'إدارة الخدمات المتاحة للمستخدمين', AppRouter.services, Icons.medical_services),
        DashboardActionSpec('التواصل الصحي', 'التواصل مع المرضى ومقدمي الرعاية', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
    'paramedic': const RoleDashboardSpec(
      role: 'paramedic', title: 'الإسعاف الميداني', subtitle: 'إدارة الاستجابات والطلبات الطارئة والمهام الميدانية',
      primaryCollection: 'bookings', primaryMetric: 'الطلبات الطارئة', secondaryMetric: 'المهام', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('الطلبات الطارئة', 'الوصول إلى خدمات الإسعاف والطوارئ', AppRouter.emergency, Icons.emergency),
        DashboardActionSpec('المهام والمواعيد', 'متابعة المهام والاستجابات الميدانية', AppRouter.appointments, Icons.calendar_month),
        DashboardActionSpec('التواصل الصحي', 'التواصل مع الحالات', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
    'delivery': const RoleDashboardSpec(
      role: 'delivery', title: 'التوصيل الصحي', subtitle: 'إدارة طلبات التوصيل والمهام وحالات التسليم',
      primaryCollection: 'bookings', primaryMetric: 'الطلبات', secondaryMetric: 'مهام التوصيل', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('المهام والطلبات', 'متابعة مهام التوصيل وحالات التسليم', AppRouter.services, Icons.local_shipping),
        DashboardActionSpec('المواعيد', 'تنظيم المهام المجدولة', AppRouter.appointments, Icons.calendar_month),
        DashboardActionSpec('التواصل الصحي', 'التواصل مع العملاء', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
    'service': const RoleDashboardSpec(
      role: 'service', title: 'مقدم خدمة صحية', subtitle: 'إدارة الخدمات والطلبات والعملاء',
      primaryCollection: 'bookings', primaryMetric: 'الطلبات', secondaryMetric: 'المواعيد', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('الخدمات', 'إدارة الخدمات الصحية المتاحة', AppRouter.services, Icons.medical_services),
        DashboardActionSpec('الطلبات والمواعيد', 'متابعة الأعمال الحالية', AppRouter.appointments, Icons.calendar_month),
        DashboardActionSpec('التواصل الصحي', 'التواصل مع العملاء', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
    'veterinarian': const RoleDashboardSpec(
      role: 'veterinarian', title: 'الطب البيطري', subtitle: 'إدارة المواعيد والخدمات البيطرية والتواصل مع أصحاب الحالات',
      primaryCollection: 'appointments', primaryMetric: 'المواعيد', secondaryMetric: 'الحجوزات', financialMetric: 'المعاملات',
      actions: [
        DashboardActionSpec('المواعيد البيطرية', 'متابعة مواعيد الحالات', AppRouter.appointments, Icons.calendar_month),
        DashboardActionSpec('الخدمات البيطرية', 'إدارة خدمات الطب البيطري', AppRouter.services, Icons.pets),
        DashboardActionSpec('التواصل الصحي', 'التواصل مع أصحاب الحالات', AppRouter.chat, Icons.chat),
        DashboardActionSpec('المحفظة', 'المعاملات والمستحقات المالية', AppRouter.wallet, Icons.account_balance_wallet),
      ],
    ),
  };

  static String displayName(String role) => _specs[role]?.title ?? AppRoles.getRoleName(role);
}
