import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/presentation/widgets/app_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  final List<String> _categories = [
    'الكل', 'صحة عامة', 'تغذية', 'صحة نفسية', 'جلدية', 'أطفال', 'رياضة'
  ];

  final List<Map<String, dynamic>> _articles = [
    {'id': '1', 'title': 'فوائد المشي اليومي للصحة العامة', 'category': 'صحة عامة', 'author': 'د. أحمد المولد', 'date': '2024-01-15', 'image': ImageKit.morningWalk, 'likes': 328, 'comments': 45, 'readTime': '5 دقائق'},
    {'id': '2', 'title': 'نصائح لتقوية المناعة في الشتاء', 'category': 'تغذية', 'author': 'د. أسماء الهندي', 'date': '2024-01-12', 'image': ImageKit.immuneBoost, 'likes': 256, 'comments': 32, 'readTime': '4 دقائق'},
    {'id': '3', 'title': 'أهمية النوم الصحي للجسم والعقل', 'category': 'صحة نفسية', 'author': 'د. خالد النخلاني', 'date': '2024-01-10', 'image': ImageKit.sleepTips, 'likes': 189, 'comments': 28, 'readTime': '6 دقائق'},
    {'id': '4', 'title': 'العناية بالبشرة في فصل الصيف', 'category': 'جلدية', 'author': 'د. فاطمة صديقي', 'date': '2024-01-08', 'image': ImageKit.skinCare, 'likes': 145, 'comments': 19, 'readTime': '4 دقائق'},
    {'id': '5', 'title': 'تغذية الأطفال في مرحلة النمو', 'category': 'أطفال', 'author': 'د. محمد العلاي', 'date': '2024-01-05', 'image': ImageKit.nutritionTips, 'likes': 98, 'comments': 12, 'readTime': '7 دقائق'},
  ];

  List<Map<String, dynamic>> get _filteredArticles {
    var list = _articles;
    if (_selectedCategory != 'الكل') {
      list = list.where((a) => a['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((a) =>
        a['title'].toString().contains(_searchQuery) ||
        a['author'].toString().contains(_searchQuery) ||
        a['category'].toString().contains(_searchQuery)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredArticles;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'المقالات الصحية',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ التصنيفات
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(category, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.primary),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : (isDark ? Colors.grey[700]! : Colors.grey.shade300),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // ✅ القائمة
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final article = filtered[index];
                      return _buildArticleCard(article, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, bool isDark) {
    return GestureDetector(
      onTap: () {
        ToastService.showSuccess(context, 'جاري عرض: ${article['title']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AppImage(
                imageUrl: article['image'],
                height: 150,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article['category'],
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        article['date'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'بواسطة ${article['author']} • ${article['readTime']} للقراءة',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            article['likes'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.comment, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            article['comments'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'اقرأ',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا توجد مقالات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير البحث أو التصنيف',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSearch = '';
        return AlertDialog(
          title: const Text('بحث عن مقالات'),
          content: TextField(
            onChanged: (value) => tempSearch = value,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل عنوان المقال...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = tempSearch);
                Navigator.pop(context);
              },
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }
}
