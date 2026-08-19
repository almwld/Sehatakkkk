import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChatStatsScreen extends StatelessWidget {
  final String chatId;
  final String userName;

  const ChatStatsScreen({
    super.key,
    required this.chatId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('إحصائيات $userName'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ إحصائيات سريعة
            _buildStatsCard(isDark),
            const SizedBox(height: 16),

            // ✅ نشاط الرسائل
            _buildActivityChart(isDark),
            const SizedBox(height: 16),

            // ✅ الأوقات النشطة
            _buildActiveTimes(isDark),
            const SizedBox(height: 16),

            // ✅ الكلمات الأكثر استخداماً
            _buildTopWords(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('📨', 'رسائل', '1,234'),
          _statItem('📞', 'مكالمات', '23'),
          _statItem('📎', 'ملفات', '45'),
          _statItem('⏱️', 'مدة المكالمات', '2.5 س'),
        ],
      ),
    );
  }

  Widget _statItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChart(bool isDark) {
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
          const Text(
            'نشاط الرسائل (الأيام الأخيرة)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBar('أحد', 20),
                _buildBar('إثن', 35),
                _buildBar('ثلث', 45),
                _buildBar('أرب', 30),
                _buildBar('خمي', 55),
                _buildBar('جم', 40),
                _buildBar('سبت', 25),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActiveTimes(bool isDark) {
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
          const Text(
            'الأوقات النشطة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _timeChip('الصباح', '8-12', 40),
              _timeChip('الظهر', '12-4', 60),
              _timeChip('المساء', '4-8', 80),
              _timeChip('الليل', '8-12', 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String label, String time, int percentage) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(percentage / 100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWords(bool isDark) {
    final words = ['مرحباً', 'شكراً', 'موعد', 'استشارة', 'طبيب', 'دواء', 'صحة', 'فحص'];

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
          const Text(
            'الكلمات الأكثر استخداماً',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
