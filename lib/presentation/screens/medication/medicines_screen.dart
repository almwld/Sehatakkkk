import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final medicines = [
      {'name': 'باراسيتامول 500mg', 'price': '500 ر.ي', 'image': ImageService.medicine1},
      {'name': 'فيتامين د 1000IU', 'price': '1200 ر.ي', 'image': ImageService.medicine2},
      {'name': 'جهاز قياس ضغط', 'price': '8500 ر.ي', 'image': ImageService.medicine3},
      {'name': 'أموكسيسيلين 500mg', 'price': '1500 ر.ي', 'image': ImageService.medicine4},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الأدوية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final medicine = medicines[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      medicine['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.medication, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  medicine['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  medicine['price'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
