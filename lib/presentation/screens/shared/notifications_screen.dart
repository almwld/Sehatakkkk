import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/sound_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    // ✅ محاكاة جلب الإشعارات من Firebase
    await Future.delayed(const Duration(seconds: 1));
    
    // ✅ بيانات تجريبية (ستأتي من Firebase لاحقاً)
    _notifications.addAll([
      {
        'id': '1',
        'title': 'موعد جديد',
        'body': 'تم تأكيد موعدك مع د. أحمد المولد غداً الساعة 10 صباحاً',
        'time': 'منذ 5 دقائق',
        'read': false,
        'icon': Icons.calendar_today_rounded,
        'color': AppColors.primary,
      },
      {
        'id': '2',
        'title': 'تذكير دواء',
        'body': 'حان موعد تناول دواء باراسيتامول 500mg',
        'time': 'منذ 30 دقيقة',
        'read': false,
        'icon': Icons.medication_rounded,
        'color': AppColors.warning,
      },
      {
        'id': '3',
        'title': 'نتيجة تحليل',
        'body': 'نتيجة تحليل الدم جاهزة للمراجعة',
        'time': 'منذ ساعتين',
        'read': true,
        'icon': Icons.science_rounded,
        'color': AppColors.purple,
      },
      {
        'id': '4',
        'title': 'رسالة جديدة',
        'body': 'د. فاطمة صديقي أرسلت لك رسالة جديدة',
        'time': 'منذ 3 ساعات',
        'read': true,
        'icon': Icons.chat_rounded,
        'color': AppColors.info,
      },
      {
        'id': '5',
        'title': 'عرض خاص',
        'body': 'خصم 30% على جميع الأدوية في صيدلية النهدي',
        'time': 'منذ يوم',
        'read': true,
        'icon': Icons.local_offer_rounded,
        'color': AppColors.success,
      },
      {
        'id': '6',
        'title': 'تحديث التطبيق',
        'body': 'تحديث جديد للإصدار 1.1.0 متوفر الآن',
        'time': 'منذ يومين',
        'read': true,
        'icon': Icons.system_update_rounded,
        'color': AppColors.orange,
      },
    ]);

    // ✅ تشغيل نغمة الإشعار
    SoundManager().playNotification();

    setState(() => _isLoading = false);
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديد جميع الإشعارات كمقروءة'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _deleteNotification(String id) async {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف الإشعار'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              onPressed: _markAllAsRead,
              tooltip: 'تحديد الكل كمقروء',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(
                      context,
                      notification,
                      isDark,
                      index,
                    );
                  },
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
              Icons.notifications_off_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ستظهر هنا الإشعارات الجديدة',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    Map<String, dynamic> notification,
    bool isDark,
    int index,
  ) {
    final isRead = notification['read'] as bool;
    final color = notification['color'] as Color;
    final icon = notification['icon'] as IconData;

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification['id']),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? (isRead ? const Color(0xFF1A2540) : const Color(0xFF2D3A54))
                : (isRead ? Colors.white : AppColors.primary.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(16),
            border: isRead
                ? null
                : Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ أيقونة الإشعار
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // ✅ محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
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
                    const SizedBox(height: 4),
                    Text(
                      notification['body'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification['time'],
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
