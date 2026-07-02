import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String _selectedCategory = 'الكل';
  bool _isLoading = false;

  final List<String> _categories = [
    'الكل',
    'الصحة العامة',
    'التغذية',
    'الأمراض',
    'الوقاية',
    'الصحة النفسية',
    'الأدوية',
  ];

  final List<Map<String, dynamic>> _articles = [
    {
      'id': '1',
      'title': 'فوائد شرب الماء على الريق',
      'subtitle': '8 أسباب تجعلك تبدأ يومك بكوب ماء',
      'category': 'الصحة العامة',
      'readTime': '5 دقائق',
      'image': '💧',
      'color': AppColors.info,
      'date': '2026-07-01',
      'likes': 245,
      'views': 1200,
      'author': 'د. أحمد المولد',
    },
    {
      'id': '2',
      'title': 'نظام غذائي صحي للقلب',
      'subtitle': 'أطعمة تحمي قلبك وتخفض الكوليسترول',
      'category': 'التغذية',
      'readTime': '7 دقائق',
      'image': '❤️',
      'color': AppColors.error,
      'date': '2026-06-28',
      'likes': 189,
      'views': 850,
      'author': 'د. خالد النخلاني',
    },
    {
      'id': '3',
      'title': 'كيف تتغلب على التوتر والقلق',
      'subtitle': '5 تقنيات فعالة للاسترخاء',
      'category': 'الصحة النفسية',
      'readTime': '6 دقائق',
      'image': '🧠',
      'color': AppColors.purple,
      'date': '2026-06-25',
      'likes': 312,
      'views': 2100,
      'author': 'د. رنا النجار',
    },
    {
      'id': '4',
      'title': 'فيتامين د: أهميته ومصادره',
      'subtitle': 'كل ما تحتاج معرفته عن فيتامين الشمس',
      'category': 'الصحة العامة',
      'readTime': '4 دقائق',
      'image': '☀️',
      'color': AppColors.warning,
      'date': '2026-06-22',
      'likes': 156,
      'views': 980,
      'author': 'د. عائشة ملك',
    },
    {
      'id': '5',
      'title': 'علامات مبكرة للسكري',
      'subtitle': 'لا تتجاهل هذه الأعراض',
      'category': 'الأمراض',
      'readTime': '8 دقائق',
      'image': '🩸',
      'color': AppColors.primary,
      'date': '2026-06-20',
      'likes': 278,
      'views': 1500,
      'author': 'د. حسن رضا',
    },
    {
      'id': '6',
      'title': 'فوائد المشي اليومي',
      'subtitle': '30 دقيقة تغير حياتك',
      'category': 'الوقاية',
      'readTime': '3 دقائق',
      'image': '🚶',
      'color': AppColors.success,
      'date': '2026-06-18',
      'likes': 198,
      'views': 1100,
      'author': 'د. علي المولد',
    },
  ];

  List<Map<String, dynamic>> get _filteredArticles {
    if (_selectedCategory == 'الكل') return _articles;
    return _articles.where((a) => a['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredArticles;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('المقالات الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ التصنيفات
          _buildCategories(isDark),
          // ✅ قائمة المقالات
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final article = filtered[index];
                      return _buildArticleCard(context, article, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF1A2540) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.grey.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.article_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد مقالات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد مقالات في هذا التصنيف',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    Map<String, dynamic> article,
    bool isDark,
  ) {
    final color = article['color'] as Color;
    final image = article['image'] as String;

    return GestureDetector(
      onTap: () {
        // ✅ فتح تفاصيل المقال
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            // ✅ أيقونة المقال
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  image,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ معلومات المقال
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article['subtitle'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article['category'],
                          style: TextStyle(
                            fontSize: 9,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${article['readTime']} • ${article['date']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ الإحصائيات
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.visibility_rounded,
                      size: 12,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${article['views']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 12,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${article['likes']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'اقرأ',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
