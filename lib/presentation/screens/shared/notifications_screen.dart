import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/sound_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'غير مقروءة', 'مقروءة'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final notifications = List<Map<String, dynamic>>.from(data['notifications'] ?? []);
          setState(() => _notifications = notifications);
        } else {
          // ✅ بيانات وهمية للاختبار
          _loadMockNotifications();
        }
      } catch (e) {
        print('❌ Error loading notifications: $e');
        _loadMockNotifications();
      }
    } else {
      _loadMockNotifications();
    }

    setState(() => _isLoading = false);

    // ✅ تشغيل نغمة الإشعار
    SoundManager().playNotification();
  }

  void _loadMockNotifications() {
    _notifications = [
      {
        'id': '1',
        'title': 'موعد جديد',
        'body': 'تم تأكيد موعدك مع د. أحمد المولد غداً الساعة 10 صباحاً',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'read': false,
        'icon': Icons.calendar_today_rounded,
        'color': AppColors.primary,
        'type': 'appointment',
      },
      {
        'id': '2',
        'title': 'تذكير دواء',
        'body': 'حان موعد تناول دواء باراسيتامول 500mg',
        'time': DateTime.now().subtract(const Duration(minutes: 30)),
        'read': false,
        'icon': Icons.medication_rounded,
        'color': AppColors.warning,
        'type': 'medication',
      },
      {
        'id': '3',
        'title': 'نتيجة تحليل',
        'body': 'نتيجة تحليل الدم الشامل جاهزة للمراجعة',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'read': true,
        'icon': Icons.science_rounded,
        'color': AppColors.purple,
        'type': 'lab',
      },
      {
        'id': '4',
        'title': 'رسالة جديدة',
        'body': 'د. فاطمة صديقي أرسلت لك رسالة جديدة',
        'time': DateTime.now().subtract(const Duration(hours: 3)),
        'read': true,
        'icon': Icons.chat_rounded,
        'color': AppColors.info,
        'type': 'message',
      },
      {
        'id': '5',
        'title': 'عرض خاص',
        'body': 'خصم 30% على جميع الأدوية في صيدلية النهدي',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'read': true,
        'icon': Icons.local_offer_rounded,
        'color': AppColors.success,
        'type': 'offer',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'الكل') return _notifications;
    if (_selectedFilter == 'غير مقروءة') {
      return _notifications.where((n) => !n['read']).toList();
    }
    return _notifications.where((n) => n['read']).toList();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${time.day}/${time.month}/${time.year}';
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'notifications': _notifications,
        }, SetOptions(merge: true));
      } catch (e) {
        print('❌ Error saving notification: $e');
      }
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'notifications': _notifications,
        }, SetOptions(merge: true));
      } catch (e) {
        print('❌ Error saving notifications: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم تحديد جميع الإشعارات كمقروءة'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _deleteNotification(String id) async {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'notifications': _notifications,
        }, SetOptions(merge: true));
      } catch (e) {
        print('❌ Error deleting notification: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredNotifications;
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
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
          : Column(
              children: [
                // ✅ فلترة الإشعارات
                _buildFilterTabs(),
                // ✅ قائمة الإشعارات
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final notification = filtered[index];
                            return _buildNotificationItem(
                              context,
                              notification,
                              isDark,
                            );
                          },
                        ),
                ),
              ],
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
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
  ) {
    final isRead = notification['read'] as bool;
    final color = notification['color'] as Color;
    final icon = notification['icon'] as IconData;
    final time = notification['time'] is DateTime
        ? notification['time'] as DateTime
        : DateTime.now();

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
          if (!isRead) {
            _markAsRead(notification['id']);
          }
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
                          _formatTime(time),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification['type'] ?? 'عام',
                            style: TextStyle(
                              fontSize: 8,
                              color: color,
                            ),
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
