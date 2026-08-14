import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> with SingleTickerProviderStateMixin {
  String _selectedType = 'standard';
  late TabController _tabController;

  final List<Map<String, dynamic>> _deliveryCompanies = [
    {'name': '🚚 توصيل صحتك', 'type': 'standard', 'rating': 4.9, 'deliveryTime': '30-60 دقيقة', 'price': 500, 'image': 'assets/images/delivery/delivery_1.png', 'active': true},
    {'name': '🚀 توصيل السريع', 'type': 'express', 'rating': 4.8, 'deliveryTime': '15-30 دقيقة', 'price': 800, 'image': 'assets/images/delivery/delivery_2.png', 'active': true},
    {'name': '🏠 توصيل ناس', 'type': 'standard', 'rating': 4.7, 'deliveryTime': '45-90 دقيقة', 'price': 400, 'image': 'assets/images/delivery/delivery_3.png', 'active': true},
    {'name': '🌟 توصيل صحتك بلس', 'type': 'premium', 'rating': 4.9, 'deliveryTime': '20-40 دقيقة', 'price': 1000, 'image': 'assets/images/delivery/delivery_4.png', 'active': true},
  ];

  // ✅ شركات توصيل قريباً
  final List<Map<String, dynamic>> _comingSoon = [
    {'name': '🛵 واصل', 'type': 'standard', 'rating': 4.6, 'deliveryTime': '30-60 دقيقة', 'price': 450, 'comingSoon': true},
    {'name': '🚗 سريع', 'type': 'express', 'rating': 4.5, 'deliveryTime': '15-30 دقيقة', 'price': 750, 'comingSoon': true},
    {'name': '🏍️ موتومان', 'type': 'express', 'rating': 4.4, 'deliveryTime': '20-40 دقيقة', 'price': 700, 'comingSoon': true},
    {'name': '🚕 تاكسي', 'type': 'standard', 'rating': 4.3, 'deliveryTime': '30-60 دقيقة', 'price': 500, 'comingSoon': true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: '🚚 خدمة التوصيل',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '🚚 شركات التوصيل'),
            Tab(text: '⏳ قريباً'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveryCompanies(isDark),
          _buildComingSoon(isDark),
        ],
      ),
    );
  }

  Widget _buildDeliveryCompanies(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deliveryCompanies.length,
      itemBuilder: (context, index) {
        final company = _deliveryCompanies[index];
        return _buildCompanyCard(company, isDark);
      },
    );
  }

  Widget _buildComingSoon(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _comingSoon.length,
      itemBuilder: (context, index) {
        final company = _comingSoon[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                company['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⏳ قريباً',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '⏱️ ${company['deliveryTime']}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '💰 ${company['price']} ريال',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
        border: company['active'] == true
            ? Border.all(color: Colors.green, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // ✅ صورة الشركة
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                company['name'].split(' ')[0],
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ✅ المعلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      company['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          company['rating'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      company['deliveryTime'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.money, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${company['price']} ريال',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ زر الاختيار
          if (company['active'] == true)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم اختيار خدمة التوصيل'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('اختيار'),
            ),
        ],
      ),
    );
  }
}
