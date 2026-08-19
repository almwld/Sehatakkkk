import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';

class InsuranceCompanies extends StatefulWidget {
  const InsuranceCompanies({super.key});

  @override
  State<InsuranceCompanies> createState() => _InsuranceCompaniesState();
}

class _InsuranceCompaniesState extends State<InsuranceCompanies> {
  String _type = 'الكل';

  final List<Map<String, dynamic>> _companies = [
    {'name': 'جوبيلي للتأمين الصحي', 'type': 'صحي', 'coverage': 'حتى 1,000,000 ر.ي', 'hospitals': '500+', 'rating': 4.7, 'premium': 'من 2,500 ر.ي/شهر', 'color': AppColors.primary, 'icon': Icons.health_and_safety},
    {'name': 'أدامجي للتأمين', 'type': 'صحي', 'coverage': 'حتى 800,000 ر.ي', 'hospitals': '400+', 'rating': 4.5, 'premium': 'من 2,000 ر.ي/شهر', 'color': AppColors.info, 'icon': Icons.shield},
    {'name': 'أليانز إي إف يو', 'type': 'عائلي', 'coverage': 'حتى 2,000,000 ر.ي', 'hospitals': '700+', 'rating': 4.8, 'premium': 'من 3,500 ر.ي/شهر', 'color': AppColors.success, 'icon': Icons.family_restroom},
    {'name': 'آي جي آي للتأمين', 'type': 'سفر', 'coverage': 'حتى 500,000 ر.ي', 'hospitals': '200+', 'rating': 4.3, 'premium': 'من 1,500 ر.ي/شهر', 'color': AppColors.primary, 'icon': Icons.flight},
    {'name': 'تي بي إل', 'type': 'صحي', 'coverage': 'حتى 1,500,000 ر.ي', 'hospitals': '600+', 'rating': 4.6, 'premium': 'من 3,000 ر.ي/شهر', 'color': AppColors.purple, 'icon': Icons.medical_services},
    {'name': 'ستيت لايف', 'type': 'عائلي', 'coverage': 'حتى 5,000,000 ر.ي', 'hospitals': '1000+', 'rating': 4.9, 'premium': 'من 5,000 ر.ي/شهر', 'color': AppColors.warning, 'icon': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _type == 'الكل' ? _companies : _companies.where((c) => c['type'] == _type).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'التأمين الصحي',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.purple.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اعثر على أفضل تأمين صحي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'قارن الخطط ووفر المال',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                    ),
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('قارن الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ✅ التصنيفات
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (ctx, i) {
                  final types = ['الكل', 'صحي', 'عائلي', 'سفر'];
                  final sel = _type == types[i];
                  return ChoiceChip(
                    label: Text(types[i], style: const TextStyle(fontSize: 11)),
                    selected: sel,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : (isDark ? Colors.white : AppColors.primary),
                    ),
                    backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                    onSelected: (v) => setState(() => _type = v! ? types[i] : 'الكل'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: sel ? AppColors.primary : (isDark ? Colors.grey[700]! : Colors.grey.shade300),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // ✅ القائمة
            ...filtered.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (c['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          c['icon'] as IconData,
                          size: 24,
                          color: c['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                Text(
                                  ' ${c['rating']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (c['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c['type'],
                          style: TextStyle(
                            fontSize: 9,
                            color: c['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _info(Icons.shield, 'التغطية', c['coverage'], isDark),
                      _info(Icons.local_hospital, 'المستشفيات', c['hospitals'], isDark),
                      _info(Icons.payments, 'القسط', c['premium'], isDark),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('عرض التفاصيل'),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.grey),
        ),
      ],
    );
  }
}
