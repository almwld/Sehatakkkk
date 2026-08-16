import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HealthCommunityScreen extends StatefulWidget {
  const HealthCommunityScreen({super.key});

  @override
  State<HealthCommunityScreen> createState() => _HealthCommunityScreenState();
}

class _HealthCommunityScreenState extends State<HealthCommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user': 'د. أحمد المولد',
      'role': 'طبيب',
      'avatar': 'https://ui-avatars.com/api/?name=أحمد+المولد&background=00796B&color=fff',
      'time': 'منذ 10 دقائق',
      'content': 'نصيحة اليوم: الإكثار من شرب الماء في فصل الصيف يحمي من الجفاف ويحسن صحة الكلى 🌿💧',
      'likes': 256,
      'comments': 48,
      'shares': 32,
      'liked': false,
      'type': 'نصيحة',
    },
    {
      'id': '2',
      'user': 'د. فاطمة صديقي',
      'role': 'طبيبة',
      'avatar': 'https://ui-avatars.com/api/?name=فاطمة+صديقي&background=00796B&color=fff',
      'time': 'منذ 25 دقيقة',
      'content': 'التغذية السليمة هي أساس الصحة الجيدة. تناولوا الخضروات والفواكه يومياً 🥗🍎',
      'likes': 189,
      'comments': 34,
      'shares': 28,
      'liked': false,
      'type': 'نصيحة',
    },
    {
      'id': '3',
      'user': 'د. خالد النخلاني',
      'role': 'طبيب',
      'avatar': 'https://ui-avatars.com/api/?name=خالد+النخلاني&background=00796B&color=fff',
      'time': 'منذ ساعة',
      'content': 'مرضى الضغط يجب عليهم متابعة قراءاتهم بانتظام وتجنب الأطعمة المالحة 🩺❤️',
      'likes': 312,
      'comments': 56,
      'shares': 45,
      'liked': false,
      'type': 'استشارة',
    },
    {
      'id': '4',
      'user': 'أم محمد',
      'role': 'مستخدمة',
      'avatar': 'https://ui-avatars.com/api/?name=أم+محمد&background=00796B&color=fff',
      'time': 'منذ ساعتين',
      'content': 'الحمد لله ابني تعافى بعد استشارة الدكتور حسن. شكراً منصة صحتك 🙏❤️',
      'likes': 278,
      'comments': 67,
      'shares': 34,
      'liked': false,
      'type': 'تجربة',
    },
    {
      'id': '5',
      'user': 'صيدلية الشفاء',
      'role': 'شريك معتمد',
      'avatar': 'https://ui-avatars.com/api/?name=صيدلية+الشفاء&background=00796B&color=fff',
      'time': 'منذ 3 ساعات',
      'content': 'وصلتنا شحنة جديدة من الأدوية المستوردة. خصم 20% على جميع الأدوية لمدة أسبوع 💊✨',
      'likes': 432,
      'comments': 87,
      'shares': 64,
      'liked': false,
      'type': 'عرض',
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.medical_services_rounded, 'label': 'استشارات', 'color': AppColors.primary},
    {'icon': Icons.tips_and_updates_rounded, 'label': 'نصائح', 'color': AppColors.success},
    {'icon': Icons.local_offer_rounded, 'label': 'عروض', 'color': AppColors.warning},
    {'icon': Icons.science_rounded, 'label': 'تحاليل', 'color': AppColors.purple},
    {'icon': Icons.chat_rounded, 'label': 'نقاشات', 'color': AppColors.info},
    {'icon': Icons.emoji_events_rounded, 'label': 'تحديات', 'color': AppColors.amber},
  ];

  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike(int index) {
    setState(() {
      _posts[index]['liked'] = !_posts[index]['liked'];
      _posts[index]['likes'] += _posts[index]['liked'] ? 1 : -1;
    });
  }

  void _showAddPostDialog() {
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
            const Text(
              'إنشاء منشور جديد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _postController,
              maxLines: 4,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'ماذا تريد مشاركته مع المجتمع؟',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _categoryChip(Icons.image_rounded, 'صورة'),
                _categoryChip(Icons.medical_services_rounded, 'استشارة'),
                _categoryChip(Icons.tips_and_updates_rounded, 'نصيحة'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم نشر المنشور بنجاح'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('نشر'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'نصيحة':
        return AppColors.success;
      case 'استشارة':
        return AppColors.primary;
      case 'تجربة':
        return AppColors.info;
      case 'عرض':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('مجتمع صحتك'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddPostDialog,
            tooltip: 'إنشاء منشور',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategories(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsList(isDark),
                _buildQuestionsTab(isDark),
                _buildDoctorsTab(isDark),
              ],
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
          children: _categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final color = category['color'] as Color;
            final isSelected = _selectedCategory == index;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected ? Colors.white : color,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey,
        tabs: const [
          Tab(text: 'الرئيسية'),
          Tab(text: 'الأسئلة'),
          Tab(text: 'الأطباء'),
        ],
      ),
    );
  }

  Widget _buildPostsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return _buildPostCard(post, isDark, index);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, bool isDark, int index) {
    final color = _getStatusColor(post['type']);
    final roleColor = post['role'] == 'طبيب' || post['role'] == 'طبيبة'
        ? AppColors.primary
        : AppColors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF2D3A54) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: NetworkImage(post['avatar']),
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post['user'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post['role'],
                            style: TextStyle(
                              fontSize: 8,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      post['time'],
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  post['type'],
                  style: TextStyle(
                    fontSize: 8,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post['content'],
            style: const TextStyle(fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(index),
                child: Row(
                  children: [
                    Icon(
                      post['liked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: post['liked'] ? AppColors.error : AppColors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: post['liked'] ? AppColors.error : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${post['comments']}',
                    style: TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ تم المشاركة'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.share_rounded, size: 16, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${post['shares']}',
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab(bool isDark) {
    final questions = _posts.where((p) => p['type'] == 'استشارة').toList();
    return _buildTabContent(questions, isDark);
  }

  Widget _buildDoctorsTab(bool isDark) {
    final doctors = _posts.where((p) => p['role'] == 'طبيب' || p['role'] == 'طبيبة').toList();
    return _buildTabContent(doctors, isDark);
  }

  Widget _buildTabContent(List<Map<String, dynamic>> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 60, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد منشورات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final post = items[index];
        final actualIndex = _posts.indexOf(post);
        return _buildPostCard(post, isDark, actualIndex);
      },
    );
  }
}
