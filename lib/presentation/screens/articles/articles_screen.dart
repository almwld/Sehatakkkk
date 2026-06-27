import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل', 'صحة عامة', 'تغذية', 'أمراض', 'أدوية', 'صحة نفسية', 'صحة المرأة', 'صحة الطفل'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المقالات الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('المقالات المحفوظة قريباً'), backgroundColor: AppColors.info),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildCategoryFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('articles')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }

                var articles = snapshot.data?.docs ?? [];
                if (_searchCtrl.text.isNotEmpty) {
                  final q = _searchCtrl.text.toLowerCase();
                  articles = articles.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['title'].toLowerCase().contains(q) ||
                        data['summary'].toLowerCase().contains(q);
                  }).toList();
                }
                if (_selectedCategory != 'الكل') {
                  articles = articles.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['category'] == _selectedCategory;
                  }).toList();
                }

                if (articles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 60, color: AppColors.grey),
                        SizedBox(height: 16),
                        Text('لا توجد مقالات', style: TextStyle(color: AppColors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final data = articles[index].data() as Map<String, dynamic>;
                    return _buildArticleCard(data, isDark);
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
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن مقال...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
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
                cat,
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

  Widget _buildArticleCard(Map<String, dynamic> data, bool isDark) {
    final date = (data['createdAt'] as Timestamp).toDate();
    final category = data['category'] ?? 'صحة عامة';
    final color = category == 'تغذية' ? AppColors.success :
                  category == 'أمراض' ? AppColors.error :
                  category == 'أدوية' ? AppColors.info :
                  category == 'صحة نفسية' ? AppColors.purple :
                  category == 'صحة المرأة' ? AppColors.pink :
                  category == 'صحة الطفل' ? AppColors.orange : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['title'] ?? 'مقال طبي',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            data['summary'] ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.visibility, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text('${data['views'] ?? 0}', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.favorite_border, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text('${data['likes'] ?? 0}', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('📖 جاري فتح المقال: ${data['title']}'), backgroundColor: AppColors.primary),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text('اقرأ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
