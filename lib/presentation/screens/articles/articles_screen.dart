import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = [
    'الكل',
    'الصحة العامة',
    'التغذية',
    'الأمراض',
    'الوقاية',
    'الصحة النفسية',
    'الرياضة',
  ];

  final List<Map<String, dynamic>> _articles = [
    {
      'id': '1',
      'title': '10 نصائح للحفاظ على صحة القلب',
      'category': 'الصحة العامة',
      'author': 'د. خالد النخلاني',
      'date': '2026-07-01',
      'readTime': '5 دقائق',
      'image': 'https://images.unsplash.com/photo-1505751172876-fa5323e0e4d?w=400',
      'likes': 245,
      'views': 1234,
      'summary': 'تعرف على أهم النصائح للحفاظ على قلبك سليماً وصحياً، من خلال تغييرات بسيطة في نمط الحياة.',
      'isSaved': false,
    },
    {
      'id': '2',
      'title': 'فوائد المشي اليومي للصحة العامة',
      'category': 'الرياضة',
      'author': 'د. حسن رضا',
      'date': '2026-06-28',
      'readTime': '4 دقائق',
      'image': 'https://images.unsplash.com/photo-1449300079326-7b6bc2d1d28?w=400',
      'likes': 189,
      'views': 987,
      'summary': 'المشي من أفضل التمارين التي يمكن ممارستها يومياً لتحسين الصحة البدنية والنفسية.',
      'isSaved': false,
    },
    {
      'id': '3',
      'title': 'دليل التغذية السليمة في رمضان',
      'category': 'التغذية',
      'author': 'د. سارة أحمد',
      'date': '2026-06-25',
      'readTime': '6 دقائق',
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63?w=400',
      'likes': 312,
      'views': 1567,
      'summary': 'كيف تحافظ على صحتك وتغذيتك خلال شهر رمضان المبارك مع نصائح عملية ومفيدة.',
      'isSaved': false,
    },
    {
      'id': '4',
      'title': 'أعراض نقص فيتامين د وكيفية علاجه',
      'category': 'الأمراض',
      'author': 'د. فاطمة صديقي',
      'date': '2026-06-22',
      'readTime': '5 دقائق',
      'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      'likes': 278,
      'views': 2100,
      'summary': 'تعرف على أعراض نقص فيتامين د وطرق العلاج الفعالة لتحسين صحتك العامة.',
      'isSaved': false,
    },
    {
      'id': '5',
      'title': 'كيف تتعامل مع التوتر والقلق اليومي',
      'category': 'الصحة النفسية',
      'author': 'د. رنا النجار',
      'date': '2026-06-20',
      'readTime': '7 دقائق',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
      'likes': 456,
      'views': 3200,
      'summary': 'استراتيجيات فعالة للتعامل مع التوتر والقلق في الحياة اليومية وتحسين الصحة النفسية.',
      'isSaved': false,
    },
    {
      'id': '6',
      'title': 'الوقاية من أمراض القلب والشرايين',
      'category': 'الوقاية',
      'author': 'د. خالد النخلاني',
      'date': '2026-06-18',
      'readTime': '6 دقائق',
      'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'likes': 345,
      'views': 1800,
      'summary': 'تعرف على طرق الوقاية من أمراض القلب والشرايين من خلال تغييرات بسيطة في نمط الحياة.',
      'isSaved': false,
    },
    {
      'id': '7',
      'title': 'أهمية شرب الماء للجسم',
      'category': 'الصحة العامة',
      'author': 'د. أحمد المولد',
      'date': '2026-06-15',
      'readTime': '3 دقائق',
      'image': 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400',
      'likes': 567,
      'views': 4500,
      'summary': 'الماء هو سر الحياة والصحة، تعرف على فوائد شرب الماء الكافية للجسم.',
      'isSaved': false,
    },
    {
      'id': '8',
      'title': 'أفضل الأطعمة لصحة الدماغ',
      'category': 'التغذية',
      'author': 'د. سارة أحمد',
      'date': '2026-06-12',
      'readTime': '5 دقائق',
      'image': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
      'likes': 234,
      'views': 1200,
      'summary': 'تعرف على الأطعمة التي تعزز صحة الدماغ وتحسن الذاكرة والتركيز.',
      'isSaved': false,
    },
    {
      'id': '9',
      'title': 'كيف تحافظ على صحة عظامك',
      'category': 'الوقاية',
      'author': 'د. حسن رضا',
      'date': '2026-06-10',
      'readTime': '4 دقائق',
      'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400',
      'likes': 198,
      'views': 980,
      'summary': 'نصائح للحفاظ على صحة العظام والوقاية من هشاشة العظام مع التقدم في العمر.',
      'isSaved': false,
    },
    {
      'id': '10',
      'title': 'الصحة النفسية في العمل',
      'category': 'الصحة النفسية',
      'author': 'د. رنا النجار',
      'date': '2026-06-08',
      'readTime': '6 دقائق',
      'image': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400',
      'likes': 389,
      'views': 2100,
      'summary': 'كيف تحافظ على صحتك النفسية في بيئة العمل وتتغلب على ضغوطات العمل اليومية.',
      'isSaved': false,
    },
    {
      'id': '11',
      'title': 'فوائد ممارسة الرياضة اليومية',
      'category': 'الرياضة',
      'author': 'د. كمال أحمد',
      'date': '2026-06-05',
      'readTime': '4 دقائق',
      'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      'likes': 456,
      'views': 2800,
      'summary': 'تعرف على فوائد ممارسة الرياضة اليومية للجسم والعقل وكيفية البدء في روتين رياضي.',
      'isSaved': false,
    },
    {
      'id': '12',
      'title': 'التغذية السليمة للأطفال',
      'category': 'التغذية',
      'author': 'د. فاطمة صديقي',
      'date': '2026-06-03',
      'readTime': '7 دقائق',
      'image': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400',
      'likes': 567,
      'views': 3500,
      'summary': 'دليل شامل لتغذية الأطفال في مختلف المراحل العمرية لضمان نمو صحي وسليم.',
      'isSaved': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredArticles {
    if (_selectedCategory == 'الكل') return _articles;
    return _articles.where((a) => a['category'] == _selectedCategory).toList();
  }

  void _showArticleDetails(Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article['image'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.article_rounded, size: 60, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  article['author'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  article['date'],
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${article['readTime']} قراءة',
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                article['category'],
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article['summary'],
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📖 جاري فتح المقال: ${article['title']}'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('قراءة المقال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      article['isSaved'] = !article['isSaved'];
                    });
                  },
                  icon: Icon(
                    article['isSaved'] ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: article['isSaved'] ? AppColors.primary : AppColors.grey,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
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
          _buildCategories(),
          // ✅ قائمة المقالات
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
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

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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
            'سيتم إضافة مقالات جديدة قريباً',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, bool isDark) {
    return GestureDetector(
      onTap: () => _showArticleDetails(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
          border: Border.all(
            color: isDark ? const Color(0xFF2D3A54) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // ✅ صورة المقال
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.article_rounded, size: 30, color: AppColors.primary),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article['summary'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article['category'],
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${article['readTime']}',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.favorite_border_rounded, size: 12, color: AppColors.grey),
                          const SizedBox(width: 2),
                          Text(
                            '${article['likes']}',
                            style: TextStyle(fontSize: 9, color: AppColors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_rounded, size: 12, color: AppColors.grey),
                          const SizedBox(width: 2),
                          Text(
                            '${article['views']}',
                            style: TextStyle(fontSize: 9, color: AppColors.grey),
                          ),
                        ],
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
}
