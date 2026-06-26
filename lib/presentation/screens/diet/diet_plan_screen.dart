import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  int _currentDay = 0;
  final List<String> _days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

  final List<Map<String, dynamic>> _meals = [
    {'time': 'الفطور', 'food': 'شوفان مع فواكه', 'calories': 350, 'icon': Icons.breakfast_dining, 'color': AppColors.warning},
    {'time': 'وجبة خفيفة', 'food': 'تفاح + مكسرات', 'calories': 150, 'icon': Icons.apple, 'color': AppColors.success},
    {'time': 'الغداء', 'food': 'دجاج مشوي + أرز + خضار', 'calories': 550, 'icon': Icons.lunch_dining, 'color': AppColors.primary},
    {'time': 'وجبة خفيفة', 'food': 'زبادي + فواكه', 'calories': 120, 'icon': Icons.icecream, 'color': AppColors.info},
    {'time': 'العشاء', 'food': 'سمك مشوي + سلطة', 'calories': 400, 'icon': Icons.dinner_dining, 'color': AppColors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النظام الغذائي', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة تقويم النظام الغذائي قريباً'), backgroundColor: AppColors.info),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ أيام الأسبوع
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, index) {
                final selected = _currentDay == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentDay = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _days[index],
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.darkGrey,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // ✅ إحصائيات اليوم
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('1,570', 'سعرة حرارية'),
                _statItem('120g', 'بروتين'),
                _statItem('200g', 'كربوهيدرات'),
                _statItem('50g', 'دهون'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('وجبات اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                final meal = _meals[index];
                return _buildMealCard(meal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final color = meal['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meal['icon'], color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['time'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(meal['food'], style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${meal['calories']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              const Text('سعرة', style: TextStyle(fontSize: 9, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
