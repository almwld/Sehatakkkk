import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  final List<Map<String, dynamic>> _pharmacies = const [
    {'name': 'صيدلية الشفاء', 'address': 'شارع الزبيري', 'rating': 4.8, 'delivery': true, 'image': ImageService.pharmacy1},
    {'name': 'صيدلية اليمن', 'address': 'شارع التحرير', 'rating': 4.6, 'delivery': true, 'image': ImageService.pharmacy2},
    {'name': 'صيدلية الأمل', 'address': 'شارع هائل', 'rating': 4.7, 'delivery': true, 'image': ImageService.pharmacy1},
    {'name': 'صيدلية ابن حيان', 'address': 'شارع الستين', 'rating': 4.4, 'delivery': false, 'image': ImageService.pharmacy2},
    {'name': 'صيدلية الشهيد', 'address': 'شارع القاهرة', 'rating': 4.5, 'delivery': true, 'image': ImageService.pharmacy1},
    {'name': 'صيدلية النصر', 'address': 'شارع الأربعين', 'rating': 4.3, 'delivery': false, 'image': ImageService.pharmacy2},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الصيدليات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = _pharmacies[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: ImageService.imageWithShimmer(
                pharmacy['image'],
                width: 50,
                height: 50,
                borderRadius: 12,
              ),
              title: Text(pharmacy['name']),
              subtitle: Text(pharmacy['address']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pharmacy['delivery'] == true)
                    const Icon(Icons.delivery_dining, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text('${pharmacy['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
