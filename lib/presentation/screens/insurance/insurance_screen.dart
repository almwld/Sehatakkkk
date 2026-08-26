import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final List<Map<String, dynamic>> _companies = [
    {
      'id': '1',
      'name': 'شركة اليمن للتأمين',
      'type': 'وطني',
      'rating': 4.5,
      'reviews': 128,
      'price': '25',
      'coverage': '80%',
      'image': '🛡️',
      'features': ['تغطية شاملة', 'شبكة واسعة من المستشفيات', 'خدمة عملاء 24/7'],
    },
    {
      'id': '2',
      'name': 'شركة الرعاية للتأمين',
      'type': 'خاص',
      'rating': 4.8,
      'reviews': 256,
      'price': '35',
      'coverage': '90%',
      'image': '🏥',
      'features': ['تغطية متقدمة', 'خصومات على الأدوية', 'استشارات مجانية'],
    },
    {
      'id': '3',
      'name': 'هيئة التأمين الصحي الوطنية',
      'type': 'حكومي',
      'rating': 4.2,
      'reviews': 89,
      'price': '15',
      'coverage': '70%',
      'image': '🏛️',
      'features': ['تغطية أساسية', 'أسعار مخفضة', 'شبكة حكومية'],
    },
    {
      'id': '4',
      'name': 'شركة الصفوة للتأمين',
      'type': 'خاص',
      'rating': 4.6,
      'reviews': 167,
      'price': '30',
      'coverage': '85%',
      'image': '⭐',
      'features': ['تغطية شاملة', 'مستشفيات ممتازة', 'خدمة سريعة'],
    },
    {
      'id': '5',
      'name': 'شركة الثقة للتأمين',
      'type': 'خاص',
      'rating': 4.4,
      'reviews': 92,
      'price': '28',
      'coverage': '82%',
      'image': '🤝',
      'features': ['تغطية متوسطة', 'أسعار تنافسية', 'دعم فوري'],
    },
  ];

  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'وطني', 'خاص', 'حكومي', 'الأعلى تقييماً'];

  List<Map<String, dynamic>> get _filteredCompanies {
    var list = List<Map<String, dynamic>>.from(_companies);
    
    switch (_selectedFilter) {
      case 'وطني':
        list = list.where((c) => c['type'] == 'وطني').toList();
        break;
      case 'خاص':
        list = list.where((c) => c['type'] == 'خاص').toList();
        break;
      case 'حكومي':
        list = list.where((c) => c['type'] == 'حكومي').toList();
        break;
      case 'الأعلى تقييماً':
        list.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('التأمين الصحي'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ToastService.showSuccess('📋 عرض سياساتي');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ الفلاتر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // ✅ قائمة شركات التأمين
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _filteredCompanies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('لا توجد شركات تأمين', style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCompanies.length,
                      itemBuilder: (context, index) {
                        final company = _filteredCompanies[index];
                        return _buildCompanyCard(company, isDark);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ العنوان
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(company['image'], style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            company['type'],
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${company['rating']} (${company['reviews']})',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${company['price']}/شهر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'تغطية ${company['coverage']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ✅ المميزات
          Wrap(
            spacing: 6,
            children: company['features'].map<Widget>((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // ✅ أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showInsuranceDetails(company);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('تفاصيل', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showSubscribeInsurance(company);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('اشتراك', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInsuranceDetails(Map<String, dynamic> company) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(company['image'], style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${company['type']} • ⭐ ${company['rating']} (${company['reviews']} تقييم)',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'مميزات الباقة:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...company['features'].map<Widget>((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSubscribeInsurance(company);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('الاشتراك الآن'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscribeInsurance(Map<String, dynamic> company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الاشتراك في ${company['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر: \$${company['price']}/شهر'),
            const SizedBox(height: 8),
            Text('التغطية: ${company['coverage']}'),
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
              ToastService.showSuccess('✅ تم الاشتراك في ${company['name']} بنجاح!');
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
}
