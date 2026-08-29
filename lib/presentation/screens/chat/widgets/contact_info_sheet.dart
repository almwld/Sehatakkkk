// ============================================================
// 👤 معلومات جهة الاتصال
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ContactInfoSheet extends StatelessWidget {
  final String name;
  final String? image;
  final String? specialty;
  final double? rating;
  final int? experience;
  final bool isOnline;

  const ContactInfoSheet({
    super.key,
    required this.name,
    this.image,
    this.specialty,
    this.rating,
    this.experience,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: image != null && image!.isNotEmpty
                ? NetworkImage(image!)
                : null,
            child: image == null || image!.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0] : 'م',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (specialty != null) ...[
            const SizedBox(height: 4),
            Text(
              specialty!,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating != null) ...[
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating!.toStringAsFixed(1),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (experience != null) ...[
                const Icon(Icons.work, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$experience+ سنة خبرة',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.online : AppColors.offline,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isOnline ? 'متصل' : 'غير متصل',
                style: TextStyle(
                  color: isOnline ? AppColors.online : AppColors.offline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('عرض الملف الشخصي'),
            ),
          ),
        ],
      ),
    );
  }
}
