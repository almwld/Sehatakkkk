import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'موعد جديد',
      'body': 'تم تأكيد موعدك مع د. أحمد المولد يوم الأحد 10:00 ص',
      'time': 'منذ 5 دقائق',
      'read': false,
      'icon': Icons.calendar_today,
      'color': Colors.blue,
    },
    {
      'title': 'نتيجة تحليل',
      'body': 'نتيجة تحليل الدم جاهزة، يمكنك الاطلاع عليها الآن',
      'time': 'منذ ساعة',
      'read': false,
      'icon': Icons.science,
      'color': Colors.green,
    },
    {
      'title': 'تذكير دواء',
      'body': 'حان وقت تناول دواء باراسيتامول 500mg',
      'time': 'منذ ساعتين',
      'read': true,
      'icon': Icons.medication,
      'color': Colors.orange,
    },
    {
      'title': 'عرض خاص',
      'body': 'خصم 20% على جميع منتجات الصيدلية حتى نهاية الشهر',
      'time': 'منذ يوم',
      'read': true,
      'icon': Icons.local_offer,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              // تحديد الكل كمقروء
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستظهر الإشعارات هنا عند استلامها',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final isRead = notification['read'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isRead ? const Color(0xFF1A2540) : const Color(0xFF1A2540).withOpacity(0.8))
                        : (isRead ? Colors.white : Colors.white.withOpacity(0.8)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRead
                          ? (isDark ? Colors.grey[800]! : Colors.grey[200]!)
                          : AppColors.primary.withOpacity(0.3),
                      width: isRead ? 1 : 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (notification['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          notification['icon'] as IconData,
                          color: notification['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['title'] as String,
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              notification['body'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              notification['time'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
