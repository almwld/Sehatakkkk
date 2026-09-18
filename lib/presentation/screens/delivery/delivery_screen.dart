import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_health_info_screen.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_tracking_screen.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> with SingleTickerProviderStateMixin {
  String _selectedType = 'standard';
  late TabController _tabController;
  final TextEditingController _orderIdController = TextEditingController();

  // ✅ شركات التوصيل مع أيقونات ImageKit
  final List<Map<String, dynamic>> _deliveryCompanies = [
    {
      'name': 'واصل',
      'type': 'standard',
      'rating': 4.9,
      'deliveryTime': '30-60 دقيقة',
      'price': 500,
      'image': ImageKit.delivery1,
      'active': true,
      'desc': 'توصيل سريع وموثوق'
    },
    {
      'name': 'توصيل صحتك',
      'type': 'express',
      'rating': 4.8,
      'deliveryTime': '15-30 دقيقة',
      'price': 800,
      'image': ImageKit.delivery2,
      'active': true,
      'desc': 'أسرع خدمة توصيل'
    },
    {
      'name': 'توصيل ون',
      'type': 'standard',
      'rating': 4.7,
      'deliveryTime': '45-90 دقيقة',
      'price': 400,
      'image': ImageKit.delivery3,
      'active': true,
      'desc': 'توصيل اقتصادي'
    },
    {
      'name': 'ناس توصيل',
      'type': 'premium',
      'rating': 4.9,
      'deliveryTime': '20-40 دقيقة',
      'price': 1000,
      'image': ImageKit.delivery4,
      'active': true,
      'desc': 'خدمة متميزة'
    },
  ];

  // ✅ شركات توصيل قريباً
  final List<Map<String, dynamic>> _comingSoon = [
    {'name': 'سريع', 'type': 'express', 'rating': 4.6, 'deliveryTime': '15-30 دقيقة', 'price': 750, 'image': ImageKit.delivery1, 'comingSoon': true},
    {'name': 'موتومان', 'type': 'express', 'rating': 4.5, 'deliveryTime': '20-40 دقيقة', 'price': 700, 'image': ImageKit.delivery2, 'comingSoon': true},
    {'name': 'تاكسي', 'type': 'standard', 'rating': 4.4, 'deliveryTime': '30-60 دقيقة', 'price': 500, 'image': ImageKit.delivery3, 'comingSoon': true},
    {'name': 'توصيل بلس', 'type': 'premium', 'rating': 4.7, 'deliveryTime': '20-40 دقيقة', 'price': 900, 'image': ImageKit.delivery4, 'comingSoon': true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('خدمة التوصيل'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'شركات التوصيل'),
            Tab(text: 'قريباً'),
            Tab(text: 'معلومات التوصيل'),
            Tab(text: 'تتبع مباشر'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveryCompanies(isDark),
          _buildComingSoon(isDark),
          const DeliveryHealthInfoScreen(),
          _buildTrackingEntry(isDark),
        ],
      ),
    );
  }

  Widget _buildTrackingEntry(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_searching_rounded, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('تتبع طلبك مباشرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text('أدخل رقم الطلب لعرض حالة التوصيل والموقع الحالي للمندوب عند توفر بيانات التتبع.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.5)),
          const SizedBox(height: 20),
          TextField(
            controller: _orderIdController,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(labelText: 'رقم الطلب', hintText: 'مثال: ORD-1001', prefixIcon: Icon(Icons.receipt_long_outlined), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                final id = _orderIdController.text.trim();
                if (id.isEmpty) {
                  ToastService.showError(context, 'أدخل رقم الطلب أولاً');
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(orderId: id)));
              },
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('فتح التتبع المباشر'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ),
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
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ صورة مصغرة
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(
                    imageUrl: company['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                company['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                imageUrl: company['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
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
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (company['active'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'نشط',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          company['rating'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  company['desc'] ?? 'خدمة توصيل موثوقة',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
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
                    const SizedBox(width: 12),
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
                ToastService.showSuccess(context, '✅ تم اختيار خدمة ${company['name']}');
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
