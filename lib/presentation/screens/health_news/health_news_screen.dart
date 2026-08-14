import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HealthNewsScreen extends StatefulWidget {
  const HealthNewsScreen({super.key});

  @override
  State<HealthNewsScreen> createState() => _HealthNewsScreenState();
}

class _HealthNewsScreenState extends State<HealthNewsScreen> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = [
    'الكل',
    'أخبار طبية',
    'در.يات',
    'أبحاث',
    'تقنيات صحية',
    'أحداث ومؤتمرات',
  ];

  final List<Map<String, dynamic>> _news = [
    {
      'id': '1',
      'title': 'اكتشاف علاج جديد لمرض السكري من النوع الثاني',
      'category': 'أخبار طبية',
      'source': 'وكالة الأنباء الصحية',
      'date': '2026-07-02',
      'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400',
      'summary': 'توصل فريق من الباحثين إلى علاج جديد لمرض السكري من النوع الثاني يحسن مستويات السكر في الدم بنسبة 40%.',
      'views': 1245,
      'isSaved': false,
      'breaking': true,
    },
    {
      'id': '2',
      'title': 'در.ية: المشي 30 دقيقة يومياً يقلل خطر الاكتئاب',
      'category': 'در.يات',
      'source': 'جامعة هارفارد',
      'date': '2026-07-01',
      'image': 'https://images.unsplash.com/photo-1449300079326-7b6bc2d1d28?w=400',
      'summary': 'در.ية جديدة تظهر أن المشي لمدة 30 دقيقة يومياً يمكن أن يقلل من خطر الاكتئاب بنسبة تصل إلى 25%.',
      'views': 987,
      'isSaved': false,
      'breaking': false,
    },
    {
      'id': '3',
      'title': 'تطوير روبوت جراحي دقيق لعمليات القلب المفتوح',
      'category': 'تقنيات صحية',
      'source': 'تيك كرانش',
      'date': '2026-06-30',
      'image': 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=400',
      'summary': 'تقنية جديدة تسمح بإجراء عمليات القلب المفتوح بدقة متناهية باستخدام روبوت جراحي متطور.',
      'views': 2345,
      'isSaved': false,
      'breaking': true,
    },
    {
      'id': '4',
      'title': 'المؤتمر العالمي للصحة ينطلق في الرياض',
      'category': 'أحداث ومؤتمرات',
      'source': 'الشرق الأوسط',
      'date': '2026-06-28',
      'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
      'summary': 'انطلاق فعاليات المؤتمر العالمي للصحة بمشاركة أكثر من 2000 خبير من جميع أنحاء العالم.',
      'views': 876,
      'isSaved': false,
      'breaking': false,
    },
    {
      'id': '5',
      'title': 'أبحاث جديدة عن لقاح كورونا طويل الأمد',
      'category': 'أبحاث',
      'source': 'ساينس ديلي',
      'date': '2026-06-27',
      'image': 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?w=400',
      'summary': 'أبحاث جديدة تظهر فعالية لقاح كورونا في توفير حماية طويلة الأمد تصل إلى 18 شهراً.',
      'views': 3456,
      'isSaved': false,
      'breaking': false,
    },
    {
      'id': '6',
      'title': 'زيادة حالات الحساسية الغذائية بين الأطفال',
      'category': 'أخبار طبية',
      'source': 'بي بي سي عربي',
      'date': '2026-06-26',
      'image': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400',
      'summary': 'تقارير طبية تشير إلى زيادة ملحوظة في حالات الحساسية الغذائية بين الأطفال في السنوات الأخيرة.',
      'views': 1543,
      'isSaved': false,
      'breaking': false,
    },
    {
      'id': '7',
      'title': 'تطوير جهاز محمول لقياس ضغط الدم بدقة عالية',
      'category': 'تقنيات صحية',
      'source': 'تك كرانش',
      'date': '2026-06-25',
      'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'summary': 'جهاز محمول جديد يمكنه قياس ضغط الدم بدقة عالية تصل إلى 98% ومزامنة البيانات مع الهواتف الذكية.',
      'views': 1987,
      'isSaved': false,
      'breaking': true,
    },
    {
      'id': '8',
      'title': 'در.ية: النظام الغذائي المتوسطي يعزز صحة الدماغ',
      'category': 'در.يات',
      'source': 'جامعة كامبريدج',
      'date': '2026-06-24',
      'image': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
      'summary': 'در.ية جديدة تؤكد أن النظام الغذائي المتوسطي يساهم في تعزيز صحة الدماغ وتأخير ظهور علامات الشيخوخة.',
      'views': 1123,
      'isSaved': false,
      'breaking': false,
    },
    {
      'id': '9',
      'title': 'المؤتمر العربي للصحة النفسية ينعقد في دبي',
      'category': 'أحداث ومؤتمرات',
      'source': 'العربية',
      'date': '2026-06-23',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
      'summary': 'انعقاد المؤتمر العربي للصحة النفسية بمشاركة أطباء ومختصين من 15 دولة عربية.',
      'views': 765,
      'isSaved': false,
      'breaking': false,
    },
    {
      'id': '10',
      'title': 'نتائج مبشرة لتجارب لقاح الملاريا',
      'category': 'أبحاث',
      'source': 'رويترز',
      'date': '2026-06-22',
      'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=400',
      'summary': 'نتائج تجارب لقاح الملاريا تظهر فعالية بنسبة 75% في الوقاية من المرض في المراحل الأولى من التجارب.',
      'views': 2341,
      'isSaved': false,
      'breaking': true,
    },
    {
      'id': '11',
      'title': 'تأثير التلوث البيئي على صحة الجهاز التنفسي',
      'category': 'أخبار طبية',
      'source': 'منظمة الصحة العالمية',
      'date': '2026-06-21',
      'image': 'https://images.unsplash.com/photo-1584467735867-d5578f55c3d9?w=400',
      'summary': 'تقرير منظمة الصحة العالمية يحذر من تأثير التلوث البيئي المتزايد على صحة الجهاز التنفسي.',
      'views': 1890,
      'isSaved': false,
      'breaking': false,
    },
    {
      'id': '12',
      'title': 'اختراق علمي في علاج أمراض المناعة الذاتية',
      'category': 'أبحاث',
      'source': 'نيتشر',
      'date': '2026-06-20',
      'image': 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=400',
      'summary': 'اختراق علمي كبير في فهم وعلاج أمراض المناعة الذاتية من خلال تقنيات جديدة لتعديل الجينات.',
      'views': 2987,
      'isSaved': false,
      'breaking': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredNews {
    if (_selectedCategory == 'الكل') return _news;
    return _news.where((n) => n['category'] == _selectedCategory).toList();
  }

  void _showNewsDetails(Map<String, dynamic> news) {
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
                news['image'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.newspaper_rounded, size: 60, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (news['breaking'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.error),
                    const SizedBox(width: 4),
                    const Text(
                      'خبر عاجل',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              news['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  news['source'],
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
                  news['date'],
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye_rounded, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${news['views']}',
                      style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              news['summary'],
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
                          content: Text('📰 جاري فتح الخبر: ${news['title']}'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_browser_rounded),
                    label: const Text('قراءة الخبر'),
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
                      news['isSaved'] = !news['isSaved'];
                    });
                  },
                  icon: Icon(
                    news['isSaved'] ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: news['isSaved'] ? AppColors.primary : AppColors.grey,
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
    final filtered = _filteredNews;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: const Text('أخبار صحية', style: TextStyle(fontWeight: FontWeight.bold)),
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
          // ✅ قائمة الأخبار
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final news = filtered[index];
                      return _buildNewsCard(news, isDark);
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
              Icons.newspaper_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد أخبار',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم إضافة أخبار جديدة قريباً',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news, bool isDark) {
    return GestureDetector(
      onTap: () => _showNewsDetails(news),
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
            // ✅ صورة الخبر
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    news['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.newspaper_rounded, size: 30, color: AppColors.primary),
                    ),
                  ),
                ),
                if (news['breaking'] == true)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'عاجل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // ✅ معلومات الخبر
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news['summary'],
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
                          news['category'],
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        news['source'],
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_rounded, size: 12, color: AppColors.grey),
                          const SizedBox(width: 2),
                          Text(
                            '${news['views']}',
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
