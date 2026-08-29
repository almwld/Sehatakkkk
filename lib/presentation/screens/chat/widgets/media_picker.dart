// ============================================================
// 📎 منتقي الوسائط
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaPicker extends StatelessWidget {
  final Function(File?) onImageSelected;
  final Function(File?) onVideoSelected;
  final Function(File?) onFileSelected;

  const MediaPicker({
    super.key,
    required this.onImageSelected,
    required this.onVideoSelected,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'اختر وسائط',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPickerOption(
                icon: Icons.photo_library,
                label: 'صور',
                color: Colors.blue,
                onTap: () => _pickImage(context),
              ),
              _buildPickerOption(
                icon: Icons.video_library,
                label: 'فيديو',
                color: Colors.green,
                onTap: () => _pickVideo(context),
              ),
              _buildPickerOption(
                icon: Icons.insert_drive_file,
                label: 'ملف',
                color: Colors.orange,
                onTap: () => _pickFile(context),
              ),
              _buildPickerOption(
                icon: Icons.camera_alt,
                label: 'كاميرا',
                color: Colors.purple,
                onTap: () => _pickCamera(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerOption({
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImageSelected(File(image.path));
      Navigator.pop(context);
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      onVideoSelected(File(video.path));
      Navigator.pop(context);
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    // TODO: تنفيذ اختيار الملفات
    Navigator.pop(context);
  }

  Future<void> _pickCamera(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      onImageSelected(File(image.path));
      Navigator.pop(context);
    }
  }
}
