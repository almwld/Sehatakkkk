// ============================================================
// 📸 شاشة الحالات (Stories)
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_strings.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  void _loadStories() {
    // TODO: جلب الحالات من Firebase
    _stories = [
      {'name': 'د. أحمد المؤيد', 'image': '', 'time': 'منذ 5 دقائق', 'viewed': false},
      {'name': 'د. خالد النخلاني', 'image': '', 'time': 'منذ ساعة', 'viewed': true},
      {'name': 'د. أسماء الهندي', 'image': '', 'time': 'منذ 3 ساعات', 'viewed': false},
    ];
  }

  Future<void> _addStory() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      ToastService.showInfo('📸 جاري رفع الحالة...');
      
      // TODO: رفع الصورة إلى Firebase Storage
      // TODO: حفظ الحالة في Firestore
      
      setState(() {
        _stories.insert(0, {
          'name': 'أنت',
          'image': image.path,
          'time': 'الآن',
          'viewed': false,
        });
      });
      
      ToastService.showSuccess('✅ تم إضافة الحالة بنجاح');
    } catch (e) {
      ToastService.showError('❌ فشل إضافة الحالة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(AppStrings.stories),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _loadStories()),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ إضافة حالة جديدة
          _buildAddStoryCard(isDark),
          // ✅ قائمة الحالات
          Expanded(
            child: _stories.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      final story = _stories[index];
                      return _buildStoryItem(story, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStoryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: _addStory,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.add, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.addStory,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'شارك لحظة مع أطبائك',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryItem(Map<String, dynamic> story, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: story['viewed'] == false
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: story['image'] != null && story['image']!.isNotEmpty
                    ? FileImage(File(story['image']))
                    : null,
                child: story['image'] == null || story['image']!.isEmpty
                    ? Text(
                        story['name'][0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (story['viewed'] == false)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story['name'],
                  style: TextStyle(
                    fontWeight: story['viewed'] == false ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  story['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: AppColors.primary,
            ),
            onPressed: () => ToastService.showSuccess('✅ تم مشاركة الحالة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حالات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف حالتك الأولى الآن',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addStory,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('إضافة حالة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ استخدام StoryModel
import 'package:sehatak/models/story_model.dart';

// ✅ دالة لإضافة حالة
Future<void> _addStoryWithModel() async {
  final story = StoryModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    userName: FirebaseAuth.instance.currentUser?.displayName ?? 'مستخدم',
    text: 'حالة جديدة',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(hours: 24)),
  );
  // حفظ في Firestore
  await FirebaseFirestore.instance.collection('stories').add(story.toMap());
}
