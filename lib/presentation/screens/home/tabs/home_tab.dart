// ============================================================
// 🏠 HomeTab - التبويب الرئيسي مع سكرول
// ============================================================

import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final ScrollController scrollController;

  const HomeTab({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    child: Text(
                      'د',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د. أحمد محمد',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'طبيب عام • منذ ساعتين',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'نصيحة طبية اليوم: شرب الماء بانتظام يحسن صحة الكلى ويقي من الجفاف. احرص على شرب 8 أكواب يومياً.',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActionButton(Icons.favorite_border, '24', isDark),
                  const SizedBox(width: 16),
                  _buildActionButton(Icons.chat_bubble_outline, '12', isDark),
                  const SizedBox(width: 16),
                  _buildActionButton(Icons.share_outlined, '8', isDark),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String count, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
