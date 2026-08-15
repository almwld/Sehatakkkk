import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PharmacyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pharmacy;

  const PharmacyDetailsScreen({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(pharmacy['name']),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ صورة الصيدلية
            Container(
              height: 200,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: pharmacy['image'],
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.local_pharmacy, size: 80, color: AppColors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ معلومات الصيدلية
                  Text(
                    pharmacy['name'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${pharmacy['rating']} (${pharmacy['reviews']} تقييم)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on, 'العنوان', pharmacy['address']),
                  _infoRow(Icons.phone, 'الهاتف', pharmacy['phone']),
                  _infoRow(Icons.access_time, 'الحالة', pharmacy['open'] ? '🟢 مفتوح' : '🔴 مغلق'),
                  _infoRow(Icons.delivery_dining, 'التوصيل', pharmacy['delivery'] ? '✅ متوفر' : '❌ غير متوفر'),
                  _infoRow(Icons.place, 'المسافة', pharmacy['distance']),
                  const SizedBox(height: 16),
                  
                  // ✅ زر الاتصال
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                      label: const Text('اتصال'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
