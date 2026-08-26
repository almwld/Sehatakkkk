import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() => _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  final List<Map<String, dynamic>> _recommendations = [
    {
      'id': '1',
      'title': 'تحسين جودة النوم',
      'description': 'بناءً على نمط نومك، نوصي بالنوم 7-8 ساعات يومياً والابتعاد عن الشاشات قبل النوم بساعة.',
      'category': 'النوم',
      'icon': Icons.bedtime,
      'color': Colors.purple,
      'rating': 4.9,
    },
    {
      'id': '2',
      'title': 'نظام غذائي صحي',
      'description': 'نوصي بتناول 5 حصص من الفواكه والخضار يومياً، وشرب 8 أكواب من الماء، وتقليل السكريات.',
      'category': 'التغذية',
      'icon': Icons.restaurant,
      'color': Colors.green,
      'rating': 4.7,
    },
    {
      'id': '3',
      'title': 'تمارين يومية',
      'description': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري. جرب صعود الدرج بدلاً من المصعد.',
      'category': 'اللياقة',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'rating': 4.8,
    },
    {
      'id': '4',
      'title': 'إدارة التوتر',
      'description': 'ممارسة التأمل والتنفس العميق 10 دقائق يومياً يساعد في تقليل التوتر وتحسين الصحة النفسية.',
      'category': 'الصحة النفسية',
      'icon': Icons.psychology,
      'color': Colors.blue,
      'rating': 4.6,
    },
    {
      'id': '5',
      'title': 'فحص دوري',
      'description': 'نوصي بإجراء فحص دوري كل 6 أشهر للاطمئنان على صحتك العامة والكشف المبكر عن الأمراض.',
      'category': 'الوقاية',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
      'rating': 4.4,
    },
    {
      'id': '6',
      'title': 'تذكير بالأدوية',
      'description': 'تذكر تناول أدويتك في المواعيد المحددة. استخدم تطبيقنا لتذكيرك بمواعيد الأدوية.',
      'category': 'الأدوية',
      'icon': Icons.medication,
      'color': Colors.teal,
      'rating': 4.5,
    },
  ];

  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'النوم', 'التغذية', 'اللياقة', 'الصحة النفسية', 'الوقاية', 'الأدوية'];

  List<Map<String, dynamic>> get _filteredRecommendations {
    if (_selectedCategory == 'الكل') return _recommendations;
    return _recommendations.where((r) => r['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('توصيات الذكاء الاصطناعي 🤖'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ الفلاتر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // ✅ قائمة التوصيات
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _filteredRecommendations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('لا توجد توصيات', style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredRecommendations.length,
                      itemBuilder: (context, index) {
                        final recommendation = _filteredRecommendations[index];
                        return _buildRecommendationCard(recommendation, isDark);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation, bool isDark) {
    final color = recommendation['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ الأيقونة
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              recommendation['icon'] as IconData,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // ✅ المحتوى
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recommendation['title'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recommendation['category'],
                        style: TextStyle(
                          fontSize: 9,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${recommendation['rating']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _showRecommendationDetails(recommendation);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: const Text(
                        'تفاصيل',
                        style: TextStyle(fontSize: 12),
                      ),
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

  void _showRecommendationDetails(Map<String, dynamic> recommendation) {
    final color = recommendation['color'] as Color;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    recommendation['icon'] as IconData,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        recommendation['category'],
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              recommendation['description'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ToastService.showSuccess('✅ تم تطبيق التوصية: ${recommendation['title']}');
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('تطبيق التوصية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('إغلاق'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
