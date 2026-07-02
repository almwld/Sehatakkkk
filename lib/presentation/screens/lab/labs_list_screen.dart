import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'lab_booking_screen.dart';

class LabsListScreen extends StatelessWidget {
  const LabsListScreen({super.key});

  final List<Map<String, dynamic>> _labs = const [
    {
      'id': '1',
      'name': 'المختبر الوطني',
      'city': 'صنعاء',
      'type': 'تحاليل دم',
      'rating': 4.8,
      'homeService': true,
      'price': '150',
      'image': '🧪',
    },
    {
      'id': '2',
      'name': 'مختبر الثقة',
      'city': 'صنعاء',
      'type': 'تحاليل دم',
      'rating': 4.7,
      'homeService': true,
      'price': '120',
      'image': '🔬',
    },
    {
      'id': '3',
      'name': 'مختبر البرج',
      'city': 'صنعاء',
      'type': 'هرمونات',
      'rating': 4.6,
      'homeService': true,
      'price': '200',
      'image': '🧬',
    },
    {
      'id': '4',
      'name': 'مختبر اليقين',
      'city': 'صنعاء',
      'type': 'فيروسات',
      'rating': 4.5,
      'homeService': true,
      'price': '100',
      'image': '🦠',
    },
    {
      'id': '5',
      'name': 'معامل النخبة',
      'city': 'صنعاء',
      'type': 'وراثة',
      'rating': 4.9,
      'homeService': true,
      'price': '250',
      'image': '🧬',
    },
    {
      'id': '6',
      'name': 'مركز الأشعة المتقدم',
      'city': 'صنعاء',
      'type': 'أشعة',
      'rating': 4.5,
      'homeService': true,
      'price': '180',
      'image': '📷',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('المختبرات والتحاليل', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _labs.length,
        itemBuilder: (context, index) {
          final lab = _labs[index];
          return _buildLabCard(context, lab, isDark);
        },
      ),
    );
  }

  Widget _buildLabCard(BuildContext context, Map<String, dynamic> lab, bool isDark) {
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
      ),
      child: Column(
        children: [
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
                  child: Text(
                    lab['image'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${lab['city']} • ${lab['type']}',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                        Text(
                          ' ${lab['rating']} ★',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (lab['homeService'])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'خدمة منزلية',
                              style: TextStyle(fontSize: 8, color: AppColors.success),
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
                    'من ${lab['price']} ر.س',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ✅ زر حجز فحص
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LabBookingScreen(
                            labName: lab['name'],
                            labId: lab['id'],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('حجز فحص', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
