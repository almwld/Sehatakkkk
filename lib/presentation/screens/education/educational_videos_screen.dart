import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class EducationalVideosScreen extends StatefulWidget {
  const EducationalVideosScreen({super.key});

  @override
  State<EducationalVideosScreen> createState() => _EducationalVideosScreenState();
}

class _EducationalVideosScreenState extends State<EducationalVideosScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'الكل';

  String _t(String value) => AppStrings.of(context).translate(value);

  final List<String> _categories = [
    'الكل', 'تشريح', 'أمراض', 'أدوية', 'تغذية', 'إسعافات', 'صحة نفسية'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(AppStrings.of(context).translate('الفيديوهات التثقيفية'), style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildCategoryFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('videos')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${AppStrings.of(context).translate('حدث خطأ')}: ${snapshot.error}'));
                }

                var videos = snapshot.data?.docs ?? [];
                if (_searchCtrl.text.isNotEmpty) {
                  final q = _searchCtrl.text.trim().toLowerCase();
                  final locale = AppStrings.of(context).locale;
                  videos = videos.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = localizedField(data, 'title', locale);
                    final arabicTitle = localizedField(
                      data,
                      'title',
                      const Locale('ar'),
                    );
                    return title.toLowerCase().contains(q) ||
                        arabicTitle.toLowerCase().contains(q);
                  }).toList();
                }
                if (_selectedCategory != 'الكل') {
                  videos = videos.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final category = localizedField(
                      data,
                      'category',
                      const Locale('ar'),
                    );
                    return category == _selectedCategory;
                  }).toList();
                }

                if (videos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library, size: 60, color: AppColors.grey),
                        SizedBox(height: 16),
                        Text(AppStrings.of(context).translate('لا توجد فيديوهات'), style: TextStyle(color: AppColors.grey)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final data = videos[index].data() as Map<String, dynamic>;
                    return _buildVideoCard(data, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: UnifiedSearchBar(controller: _searchCtrl, onChanged: (_) => setState(() {}), hintText: AppStrings.of(context).translate('ابحث عن فيديو...')),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final cat = _categories[index];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppStrings.of(context).translate(cat),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.darkGrey,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> data, bool isDark) {
    final locale = AppStrings.of(context).locale;
    final title = _t(
      localizedField(data, 'title', locale, fallback: _t('فيديو تعليمي')),
    );
    final category = _t(
      localizedField(data, 'category', locale, fallback: _t('تعليمي')),
    );
    final color = AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              color: color.withOpacity(0.1),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: color,
                    size: 40,
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data['duration'] ?? '5:00',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(fontSize: 9, color: AppColors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.visibility, size: 12, color: AppColors.grey),
                    const SizedBox(width: 2),
                    Text('${data['views'] ?? 0}', style: const TextStyle(fontSize: 8, color: AppColors.grey)),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        ToastService.showSuccess(context, '▶️ ${AppStrings.of(context).translate('جاري تشغيل الفيديو...')}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(40, 20),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        textStyle: const TextStyle(fontSize: 8),
                      ),
                      child: Text(AppStrings.of(context).translate('تشغيل')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
