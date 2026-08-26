import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final List<Map<String, dynamic>> _packages = [
    {
      'id': '1',
      'name': 'الباقة الأساسية',
      'price': '0',
      'period': 'شهرياً',
      'features': [
        'استشارات طبية محدودة',
        'متابعة الحالة الصحية',
        'تذكير بالأدوية',
        'تقارير صحية أساسية',
      ],
      'color': Colors.blue,
      'popular': false,
      'save': '0%',
    },
    {
      'id': '2',
      'name': 'الباقة الذهبية',
      'price': '49',
      'period': 'شهرياً',
      'features': [
        'استشارات غير محدودة',
        'متابعة الحالة الصحية المتقدمة',
        'تذكير بالأدوية الذكي',
        'تقارير صحية مفصلة',
        'استشارات فيديو غير محدودة',
        'خصم 20% على الأدوية',
        'أولوية الحجز مع الأطباء',
      ],
      'color': Colors.amber,
      'popular': true,
      'save': '42%',
    },
    {
      'id': '3',
      'name': 'الباقة العائلية',
      'price': '79',
      'period': 'شهرياً',
      'features': [
        'جميع ميزات الباقة الذهبية',
        'إضافة 5 أفراد من العائلة',
        'تتبع صحي للعائلة كاملة',
        'استشارات عائلية غير محدودة',
        'خصم 30% على الأدوية للعائلة',
        'تذكير جماعي بالأدوية',
        'تقارير صحية للعائلة',
      ],
      'color': Colors.purple,
      'popular': false,
      'save': '35%',
    },
    {
      'id': '4',
      'name': 'الباقة الماسية',
      'price': '149',
      'period': 'شهرياً',
      'features': [
        'جميع ميزات الباقة العائلية',
        'استشارات منزلية مجانية',
        'توصيل الأدوية المجاني',
        'تحاليل مخبرية مجانية شهرياً',
        'متابعة صحية شخصية',
        'خط ساخن 24/7',
        'خصم 50% على جميع الخدمات',
        'أولوية VIP في الحجز',
      ],
      'color': Colors.pink,
      'popular': false,
      'save': '55%',
    },
  ];

  int _selectedPackage = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الباقات الصحية'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ToastService.showSuccess('📋 عرض اشتراكاتي');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ العنوان
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر الباقة المناسبة لك',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'استمتع بخصومات ومميزات حصرية مع باقاتنا الصحية',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // ✅ قائمة الباقات
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final package = _packages[index];
                  return _buildPackageCard(package, isDark, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package, bool isDark, int index) {
    final isSelected = _selectedPackage == index;
    final color = package['color'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ العنوان والسعر
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (package['popular'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'الأكثر طلباً',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (package['save'] != '0%')
                        Text(
                          'وفر ${package['save']} عند الاشتراك السنوي',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${package['price']}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      package['period'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ✅ المميزات
            ...package['features'].map<Widget>((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            // ✅ زر الاشتراك
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSubscribeDialog(package);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
                  foregroundColor: isSelected ? Colors.white : Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isSelected ? 'اشتراك الآن' : 'اختيار الباقة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscribeDialog(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الاشتراك في ${package['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر: \$${package['price']} ${package['period']}'),
            const SizedBox(height: 8),
            const Text('سيتم خصم المبلغ من محفظتك'),
            const SizedBox(height: 8),
            const Text('هل أنت متأكد من رغبتك في الاشتراك؟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastService.showSuccess('✅ تم الاشتراك في ${package['name']} بنجاح!');
              _showSuccessDialog(package);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد الاشتراك'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 تم الاشتراك بنجاح!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: Colors.green),
            const SizedBox(height: 12),
            Text('تم تفعيل ${package['name']} بنجاح'),
            const SizedBox(height: 8),
            Text(
              'يمكنك الآن الاستمتاع بجميع المميزات',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
