import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/data/medicines_data.dart';

class MedicineDetailScreen extends StatelessWidget {
  final String medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  Map<String, dynamic>? get _medicine {
    try {
      final all = MedicinesData.getAll();
      return all.firstWhere((med) => med['id'] == medicineId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicine = _medicine;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (medicine == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الدواء'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('الدواء غير موجود'),
        ),
      );
    }

    final inStock = medicine['inStock'] as bool? ?? true;
    final requiresPrescription = medicine['requiresPrescription'] as bool? ?? false;
    final price = medicine['price'] as int? ?? 0;
    final rating = medicine['rating'] as double? ?? 0.0;
    final category = medicine['category'] as String? ?? '';
    final subcategory = medicine['subcategory'] as String? ?? '';
    final description = medicine['description'] as String? ?? '';
    final image = medicine['image'] as String? ?? ImageService.medicine1;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(medicine['name'] ?? 'الدواء'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة الدواء إلى المفضلة'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري مشاركة الدواء...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ صورة الدواء
            Container(
              width: double.infinity,
              height: 250,
              color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.medication,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ الاسم والتصنيف
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          medicine['name'] ?? '',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: inStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          inStock ? 'متوفر' : 'غير متوفر',
                          style: TextStyle(
                            color: inStock ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ✅ التصنيفات
                  Wrap(
                    spacing: 8,
                    children: [
                      if (category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (subcategory.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subcategory,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      if (requiresPrescription)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.assignment, size: 12, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'يتطلب وصفة طبية',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ✅ السعر والتقييم
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$price ر.ي',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ✅ الوصف
                  const Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ معلومات إضافية
                  const Text(
                    'معلومات إضافية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('التصنيف', category, isDark),
                  _buildInfoRow('التصنيف الفرعي', subcategory, isDark),
                  _buildInfoRow('السعر', '$price ريال', isDark),
                  _buildInfoRow('التقييم', '$rating من 5', isDark),
                  _buildInfoRow('الوصفة الطبية', requiresPrescription ? 'مطلوبة' : 'غير مطلوبة', isDark),
                  _buildInfoRow('التوفر', inStock ? 'متوفر' : 'غير متوفر', isDark),
                  const SizedBox(height: 32),

                  // ✅ أزرار الإجراءات
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: inStock
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ تمت إضافة الدواء إلى السلة'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('إضافة إلى السلة'),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📋 تم نسخ معلومات الدواء'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('نسخ المعلومات'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value.isNotEmpty ? value : 'غير محدد',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
