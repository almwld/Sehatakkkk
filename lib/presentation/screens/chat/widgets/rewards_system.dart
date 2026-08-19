import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class RewardsSystem extends StatefulWidget {
  final int points;
  final List<Map<String, dynamic>> achievements;

  const RewardsSystem({
    super.key,
    required this.points,
    this.achievements = const [],
  });

  @override
  State<RewardsSystem> createState() => _RewardsSystemState();
}

class _RewardsSystemState extends State<RewardsSystem> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
          // ✅ النقاط
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'نقاطي:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.points}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const Spacer(),
              Text(
                'مستوى ${(widget.points / 100).floor() + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ شريط التقدم
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: (widget.points % 100) / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ الإنجازات
          const Text(
            'الإنجازات',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getAchievements().map((achievement) {
              final isUnlocked = _isAchievementUnlocked(achievement);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlocked ? Icons.emoji_events : Icons.lock,
                      color: isUnlocked ? Colors.green : Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      achievement['name'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isUnlocked ? Colors.green : Colors.grey,
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 12,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements() {
    return [
      {'name': 'أول رسالة', 'points': 10},
      {'name': '10 رسائل', 'points': 20},
      {'name': 'أول مكالمة', 'points': 30},
      {'name': '50 رسالة', 'points': 50},
      {'name': 'أول موعد', 'points': 40},
      {'name': '100 رسالة', 'points': 100},
      {'name': 'أول استشارة', 'points': 60},
      {'name': 'خبير الدردشة', 'points': 200},
    ];
  }

  bool _isAchievementUnlocked(Map<String, dynamic> achievement) {
    return widget.points >= (achievement['points'] as int);
  }
}
