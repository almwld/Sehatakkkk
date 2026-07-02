import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HealthEducationScreen extends StatefulWidget {
  const HealthEducationScreen({super.key});

  @override
  State<HealthEducationScreen> createState() => _HealthEducationScreenState();
}

class _HealthEducationScreenState extends State<HealthEducationScreen> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = [
    'الكل',
    'التغذية',
    'الرياضة',
    'الصحة النفسية',
    'الأمراض',
    'الوقاية',
    'العناية الشخصية',
  ];

  final List<Map<String, dynamic>> _videos = [
    {
      'id': '1',
      'title': 'تمارين اليوغا للمبتدئين',
      'category': 'الرياضة',
      'doctor': 'د. سارة أحمد',
      'duration': '12:30',
      'views': '15.2K',
      'thumbnail': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
      'likes': 1234,
      'isLiked': false,
      'description': 'تعلم أساسيات اليوغا مع تمارين بسيطة للمبتدئين لتحسين المرونة والاسترخاء.',
    },
    {
      'id': '2',
      'title': 'كيف تحافظ على صحة قلبك',
      'category': 'الوقاية',
      'doctor': 'د. خالد النخلاني',
      'duration': '8:45',
      'views': '8.7K',
      'thumbnail': 'https://images.unsplash.com/photo-1505751172876-fa5323e0e4d?w=400',
      'likes': 876,
      'isLiked': false,
      'description': 'نصائح عملية للحفاظ على صحة القلب والوقاية من الأمراض القلبية.',
    },
    {
      'id': '3',
      'title': 'أفضل 10 أطعمة لصحة الدماغ',
      'category': 'التغذية',
      'doctor': 'د. فاطمة صديقي',
      'duration': '10:15',
      'views': '22.3K',
      'thumbnail': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
      'likes': 2345,
      'isLiked': false,
      'description': 'تعرف على الأطعمة التي تعزز صحة الدماغ وتحسن الذاكرة والتركيز.',
    },
    {
      'id': '4',
      'title': 'تمارين التنفس للتخلص من التوتر',
      'category': 'الصحة النفسية',
      'doctor': 'د. رنا النجار',
      'duration': '6:20',
      'views': '18.9K',
      'thumbnail': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'likes': 1567,
      'isLiked': false,
      'description': 'تعلم تمارين التنفس العميق للتخلص من التوتر والقلق وتحسين الصحة النفسية.',
    },
    {
      'id': '5',
      'title': 'كيف تعتني ببشرتك بشكل صحيح',
      'category': 'العناية الشخصية',
      'doctor': 'د. علي البراشي',
      'duration': '9:50',
      'views': '12.1K',
      'thumbnail': 'https://images.unsplash.com/photo-1556228578-0b7e1b3c0c8f?w=400',
      'likes': 987,
      'isLiked': false,
      'description': 'دليل شامل للعناية بالبشرة حسب نوعها مع نصائح عملية وفعالة.',
    },
    {
      'id': '6',
      'title': 'التمارين المنزلية بدون أدوات',
      'category': 'الرياضة',
      'doctor': 'د. كمال أحمد',
      'duration': '15:00',
      'views': '32.5K',
      'thumbnail': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      'likes': 2876,
      'isLiked': false,
      'description': 'تمارين فعالة يمكن ممارستها في المنزل بدون استخدام أي أدوات رياضية.',
    },
    {
      'id': '7',
      'title': 'أعراض نقص الفيتامينات وكيفية علاجها',
      'category': 'الأمراض',
      'doctor': 'د. أحمد المولد',
      'duration': '11:30',
      'views': '9.8K',
      'thumbnail': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      'likes': 654,
      'isLiked': false,
      'description': 'تعرف على أعراض نقص الفيتامينات الشائعة وطرق علاجها الفعالة.',
    },
    {
      'id': '8',
      'title': 'كيف تحسن جودة نومك',
      'category': 'الصحة النفسية',
      'doctor': 'د. رنا النجار',
      'duration': '7:40',
      'views': '14.7K',
      'thumbnail': 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=400',
      'likes': 1345,
      'isLiked': false,
      'description': 'نصائح عملية لتحسين جودة النوم والتغلب على مشاكل الأرق واضطرابات النوم.',
    },
    {
      'id': '9',
      'title': 'التغذية السليمة للأطفال',
      'category': 'التغذية',
      'doctor': 'د. فاطمة صديقي',
      'duration': '13:20',
      'views': '20.1K',
      'thumbnail': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=400',
      'likes': 1987,
      'isLiked': false,
      'description': 'دليل شامل لتغذية الأطفال في مختلف المراحل العمرية لضمان نمو صحي وسليم.',
    },
    {
      'id': '10',
      'title': 'كيف تتعامل مع ارتفاع ضغط الدم',
      'category': 'الأمراض',
      'doctor': 'د. خالد النخلاني',
      'duration': '9:15',
      'views': '7.3K',
      'thumbnail': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'likes': 543,
      'isLiked': false,
      'description': 'تعرف على طرق التعامل مع ارتفاع ضغط الدم والوقاية من مضاعفاته.',
    },
    {
      'id': '11',
      'title': 'فوائد المشي اليومي للصحة',
      'category': 'الرياضة',
      'doctor': 'د. حسن رضا',
      'duration': '5:50',
      'views': '25.8K',
      'thumbnail': 'https://images.unsplash.com/photo-1449300079326-7b6bc2d1d28?w=400',
      'likes': 3456,
      'isLiked': false,
      'description': 'اكتشف فوائد المشي اليومية للصحة البدنية والنفسية وكيفية جعله جزءاً من روتينك.',
    },
    {
      'id': '12',
      'title': 'كيف تحافظ على صحة عظامك',
      'category': 'الوقاية',
      'doctor': 'د. حسن رضا',
      'duration': '8:30',
      'views': '11.2K',
      'thumbnail': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400',
      'likes': 765,
      'isLiked': false,
      'description': 'نصائح للحفاظ على صحة العظام والوقاية من هشاشة العظام مع التقدم في العمر.',
    },
  ];

  List<Map<String, dynamic>> get _filteredVideos {
    if (_selectedCategory == 'الكل') return _videos;
    return _videos.where((v) => v['category'] == _selectedCategory).toList();
  }

  void _showVideoDetails(Map<String, dynamic> video) {
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
            // ✅ صورة مصغرة مع زر تشغيل
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    video['thumbnail'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.video_library_rounded, size: 60, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['duration'],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              video['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  video['doctor'],
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
                  video['category'],
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye_rounded, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      video['views'],
                      style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              video['description'],
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
                          content: Text('▶️ جاري تشغيل: ${video['title']}'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('تشغيل الفيديو'),
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
                      video['isLiked'] = !video['isLiked'];
                      video['likes'] += video['isLiked'] ? 1 : -1;
                    });
                  },
                  icon: Icon(
                    video['isLiked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: video['isLiked'] ? AppColors.error : AppColors.grey,
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
    final filtered = _filteredVideos;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('التثقيف الصحي', style: TextStyle(fontWeight: FontWeight.bold)),
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
          // ✅ قائمة الفيديوهات
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final video = filtered[index];
                      return _buildVideoCard(video, isDark);
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
              Icons.video_library_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد فيديوهات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم إضافة فيديوهات جديدة قريباً',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, bool isDark) {
    return GestureDetector(
      onTap: () => _showVideoDetails(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
            // ✅ صورة مصغرة
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    video['thumbnail'],
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 70,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.video_library_rounded, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['duration'],
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // ✅ معلومات الفيديو
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video['doctor'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          video['category'],
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        video['views'],
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            video['isLiked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: video['isLiked'] ? AppColors.error : AppColors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            video['likes'].toString(),
                            style: TextStyle(
                              fontSize: 9,
                              color: video['isLiked'] ? AppColors.error : AppColors.grey,
                            ),
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
