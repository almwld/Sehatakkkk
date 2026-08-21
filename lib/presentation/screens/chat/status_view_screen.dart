import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class StatusViewScreen extends StatelessWidget {
  final String name;
  final String statusText;
  final File? imageFile;

  const StatusViewScreen({
    super.key,
    required this.name,
    required this.statusText,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                name.isNotEmpty ? name[0] : 'م',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ عرض الصورة أو النص
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageFile != null
                      ? Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              statusText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // ✅ أزرار التفاعل
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.reply,
                    label: 'رد',
                    color: Colors.grey[600]!,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري الرد على الحالة...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.favorite_border,
                    label: 'إعجاب',
                    color: Colors.red,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❤️ تم الإعجاب بالحالة'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'مشاركة',
                    color: AppColors.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📤 جاري المشاركة...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
