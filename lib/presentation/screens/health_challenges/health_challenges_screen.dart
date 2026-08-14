import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HealthChallengesScreen extends StatefulWidget {
  const HealthChallengesScreen({super.key});

  @override
  State<HealthChallengesScreen> createState() => _HealthChallengesScreenState();
}

class _HealthChallengesScreenState extends State<HealthChallengesScreen> {
  String _selectedFilter = 'جميع';
  final List<String> _filters = ['جميع', 'نشطة', 'مكتملة', 'قادمة'];

  final List<Map<String, dynamic>> _challenges = [
    {
      'id': '1',
      'title': 'تحدي المشي 10,000 خطوة',
      'description': 'امشِ 10,000 خطوة يومياً لمدة 7 أيام متواصلة',
      'icon': Icons.directions_walk_rounded,
      'color': AppColors.success,
      'status': 'نشطة',
      'progress': 0.6,
      'reward': '🌟 100 نقطة',
      'participants': 1240,
      'daysLeft': 3,
      'steps': 6000,
      'targetSteps': 10000,
    },
    {
      'id': '2',
      'title': '30 يوم بدون سكر',
      'description': 'تجنب السكر المضاف لمدة 30 يوماً',
      'icon': Icons.emoji_events_rounded,
      'color': AppColors.warning,
      'status': 'نشطة',
      'progress': 0.3,
      'reward': '🏆 200 نقطة',
      'participants': 856,
      'daysLeft': 21,
      'sugarFree': 9,
      'targetDays': 30,
    },
    {
      'id': '3',
      'title': 'تحدي شرب الماء',
      'description': 'اشرب 8 أكواب من الماء يومياً لمدة 30 يوماً',
      'icon': Icons.water_drop_rounded,
      'color': AppColors.info,
      'status': 'نشطة',
      'progress': 0.45,
      'reward': '💧 150 نقطة',
      'participants': 2100,
      'daysLeft': 16,
      'glasses': 4,
      'targetGlasses': 8,
    },
    {
      'id': '4',
      'title': 'تحدي النوم الصحي',
      'description': 'احصل على 7-8 ساعات نوم يومياً لمدة 14 يوماً',
      'icon': Icons.bedtime_rounded,
      'color': AppColors.purple,
      'status': 'قادمة',
      'progress': 0.0,
      'reward': '🌙 120 نقطة',
      'participants': 567,
      'daysLeft': 0,
      'hoursSleep': 0,
      'targetHours': 8,
    },
    {
      'id': '5',
      'title': 'تحدي قراءة 5 كتب طبية',
      'description': 'اقرأ 5 كتب طبية أو مقالات صحية',
      'icon': Icons.menu_book_rounded,
      'color': AppColors.orange,
      'status': 'مكتملة',
      'progress': 1.0,
      'reward': '📚 300 نقطة',
      'participants': 432,
      'daysLeft': 0,
      'booksRead': 5,
      'targetBooks': 5,
    },
  ];

  List<Map<String, dynamic>> get _filteredChallenges {
    if (_selectedFilter == 'جميع') return _challenges;
    return _challenges.where((c) => c['status'] == _selectedFilter).toList();
  }

  void _showChallengeDetails(Map<String, dynamic> challenge) {
    final color = challenge['color'] as Color;
    final isCompleted = challenge['status'] == 'مكتملة';

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
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(challenge['icon'] as IconData, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        challenge['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(challenge['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    challenge['reward'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              challenge['description'],
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            // ✅ التقدم
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('التقدم', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: challenge['progress'],
                              backgroundColor: color.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(challenge['progress'] * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statItem('👥', '${challenge['participants']}', 'مشارك'),
                _statItem('📅', '${challenge['daysLeft']}', 'يوم متبقي'),
                if (challenge['status'] != 'مكتملة') ...[
                  _statItem('🏆', challenge['reward'], 'المكافأة'),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (!isCompleted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ انضممت إلى تحدي ${challenge['title']}'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('انضم إلى التحدي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.emoji_events_rounded),
                  label: const Text('تهانينا! 🎉'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
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

  Widget _statItem(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'نشطة':
        return AppColors.success;
      case 'قادمة':
        return AppColors.info;
      case 'مكتملة':
        return AppColors.amber;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredChallenges;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: const Text('التحديات الصحية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ إحصائيات سريعة
          _buildStats(),
          // ✅ فلترة التحديات
          _buildFilterTabs(),
          // ✅ قائمة التحديات
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final challenge = filtered[index];
                      return _buildChallengeCard(challenge, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final active = _challenges.where((c) => c['status'] == 'نشطة').length;
    final completed = _challenges.where((c) => c['status'] == 'مكتملة').length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBadge(Icons.play_arrow_rounded, '$active', 'نشطة', AppColors.success),
          _statBadge(Icons.check_circle_rounded, '$completed', 'مكتملة', AppColors.amber),
          _statBadge(Icons.star_rounded, '${_challenges.length}', 'إجمالي', AppColors.primary),
        ],
      ),
    );
  }

  Widget _statBadge(IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          ' $label',
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.grey,
                    ),
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
              Icons.emoji_events_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد تحديات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ترقب التحديات الجديدة قريباً',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge, bool isDark) {
    final color = challenge['color'] as Color;
    final isCompleted = challenge['status'] == 'مكتملة';
    final progress = challenge['progress'] as double;

    return GestureDetector(
      onTap: () => _showChallengeDetails(challenge),
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
            color: isCompleted
                ? AppColors.amber.withOpacity(0.3)
                : isDark
                    ? const Color(0xFF2D3A54)
                    : Colors.transparent,
            width: isCompleted ? 1.5 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    challenge['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        challenge['description'],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    challenge['status'],
                    style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people_rounded, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(
                  '${challenge['participants']} مشارك',
                  style: TextStyle(fontSize: 10, color: AppColors.grey),
                ),
                const Spacer(),
                Icon(Icons.emoji_events_rounded, size: 14, color: AppColors.amber),
                const SizedBox(width: 4),
                Text(
                  challenge['reward'],
                  style: TextStyle(fontSize: 10, color: AppColors.amber),
                ),
                if (challenge['daysLeft'] > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.access_time_rounded, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge['daysLeft']} يوم',
                    style: TextStyle(fontSize: 10, color: AppColors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
